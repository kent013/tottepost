//
//  TottepostSettingTableViewController.h
//  tottepost
//
//  Created by Kentaro ISHITOYA on 12/03/06.
//  Copyright (c) 2012 cocotomo. All rights reserved.
//

#import "PhotoSubmitterSettingTableViewController.h"
#import "AboutSettingViewController.h"
#import "AVFoundationPresetTableViewController.h"

@protocol TottepostSettingTableViewControllerDelegate;
@interface TottepostSettingTableViewController : PhotoSubmitterSettingTableViewController<AboutSettingViewControllerDelegate>{
    __strong AboutSettingViewController *aboutSettingViewController_;
    __strong AVFoundationPresetTableViewController *presetSettingViewController_;
}
@end
@protocol TottepostSettingTableViewControllerDelegate<PhotoSubmitterSettingTableViewControllerDelegate>
- (void) didMailFeedbackButtonPressed;
- (void) didUserVoiceFeedbackButtonPressed;
@end
