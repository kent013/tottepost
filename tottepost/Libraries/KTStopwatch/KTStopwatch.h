//
//  KTStopwatch.h
//  SimpleTimer
//
//  Created by Kirby Turner on 7/19/10.
//  Copyright 2010 White Peak Software Inc. All rights reserved.
//
//  Disclaimer: Code adapted from Late Night Code blog entry.
//  URL: http://is.gd/2mZs
//
//  Modified to support wall clock or elapsed time.  Elapsed
//  time is used by default.

#import <mach/mach_time.h>


@interface KTStopwatch : NSObject {
   BOOL isRunning;
   BOOL isUseWallClockTimer;
   double lastElapseTimeInSeconds;
   
   // Fields used by elapse timer.
   double conversionToSeconds;
   uint64_t lastStart;
   uint64_t sum;
   
   // Fields used by wall clock timer.
   NSTimeInterval lastStartTimeInterval;
   NSTimeInterval sumTimeInterval;
}

@property(readonly) BOOL isRunning;

- (id)init;
- (id)initForWallClockTime;
- (void)reset;
- (void)start;
- (void)stop;
- (double)elapsedSeconds;
- (NSString *)elapsedTime;

@end
