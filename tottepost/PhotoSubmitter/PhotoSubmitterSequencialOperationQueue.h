//
//  PhotoSubmitterSequencialOperationQueue.h
//  tottepost
//
//  Created by ISHITOYA Kentaro on 12/01/25.
//  Copyright (c) 2012 ISHITOYA Kentaro. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PhotoSubmitterOperation.h"
#import "PhotoSubmitterProtocol.h"
#import "NSMutableArray+QueueAdditions.h"

@protocol PhotoSubmitterSequencialOperationQueueDelegate;

@interface PhotoSubmitterSequencialOperationQueue : NSObject<PhotoSubmitterOperationDelegate>{
    NSMutableArray *queue_;
    PhotoSubmitterType type_;
    id<PhotoSubmitterSequencialOperationQueueDelegate> delegate_;
}
@property (readonly, nonatomic) PhotoSubmitterType type;
@property (readonly, nonatomic) int count;
@property (readonly, nonatomic) int interval;
- (id) initWithPhotoSubmitterType:(PhotoSubmitterType) type andDelegate:(id<PhotoSubmitterSequencialOperationQueueDelegate>)delegate;
- (void) enqueue: (PhotoSubmitterOperation *)operation;
- (PhotoSubmitterOperation *) dequeue;
@end

@protocol PhotoSubmitterSequencialOperationQueueDelegate <NSObject>
- (void) sequencialOperationQueue:(PhotoSubmitterSequencialOperationQueue *)sequencialOperationQueue didEnqueued:(PhotoSubmitterOperation *)operation;
- (void) sequencialOperationQueue:(PhotoSubmitterSequencialOperationQueue *)sequencialOperationQueue didPeeked:(PhotoSubmitterOperation *)operation;
@end
