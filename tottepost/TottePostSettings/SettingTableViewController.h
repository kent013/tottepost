//
//  SettingViewController.h
//  tottepost
//
//  Created by ISHITOYA Kentaro on 11/12/11.
//  Copyright (c) 2011 cocotomo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AlbumPhotoSubmitterSettingTableViewController.h"
#import "PhotoSubmitterSettingTableViewController.h"
#import "TwitterPhotoSubmitterSettingTableViewController.h"
#import "PhotoSubmitterManager.h"
#import "AboutSettingViewController.h"

@protocol SettingTableViewControllerDelegate;

/*!
 * setting view controller
 */
@interface SettingTableViewController : UITableViewController<PhotoSubmitterAuthenticationDelegate, AboutSettingViewControllerDelegate>{
@protected
    __strong NSMutableDictionary *settingControllers_;
    __strong AboutSettingViewController *aboutSettingViewController_;
    __strong NSMutableArray *switches_;
}
- (void) updateSocialAppSwitches;
@property (weak, nonatomic) id<SettingTableViewControllerDelegate> delegate;
@end

@protocol SettingTableViewControllerDelegate <NSObject>
- (void) didDismissSettingTableViewController;
- (void) didMailFeedbackButtonPressed;
- (void) didUserVoiceFeedbackButtonPressed;
@end