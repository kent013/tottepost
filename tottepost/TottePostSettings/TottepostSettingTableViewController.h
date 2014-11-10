//
//  TottepostSettingTableViewController.h
//  tottepost
//
//  Created by Kentaro ISHITOYA on 12/03/06.
//  Copyright (c) 2012 cocotomo. All rights reserved.
//

#import "ENGPhotoSubmitterSettingTableViewController.h"
#import "AboutSettingViewController.h"
#import "AVFoundationPresetTableViewController.h"

@protocol TottepostSettingTableViewControllerDelegate;
@interface TottepostSettingTableViewController : ENGPhotoSubmitterSettingTableViewController<AboutSettingViewControllerDelegate>{
    __strong AboutSettingViewController *aboutSettingViewController_;
    __strong AVFoundationPresetTableViewController *presetSettingViewController_;
}
@end
@protocol TottepostSettingTableViewControllerDelegate<ENGPhotoSubmitterSettingTableViewControllerDelegate>
- (void) didMailFeedbackButtonPressed;
- (void) didUserVoiceFeedbackButtonPressed;
@end
