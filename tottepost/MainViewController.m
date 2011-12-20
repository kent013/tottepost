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
- (void) updateCoordinates;
- (BOOL) checkForConnection;
@end

@implementation MainViewController(PrivateImplementation)
/*!
 * Initialize view controller
 */
- (void) setupInitialState: (CGRect) aFrame{
    aFrame.origin.y = 0;
    self.view.frame = aFrame;
    [UIApplication sharedApplication].statusBarHidden = YES;
    
    //setting view
    settingViewController_ = 
        [[SettingTableViewController alloc] init];
    settingNavigationController_ = [[UINavigationController alloc] initWithRootViewController:settingViewController_];
    settingNavigationController_.modalPresentationStyle = UIModalPresentationFormSheet;
    settingNavigationController_.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    settingViewController_.delegate = self;
    
    //progress view
    progressTableViewController_ = [[ProgressTableViewController alloc] initWithFrame:CGRectZero];
    
    [[PhotoSubmitterManager getInstance] setPhotoDelegate:self];
    
    //setting button
    settingButton_ = [UIButton buttonWithType:UIButtonTypeCustom];
    [settingButton_ addTarget:self action:@selector(didSettingButtonTapped:) 
             forControlEvents:UIControlEventTouchUpInside];
    [settingButton_ setImage:[UIImage imageNamed:@"setting.png"] 
                    forState: UIControlStateNormal];
    [settingButton_ setFrame:CGRectMake(10, 10, 32, 32)];
    
    //add tool bar
    toolbar_ = [[UIToolbar alloc] initWithFrame:CGRectZero];
    toolbar_.barStyle = UIBarStyleBlack;
    
    //camera button
    cameraButton_ =
    [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCamera
                                                 target:self
                                                 action:@selector(clickPhoto:)];
    cameraButton_.style = UIBarButtonItemStyleBordered;
    
    
    //spacer for centalize camera button 
    flexSpace_ = [[UIBarButtonItem alloc]
                  initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                  target:nil
                  action:nil];
    
    [toolbar_ setItems:[NSArray arrayWithObjects:flexSpace_, cameraButton_, nil]];
}

/*!
 * on setting button tapped, open setting view
 */
- (void) didSettingButtonTapped:(id)sender{
    [UIApplication sharedApplication].statusBarHidden = NO;
    [self presentModalViewController:settingNavigationController_ animated:YES];
}

/*!
 * did rotate
 */
- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    imagePicker_.showsCameraControls = YES;
    NSLog(@"did");
}

/*!
 * will rotate
 */
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    NSLog(@"will");
    imagePicker_.showsCameraControls = NO;
    if(toInterfaceOrientation == UIInterfaceOrientationPortrait ||
       toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown ||
       toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
       toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)
    {
        orientation_ = toInterfaceOrientation;
    }
    
    if(orientation_ == lastOrientation_)
    {
        return;
    }
    lastOrientation_ = orientation_;
    [self updateCoordinates];
}
/*!
 * update control coodinates
 */
- (void)updateCoordinates{ 
    CGRect frame = self.view.frame;
    CGRect screen = [UIScreen mainScreen].bounds;
    if(UIInterfaceOrientationIsLandscape(orientation_)){
        frame = CGRectMake(0, 0, screen.size.height, screen.size.width);
    }else if(UIInterfaceOrientationIsPortrait(orientation_)){
        frame = CGRectMake(0, 0, screen.size.width, screen.size.height);
    }
    //[self.view setBounds:frame];
    //self.view.frame = frame;
    self.view.frame = frame;
    NSLog(@"screen bou = %@\n", NSStringFromCGRect([UIScreen mainScreen].bounds));
    NSLog(@"     frame = %@\n", NSStringFromCGRect(frame));
    NSLog(@"    bounds = %@\n", NSStringFromCGRect(self.view.bounds));
    NSLog(@"view frame = %@\n", NSStringFromCGRect(self.view.frame));
    NSLog(@"pick frame = %@\n", NSStringFromCGRect(imagePicker_.view.frame));
    //overlayView_.frame = frame;
    
    [progressTableViewController_ updateWithFrame:CGRectMake(frame.size.width - 80, 40, 80, frame.size.height - 80)];
    [toolbar_ setFrame:CGRectMake(0, frame.size.height - 55, frame.size.width, 55)];
    flexSpace_.width = frame.size.width / 2 - 30;

    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        CGRect bframe = settingButton_.frame;
        if(UIInterfaceOrientationIsLandscape(orientation_)){
            bframe.origin.x = frame.size.width - 10 - bframe.size.width;
        }else{
            bframe.origin.x = 10;
        }
        settingButton_.frame = bframe;
    }
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
    imagePicker_.showsCameraControls = NO;
    [imagePicker_ takePicture];
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
- (void) createCameraController{
    [UIApplication sharedApplication].statusBarHidden = YES;
    imagePicker_ = [[UIImagePickerController alloc] init];
    imagePicker_.delegate = self;
    imagePicker_.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePicker_.showsCameraControls = YES;
    
    [self.view addSubview:imagePicker_.view];
    [self.view addSubview:progressTableViewController_.view];
    [self.view addSubview:settingButton_];
    [self.view addSubview:toolbar_];
    [self updateCoordinates];
}

/*! 
 * take photo
 */
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    imagePicker_.showsCameraControls = YES;
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
    [self updateCoordinates];
}

/*!
 * auto rotation
 */
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}
@end
