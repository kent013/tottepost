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

/*!
 * photo submitter aggregation class
 */
@interface PhotoSubmitter : NSObject{
    @protected 
    __strong NSMutableDictionary *submitters_;
}
- (void) submitPhoto:(UIImage *)photo;
- (void) submitPhoto:(UIImage *)photo comment:(NSString *)comment;

- (void) loadSubmitters;
- (void) setAuthenticationDelegate:(id<PhotoSubmitterAuthenticationDelegate>) delegate;
- (void) setPhotoDelegate:(id<PhotoSubmitterPhotoDelegate>) delegate;
- (id<PhotoSubmitterProtocol>) submitterWithType:(PhotoSubmitterType)type;
- (BOOL) didOpenURL: (NSURL *)url;
+ (PhotoSubmitter *)getInstance;
+ (FacebookPhotoSubmitter *)facebookPhotoSubmitter;
@end