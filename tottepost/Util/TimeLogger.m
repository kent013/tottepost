//
//  TimeLogger.m
//  tottepost
//
//  Created by Kentaro ISHITOYA on 12/05/27.
//  Copyright (c) 2012 cocotomo. All rights reserved.
//

#import "TimeLogger.h"
static TimeLogger *TimeLoggerSingletonInstance;

//-----------------------------------------------------------------------------
//Private Implementations
//-----------------------------------------------------------------------------
@interface TimeLogger(PrivateImplementation)
- (id)init;
- (double) elapsedTime;
- (void) updateTime;
+ (TimeLogger *) sharedLogger;
@end

@implementation TimeLogger(PrivateImplementation)
/*!
 * get singleton instance
 */
+ (TimeLogger *)sharedLogger{
    if(TimeLoggerSingletonInstance == nil){
        TimeLoggerSingletonInstance = [TimeLogger new];
    }
    return TimeLoggerSingletonInstance;
}

/*!
 * initialize
 */
- (id)init{
    self = [super init];
    if(self != nil){
        mach_timebase_info(&baseInfo_);
        [self updateTime];
    }
    return self;
}

/*!
 * get elapsed time
 */
- (double) elapsedTime{
    double currentTime = mach_absolute_time();
    return (double)(currentTime - startTime_) * baseInfo_.numer / baseInfo_.denom / 1000000000.0;
}

/*!
 * update time
 */
- (void)updateTime{
    startTime_ = mach_absolute_time();
}
@end

//-----------------------------------------------------------------------------
//Public Implementations
//-----------------------------------------------------------------------------
@implementation TimeLogger

/*!
 * log time
 */
+ (void)log{
    NSLog(@"elapsed:%f", [TimeLoggerSingletonInstance elapsedTime]);
}

/*!
 * log time
 */
+ (void)logOnce{
    NSLog(@"elapsed:%f", [TimeLoggerSingletonInstance elapsedTime]);
    [TimeLoggerSingletonInstance updateTime];
}

/*!
 * lap
 */
+ (void)lap{
    [TimeLoggerSingletonInstance updateTime];
}
@end
