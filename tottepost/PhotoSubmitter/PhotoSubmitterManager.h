//
//  PhotoSubmitter.h
//  tottepost
//
//  Created by ISHITOYA Kentaro on 11/12/13.
//  Copyright (c) 2011 cocotomo. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <Foundation/Foundation.h>
#import "PhotoSubmitterProtocol.h"
#import "FacebookPhotoSubmitter.h"
#import "FlickrPhotoSubmitter.h"
#import "TwitterPhotoSubmitter.h"
#import "DropboxPhotoSubmitter.h"
#import "EvernotePhotoSubmitter.h"
#import "PicasaPhotoSubmitter.h"
#import "PhotoSubmitterOperation.h"
#import "MixiPhotoSubmitter.h"
#import "FilePhotoSubmitter.h"
#import "FotolifePhotoSubmitter.h"
#import "PhotoSubmitterImageEntity.h"
#import "PhotoSubmitterSequencialOperationQueue.h"

@protocol PhotoSubmitterManagerDelegate;

/*!
 * photo submitter aggregation class
 */
@interface PhotoSubmitterManager : NSObject<CLLocationManagerDelegate, PhotoSubmitterPhotoDelegate, PhotoSubmitterOperationDelegate, PhotoSubmitterSequencialOperationQueueDelegate>{
    @protected 
    __strong NSMutableDictionary *submitters_;
    __strong NSMutableDictionary *operations_;
    __strong NSMutableDictionary *sequencialOperationQueues_;
    __strong NSMutableArray *supportedTypes_;
    __strong NSOperationQueue *operationQueue_;
    __strong NSMutableArray *delegates_;
    __strong CLLocationManager *locationManager_;
    __strong CLLocation *location_;
    BOOL geoTaggingEnabled_;
    BOOL isPausingOperation_;
}

@property (nonatomic, assign) id<PhotoSubmitterAuthControllerDelegate> authControllerDelegate;
@property (nonatomic, readonly) NSArray* supportedTypes;
@property (nonatomic, assign) BOOL submitPhotoWithOperations;
@property (nonatomic, readonly) int enabledSubmitterCount;
@property (nonatomic, readonly) int uploadOperationCount;
@property (nonatomic, assign) BOOL enableGeoTagging;
@property (nonatomic, readonly) CLLocation *location;
@property (nonatomic, readonly) BOOL requiresNetwork;
@property (nonatomic, readonly) BOOL isUploading;
@property (nonatomic, readonly) BOOL isPausingOperation;

- (void) submitPhoto:(PhotoSubmitterImageEntity *)photo;
- (void) loadSubmitters;
- (void) suspend;
- (void) wakeup;
- (void) pause;
- (void) cancel;
- (void) restart;
- (void) setAuthenticationDelegate:(id<PhotoSubmitterAuthenticationDelegate>) delegate;
- (void) setPhotoDelegate:(id<PhotoSubmitterPhotoDelegate>) delegate;
- (id<PhotoSubmitterProtocol>) submitterForType:(PhotoSubmitterType)type;
- (BOOL) didOpenURL: (NSURL *)url;

- (void) addDelegate:(id<PhotoSubmitterManagerDelegate>)delegate;
- (void) removeDelegate:(id<PhotoSubmitterManagerDelegate>)delegate;
- (void) clearDelegate:(id<PhotoSubmitterManagerDelegate>)delegate;

+ (PhotoSubmitterManager *)sharedInstance;
+ (id<PhotoSubmitterProtocol>) submitterForType:(PhotoSubmitterType)type;
@end


@protocol PhotoSubmitterManagerDelegate <NSObject>
- (void) photoSubmitterManager:(PhotoSubmitterManager *)photoSubmitterManager didOperationAdded:(PhotoSubmitterOperation *)operation;
- (void) didUploadCanceled;
@end