//
//  AVFoundationPresetTableViewController.h
//  tottepost
//
//  Created by Kentaro ISHITOYA on 12/03/17.
//  Copyright (c) 2012 cocotomo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AVFoundationPreset.h"

@interface AVFoundationPresetTableViewController : UITableViewController{
    AVFoundationPresetType type_;
    int selectedIndex_;
}

@property (nonatomic, assign) AVFoundationPresetType type;
@end