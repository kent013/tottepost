//
//  MainViewController.m
//  tottepost mainview controller
//
//  Created by Ken Watanabe on 11/12/10.
//  Copyright (c) 2011 cocotomo. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "MainViewController.h"
#import "PhotoSubmitterSettings.h"
#import "MainViewControllerConstants.h"
#import "TTLang.h"
#import "UIColor-Expanded.h"
#import "AAMFeedbackViewController.h"
#import "UserVoiceAPIKey.h"
#import "UserVoice.h"
#import "UVSession.h"
#import "UVToken.h"
#import "NSData+Digest.h"
#import "FilePhotoSubmitter.h"

static NSString *kFilePhotoSubmitterType = @"FilePhotoSubmitter";

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
- (void) previewPhoto:(PhotoSubmitterImageEntity *)photo;
- (void) closePreview;
- (void) postPhoto:(PhotoSubmitterImageEntity *)photo;
- (void) changeCenterButtonTo: (UIBarButtonItem *)toButton;
- (void) updateCameraController;
- (void) createCameraController;
- (void) firstLaunched;
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
    self.view.backgroundColor = [UIColor clearColor];
    refreshCameraNeeded_ = NO;
    [UIApplication sharedApplication].statusBarHidden = YES;
    
    //photo submitter setting
    [[PhotoSubmitterManager sharedInstance] setPhotoDelegate:self];
    [PhotoSubmitterManager sharedInstance].submitPhotoWithOperations = YES;
    [PhotoSubmitterManager sharedInstance].authControllerDelegate = self;
    
    //setting view
    settingViewController_ = 
        [[TottepostSettingTableViewController alloc] init];
    settingNavigationController_ = [[UINavigationController alloc] initWithRootViewController:settingViewController_];
    settingNavigationController_.modalPresentationStyle = UIModalPresentationFormSheet;
    settingNavigationController_.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    settingViewController_.delegate = self;
    
    //preview image view
    previewImageView_ = [[PreviewPhotoView alloc] initWithFrame:CGRectZero];
    previewImageView_.delegate = self;
    
    //progress view
    progressTableViewController_ = [[ProgressTableViewController alloc] initWithFrame:CGRectZero andProgressSize:CGSizeMake(MAINVIEW_PROGRESS_WIDTH, MAINVIEW_PROGRESS_HEIGHT)];
    
    //add tool bar
    toolbar_ = [[UIToolbar alloc] initWithFrame:CGRectZero];
    toolbar_.barStyle = UIBarStyleBlack;
    
    //camera button
    UIButton *customView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, MAINVIEW_CAMERA_BUTTON_WIDTH, MAINVIEW_CAMERA_BUTTON_HEIGHT)];
    [customView setBackgroundImage:[UIImage imageNamed:@"button_template.png"]forState:UIControlStateNormal];
    [customView addTarget:self action:@selector(didCameraButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    cameraButton_ = [[UIBarButtonItem alloc]initWithCustomView:customView];
    cameraButton_.style = UIBarButtonItemStyleBordered;
    UIImage *cameraIconImage = [UIImage imageNamed:@"camera.png"];
    cameraIconImageView_ = [[UIImageView alloc] initWithImage:cameraIconImage];
    cameraIconImageView_.frame = CGRectMake(MAINVIEW_CAMERA_BUTTON_WIDTH/2 - cameraIconImage.size.width/2, (MAINVIEW_CAMERA_BUTTON_HEIGHT - cameraIconImage.size.height)/2, cameraIconImage.size.width, cameraIconImage.size.height);
    [customView addSubview:cameraIconImageView_];
    
    //comment button
    commentButton_ = [[UIBarButtonItem alloc] init];
        
    //setting button
    settingButton_ = [[UIBarButtonItem alloc] init];
    
    //post button
    postButton_ = [[UIBarButtonItem alloc] initWithTitle:[TTLang localized:@"Main_Post"] style:UIBarButtonItemStyleBordered target:self action:@selector(didPostButtonTapped:)];

    //cancel button
    postCancelButton_ = [[UIBarButtonItem alloc] initWithTitle:[TTLang localized:@"Main_Cancel"] style:UIBarButtonItemStyleBordered target:self action:@selector(didPostCancelButtonTapped:)];
    
    //spacer for centalize camera button 
    flexSpace_ = [[UIBarButtonItem alloc]
                  initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                  target:nil
                  action:nil];
    UIBarButtonItem* spacer =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [toolbar_ setItems:[NSArray arrayWithObjects:commentButton_,spacer, cameraButton_, spacer, settingButton_, nil]];
    
    //setting indicator view
    settingIndicatorView_ = [[SettingIndicatorView alloc] initWithFrame:CGRectZero];
    
    //progress summary
    progressSummaryView_ = [[ProgressSummaryView alloc] initWithFrame:CGRectZero];
    [[PhotoSubmitterManager sharedInstance] setPhotoDelegate:progressSummaryView_];
    [PhotoSubmitterManager sharedInstance].enableGeoTagging = 
      [PhotoSubmitterSettings getInstance].gpsEnabled;
    if([UIDevice currentDevice].orientation == UIDeviceOrientationPortraitUpsideDown){
        orientation_ = UIDeviceOrientationPortraitUpsideDown;
    }else{
        orientation_ = UIDeviceOrientationPortrait;
    }
    lastOrientation_ = orientation_;
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        launchImageView_ = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Default.png"]];
        [self.view addSubview:launchImageView_];
    }
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    BOOL isNotFirstLaunched = [defaults boolForKey:@"IsNotFirstLaunched"];
    if(isNotFirstLaunched == false)
    {
        [self firstLaunched];
        [defaults setBool:YES forKey:@"IsNotFirstLaunched"];
    }
}

/*!
 * on setting button tapped, open setting view
 */
- (void) didSettingButtonTapped:(id)sender{
    [UIApplication sharedApplication].statusBarHidden = NO;
    [self presentModalViewController:settingNavigationController_ animated:YES];
    settingViewPresented_ = YES;
}

/*!
 * on comment button tapped, switch toggle comment post
 */
- (void) didCommentButtonTapped:(id)sender{
    [PhotoSubmitterSettings getInstance].commentPostEnabled = ![PhotoSubmitterSettings getInstance].commentPostEnabled;
    [self updateCoordinates];
}

#pragma mark -
#pragma mark coordinates

/*!
 * update control coodinates
 */
- (void)updateCoordinates{ 
    CGRect frame = self.view.frame;
    CGRect screen = [UIScreen mainScreen].bounds;

    frame = CGRectMake(0, 0, screen.size.width, screen.size.height);    
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
    flexSpace_.width = frame.size.width / 2 - MAINVIEW_CAMERA_BUTTON_WIDTH/2 - MAINVIEW_COMMENT_BUTTON_WIDTH - MAINVIEW_COMMENT_BUTTON_PADDING; 
    
    postButton_.width = MAINVIEW_POST_BUTTON_WIDTH;
    postCancelButton_.width = MAINVIEW_POSTCANCEL_BUTTON_WIDTH;

    CGAffineTransform t;
    switch (orientation_) {
        case UIDeviceOrientationPortrait:
            t = CGAffineTransformMakeRotation(0 * M_PI / 180);
            break;
        case UIDeviceOrientationLandscapeLeft:
            t = CGAffineTransformMakeRotation(90 * M_PI / 180);
            break;
        case UIDeviceOrientationLandscapeRight:
            t = CGAffineTransformMakeRotation(270 * M_PI / 180);
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            t = CGAffineTransformMakeRotation(180 * M_PI / 180);
            break;
        default:
            break;
    }
    
    UIButton *commentButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 42, 42)];
    if([PhotoSubmitterSettings getInstance].commentPostEnabled){
        [commentButton setBackgroundImage:[UIImage imageNamed:@"comment-selected.png"]forState:UIControlStateNormal];
    }else{
        [commentButton setBackgroundImage:[UIImage imageNamed:@"comment.png"]forState:UIControlStateNormal];
    }
    [commentButton addTarget:self action:@selector(didCommentButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    commentButton_.customView = commentButton;

    UIButton *settingButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 42, 42)];
    [settingButton setBackgroundImage:[UIImage imageNamed:@"setting.png"]forState:UIControlStateNormal];
    [settingButton addTarget:self action:@selector(didSettingButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    settingButton_.customView = settingButton;

    [UIView beginAnimations:@"RotateIcon" context:nil];
    commentButton.transform = t;
    settingButton.transform = t;
    cameraIconImageView_.transform = t;
    [UIView commitAnimations];
    
}

#pragma mark -
#pragma mark photo methods
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
- (void)postPhoto:(PhotoSubmitterImageEntity *)photo{
    PhotoSubmitterManager *manager = [PhotoSubmitterManager sharedInstance];
    if(manager.enabledSubmitterCount == 0){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[TTLang localized:@"Alert_Error"] message:[TTLang localized:@"Alert_NoSubmittersEnabled"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    [manager submitPhoto:photo];
}

#pragma mark -
#pragma mark preview methods
/*!
 * on post button tapped
 */
- (void) didPostButtonTapped:(id)sender{
    [self closePreview];
    [self postPhoto:previewImageView_.photo];
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
- (void)previewPhoto:(PhotoSubmitterImageEntity *)photo{
    [self.view addSubview:previewImageView_];
    [previewImageView_ presentWithPhoto:photo videoOrientation:orientation_];
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
    imagePicker_.delegate = self;

    [self updateCoordinates];
}

/*!
 * create camera view
 */
- (void) createCameraController{
    [UIApplication sharedApplication].statusBarHidden = YES;
    if(imagePicker_ == nil){
        imagePicker_ = [[AVFoundationCameraController alloc] initWithFrame:self.view.frame];
        imagePicker_.delegate = self;
        imagePicker_.showsCameraControls = YES;
        imagePicker_.showsShutterButton = NO;
    }
    [self updateCameraController];
}

/*!
 * first launched
 */
- (void) firstLaunched{
    UIAlertView *alert =
    [[UIAlertView alloc] initWithTitle:[TTLang localized:@"FirstAlert_Title"] message:[TTLang localized:@"FirstAlert_Message"]
                              delegate:nil cancelButtonTitle:[TTLang localized:@"FirstAlert_OK"] otherButtonTitles:nil];
    [alert show];
}
@end

//-----------------------------------------------------------------------------
//Public Implementations
//-----------------------------------------------------------------------------
@implementation MainViewController
@synthesize refreshCameraNeeded = refreshCameraNeeded_;

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
 * application Did Become active
 */
- (void)applicationDidBecomeActive{
    if(settingViewPresented_){
        [settingViewController_ updateSocialAppSwitches];
    }
    [settingIndicatorView_ update];
}

/*!
 * determin refresh needed
 */
- (void)determinRefreshCameraNeeded{
    if(settingViewPresented_){
        refreshCameraNeeded_ = YES;
    }else{
        refreshCameraNeeded_ = NO;
    }
}

#pragma mark -
#pragma mark Image Picker delegate
/*! 
 * take photo
 */
- (void)cameraController:(AVFoundationCameraController *)cameraController didFinishPickingImageData:(NSData *)data{
    cameraButton_.enabled = YES;
    imagePicker_.showsCameraControls = YES;
    PhotoSubmitterImageEntity *photo = [[PhotoSubmitterImageEntity alloc] initWithData:data];
    if([PhotoSubmitterSettings getInstance].commentPostEnabled){
        [self previewPhoto:photo];
    }else{
        [self postPhoto:photo];
    }    
}

/*!
 * dismiss launch image
 */
- (void)cameraControllerDidInitialized:(AVFoundationCameraController *)cameraController{
}

/*
 * did rotated device orientation
 */
- (void) didRotatedDeviceOrientation:(UIDeviceOrientation) orientation{
    if(orientation == UIDeviceOrientationPortrait ||
       orientation == UIDeviceOrientationPortraitUpsideDown ||
       orientation == UIDeviceOrientationLandscapeLeft ||
       orientation == UIDeviceOrientationLandscapeRight)
    {
        orientation_ = orientation;
    }
    
    if(orientation_ == lastOrientation_)
    {
        return;
    }
    lastOrientation_ = orientation_;
    [self updateCoordinates];
}

#pragma mark -
#pragma mark PhotoSubmitter delegate
/*!
 * photo upload start
 */
- (void)photoSubmitter:(id<PhotoSubmitterProtocol>)photoSubmitter willStartUpload:(NSString *)imageHash{
    if([photoSubmitter.type isEqualToString:kFilePhotoSubmitterType]){
        return;
    }
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
    
    NSString *msg = [TTLang localized:@"ProgressCell_Completed"];
    int delay = TOTTEPOST_PROGRESS_REMOVE_DELAY;
    if([photoSubmitter.type isEqualToString:kFilePhotoSubmitterType]){
        return;
    }else if(suceeded == NO){
        delay = 0;
        msg = @"";
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [progressTableViewController_ removeProgressWithType:photoSubmitter.type
                                                     forHash:imageHash 
                                                     message:msg delay:delay];
    });
}

/*!
 * photo upload progress changed
 */
- (void)photoSubmitter:(id<PhotoSubmitterProtocol>)photoSubmitter didProgressChanged:(NSString *)imageHash progress:(CGFloat)progress{
    if([photoSubmitter.type isEqualToString:kFilePhotoSubmitterType]){
        return;
    }
    //NSLog(@"%@, %f", imageHash, progress);
    dispatch_async(dispatch_get_main_queue(), ^{
        [progressTableViewController_ updateProgressWithType:photoSubmitter.type 
                                                     forHash:imageHash progress:progress];
    });
}

/*!
 * photo submitter did canceled
 */
- (void)photoSubmitter:(id<PhotoSubmitterProtocol>)photoSubmitter didCanceled:(NSString *)imageHash{   
    NSString *msg = [TTLang localized:@"ProgressCell_Canceled"];
    if([photoSubmitter.type isEqualToString:kFilePhotoSubmitterType]){
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [progressTableViewController_ removeProgressWithType:photoSubmitter.type
                                                     forHash:imageHash 
                                                     message:msg delay:0];
    });
    
}

#pragma mark -
#pragma mark PreviewPhotoView delegate
/*!
 * request for orientation
 */
- (UIDeviceOrientation)requestForOrientation{
    return orientation_;
}

#pragma mark -
#pragma mark SettingView delegate
/*!
 * did dismiss setting view
 */
- (void)didDismissSettingTableViewController{
    //for iphone heck
    if(self.view.frame.origin.y == MAINVIEW_STATUS_BAR_HEIGHT){
        CGRect frame = self.view.frame;
        frame.origin.y = 0;
        frame.size.height += MAINVIEW_STATUS_BAR_HEIGHT;
        [self.view setFrame:frame];
    }
    if(self.refreshCameraNeeded){
        refreshCameraNeeded_ = NO;
        //[self performSelector:@selector(updateCameraController) withObject:nil afterDelay:0.5];
    }else{
        [self updateCoordinates];
    }
    [settingIndicatorView_ update];
    settingViewPresented_ = NO;
}

/*!
 * feedback button pressed
 */
- (void)didMailFeedbackButtonPressed{
    isMailFeedbackButtonPressed_ = YES;
}

/*!
 * feedback button pressed
 */
- (void)didUserVoiceFeedbackButtonPressed{
    isUserVoiceFeedbackButtonPressed_ = YES;
}

#pragma mark - PhotoSubmitterAuthControllerDelegate
/*!
 * request UINavigationController to present authentication view
 */
- (UINavigationController *) requestNavigationControllerToPresentAuthenticationView{
    return settingNavigationController_;
}

#pragma mark -
#pragma mark UIView delegate
/*!
 * auto rotation
 */
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        if(interfaceOrientation == UIInterfaceOrientationPortrait)
            return YES;
        else
            return NO;
    }
    return YES;
}

/*!
 * create camera controller when the view appeared
 */
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [UIApplication sharedApplication].statusBarHidden = YES;
    if(imagePicker_ == nil){
        [self createCameraController];
        //[self performSelector:@selector(createCameraController) withObject:nil afterDelay:0.5];
    }
    if(isMailFeedbackButtonPressed_){
        isMailFeedbackButtonPressed_ = NO;
        isUserVoiceFeedbackButtonPressed_ = NO;
        AAMFeedbackViewController *fv = [[AAMFeedbackViewController alloc] init];
        fv.toRecipients = [NSArray arrayWithObject:@"kentaro.ishitoya@gmail.com"];
        fv.bccRecipients = [NSArray arrayWithObject:@"ken45000@gmail.com"];
        UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:fv];
        [self presentModalViewController:nvc animated:YES];
    }else if(isUserVoiceFeedbackButtonPressed_){
        isMailFeedbackButtonPressed_ = NO;
        isUserVoiceFeedbackButtonPressed_ = NO;
        
        [UVSession clearCurrentSession];
        [UserVoice presentUserVoiceModalViewControllerForParent:self
                    andSite:TOTTEPOST_USERVOICE_API_SITE
                     andKey:TOTTEPOST_USERVOICE_API_KEY
                  andSecret:TOTTEPOST_USERVOICE_API_SECRET];
    }
}
@end
