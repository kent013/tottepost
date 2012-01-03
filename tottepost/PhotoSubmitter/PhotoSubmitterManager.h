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

/*!
 * photo submitter aggregation class
 */
@interface PhotoSubmitterManager : NSObject<CLLocationManagerDelegate>{
    @protected 
    __strong NSMutableDictionary *submitters_;
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