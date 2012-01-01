//
//  MainViewController.m
//  tottepost mainview controller
//
//  Created by Ken Watanabe on 11/12/10.
//  Copyright (c) 2011 cocotomo. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "MainViewController.h"
#import "Reachability.h"
#import "UIImage+AutoRotation.h"
#import "TottePostSettings.h"
#import "MainViewControllerConstants.h"
#import "TTLang.h"

//-----------------------------------------------------------------------------
//Private Implementations
//-----------------------------------------------------------------------------
@interface MainViewController(PrivateImplementation)
- (void) setupInitialState: (CGRect)aFrame;
- (void) didSettingButtonTapped: (id)sender;
- (void) didPostButtonTapped: (id)sender;
- (void) didPostCancelButtonTapped: (id)sender;
- (void) didCameraButtonTapped: (id)sender;
- (void) updateCoordinates;
- (BOOL) checkForConnection;
- (void) previewPhoto:(UIImage *)photo;
- (void) closePreview;
- (void) postPhoto:(UIImage *)photo comment:(NSString *)comment;
- (void) changeCenterButtonTo: (UIBarButtonItem *)toButton;
- (void) updateCameraController;
@end

@implementation MainViewController(PrivateImplementation)
#pragma mark -
#pragma mark private methods
/*!
 * Initialize view controller
 */
- (void) setupInitialState: (CGRect) aFrame{
    aFrame.origin.y = 0;
    self.view.frame = aFrame;
    self.isRecoveredFromSuspend = NO;
    [UIApplication sharedApplication].statusBarHidden = YES;
    
    //photo submitter setting
    [[PhotoSubmitterManager getInstance] setPhotoDelegate:self];
    [PhotoSubmitterManager getInstance].submitPhotoWithOperations = YES;
    
    //setting view
    settingViewController_ = 
        [[SettingTableViewController alloc] init];
    settingNavigationController_ = [[UINavigationController alloc] initWithRootViewController:settingViewController_];
    settingNavigationController_.modalPresentationStyle = UIModalPresentationFormSheet;
    settingNavigationController_.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    settingViewController_.delegate = self;
    
    //preview image view
    previewImageView_ = [[PreviewPhotoView alloc] initWithFrame:CGRectZero];
    
    //progress view
    progressTableViewController_ = [[ProgressTableViewController alloc] initWithFrame:CGRectZero andProgressSize:CGSizeMake(MAINVIEW_PROGRESS_WIDTH, MAINVIEW_PROGRESS_HEIGHT)];
    
    //add tool bar
    toolbar_ = [[UIToolbar alloc] initWithFrame:CGRectZero];
    toolbar_.barStyle = UIBarStyleBlack;
    
    //camera button
    cameraButton_ =
    [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCamera
                                                 target:self
                                                 action:@selector(didCameraButtonTapped:)];
    cameraButton_.style = UIBarButtonItemStyleBordered;
    
    //comment button
    commentButton_ = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"comment.png"] style:UIBarButtonItemStylePlain target:self action:@selector(didCommentButtonTapped:)];
        
    //setting button
    settingButton_ = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"setting.png"] style:UIBarButtonItemStylePlain target:self action:@selector(didSettingButtonTapped:)];
    
    //post button
    postButton_ = [[UIBarButtonItem alloc] initWithTitle:[TTLang lstr:@"Main_Post"] style:UIBarButtonItemStyleBordered target:self action:@selector(didPostButtonTapped:)];

    //cancel button
    postCancelButton_ = [[UIBarButtonItem alloc] initWithTitle:[TTLang lstr:@"Main_Cancel"] style:UIBarButtonItemStyleBordered target:self action:@selector(didPostCancelButtonTapped:)];
    
    //spacer for centalize camera button 
    flexSpace_ = [[UIBarButtonItem alloc]
                  initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                  target:nil
                  action:nil];
    UIBarButtonItem* spacer =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [toolbar_ setItems:[NSArray arrayWithObjects:commentButton_,flexSpace_, cameraButton_, spacer, settingButton_, nil]];
    
    //setting indicator view
    settingIndicatorView_ = [[SettingIndicatorView alloc] initWithFrame:CGRectZero];
    
    //progress summary
    progressSummaryView_ = [[ProgressSummaryView alloc] initWithFrame:CGRectZero];
    [[PhotoSubmitterManager getInstance] setPhotoDelegate:progressSummaryView_];
    [PhotoSubmitterManager getInstance].enableGeoTagging = 
      [TottePostSettings getInstance].gpsEnabled;
}

/*!
 * on setting button tapped, open setting view
 */
- (void) didSettingButtonTapped:(id)sender{
    [UIApplication sharedApplication].statusBarHidden = NO;
    [self presentModalViewController:settingNavigationController_ animated:YES];
}

/*!
 * on comment button tapped, switch toggle comment post
 */
- (void) didCommentButtonTapped:(id)sender{
    [TottePostSettings getInstance].commentPostEnabled = ![TottePostSettings getInstance].commentPostEnabled;
    [self updateCoordinates];
}

#pragma mark -
#pragma mark coordinates
/*!
 * did rotate
 */
- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    imagePicker_.showsCameraControls = YES;
}

/*!
 * will rotate
 */
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
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
    
    [previewImageView_ updateWithFrame:frame];
    
    //progress view
    [progressTableViewController_ updateWithFrame:CGRectMake(frame.size.width - MAINVIEW_PROGRESS_WIDTH - MAINVIEW_PROGRESS_PADDING_X, MAINVIEW_PROGRESS_PADDING_Y, MAINVIEW_PROGRESS_WIDTH, frame.size.height - MAINVIEW_PROGRESS_PADDING_Y - MAINVIEW_PROGRESS_HEIGHT - MAINVIEW_TOOLBAR_HEIGHT - (MAINVIEW_PADDING_Y * 2) - settingIndicatorView_.contentSize.height - MAINVIEW_INDICATOR_PADDING_Y)];
    
    //progress summary
    CGRect ptframe = progressTableViewController_.view.frame;
    [progressSummaryView_ updateWithFrame:CGRectMake(ptframe.origin.x, ptframe.origin.y + ptframe.size.height + MAINVIEW_PADDING_Y, MAINVIEW_PROGRESS_WIDTH, MAINVIEW_PROGRESS_HEIGHT)];
    
    //setting indicator
    CGRect psframe = progressSummaryView_.frame;
    settingIndicatorView_.frame = CGRectMake(frame.size.width - settingIndicatorView_.contentSize.width - MAINVIEW_PROGRESS_PADDING_X, psframe.origin.y + psframe.size.height + MAINVIEW_PADDING_Y, settingIndicatorView_.contentSize.width, settingIndicatorView_.contentSize.height);
    [settingIndicatorView_ update];
    
    //toolbar
    [toolbar_ setFrame:CGRectMake(0, frame.size.height - MAINVIEW_TOOLBAR_HEIGHT, frame.size.width, MAINVIEW_TOOLBAR_HEIGHT)];
    flexSpace_.width = frame.size.width / 2 - MAINVIEW_CAMERA_BUTTON_WIDTH * 2 - MAINVIEW_COMMENT_BUTTON_PADDING; 

    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        CGAffineTransform transform = CGAffineTransformIdentity;
        if(orientation_ == UIInterfaceOrientationPortraitUpsideDown){
            transform = CGAffineTransformMakeRotation(M_PI);
        }else if(orientation_ == UIInterfaceOrientationPortrait){
            transform = CGAffineTransformMakeRotation(0);
        }
        [imagePicker_ setCameraViewTransform:transform];
    }
    
    if([TottePostSettings getInstance].commentPostEnabled){
        commentButton_.tintColor = [UIColor colorWithRed:77/255.0f green:77/255.0f blue:200/255.0f alpha:1.0f];
    }else{
        commentButton_.tintColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0f];
    }
}

#pragma mark -
#pragma mark photo methods
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
- (void)didCameraButtonTapped:(id)sender
{
    imagePicker_.showsCameraControls = NO;
    cameraButton_.enabled = NO;
    [imagePicker_ takePicture];
}

/*!
 * post photo
 */
- (void)postPhoto:(UIImage *)photo comment:(NSString *)comment{
    if([self checkForConnection]){
        [[PhotoSubmitterManager getInstance] submitPhoto:photo.UIImageAutoRotated comment:comment];
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[TTLang lstr:@"Alert_Error"] message:[TTLang lstr:@"Alert_NoNetwork"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

#pragma mark -
#pragma mark preview methods
/*!
 * on post button tapped
 */
- (void) didPostButtonTapped:(id)sender{
    [self postPhoto:previewImageView_.photo comment:previewImageView_.comment];
    [self closePreview];
}

/*!
 * on post cancel button tapped
 */
- (void) didPostCancelButtonTapped:(id)sender{
    [self closePreview];
}

/*!
 * close preview
 */
- (void)closePreview{
    [previewImageView_ dissmiss];
    [self changeCenterButtonTo:cameraButton_];
}

/*!
 * preview photo
 */
- (void)previewPhoto:(UIImage *)photo{
    [self.view addSubview:previewImageView_];
    [previewImageView_ presentWithPhoto:photo];
    
    [self.view bringSubviewToFront:toolbar_];
    [self changeCenterButtonTo:postButton_];
}

/*!
 * toggle camera button <-> post button
 */
- (void)changeCenterButtonTo:(UIBarButtonItem *)toButton{
    NSMutableArray *items = [NSMutableArray arrayWithArray: toolbar_.items];
    if(toButton == cameraButton_){
        int index = [items indexOfObject:postButton_];
        flexSpace_.width += MAINVIEW_CAMERA_BUTTON_WIDTH;
        [items removeObject:postButton_];
        [items removeObject:postCancelButton_];
        [items insertObject:toButton atIndex:index];
    }else{
        int index = [items indexOfObject:cameraButton_];
        flexSpace_.width -= MAINVIEW_CAMERA_BUTTON_WIDTH;
        [items removeObject:cameraButton_];
        [items insertObject:postCancelButton_ atIndex:index];
        [items insertObject:toButton atIndex:index];
    }
    [toolbar_ setItems: items animated:YES];    
}

/*!
 * update cameracontroller
 */
- (void)updateCameraController{
    [imagePicker_.view removeFromSuperview];
    [progressTableViewController_.view removeFromSuperview];
    [settingIndicatorView_ removeFromSuperview];
    [toolbar_ removeFromSuperview];
    [progressSummaryView_ removeFromSuperview];
    [self.view addSubview:imagePicker_.view];
    [self.view addSubview:progressTableViewController_.view];
    [self.view addSubview:settingIndicatorView_];
    [self.view addSubview:toolbar_];
    [self.view addSubview:progressSummaryView_];
    [self updateCoordinates];
}
@end

//-----------------------------------------------------------------------------
//Public Implementations
//-----------------------------------------------------------------------------
@implementation MainViewController
@synthesize isRecoveredFromSuspend;

#pragma mark -
#pragma mark public methods
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
    if(imagePicker_ == nil){
        imagePicker_ = [[UIImagePickerController alloc] init];
        imagePicker_.delegate = self;
        imagePicker_.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePicker_.showsCameraControls = YES;
        //[imagePicker_.view setAutoresizingMask:UIViewAutoresizingNone]; 
    }
    [self updateCameraController];
}

#pragma mark -
#pragma mark Image Picker delegate
/*! 
 * take photo
 */
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    cameraButton_.enabled = YES;
    imagePicker_.showsCameraControls = YES;
    UIImage *image = (UIImage*)[info objectForKey:UIImagePickerControllerOriginalImage];
    image = image.UIImageAutoRotated;
    if([TottePostSettings getInstance].commentPostEnabled){
        [self previewPhoto:image];
    }else{
        [self postPhoto:image comment:nil];
    }
}

#pragma mark -
#pragma mark PhotoSubmitter delegate
/*!
 * photo upload start
 */
- (void)photoSubmitter:(id<PhotoSubmitterProtocol>)photoSubmitter willStartUpload:(NSString *)imageHash{
    //NSLog(@"%@ upload started", imageHash);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [progressTableViewController_ addProgressWithType:photoSubmitter.type
                                                  forHash:imageHash];
    });
}

/*!
 * photo submitted
 */
- (void)photoSubmitter:(id<PhotoSubmitterProtocol>)photoSubmitter didSubmitted:(NSString *)imageHash suceeded:(BOOL)suceeded message:(NSString *)message{
    //NSLog(@"%@ submitted.", imageHash);
    dispatch_async(dispatch_get_main_queue(), ^{
        [progressTableViewController_ removeProgressWithType:photoSubmitter.type
                                                 forHash:imageHash];
    });
}

/*!
 * photo upload progress changed
 */
- (void)photoSubmitter:(id<PhotoSubmitterProtocol>)photoSubmitter didProgressChanged:(NSString *)imageHash progress:(CGFloat)progress{
    //NSLog(@"%@, %f", imageHash, progress);
    dispatch_async(dispatch_get_main_queue(), ^{
        [progressTableViewController_ updateProgressWithType:photoSubmitter.type 
                                                     forHash:imageHash progress:progress];
    });
}

#pragma mark -
#pragma mark SettingView delegate
/*!
 * did dismiss setting view
 */
- (void)didDismissSettingTableViewController{
    [UIApplication sharedApplication].statusBarHidden = YES;
    //for iphone heck
    if(self.view.frame.origin.y == MAINVIEW_STATUS_BAR_HEIGHT){
        CGRect frame = self.view.frame;
        frame.origin.y = 0;
        frame.size.height += MAINVIEW_STATUS_BAR_HEIGHT;
        [self.view setFrame:frame];
    }
    if(self.isRecoveredFromSuspend){
        self.isRecoveredFromSuspend = NO;
        [self performSelector:@selector(updateCameraController) withObject:nil afterDelay:0.5];
    }else{
        [self updateCoordinates];
    }
}

#pragma mark -
#pragma mark UIView delegate
/*!
 * auto rotation
 */
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        if(interfaceOrientation == UIInterfaceOrientationPortrait ||
           interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown){
            return YES;
        }
        return NO;
    }
    return YES;
}
@end
