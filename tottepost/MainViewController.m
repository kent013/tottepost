//
//  MainViewController.m
//  tottepost mainview controller
//
//  Created by Ken Watanabe on 11/12/10.
//  Copyright (c) 2011 cocotomo. All rights reserved.
//

#import "MainViewController.h"
#import "Reachability.h"
#import "UIImage+AutoRotation.h"

//-----------------------------------------------------------------------------
//Private Implementations
//-----------------------------------------------------------------------------
@interface MainViewController(PrivateImplementation)
- (void) setupInitialState: (CGRect) aFrame;
- (void) didSettingButtonTapped: (id) sender;
- (void) updateCoodinates;
- (BOOL) checkForConnection;
- (void) showStatusBar;
@end

@implementation MainViewController(PrivateImplementation)
/*!
 * Initialize view controller
 */
- (void) setupInitialState: (CGRect) aFrame{
    aFrame.origin.y = 0;
    self.view.frame = aFrame;
    settingViewController_ = 
        [[SettingTableViewController alloc] init];
    settingNavigationController_ = [[UINavigationController alloc] initWithRootViewController:settingViewController_];
    settingNavigationController_.modalPresentationStyle = UIModalPresentationFormSheet;
    settingNavigationController_.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    settingViewController_.delegate = self;
    
    progressTableViewController_ = [[ProgressTableViewController alloc] initWithFrame:CGRectZero];
    
    [[PhotoSubmitterManager getInstance] setPhotoDelegate:self];
    [self updateCoodinates];
    
    device_ = [UIDevice currentDevice];
    [device_ beginGeneratingDeviceOrientationNotifications];
    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(deviceRotate) name:UIDeviceOrientationDidChangeNotification object:nil];
}

/*!
 * on setting button tapped, open setting view
 */
- (void) didSettingButtonTapped:(id)sender{
    [UIApplication sharedApplication].statusBarHidden = NO;
    [self presentModalViewController:settingNavigationController_ animated:YES];
}

/*!
 * update control coodinates
 */
- (void)updateCoodinates{
    CGRect frame = self.view.frame;
    [progressTableViewController_ updateWithFrame:CGRectMake(frame.size.width - 80, 40, 80, frame.size.height - 80)];
}

/*!
 * check for connection
 */
- (BOOL) checkForConnection
{
    Reachability* pathReach = [Reachability reachabilityWithHostName:@"www.facebook.com"];
    switch([pathReach currentReachabilityStatus])
    {
        case NotReachable:
            return NO;
            break;
        case ReachableViaWWAN:
        case ReachableViaWiFi:
            return YES;
            break;
    }
    return NO;
}

/*!
 * on camera button tapped
 */
- (void)clickPhoto:(UIBarButtonItem*)sender
{
    [imagePicker_ takePicture];
}

/*!
 * show status
 */
- (void)showStatusBar
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
}
@end

//-----------------------------------------------------------------------------
//Public Implementations
//-----------------------------------------------------------------------------
@implementation MainViewController
/*!
 * initializer
 */
- (id)initWithFrame:(CGRect)frame
{
    self = [super init];
    if(self){
        [self setupInitialState:frame];
    }
    bool isCameraSupported = [UIImagePickerController isSourceTypeAvailable:
                              UIImagePickerControllerSourceTypeCamera];        
    if (isCameraSupported == false) {
        NSLog(@"camera is not supported");
    }
    return self;
}

/*!
 * create camera view
 */
- (void) createCameraController
{
    CGRect f = self.view.frame;
    f.size.height += f.origin.y;
    f.origin.y = 0;
    self.view.frame = f;
    
    imagePicker_ = [[UIImagePickerController alloc] init];
    imagePicker_.delegate = self;
    imagePicker_.sourceType = UIImagePickerControllerSourceTypeCamera;
    //imagePicker_.cameraOverlayView = imagePickerOverlayView_;
    imagePicker_.showsCameraControls = NO;
    
    settingButton_ = [UIButton buttonWithType:UIButtonTypeCustom];
    [settingButton_ addTarget:self action:@selector(didSettingButtonTapped:) 
             forControlEvents:UIControlEventTouchUpInside];
    [settingButton_ setImage:[UIImage imageNamed:@"setting.png"] 
                    forState: UIControlStateNormal];
    [settingButton_ setFrame:CGRectMake(10, 10, 32, 32)];
    [imagePicker_.view addSubview:settingButton_];
    
    //add tool bar
    CGRect toolbarRect = CGRectMake(0, self.view.frame.size.height - 55, self.view.frame.size.width, 55);
    UIToolbar* toolbar = [[UIToolbar alloc] initWithFrame:toolbarRect];
    toolbar.barStyle = UIBarStyleBlack;
    [imagePicker_.view addSubview:toolbar];
    [imagePicker_.view addSubview:progressTableViewController_.view];
    
    //camera button
    cameraButton_ =
    [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCamera
                                                 target:self
                                                 action:@selector(clickPhoto:)];
    cameraButton_.style = UIBarButtonItemStyleBordered;
    
    
    //spacer for centalize camera button 
    UIBarButtonItem* fixedSpace = [[UIBarButtonItem alloc]
                                   initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                   target:nil
                                   action:nil];
    fixedSpace.width = self.view.frame.size.width/2 - 30;
    
    [toolbar setItems:[NSArray arrayWithObjects:fixedSpace, cameraButton_, nil]];
    
    [self.view addSubview:imagePicker_.view];
}

/*!
 * delegate when image picking finished
 */
-(void)imagePickerController:(UIImagePickerController*)picker didFinishPickingImage:(UIImage*)image editingInfo:(NSDictionary*)editingInfo{
    if([self checkForConnection]){
        [[PhotoSubmitterManager getInstance] submitPhoto:image];
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"There is no network connection. We will cancel upload." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

/*!
 * image picker delegate
 */
-(void)targetImage:(UIImage*)image didFinishSavingWithError:(NSError*)error contextInfo:(void*)context{
    if(error){
    }else{
    }
}

/*! 
 * take photo
 */
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    UIImage *image = (UIImage*)[info objectForKey:UIImagePickerControllerOriginalImage];
    
    if([self checkForConnection]){
        [[PhotoSubmitterManager getInstance] submitPhoto:image];
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"There is no network connection. \nWe will cancel upload." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
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

/*!
 * did dismiss setting view
 */
- (void)didDismissSettingTableViewController{
    [UIApplication sharedApplication].statusBarHidden = YES;
    CGRect f = self.view.frame;
    f.size.height += 20;
    f.origin.y = 0;
    
    imagePicker_.view.frame = f;
    self.view.frame = f;    
}

/*!
 * on device rotation
 */
-(void) deviceRotate
{
    if(device_.orientation == UIDeviceOrientationPortrait ||
       device_.orientation == UIDeviceOrientationPortraitUpsideDown)
    {
        row = 0;
        //NSLog(@"ImageTab deviceRotate portrait");
    }
    else if(device_.orientation == UIDeviceOrientationLandscapeLeft ||
            device_.orientation == UIDeviceOrientationLandscapeRight)
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

/*!
 * auto rotation
 */
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}
@end
