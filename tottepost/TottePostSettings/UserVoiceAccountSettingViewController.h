//
//  UserVoiceAccountSettingView.h
//  tottepost
//
//  Created by Kentaro ISHITOYA on 12/03/02.
//  Copyright (c) 2012 cocotomo. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UserVoiceAccountSettingViewControllerDelegate;

@interface UserVoiceAccountSettingViewController: UITableViewController<UITextFieldDelegate>{
    UITextField *titleField_;
    __strong UITextField *mailAddressTextField_;
    __strong UITextField *usernameTextField_;
    BOOL isDone_;
}
@property (nonatomic, assign) id<UserVoiceAccountSettingViewControllerDelegate> delegate;
@end


@protocol UserVoiceAccountSettingViewControllerDelegate <NSObject>
- (void)accountSettingViewController:(UserVoiceAccountSettingViewController *)accountSettingViewController didPresentMailAddress:(NSString*)mailAddress andUsername:(NSString *)username;
- (void)didCancelAccountSettingViewController:(UserVoiceAccountSettingViewController *)accountSettingViewController;
@end
