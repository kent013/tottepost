//
//  PhotoSubmitterSettingTableViewController.h
//  tottepost
//
//  Created by Kentaro ISHITOYA on 12/01/02.
//  Copyright (c) 2012 cocotomo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoSubmitterManager.h"
#import "PhotoSubmitterSettingTableViewProtocol.h"


@interface PhotoSubmitterSettingTableViewController : UITableViewController<PhotoSubmitterSettingTableViewProtocol, PhotoSubmitterDataDelegate>{
    PhotoSubmitterType type_;
}

- (id)initWithType:(PhotoSubmitterType)type;
@end
