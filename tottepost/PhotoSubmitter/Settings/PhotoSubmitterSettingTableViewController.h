//
//  SettingViewController.h
//  tottepost
//
//  Created by ISHITOYA Kentaro on 11/12/11.
//  Copyright (c) 2011 cocotomo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AlbumPhotoSubmitterSettingTableViewController.h"
#import "PhotoSubmitterServiceSettingTableViewController.h"
#import "TwitterPhotoSubmitterSettingTableViewController.h"
#import "PhotoSubmitterManager.h"
#import "AboutSettingViewController.h"

@protocol PhotoSubmitterSettingTableViewControllerDelegate;

/*!
 * setting view controller
 */
@interface PhotoSubmitterSettingTableViewController : UITableViewController<PhotoSubmitterAuthenticationDelegate, AboutSettingViewControllerDelegate>{
@protected
    __strong NSMutableDictionary *settingControllers_;
    __strong NSMutableArray *switches_;
}
- (void) updateSocialAppSwitches;
- (UITableViewCell *) createGeneralSettingCell:(int)tag;
@property (weak, nonatomic) id<PhotoSubmitterSettingTableViewControllerDelegate> delegate;
@end

@protocol PhotoSubmitterSettingTableViewControllerDelegate <NSObject>
- (void) didDismissSettingTableViewController;
- (void) didMailFeedbackButtonPressed;
- (void) didUserVoiceFeedbackButtonPressed;
@end