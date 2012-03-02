//
//  AboutSettingViewController.h
//  tottepost
//
//  Created by Kentaro ISHITOYA on 12/01/27.
//  Copyright (c) 2012 cocotomo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserVoiceAccountSettingViewController.h"

@protocol AboutSettingViewControllerDelegate;

@interface AboutSettingViewController : UITableViewController<UserVoiceAccountSettingViewControllerDelegate>{
}
@property (nonatomic, assign) id<AboutSettingViewControllerDelegate> delegate;
@end

@protocol AboutSettingViewControllerDelegate <NSObject>
- (void) didMailFeedbackButtonPressed;
- (void) didUserVoiceFeedbackButtonPressed;
@end