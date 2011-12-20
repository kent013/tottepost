//
//  PhotoSubmitterOperation.h
//  tottepost
//
//  Created by ISHITOYA Kentaro on 11/12/19.
//  Copyright (c) 2011 cocotomo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PhotoSubmitterProtocol.h"

/*!
 * NSOperation subclass for submitting photo
 */
@interface PhotoSubmitterOperation : NSOperation<PhotoSubmitterOperationDelegate>{
    BOOL isExecuting;
    BOOL isFinished;
}
@property (strong, nonatomic) id<PhotoSubmitterProtocol> submitter;
@property (strong, nonatomic) UIImage *photo;
@property (strong, nonatomic) NSString *comment;

- (id)initWithSubmitter:(id<PhotoSubmitterProtocol>)submitter photo:(UIImage *)photo comment:(NSString *)comment;
@end
