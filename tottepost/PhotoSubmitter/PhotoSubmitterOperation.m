//
//  PhotoSubmitterOperation.m
//  tottepost
//
//  Created by ISHITOYA Kentaro on 11/12/19.
//  Copyright (c) 2011 cocotomo. All rights reserved.
//

#import "PhotoSubmitterOperation.h"
//-----------------------------------------------------------------------------
//Private Implementations
//-----------------------------------------------------------------------------
@interface PhotoSubmitterOperation(PrivateImplementation)
- (void) finishOperation;
@end

@implementation PhotoSubmitterOperation(PrivateImplementation)
#pragma mark -
#pragma mark NSOperation methods
/*!
 * is concurrent
 */
- (BOOL)isConcurrent {
    return YES;
}

/*!
 * return isExecuting
 */
- (BOOL)isExecuting {
    return isExecuting;
}

/*!
 * return isFinished
 */
- (BOOL)isFinished {
    return isFinished;
}
/*!
 * KVO key setting
 */
+ (BOOL)automaticallyNotifiesObserversForKey:(NSString*)key {
    if ([key isEqualToString:@"isExecuting"] || 
        [key isEqualToString:@"isFinished"]) {
        return YES;
    }
    return [super automaticallyNotifiesObserversForKey:key];
}

/*!
 * start operation
 */
- (void)start{    
    [self setValue:[NSNumber numberWithBool:YES] forKey:@"isExecuting"];
    [self.submitter submitPhoto:self.photo comment:self.comment andDelegate:self];
    do {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate distantFuture]];
    } while (isExecuting);
}

#pragma mark -
#pragma mark util methods
/*!
 * finish operation
 */
- (void) finishOperation{
    [self setValue:[NSNumber numberWithBool:NO] forKey:@"isExecuting"];
	[self setValue:[NSNumber numberWithBool:YES] forKey:@"isFinished"];
}
@end

//-----------------------------------------------------------------------------
//Public Implementations
//----------------------------------------------------------------------------
@implementation PhotoSubmitterOperation
@synthesize submitter;
@synthesize photo;
@synthesize comment;

/*!
 * initialize with data
 */
- (id)initWithSubmitter:(id<PhotoSubmitterProtocol>)inSubmitter 
                  photo:(UIImage *)inPhoto comment:(NSString *)inComment{
    self = [super init];
    if(self){
        self.submitter = inSubmitter;
        self.photo = inPhoto;
        self.comment = inComment;
    }
    return self;
}

/*!
 * submitter operation delegate
 */
- (void)photoSubmitterDidOperationFinished{
    [self finishOperation];
}
@end
