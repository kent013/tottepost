//
//  TottepostSettingTableViewController.h
//  tottepost
//
//  Created by Kentaro ISHITOYA on 12/03/06.
//  Copyright (c) 2012 cocotomo. All rights reserved.
//

#import "PhotoSubmitterSettingTableViewController.h"
#import "AboutSettingViewController.h"

@protocol TottepostSettingTableViewControllerDelegate;
@interface TottepostSettingTableViewController : PhotoSubmitterSettingTableViewController<AboutSettingViewControllerDelegate>{
    __strong AboutSettingViewController *aboutSettingViewController_;
}
@end
@protocol TottepostSettingTableViewControllerDelegate<PhotoSubmitterSettingTableViewControllerDelegate>
- (void) didMailFeedbackButtonPressed;
- (void) didUserVoiceFeedbackButtonPressed;
@end
