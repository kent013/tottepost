//
//  PhotoSubmitter.m
//  tottepost
//
//  Created by ISHITOYA Kentaro on 11/12/13.
//  Copyright (c) 2011 cocotomo. All rights reserved.
//

#import <objc/runtime.h>
#import <objc/message.h>
#import "PhotoSubmitterManager.h"
#import "PhotoSubmitterFactory.h"
#import "UIImage+EXIF.h"
#import "FBNetworkReachability.h"
#import "RegexKitLite.h"

#define PS_OPERATIONS @"PSOperations"

/*!
 * singleton instance
 */
static PhotoSubmitterManager* TottePostPhotoSubmitterSingletonInstance = nil;

/*!
 * photo submitter supported types
 */
static NSMutableArray* registeredPhotoSubmitterTypes = nil;

//-----------------------------------------------------------------------------
//Private Implementations
//-----------------------------------------------------------------------------
@interface PhotoSubmitterManager(PrivateImplementation)
- (void) setupInitialState;
- (void) addOperation: (PhotoSubmitterOperation *)operation;
- (PhotoSubmitterSequencialOperationQueue *) sequencialOperationQueueForType: (NSString *) type;
- (void) pauseFinished;
- (void) didChangeNetworkReachability:(NSNotification*)notification;
@end

@implementation PhotoSubmitterManager(PrivateImplementation)
/*!
 * initialize
 */
-(void)setupInitialState{
    submitters_ = [[NSMutableDictionary alloc] init];
    operations_ = [[NSMutableDictionary alloc] init];
    delegates_ = [[NSMutableArray alloc] init];
    sequencialOperationQueues_ = [[NSMutableDictionary alloc] init];

    operationQueue_ = [[NSOperationQueue alloc] init];
    operationQueue_.maxConcurrentOperationCount = 6;
    self.submitPhotoWithOperations = NO;
    isPausingOperation_ = NO;
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(didChangeNetworkReachability:)
     name:FBNetworkReachabilityDidChangeNotification
     object:nil];
    if([FBNetworkReachability sharedInstance].connectionMode == FBNetworkReachableNon){
        isConnected_ = NO;
    }else{
        isConnected_ = YES;
    }
    [[FBNetworkReachability sharedInstance] startNotifier];
    
    [self loadSubmitters];
}

/*!
 * get sequenctial operation queue for type
 */
- (PhotoSubmitterSequencialOperationQueue *)sequencialOperationQueueForType:(NSString *)type{
    PhotoSubmitterSequencialOperationQueue *queue = 
        [sequencialOperationQueues_ objectForKey:type];
    if(queue == nil){
        queue = [[PhotoSubmitterSequencialOperationQueue alloc] initWithPhotoSubmitterType:type andDelegate:self];
        [sequencialOperationQueues_ setObject:queue forKey:type];
    }
    return queue;
}

/*!
 * add operation
 */
- (void)addOperation:(PhotoSubmitterOperation *)operation{
    [operation addDelegate: self];
    [operations_ setObject:operation forKey:[NSNumber numberWithInt:operation.hash]];
    
    if(isConnected_){
        if(operation.submitter.isSequencial){
            PhotoSubmitterSequencialOperationQueue *queue = [self sequencialOperationQueueForType:operation.submitter.type];
            [queue enqueue:operation];
        }else{
            [operationQueue_ addOperation:operation];
        }
    }
    for(id<PhotoSubmitterManagerDelegate> delegate in delegates_){
        [delegate photoSubmitterManager:self didOperationAdded:operation];
    }
}

/*!
 * cancel operation finished
 */
- (void)pauseFinished{
    isPausingOperation_ = NO;
}

/*!
 * check for connection
 */
- (void)didChangeNetworkReachability:(NSNotification *)notification
{
    FBNetworkReachability *reachability = (FBNetworkReachability *)[notification object];
    BOOL oldValue = isConnected_;
    isConnected_ = (reachability.connectionMode != FBNetworkReachableNon);
    if(oldValue == NO && isConnected_){
        [self restart];
    }else if(oldValue == YES && isConnected_ == NO){
        [self pause];
    }
}
@end

//-----------------------------------------------------------------------------
//Public Implementations
//-----------------------------------------------------------------------------

@implementation PhotoSubmitterManager
@synthesize loadedSubmitterTypes = loadedSubmitterTypes_;
@synthesize submitPhotoWithOperations;
@synthesize location = location_;
@synthesize isUploading;
@synthesize isPausingOperation = isPausingOperation_;
@synthesize authControllerDelegate;

/*!
 * initializer
 */
- (id)init{
    self = [super init];
    if(self){
        [self setupInitialState];
    }
    return self;
}

/*!
 * get submitter
 */
- (id<PhotoSubmitterProtocol>)submitterForType:(NSString *)type{
    id <PhotoSubmitterProtocol> submitter = [submitters_ objectForKey:type];
    if(submitter){
        return submitter;
    }
    submitter = [PhotoSubmitterFactory createWithType:type];
    if(submitter){
        [submitters_ setObject:submitter forKey:type];
    }
    [submitter addPhotoDelegate:self];
    [submitter addPhotoDelegate:photoDelegate_];
    return submitter;
}

/*!
 * submit photo to social app
 */
- (void)submitPhoto:(PhotoSubmitterImageEntity *)photo{
    if(self.enableGeoTagging){
        photo.location = self.location;
    }
    [photo applyMetadata];
    for(NSNumber *key in submitters_){
        id<PhotoSubmitterProtocol> submitter = [submitters_ objectForKey:key];
        if([submitter isLogined]){
            if(self.submitPhotoWithOperations && submitter.useOperation){
                PhotoSubmitterOperation *operation = [[PhotoSubmitterOperation alloc] initWithSubmitter:submitter photo:photo];
                [self addOperation:operation];
            }else{
                [submitter submitPhoto:photo andOperationDelegate:nil];
            }
        }
    }
}

/*!
 * set authentication delegate to submitters
 */
- (void)setAuthenticationDelegate:(id<PhotoSubmitterAuthenticationDelegate>)delegate{
    for(NSNumber *key in submitters_){
        id<PhotoSubmitterProtocol> submitter = [submitters_ objectForKey:key];
        submitter.authDelegate = delegate;
    }
}

/*!
 * set photo delegate to submitters
 */
- (void)setPhotoDelegate:(id<PhotoSubmitterPhotoDelegate>)delegate{
    photoDelegate_ = delegate;
}

/*!
 * load selected submitters
 */
- (void)loadSubmitters{
    registeredPhotoSubmitterTypes = [[NSMutableArray alloc] init];
    
    int numClasses;
    Class *classes = NULL;
    
    classes = NULL;
    numClasses = objc_getClassList(NULL, 0);
    
    if (numClasses > 0 )
    {
        classes = (__unsafe_unretained Class *)malloc(sizeof(Class) * numClasses);
        numClasses = objc_getClassList(classes, numClasses);
        for (int i = 0; i < numClasses; i++) {
            Class cls = classes[i];
            NSString *className = [NSString stringWithUTF8String:class_getName(cls)];
            if([className isMatchedByRegex:@"^(.+?)PhotoSubmitter$"]){
                id<PhotoSubmitterProtocol> submitter = [[NSClassFromString(className) alloc] init];
                [registeredPhotoSubmitterTypes addObject:submitter.type];
                submitter = nil;
            }
        }
        free(classes);
    }
}

/*!
 * refresh credentials
 */
- (void)refreshCredentials{
    for (NSString *type in [PhotoSubmitterManager registeredPhotoSubmitters]){
        id<PhotoSubmitterProtocol> submitter = [self submitterForType:type];
        if([submitter isEnabled]){
            [submitter refreshCredential];
        }
    }
}

/*!
 * on url loaded
 */
- (BOOL)didOpenURL:(NSURL *)url{
    for(NSNumber *key in submitters_){
        id<PhotoSubmitterProtocol> submitter = [submitters_ objectForKey:key];
        if([submitter isProcessableURL:url]){
            return [submitter didOpenURL:url];
        }
    }
    return NO; 
}

/*!
 * get uploadOperationCount
 */
- (int)uploadOperationCount{
    return [operations_ count];
}

/*!
 * get number of enabled Submitters
 */
- (int)enabledSubmitterCount{
    int i = 0;
    for(NSNumber *key in submitters_){
        id<PhotoSubmitterProtocol> submitter = [submitters_ objectForKey:key];
        if(submitter.isEnabled){
            i++;
        }
    }
    return i;
}

/*!
 * geo tagging enabled
 */
- (BOOL)enableGeoTagging{
    return geoTaggingEnabled_; 
}

/*!
 * check is uploading
 */
- (BOOL)isUploading{
    if(operations_.count != 0){
        for(NSNumber *key in operations_){
            PhotoSubmitterOperation *operation = [operations_ objectForKey:key];
            if(operation.isExecuting && operation.isCancelled == NO && 
               operation.isFailed == NO){
                return YES;
            }
        }
    }
    for(NSNumber *key in sequencialOperationQueues_){
        PhotoSubmitterSequencialOperationQueue *queue = [sequencialOperationQueues_ objectForKey:key];
        if(queue.count != 0){
            
            return YES;
        }
    }
    return NO;
}

/*!
 * set enable geo tagging
 */
- (void)setEnableGeoTagging:(BOOL)enableGeoTagging{
    if(locationManager_ == nil){
        locationManager_ = [[CLLocationManager alloc] init];
        locationManager_.delegate = self;
        locationManager_.desiredAccuracy = kCLLocationAccuracyBest;
        locationManager_.distanceFilter = kCLDistanceFilterNone; 
        if(enableGeoTagging){
            [locationManager_ startUpdatingLocation];
        }
    }else if(enableGeoTagging != geoTaggingEnabled_){
        if(enableGeoTagging){
            [locationManager_ startUpdatingLocation];
        }else{
            [locationManager_ stopUpdatingLocation];
        }
    }
    geoTaggingEnabled_ = enableGeoTagging;
}

/*!
 * location did changed
 */
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation{
    location_ = newLocation;
    //NSLog(@"%@, %@", location_.coordinate.longitude, location_.coordinate.latitude);
}

/*!
 * requires network
 */
- (BOOL)requiresNetwork{
    for(NSNumber *key in submitters_){
        id<PhotoSubmitterProtocol> submitter = [submitters_ objectForKey:key];
        if(submitter.isEnabled && submitter.requiresNetwork){
            return YES;
        }
    }
    return NO;
}

#pragma mark -
#pragma mark PhotoSubmitterPhotoDelegate methods
/*!
 * upload started
 */
- (void)photoSubmitter:(id<PhotoSubmitterProtocol>)photoSubmitter willStartUpload:(NSString *)imageHash{
    //NSLog(@"start");
}

/*!
 * upload finished
 */
- (void)photoSubmitter:(id<PhotoSubmitterProtocol>)photoSubmitter didSubmitted:(NSString *)imageHash suceeded:(BOOL)suceeded message:(NSString *)message{
    //NSLog(@"submitted");
}

/*!
 * progress changed
 */
- (void)photoSubmitter:(id<PhotoSubmitterProtocol>)photoSubmitter didProgressChanged:(NSString *)imageHash progress:(CGFloat)progress{
    //NSLog(@"progress:%f", progress);
}

/*!
 * upload canceled
 */
- (void)photoSubmitter:(id<PhotoSubmitterProtocol>)photoSubmitter didCanceled:(NSString *)imageHash{
    
}

#pragma mark -
#pragma mark operation delegate
/*!
 * operation finished
 */
- (void)photoSubmitterOperation:(PhotoSubmitterOperation *)operation didFinished:(BOOL)suceeeded{
    if(suceeeded){
        [operations_ removeObjectForKey:[NSNumber numberWithInt:operation.hash]];
    }else if(self.isUploading == NO){
        for(id<PhotoSubmitterManagerDelegate> delegate in delegates_){
            [delegate didUploadCanceled];
        }
    }
}

/*!
 * operation canceled
 */
- (void)photoSubmitterOperationDidCanceled:(PhotoSubmitterOperation *)operation{
    if(self.isUploading == NO){
        for(id<PhotoSubmitterManagerDelegate> delegate in delegates_){
            [delegate didUploadCanceled];
        }
    }
}

#pragma mark -
#pragma mark suspend
/*!
 * save operations and suspend
 */
- (void)suspend{
    if(operations_.count == 0){
        return;
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:operations_];
    [defaults setValue:data forKey:PS_OPERATIONS];
    [defaults synchronize];
}

/*!
 * load operations and wakeup
 */
- (void)wakeup{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [defaults valueForKey:PS_OPERATIONS];
    if(data == nil){
        return;
    }
    [defaults removeObjectForKey:PS_OPERATIONS];
    [defaults synchronize];
    NSMutableDictionary *ops = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    for(NSNumber *key in ops){
        PhotoSubmitterOperation *operation = [ops objectForKey:key];
        [self addOperation:operation];
    }
}

/*!
 * pause
 */
- (void) pause{
    if(isPausingOperation_){
        return;
    }
    isPausingOperation_ = YES;
    [operationQueue_ cancelAllOperations];
    for(NSNumber *key in operations_){
        PhotoSubmitterOperation *operation = [operations_ objectForKey:key];
        [operation pause];
    }
    for(NSNumber *key in sequencialOperationQueues_){
        PhotoSubmitterSequencialOperationQueue *queue = [sequencialOperationQueues_ objectForKey:key];
        [queue cancel];
    }
    
    [self performSelector:@selector(pauseFinished) withObject:nil afterDelay:2];
}

/*!
 * cancel
 */
- (void) cancel{
    for(NSNumber *key in sequencialOperationQueues_){
        PhotoSubmitterSequencialOperationQueue *queue = [sequencialOperationQueues_ objectForKey:key];
        [queue cancel];
    }
    [sequencialOperationQueues_ removeAllObjects];
    [operationQueue_ cancelAllOperations];
    [operations_ removeAllObjects];
    for(id<PhotoSubmitterManagerDelegate> delegate in delegates_){
        [delegate didUploadCanceled];
    }
}

/*!
 * restart operations
 */
- (void)restart{
    if(isPausingOperation_){
        return;
    }
    [operationQueue_ cancelAllOperations];
    operationQueue_ = [[NSOperationQueue alloc] init];
    operationQueue_.maxConcurrentOperationCount = 6;
    NSMutableDictionary *ops = operations_;
    operations_ = [[NSMutableDictionary alloc] init];
    for(NSNumber *key in ops){
        PhotoSubmitterOperation *operation = [PhotoSubmitterOperation operationWithOperation:[ops objectForKey:key]];
        [operation resume];
        [self addOperation:operation];
    }
}


#pragma mark -
#pragma mark PhotoSubmitterSequencialOperationQueue delegate
- (void)sequencialOperationQueue:(PhotoSubmitterSequencialOperationQueue *)sequencialOperationQueue didPeeked:(PhotoSubmitterOperation *)operation{    
    if(operation.isCancelled){
        return;
    }
    [operationQueue_ addOperation:operation];
}

#pragma mark -
#pragma mark delegate methods

/*!
 * add delegate
 */
- (void)addDelegate:(id<PhotoSubmitterManagerDelegate>)delegate{
    if([delegates_ containsObject:delegate]){
        return;
    }
    [delegates_ addObject:delegate];
}

/*!
 * remove delegate
 */
- (void)removeDelegate:(id<PhotoSubmitterManagerDelegate>)delegate{
    [delegates_ removeObject:delegate];
}

/*!
 * clear delegate
 */
- (void)clearDelegate:(id<PhotoSubmitterManagerDelegate>)delegate{
    [delegates_ removeAllObjects];
}

#pragma mark -
#pragma mark static methods
/*!
 * singleton method
 */
+ (PhotoSubmitterManager *)sharedInstance{
    if(TottePostPhotoSubmitterSingletonInstance == nil){
        TottePostPhotoSubmitterSingletonInstance = [[PhotoSubmitterManager alloc]init];
    }
    return TottePostPhotoSubmitterSingletonInstance;
}

/*!
 * get submitter
 */
+ (id<PhotoSubmitterProtocol>)submitterForType:(NSString *)type{
    return [[PhotoSubmitterManager sharedInstance] submitterForType:type];
}

/*!
 * photo submitter count
 */
+ (int)registeredPhotoSubmitterCount{
    return registeredPhotoSubmitterTypes.count;
}

/*!
 * get photo submitters
 */
+ (NSArray *)registeredPhotoSubmitters{
    return registeredPhotoSubmitterTypes;
}

@end
