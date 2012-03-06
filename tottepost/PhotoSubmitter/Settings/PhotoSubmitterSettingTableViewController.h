//
//  SettingViewController.h
//  tottepost
//
//  Created by ISHITOYA Kentaro on 11/12/11.
//  Copyright (c) 2011 cocotomo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoSubmitterManager.h"

@protocol PhotoSubmitterSettingTableViewControllerDelegate;

/*!
 * setting view controller
 */
@interface PhotoSubmitterSettingTableViewController : UITableViewController<PhotoSubmitterAuthenticationDelegate>{
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
@end