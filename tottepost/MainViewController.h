//
//  MainViewController.h
//  tottepost mainview controller   	
//
//  Created by Ken Watanabe on 11/12/10.
//  Copyright (c) 2011 cocotomo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ENGPhotoSubmitterSettings.h"
#import "ENGPhotoSubmitterAccountTableViewController.h"
#import "TottepostSettingTableViewController.h"
#import "ProgressTableViewController.h"
#import "ProgressSummaryView.h"
#import "PreviewPhotoView.h"
#import "SettingIndicatorView.h"
#import "AVFoundationCameraController.h"
#import "CameraModeSwitchView.h"
#import "UVDelegate.h"
#import "FlashView.h"

/*!
 * Main view controller
 */
@interface MainViewController : UIViewController<UINavigationControllerDelegate, ENGPhotoSubmitterPhotoDelegate, TottepostSettingTableViewControllerDelegate, AVFoundationCameraControllerDelegate, PreviewPhotoViewDelegate, ENGPhotoSubmitterNavigationControllerDelegate, UVDelegate, CameraModeSwitchViewDelegate, ENGPhotoSubmitterSettingViewFactoryProtocol>{
@protected
    __strong TottepostSettingTableViewController *settingViewController_;
    __strong ProgressTableViewController *progressTableViewController_;
    __strong UINavigationController *settingNavigationController_;
    __strong AVFoundationCameraController *imagePicker_;
    __strong UIBarButtonItem* cameraButton_;
    __strong UIBarButtonItem* postButton_;
    __strong UIBarButtonItem* postCancelButton_;
    __strong UIToolbar *toolbar_;
    __strong UIBarButtonItem *flexSpace_;
    __strong UIBarButtonItem *settingButton_;
    __strong UIBarButtonItem *commentButton_;
    __strong ProgressSummaryView *progressSummaryView_;
    __strong PreviewPhotoView *previewImageView_;
    __strong SettingIndicatorView *settingIndicatorView_;
    __strong UIImageView *launchImageView_;
    __strong UIImageView *cameraIconImageView_;
    __strong CameraModeSwitchView *cameraModeSwitchView_;
    __strong id<ENGPhotoSubmitterServiceSettingTableViewDelegate> settingTableViewDelegate_;
    __strong FlashView *flashView_;
    UIDeviceOrientation orientation_;
    UIDeviceOrientation lastOrientation_;
    BOOL refreshCameraNeeded_;
    BOOL settingViewPresented_;
    BOOL isConnected_;
    BOOL isMailFeedbackButtonPressed_;
    BOOL isUserVoiceFeedbackButtonPressed_;    
    BOOL videoButtonFlush_;
    NSTimer *videoButtonTimer_;
}

@property (nonatomic, readonly) BOOL refreshCameraNeeded;

- (id) initWithFrame:(CGRect)frame;
- (void) applicationDidBecomeActive;
- (void) applicationWillResignActivate;
- (void) determinRefreshCameraNeeded;
@end

