//
//  SettingViewController.h
//  tottepost
//
//  Created by ISHITOYA Kentaro on 11/12/11.
//  Copyright (c) 2011 cocotomo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FacebookSettingViewController.h"

@interface SettingViewController : UITableViewController{
    __strong FacebookSettingViewController *facebookSettingViewController_;
}
@property (nonatomic, readonly) Facebook* facebook;
@end
