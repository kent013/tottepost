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
#import "PhotoSubmitterOperation.h"
#import "FilePhotoSubmitter.h"
#import "PhotoSubmitterImageEntity.h"

/*!
 * photo submitter aggregation class
 */
@interface PhotoSubmitterManager : NSObject<CLLocationManagerDelegate, PhotoSubmitterPhotoDelegate, PhotoSubmitterOperationDelegate>{
    @protected 
    __strong NSMutableDictionary *submitters_;
    __strong NSMutableDictionary *operations_;
    __strong NSMutableArray *supportedTypes_;
    __strong NSOperationQueue *operationQueue_;
    __strong CLLocationManager *locationManager_;
    __strong CLLocation *location_;
    BOOL geoTaggingEnabled_;
}

@property (nonatomic, readonly) NSArray* supportedTypes;
@property (nonatomic, assign) BOOL submitPhotoWithOperations;
@property (nonatomic, readonly) int enabledSubmitterCount;
@property (nonatomic, readonly) int uploadOperationCount;
@property (nonatomic, assign) BOOL enableGeoTagging;
@property (nonatomic, readonly) CLLocation *location;
@property (nonatomic, readonly) BOOL requiresNetwork;

- (void) submitPhoto:(PhotoSubmitterImageEntity *)photo;
- (void) loadSubmitters;
- (void) suspend;
- (void) wakeup;
- (void) restartOperations;
- (void) setAuthenticationDelegate:(id<PhotoSubmitterAuthenticationDelegate>) delegate;
- (void) setPhotoDelegate:(id<PhotoSubmitterPhotoDelegate>) delegate;
- (id<PhotoSubmitterProtocol>) submitterForType:(PhotoSubmitterType)type;
- (BOOL) didOpenURL: (NSURL *)url;
+ (PhotoSubmitterManager *)sharedInstance;
+ (id<PhotoSubmitterProtocol>) submitterForType:(PhotoSubmitterType)type;
@end