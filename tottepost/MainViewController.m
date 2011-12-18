//
//  MainViewController.m
//  tottepost mainview controller
//
//  Created by Ken Watanabe on 11/12/10.
//  Copyright (c) 2011 cocotomo. All rights reserved.
//

#import "MainViewController.h"
#import "MainView.h"

//-----------------------------------------------------------------------------
//Private Implementations
//-----------------------------------------------------------------------------
@interface MainViewController(PrivateImplementation)
- (void) setupInitialState: (CGRect) aFrame;
- (void) didSettingButtonTapped: (id) sender;
- (void) updateCoodinates;
@end

@implementation MainViewController(PrivateImplementation)
/*!
 * Initialize view controller
 */
- (void) setupInitialState: (CGRect) aFrame{
    NSLog(@"width = %f",aFrame.size.width);
    NSLog(@"height = %f",aFrame.size.height);
    aFrame.origin.y = 20;
    self.view = [[MainView alloc] initWithFrame:aFrame];
    
    // iPad か iPhone/iPod touch かの判定
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        // iPad 時の処理
    }else{
        // iPhone/iPod touch の処理
    }
    
    settingViewController_ = 
        [[SettingTableViewController alloc] init];
    settingNavigationController_ = [[UINavigationController alloc] initWithRootViewController:settingViewController_];
    settingNavigationController_.modalPresentationStyle = UIModalPresentationFormSheet;
    settingNavigationController_.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    
    progressTableViewController_ = [[ProgressTableViewController alloc] initWithFrame:CGRectZero];
    
    [[PhotoSubmitterManager getInstance] setPhotoDelegate:self];
    [self updateCoodinates];
}

/*!
 * on setting button tapped, open setting view
 */
- (void) didSettingButtonTapped:(id)sender{
    [self presentModalViewController:settingNavigationController_ animated:YES];
}

/*!
 * update control coodinates
 */
- (void)updateCoodinates{
    CGRect frame = self.view.frame;
    [progressTableViewController_ updateWithFrame:CGRectMake(frame.size.width - 80, 40, 80, frame.size.height - 80)];
}
@end

//-----------------------------------------------------------------------------
//Public Implementations
//-----------------------------------------------------------------------------
@implementation MainViewController
- (id)initWithFrame:(CGRect)frame
{
    self = [super init];
    if(self){
        [self setupInitialState:frame];
    }
    bool isCameraSupported = [UIImagePickerController isSourceTypeAvailable:
                              UIImagePickerControllerSourceTypeCamera];        
    if (isCameraSupported == false) {
        // TODO: カメラがサポートしてないときの処理
        NSLog(@"カメラがサポートされていません。");
    }
    return self;
}

// モーダルビューとしてカメラ画面を呼び出す
- (void) createCameraController
{
    imagePickerOverlayView_ = [[UIView alloc] initWithFrame:self.view.frame];
    imagePicker_ = [[UIImagePickerController alloc] init];
    imagePicker_.delegate = self;
    imagePicker_.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePicker_.cameraOverlayView = imagePickerOverlayView_;
    imagePicker_.showsCameraControls = NO;
    
    settingButton_ = [UIButton buttonWithType:UIButtonTypeCustom];
    [settingButton_ addTarget:self action:@selector(didSettingButtonTapped:) 
             forControlEvents:UIControlEventTouchUpInside];
    [settingButton_ setImage:[UIImage imageNamed:@"setting.png"] 
                    forState: UIControlStateNormal];
    [settingButton_ setFrame:CGRectMake(10, 10, 32, 32)];
    [imagePicker_.view addSubview:settingButton_];
    
    //ツールバー追加
    CGRect toolbarRect = CGRectMake(0, self.view.frame.size.height - 55, self.view.frame.size.width, 55);
    UIToolbar* toolbar = [[UIToolbar alloc] initWithFrame:toolbarRect];
    toolbar.barStyle = UIBarStyleBlack;
    [imagePicker_.view addSubview:toolbar];
    [imagePicker_.view addSubview:progressTableViewController_.view];
    
    // カメラボタン
    cameraButton_ =
    [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCamera
                                                 target:self
                                                 action:@selector(clickPhoto:)];
    cameraButton_.style = UIBarButtonItemStyleBordered;
    
    
    //カメラボタンを真ん中に寄せるためのスペース
    UIBarButtonItem* fixedSpace = [[UIBarButtonItem alloc]
                                   initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                   target:nil
                                   action:nil];
    fixedSpace.width = self.view.frame.size.width/2 - 30;
    
    [toolbar setItems:[NSArray arrayWithObjects:fixedSpace, cameraButton_, nil]];
    
    [self.view addSubview:imagePicker_.view];
    //イメージピッカーを前面に表示
    //[self presentModalViewController:imagePicker_ animated:YES];    
}

//撮影ボタンを押したときに呼ばれるメソッド
- (void)clickPhoto:(UIBarButtonItem*)sender
{
    [imagePicker_ takePicture];
}

//画像が選択された時に呼ばれるデリゲートメソッド
-(void)imagePickerController:(UIImagePickerController*)picker didFinishPickingImage:(UIImage*)image editingInfo:(NSDictionary*)editingInfo{
    [[PhotoSubmitterManager getInstance] submitPhoto:image];
}


//画像の保存完了時に呼ばれるメソッド
-(void)targetImage:(UIImage*)image
didFinishSavingWithError:(NSError*)error contextInfo:(void*)context{
    
    if(error){
        // 保存失敗時
    }else{
    }
}

/*! 
 * take photo
 */
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    UIImage *image = (UIImage*)[info objectForKey:UIImagePickerControllerOriginalImage];
    [[PhotoSubmitterManager getInstance] submitPhoto:image];
}

/*!
 * photo upload start
 */
- (void)photoSubmitter:(id<PhotoSubmitterProtocol>)photoSubmitter willStartUpload:(NSString *)imageHash{
    NSLog(@"%@ upload started", imageHash);
    [progressTableViewController_ addProgressWithType:photoSubmitter.type forHash:imageHash];
}

/*!
 * photo submitted
 */
- (void)photoSubmitter:(id<PhotoSubmitterProtocol>)photoSubmitter didSubmitted:(NSString *)imageHash suceeded:(BOOL)suceeded message:(NSString *)message{
    NSLog(@"%@ submitted.", imageHash);
    [progressTableViewController_ removeProgressWithType:photoSubmitter.type forHash:imageHash];
}

/*!
 * photo upload progress changed
 */
- (void)photoSubmitter:(id<PhotoSubmitterProtocol>)photoSubmitter didProgressChanged:(NSString *)imageHash progress:(CGFloat)progress{
    NSLog(@"%@, %f", imageHash, progress);
    [progressTableViewController_ updateProgressWithType:photoSubmitter.type forHash:imageHash progress:progress];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    //回転検知関係の初期化
    device_ = [UIDevice currentDevice];
    [device_ beginGeneratingDeviceOrientationNotifications];
    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(deviceRotate) name:UIDeviceOrientationDidChangeNotification object:nil];
}

//デバイスが動いたときに呼ばれる
-(void) deviceRotate
{
    NSLog(@"DEBUG");
    if(device_.orientation == UIDeviceOrientationPortrait ||
       device_.orientation == UIDeviceOrientationPortraitUpsideDown) //縦向きの場合
    {
        row = 0;
        //NSLog(@"ImageTab deviceRotate portrait");
    }
    else if(device_.orientation == UIDeviceOrientationLandscapeLeft ||
            device_.orientation == UIDeviceOrientationLandscapeRight) //横向きの場合
    {
        row = 1;
        //NSLog(@"ImageTab deviceRotate landscape");
    }
    
    if(row == prevRow)
    {
        return;
    }
    [self updateCoodinates];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return YES;
}

- (void)viewDidShow:(UIView *)view{
}
@end
