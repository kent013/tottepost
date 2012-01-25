//
//  PhotoSubmitterSequencialOperationQueue.m
//  tottepost
//
//  Created by ISHITOYA Kentaro on 12/01/25.
//  Copyright (c) 2012 cocotomo. All rights reserved.
//

#import "PhotoSubmitterSequencialOperationQueue.h"

#define PS_SEQ_INTERVAL 5

//-----------------------------------------------------------------------------
//Private Implementations
//-----------------------------------------------------------------------------
@interface PhotoSubmitterSequencialOperationQueue(PrivateImplementation)
- (PhotoSubmitterOperation *)peek;
@end

@implementation PhotoSubmitterSequencialOperationQueue(PrivateImplementation)
/*!
 * peek
 */
- (PhotoSubmitterOperation *)peek{
    [self dequeue];
    if(self.count == 0){
        return nil;
    }
    PhotoSubmitterOperation *operation = [queue_ peekHead];
    [delegate_ sequencialOperationQueue:self didPeeked:operation];
    return operation;    
}
@end

//-----------------------------------------------------------------------------
//Public Implementations
//----------------------------------------------------------------------------
@implementation PhotoSubmitterSequencialOperationQueue
@synthesize type;
@synthesize interval;
/*!
 * init with photo submitter type
 */
-(id)initWithPhotoSubmitterType:(PhotoSubmitterType)inType andDelegate:(id<PhotoSubmitterSequencialOperationQueueDelegate>)inDelegate{
    self = [super init];
    if(self){
        queue_ = [[NSMutableArray alloc] init];
        type_ = inType;
        delegate_ = inDelegate;
        interval = PS_SEQ_INTERVAL;
    }
    return self;
}

/*!
 * enqueue
 */
- (void)enqueue:(PhotoSubmitterOperation *)operation{
    [operation addDelegate:self];
    [queue_ enqueue:operation];
    if(queue_.count == 1){
        [delegate_ sequencialOperationQueue:self didPeeked:operation];
    }
}

/*!
 * dequeue
 */
- (PhotoSubmitterOperation *)dequeue{
    PhotoSubmitterOperation *operation = [queue_ dequeue];
    return operation;
}

/*!
 * count
 */
- (int) count{
    return queue_.count;
}

#pragma mark -
#pragma mark operation delegate
/*!
 * if current operation finished, dequeue next operation
 */
- (void)photoSubmitterOperation:(PhotoSubmitterOperation *)operation didFinished:(BOOL)suceeeded{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self performSelector:@selector(peek) withObject:nil afterDelay:interval];
    });
}
@end