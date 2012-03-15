//
//  KTStopwatch.m
//  SimpleTimer
//
//  Created by Kirby Turner on 7/19/10.
//  Copyright 2010 White Peak Software Inc. All rights reserved.
//

#if __has_feature(objc_arc)
#error This file must be compiled with Non-ARC. use -fno-objc_arc flag (or convert project to Non-ARC)
#endif

#import "KTStopwatch.h"


@implementation KTStopwatch

@synthesize isRunning;

- (void)dealloc
{
   [super dealloc];
}

- (id)init 
{
   isUseWallClockTimer = NO;
   
   mach_timebase_info_data_t info;
   mach_timebase_info(&info);
   conversionToSeconds = 1e-9 * ((double)info.numer) / ((double)info.denom);
   
   [self reset];
   return self;
}

- (id)initForWallClockTime 
{
   isUseWallClockTimer = YES;
   
   [self reset];
   return self;
}

- (void)reset 
{
   isRunning = NO;
   sum = 0;
   sumTimeInterval = 0;
   lastElapseTimeInSeconds = 0;
}

- (void)start 
{
   if(!isRunning) {
      if(!isUseWallClockTimer) {
         lastStart = mach_absolute_time();
      } else {
         lastStartTimeInterval = [NSDate timeIntervalSinceReferenceDate];
      }
      isRunning = YES;
   }
}

- (void)stop 
{
   if(isRunning) {
      if(!isUseWallClockTimer) {
         sum += mach_absolute_time() - lastStart;
      } else {
         sumTimeInterval += [NSDate timeIntervalSinceReferenceDate] - lastStartTimeInterval;
      }
      isRunning = NO;
   }
}

/*
 Returns the number of seconds elapsed as a decimal.
 NOTE: This can be called without calling stop: for
 incremental timing.
 */
- (double)elapsedSeconds {
   uint64_t extra = 0;
   NSTimeInterval extraTimeInterval = 0;
   
   if(isRunning) {
      // Account for time between last start and now.
      if(!isUseWallClockTimer) {
         extra = mach_absolute_time() - lastStart;
         lastElapseTimeInSeconds = conversionToSeconds * (sum + extra);
      } else {
         extraTimeInterval = [NSDate timeIntervalSinceReferenceDate] - lastStartTimeInterval;
         lastElapseTimeInSeconds = sumTimeInterval + extraTimeInterval;
      }
   }
   return lastElapseTimeInSeconds;
}

- (NSString *)elapsedTime {
   double hours; 
   double minutes;
   double seconds;
   
   seconds = round([self elapsedSeconds]);
   
   hours = floor(seconds / 3600.);
   seconds -= 3600. * hours;
   minutes = floor(seconds / 60.);
   seconds -= 60. * minutes;
   
   NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
   [formatter setFormatterBehavior:NSNumberFormatterBehaviorDefault];
   [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
   [formatter setMaximumFractionDigits:1];
   [formatter setPositiveFormat:@"#00"];  // Use @"#00.0" to display milliseconds as decimal value.
   NSString *secondsInString = [formatter stringFromNumber:[NSNumber numberWithDouble:seconds]];
   [formatter release];
   
   
   if (hours == 0) {
      return [NSString stringWithFormat:NSLocalizedString(@"%02.0f:%@", @"Short format for elapsed time (minute:second). Example: 05:3.4"), minutes, secondsInString];
   } else {
      return [NSString stringWithFormat:NSLocalizedString(@"%.0f:%02.0f:%@", @"Short format for elapsed time (hour:minute:second). Example: 1:05:3.4"), hours, minutes, secondsInString];
   }
}

@end
