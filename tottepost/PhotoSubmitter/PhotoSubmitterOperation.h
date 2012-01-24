//
//  PhotoSubmitterOperation.h
//  tottepost
//
//  Created by ISHITOYA Kentaro on 11/12/19.
//  Copyright (c) 2011 cocotomo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PhotoSubmitterProtocol.h"

@protocol PhotoSubmitterOperationDelegate;

/*!
 * NSOperation subclass for submitting photo
 */
@interface PhotoSubmitterOperation : NSOperation<NSCoding, PhotoSubmitterPhotoOperationDelegate>{
    BOOL isExecuting;
    BOOL isFinished;
}
@property (strong, nonatomic) id<PhotoSubmitterProtocol> submitter;
@property (strong, nonatomic) PhotoSubmitterImageEntity *photo;
@property (weak, nonatomic) id<PhotoSubmitterOperationDelegate> delegate;

- (id)initWithSubmitter:(id<PhotoSubmitterProtocol>)submitter photo:(PhotoSubmitterImageEntity *)photo;
+ (id)operationWithOperation:(PhotoSubmitterOperation *)operation;
@end

/*!
 * delegate for operation
 */
@protocol PhotoSubmitterOperationDelegate <NSObject>
- (void) photoSubmitterOperation:(PhotoSubmitterOperation *)operation didFinished:(BOOL)suceeeded;
@end