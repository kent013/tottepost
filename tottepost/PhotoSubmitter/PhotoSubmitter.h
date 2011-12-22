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

    /*!
     * an array of id<PhotoSubmitterOperationDelegate>
     */
    __strong NSMutableDictionary *operationDelegates_;
    
    /*!
     * an array of id<PhotoSubmitterPhotoDelegate>
     */
    __strong NSMutableArray *photoDelegates_;
}
//request methods
- (void) addRequest:(NSObject *)request;
- (void) removeRequest:(NSObject *)request;

//operation delegate methods
- (void) setOperationDelegate:(id<PhotoSubmitterOperationDelegate>)operation forRequest:(NSObject *)request;
- (void) removeOperationDelegateForRequest:(NSObject *)request;
- (id<PhotoSubmitterOperationDelegate>) operationDelegateForRequest:(NSObject *)request;

//photo delegate methods
- (void) addPhotoDelegate:(id<PhotoSubmitterPhotoDelegate>)photoDelegate;
- (void)removePhotoDelegate: (id<PhotoSubmitterPhotoDelegate>)photoDelegate;
- (void) photoSubmitter:(id<PhotoSubmitterProtocol>)photoSubmitter willStartUpload:(NSString *)imageHash;
- (void) photoSubmitter:(id<PhotoSubmitterProtocol>)photoSubmitter didSubmitted:(NSString *)imageHash suceeded:(BOOL)suceeded message:(NSString *)message;
- (void) photoSubmitter:(id<PhotoSubmitterProtocol>)photoSubmitter didProgressChanged:(NSString *)imageHash progress:(CGFloat)progress;

//photo hash methods
- (void) setPhotoHash:(NSString *)photoHash forRequest:(NSObject *)request;
- (void) removePhotoForRequest:(NSObject *)request;
- (NSString*) photoForRequest:(NSObject *)request;

//util
- (void) clearRequest: (NSObject *)request;

//submit photo
- (void) submitPhoto:(UIImage *)photo;
- (void) submitPhoto:(UIImage *)photo comment:(NSString *)comment;
- (void) submitPhoto:(UIImage *)photo andOperationDelegate:(id<PhotoSubmitterOperationDelegate>)delegate;
- (void) submitPhoto:(UIImage *)photo comment:(NSString *)comment andDelegate:(id<PhotoSubmitterOperationDelegate>)delegate;

//write setting methods
- (void)setSetting:(id)value forKey:(NSString *)key;
- (id)settingForKey:(NSString *)key;
- (void) removeSettingForKey: (NSString *)key;
- (BOOL) settingExistsForKey: (NSString *)key;
@end
