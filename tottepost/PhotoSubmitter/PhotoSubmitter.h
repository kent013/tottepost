//
//  PhotoSubmitter.h
//  tottepost
//
//  Created by ISHITOYA Kentaro on 11/12/17.
//  Copyright (c) 2011 cocotomo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PhotoSubmitterProtocol.h"
#import "PhotoSubmitterOperation.h"

/*!
 * this class manages 
 * image hash <-> request hash, conversion table for asyncronous request
 * and request objects.
 */
@interface PhotoSubmitter : NSObject{
@private
    __strong NSMutableDictionary *photos_;
    __strong NSMutableDictionary *requests_;
    __strong NSMutableDictionary *operations_;
}

- (void) addRequest:(NSObject *)request;
- (void) removeRequest:(NSObject *)request;

- (void) setOperation:(id<PhotoSubmitterOperationDelegate>)operation forRequest:(NSObject *)request;
- (void) removeOperationForRequest:(NSObject *)request;
- (id<PhotoSubmitterOperationDelegate>) operationForRequest:(NSObject *)request;

- (void) setPhotoHash:(NSString *)photoHash forRequest:(NSObject *)request;
- (void) removePhotoForRequest:(NSObject *)request;
- (NSString*) photoForRequest:(NSObject *)request;

- (void) clearRequest: (NSObject *)request;

- (void) submitPhoto:(UIImage *)photo;
- (void) submitPhoto:(UIImage *)photo comment:(NSString *)comment;
- (void) submitPhoto:(UIImage *)photo andOperationDelegate:(id<PhotoSubmitterOperationDelegate>)delegate;
- (void) submitPhoto:(UIImage *)photo comment:(NSString *)comment andDelegate:(id<PhotoSubmitterOperationDelegate>)delegate;
@end
