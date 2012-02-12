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
#import "PhotoSubmitterManager.h"
#import "AboutSettingViewController.h"

@protocol SettingTableViewControllerDelegate;

/*!
 * setting view controller
 */
@interface SettingTableViewController : UITableViewController<PhotoSubmitterAuthenticationDelegate, AboutSettingViewControllerDelegate>{
@protected
    __strong AlbumPhotoSubmitterSettingTableViewController *facebookSettingViewController_;
    __strong PhotoSubmitterSettingTableViewController *twitterSettingViewController_;
    __strong PhotoSubmitterSettingTableViewController *flickrSettingViewController_;
    __strong AlbumPhotoSubmitterSettingTableViewController *dropboxSettingViewController_;
    __strong AlbumPhotoSubmitterSettingTableViewController *evernoteSettingViewController_;
    __strong AlbumPhotoSubmitterSettingTableViewController *picasaSettingViewController_;
    __strong AboutSettingViewController *aboutSettingViewController_;
    __strong NSMutableDictionary *switches_;
    __strong NSMutableArray *accountTypeIndexes_;
}
- (void) updateSocialAppSwitches;
@property (weak, nonatomic) id<SettingTableViewControllerDelegate> delegate;
@end

@protocol SettingTableViewControllerDelegate <NSObject>
- (void) didDismissSettingTableViewController;
- (void) didFeedbackButtonPressed;
@end