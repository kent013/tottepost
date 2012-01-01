//
//  SettingViewController.h
//  tottepost
//
//  Created by ISHITOYA Kentaro on 11/12/11.
//  Copyright (c) 2011 cocotomo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FacebookSettingTableViewController.h"
#import "PhotoSubmitterSettingTableViewController.h"
#import "PhotoSubmitterManager.h"

@protocol SettingTableViewControllerDelegate;

/*!
 * setting view controller
 */
@interface SettingTableViewController : UITableViewController<PhotoSubmitterAuthenticationDelegate>{
@protected
    __strong FacebookSettingTableViewController *facebookSettingViewController_;
    __strong PhotoSubmitterSettingTableViewController *twitterSettingViewController_;
    __strong PhotoSubmitterSettingTableViewController *flickrSettingViewController_;
    __strong PhotoSubmitterSettingTableViewController *dropboxSettingViewController_;
    __strong NSMutableDictionary *switches_;
    __strong NSArray *accountTypes_;
}
- (void) updateSocialAppSwitches;
@property (weak, nonatomic) id<SettingTableViewControllerDelegate> delegate;
@end

@protocol SettingTableViewControllerDelegate <NSObject>
- (void) didDismissSettingTableViewController;
@end