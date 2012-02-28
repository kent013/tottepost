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
#import "PhotoSubmitterImageEntity.h"

/*!
 * this class manages 
 * image hash <-> request hash, conversion table for asyncronous request
 * and request objects.
 */
@interface PhotoSubmitter : NSObject<PhotoSubmitterProtocol>{
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
    
    BOOL isConcurrent_;
    BOOL isSequencial_;
    BOOL useOperation_;
    BOOL requiresNetwork_;
    BOOL isAlbumSupported_;
}

- (void) setSubmitterIsConcurrent:(BOOL)isConcurrent 
                     isSequencial:(BOOL)isSequencial 
                    usesOperation:(BOOL)usesOperation
                  requiresNetwork:(BOOL)requiresNetwork 
                 isAlbumSupported:(BOOL)isAlbumSupported;

//request methods
- (void) addRequest:(NSObject *)request;
- (void) removeRequest:(NSObject *)request;

//operation delegate methods
- (void) setOperationDelegate:(id<PhotoSubmitterPhotoOperationDelegate>)operation forRequest:(NSObject *)request;
- (void) removeOperationDelegateForRequest:(NSObject *)request;
- (id<PhotoSubmitterPhotoOperationDelegate>) operationDelegateForRequest:(NSObject *)request;

//photo delegate methods
- (void) addPhotoDelegate:(id<PhotoSubmitterPhotoDelegate>)photoDelegate;
- (void)removePhotoDelegate: (id<PhotoSubmitterPhotoDelegate>)photoDelegate;
- (void) photoSubmitter:(id<PhotoSubmitterProtocol>)photoSubmitter willStartUpload:(NSString *)imageHash;
- (void) photoSubmitter:(id<PhotoSubmitterProtocol>)photoSubmitter didSubmitted:(NSString *)imageHash suceeded:(BOOL)suceeded message:(NSString *)message;
- (void) photoSubmitter:(id<PhotoSubmitterProtocol>)photoSubmitter didProgressChanged:(NSString *)imageHash progress:(CGFloat)progress;
- (void) photoSubmitter:(id<PhotoSubmitterProtocol>)photoSubmitter didCanceled:(NSString *)imageHash;

//photo hash methods
- (void) setPhotoHash:(NSString *)photoHash forRequest:(NSObject *)request;
- (void) removePhotoForRequest:(NSObject *)request;
- (NSString*) photoForRequest:(NSObject *)request;
- (NSObject*) requestForPhoto:(NSString *)photoHash;

//util
- (void) clearRequest: (NSObject *)request;

//submit photo
- (void) submitPhoto:(PhotoSubmitterImageEntity *)photo andOperationDelegate:(id<PhotoSubmitterPhotoOperationDelegate>)delegate;

//setting methods
- (void)setSetting:(id)value forKey:(NSString *)key;
- (id)settingForKey:(NSString *)key;
- (void) removeSettingForKey: (NSString *)key;
- (BOOL) settingExistsForKey: (NSString *)key;
- (void)setComplexSetting:(id)value forKey:(NSString *)key;
- (id)complexSettingForKey:(NSString *)key;

//secure setting methods
- (void)setSecureSetting:(id)value forKey:(NSString *)key;
- (id)secureSettingForKey:(NSString *)key;
- (void) removeSecureSettingForKey: (NSString *)key;
- (BOOL) secureSettingExistsForKey: (NSString *)key;
@end
