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
- (void) finishOperation{
    NSLog(@"finish op");
    [self setValue:[NSNumber numberWithBool:NO] forKey:@"isExecuting_"];
	[self setValue:[NSNumber numberWithBool:YES] forKey:@"isFinished_"];
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
        self.submitter.operationDelegate = self;
        self.photo = inPhoto;
        self.comment = inComment;
    }
    return self;
}

/*!
 */
- (void)start{
    [self.submitter submitPhoto:self.photo comment:self.comment];
    NSLog(@"operation started");
    while (![self isFinished] && ![self isCancelled]) {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }
    NSLog(@"operation ended");
}

- (void)photoSubmitterDidOperationFinished{
    NSLog(@"del finish op");
    [self performSelector:@selector(finishOperation) withObject:nil afterDelay:2];
}

- (BOOL)isConcurrent {
    return YES;
}
- (BOOL)isExecuting {
    return isExecuting_;
}
- (BOOL)isFinished {
    return isFinished_;
}
/*!
 * operation main
 */
//- (void)main{
//}
@end
