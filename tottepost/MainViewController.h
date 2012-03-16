//
//  MainViewController.h
//  tottepost mainview controller   	
//
//  Created by Ken Watanabe on 11/12/10.
//  Copyright (c) 2011 cocotomo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TottepostSettingTableViewController.h"
#import "PhotoSubmitterSettings.h"
#import "Facebook.h"
#import "ProgressTableViewController.h"
#import "ProgressSummaryView.h"
#import "PreviewPhotoView.h"
#import "SettingIndicatorView.h"
#import "AVFoundationCameraController.h"
#import "PhotoSubmitterAccountTableViewController.h"
#import "CameraModeSwitchView.h"
#import "UVDelegate.h"

/*!
 * Main view controller
 */
@interface MainViewController : UIViewController<UINavigationControllerDelegate, PhotoSubmitterPhotoDelegate, TottepostSettingTableViewControllerDelegate, AVFoundationCameraControllerDelegate, PreviewPhotoViewDelegate, PhotoSubmitterAuthControllerDelegate, UVDelegate, CameraModeSwitchViewDelegate>{
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
    UIDeviceOrientation orientation_;
    UIDeviceOrientation lastOrientation_;
    BOOL refreshCameraNeeded_;
    BOOL settingViewPresented_;
    BOOL isConnected_;
    BOOL isMailFeedbackButtonPressed_;
    BOOL isUserVoiceFeedbackButtonPressed_;
}

@property (nonatomic, readonly) BOOL refreshCameraNeeded;

- (id) initWithFrame:(CGRect)frame;
- (void) applicationDidBecomeActive;
- (void) determinRefreshCameraNeeded;
@end

