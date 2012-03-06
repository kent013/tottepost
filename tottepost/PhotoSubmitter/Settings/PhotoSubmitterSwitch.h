//
//  PhotoSubmitterSwitch.h
//  tottepost
//
//  Created by Kentaro ISHITOYA on 12/03/06.
//  Copyright (c) 2012 cocotomo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoSubmitterSwitch : UISwitch
@property (nonatomic, strong) NSString *submitterType;
@property (nonatomic, strong) NSDate *onEnabled;
@property (nonatomic, assign) int index;
@end
