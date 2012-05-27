//
//  TimeLogger.h
//  tottepost
//
//  Created by Kentaro ISHITOYA on 12/05/27.
//  Copyright (c) 2012 cocotomo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <mach/mach_time.h>

@interface TimeLogger : NSObject{
    uint64_t startTime_;
    mach_timebase_info_data_t baseInfo_;
}
+ (void) log;
+ (void) logOnce;
+ (void) lap;
@end
