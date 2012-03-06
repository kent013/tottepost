//
//  PhotoSubmitterSettingTableViewController.h
//  tottepost
//
//  Created by ISHITOYA Kentaro on 12/01/02.
//  Copyright (c) 2012 cocotomo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoSubmitterManager.h"
#import "PhotoSubmitterSettingTableViewProtocol.h"


@interface PhotoSubmitterSettingTableViewController : UITableViewController<PhotoSubmitterSettingTableViewProtocol>{
    NSString *type_;
}

- (id)initWithType:(NSString *)type;
@property (nonatomic, readonly) NSString *type;
@end
