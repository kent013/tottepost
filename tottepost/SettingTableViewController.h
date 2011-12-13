//
//  SettingViewController.h
//  tottepost
//
//  Created by ISHITOYA Kentaro on 11/12/11.
//  Copyright (c) 2011 cocotomo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FacebookSettingViewController.h"

@interface SettingTableViewController : UITableViewController<FacebookSettingViewControllerDelegate>{
@protected
    __strong FacebookSettingViewController *facebookSettingViewController_;
    __strong NSMutableDictionary *switches_;
}
@property (nonatomic, readonly) Facebook* facebook;
@end
