//
//  PhotoSubmitter.h
//  tottepost
//
//  Created by ISHITOYA Kentaro on 11/12/17.
//  Copyright (c) 2011 cocotomo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PhotoSubmitterProtocol.h"

/*!
 * this class manages 
 * image hash <-> request hash, conversion table for asyncronous request
 * and request objects.
 */
@interface PhotoSubmitter : NSObject{
@private
    __strong NSMutableDictionary *photos_;
    __strong NSMutableDictionary *requests_;
}

- (void) addRequest:(NSObject *)request;
- (void) removeRequest:(NSObject *)request;

- (void) setPhotoHash:(NSString *)photoHash forRequest:(NSObject *)request;
- (void) removePhotoForRequest:(NSObject *)request;
- (NSString*) photoForRequest:(NSObject *)request;
@end
