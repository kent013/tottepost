//
//  PhotoSubmitter.h
//  tottepost
//
//  Created by ISHITOYA Kentaro on 11/12/13.
//  Copyright (c) 2011 cocotomo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PhotoSubmitterProtocol.h"
#import "FacebookPhotoSubmitter.h"
#import "FlickrPhotoSubmitter.h"
#import "TwitterPhotoSubmitter.h"
#import "PhotoSubmitterOperation.h"

/*!
 * photo submitter aggregation class
 */
@interface PhotoSubmitterManager : NSObject{
    @protected 
    __strong NSMutableDictionary *submitters_;
    __strong NSMutableArray *supportedTypes_;
    __strong NSOperationQueue *operationQueue_;
}

@property (nonatomic, readonly) NSArray* supportedTypes;
@property (nonatomic, assign) BOOL submitPhotoWithOperations;

- (void) submitPhoto:(UIImage *)photo;
- (void) submitPhoto:(UIImage *)photo comment:(NSString *)comment;

- (void) loadSubmitters;
- (void) setAuthenticationDelegate:(id<PhotoSubmitterAuthenticationDelegate>) delegate;
- (void) setPhotoDelegate:(id<PhotoSubmitterPhotoDelegate>) delegate;
- (id<PhotoSubmitterProtocol>) submitterForType:(PhotoSubmitterType)type;
- (BOOL) didOpenURL: (NSURL *)url;
+ (PhotoSubmitterManager *)getInstance;
+ (id<PhotoSubmitterProtocol>) submitterForType:(PhotoSubmitterType)type;
@end