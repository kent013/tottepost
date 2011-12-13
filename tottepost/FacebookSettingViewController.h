//
//  FacebookSettingViewController.h
//  tottepost
//
//  Created by ISHITOYA Kentaro on 11/12/12.
//  Copyright (c) 2011 cocotomo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBConnect.h"

@protocol FacebookSettingViewControllerDelegate;

@interface FacebookSettingViewController : UIViewController<FBSessionDelegate>{
    __strong Facebook *facebook_;
}

@property (nonatomic, readonly) Facebook* facebook;
@property (weak, nonatomic) id<FacebookSettingViewControllerDelegate> delegate;

- (void) login;
- (void) logout;
@end

/*!
 * facebook setting view controller delegate
 */
@protocol FacebookSettingViewControllerDelegate <NSObject>
- (void) fbDidLogout;
- (void) fbDidLogin;
@end
