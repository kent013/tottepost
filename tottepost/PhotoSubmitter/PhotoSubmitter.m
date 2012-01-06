//
//  PhotoSubmitter.m
//  tottepost
//
//  Created by ISHITOYA Kentaro on 11/12/17.
//  Copyright (c) 2011 cocotomo. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <ImageIO/ImageIO.h>
#import "PhotoSubmitter.h"
#import "PhotoSubmitterManager.h"
#import "UIImage+Digest.h"
#import "UIImage+EXIF.h"

//-----------------------------------------------------------------------------
//Private Implementations
//-----------------------------------------------------------------------------
@interface PhotoSubmitter(PrivateImplementation)
@end

@implementation PhotoSubmitter(PrivateImplementation)
@end

//-----------------------------------------------------------------------------
//Public Implementations
//-----------------------------------------------------------------------------

@implementation PhotoSubmitter

/*!
 * initialize
 */
- (id)init{
    self = [super init];
    if(self){
        photos_ = [[NSMutableDictionary alloc] init];
        requests_ = [[NSMutableDictionary alloc] init];
        operationDelegates_ = [[NSMutableDictionary alloc] init];
        photoDelegates_ = [[NSMutableArray alloc] init];
    }
    return self;
}

#pragma mark -
#pragma mark request methods
/*!
 * add request
 */
- (void)addRequest:(NSObject *)request{
    [requests_ setObject:request forKey:[NSNumber numberWithInt:request.hash]];
}

/*!
 * remove request
 */
- (void)removeRequest:(NSObject *)request{
    [requests_ removeObjectForKey:[NSNumber numberWithInt:request.hash]];
}

#pragma mark -
#pragma mark photo delegate methods
/*!
 * add request
 */
- (void)addPhotoDelegate:(id<PhotoSubmitterPhotoDelegate>)photoDelegate{
    [photoDelegates_ addObject:photoDelegate];
}

/*!
 * remove request
 */
- (void)removePhotoDelegate: (id<PhotoSubmitterPhotoDelegate>)photoDelegate{
    [photoDelegates_ removeObject:photoDelegate];
}

/*!
 * call will start upload delegate method
 */
- (void) photoSubmitter:(id<PhotoSubmitterProtocol>)photoSubmitter willStartUpload:(NSString *)imageHash{
    for(id<PhotoSubmitterPhotoDelegate> delegate in photoDelegates_){
        [delegate photoSubmitter:photoSubmitter willStartUpload:imageHash];
    }
}

/*!
 * call did submitted delegate method
 */
- (void) photoSubmitter:(id<PhotoSubmitterProtocol>)photoSubmitter didSubmitted:(NSString *)imageHash suceeded:(BOOL)suceeded message:(NSString *)message{
    for(id<PhotoSubmitterPhotoDelegate> delegate in photoDelegates_){
        [delegate photoSubmitter:photoSubmitter didSubmitted:imageHash suceeded:suceeded message:message];
    }
}

/*!
 * call did progress changed delegate method
 */
- (void) photoSubmitter:(id<PhotoSubmitterProtocol>)photoSubmitter didProgressChanged:(NSString *)imageHash progress:(CGFloat)progress{
    for(id<PhotoSubmitterPhotoDelegate> delegate in photoDelegates_){
        [delegate photoSubmitter:photoSubmitter didProgressChanged:imageHash progress:progress];
    }    
}

#pragma mark -
#pragma mark operation delegates
/*!
 * set operation
 */
- (void)setOperationDelegate:(id<PhotoSubmitterOperationDelegate>)operation forRequest:(NSObject *)request{
    if(operation != nil){
        [operationDelegates_ setObject:operation forKey:[NSNumber numberWithInt:request.hash]];
    }
}

/*!
 * remove operation
 */
- (void)removeOperationDelegateForRequest:(NSObject *)request{
    [operationDelegates_ removeObjectForKey:[NSNumber numberWithInt:request.hash]];
}

/*!
 * operation for request
 */
- (id<PhotoSubmitterOperationDelegate>)operationDelegateForRequest:(NSObject *)request{
    return [operationDelegates_ objectForKey:[NSNumber numberWithInt:request.hash]];
}

#pragma mark -
#pragma mark photo hash methods
/*!
 * set photo hash
 */
- (void)setPhotoHash:(NSString *)photoHash forRequest:(NSObject *)request{
    [photos_ setObject:photoHash forKey:[NSNumber numberWithInt:request.hash]];
}


/*!
 * remove photo hash
 */
- (void)removePhotoForRequest:(NSObject *)request{
    [photos_ removeObjectForKey:[NSNumber numberWithInt:request.hash]];
}

/*!
 * get photo hash
 */
- (NSString *)photoForRequest:(NSObject *)request{
    return [photos_ objectForKey:[NSNumber numberWithInt:request.hash]];
}

#pragma mark -
#pragma mark util methods
/*!
 * clear request data
 */
- (void)clearRequest:(NSObject *)request{
    [self removeRequest:request];
    [self removeOperationDelegateForRequest:request];
    [self removePhotoForRequest:request];
}


/*!
 * preprocess photo
 */
- (UIImage *) photoPreprocess:(UIImage *)photo andComment:(NSString *)comment{
    if([PhotoSubmitterManager getInstance].enableGeoTagging){
        photo = [UIImage imageWithData:[photo geoTaggedDataWithLocation:[PhotoSubmitterManager getInstance].location andComment:comment]];
    }
    return photo;
}
#pragma mark -
#pragma mark submit photo methods
/*!
 * submit photo
 */
- (void)submitPhoto:(UIImage *)photo{
    [self submitPhoto:photo comment:nil andDelegate:nil];
}

/*!
 * submit photo with comment
 */
- (void)submitPhoto:(UIImage *)photo comment:(NSString *)comment{
    [self submitPhoto:photo comment:comment andDelegate:nil];
}

/*!
 * submit photo with operation
 */
- (void)submitPhoto:(UIImage *)photo andOperationDelegate:(id<PhotoSubmitterOperationDelegate>)delegate{
    return [self submitPhoto:photo comment:nil andDelegate:delegate];
}

/*!
 * submit photo with comment and operation
 */
- (void)submitPhoto:(UIImage *)photo comment:(NSString *)comment andDelegate:(id<PhotoSubmitterOperationDelegate>)delegate{
    NSLog(@"Subclasses must implement this method, %@", __PRETTY_FUNCTION__);    
}

/*!
 * write setting to user defaults
 */
- (void)setSetting:(id)value forKey:(NSString *)key{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:value forKey:key];
    [defaults synchronize];
}

/*!
 * read setting from user defaults
 */
- (id)settingForKey:(NSString *)key{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults valueForKey:key];
}
/*!
 * write complex setting to user defaults
 */
- (void)setComplexSetting:(id)value forKey:(NSString *)key{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:value];
    [defaults setValue:data forKey:key];
    [defaults synchronize];
}

/*!
 * read complex setting from user defaults
 */
- (id)complexSettingForKey:(NSString *)key{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [defaults valueForKey:key];
    if(data == nil){
        return nil;
    }
    return [NSKeyedUnarchiver unarchiveObjectWithData:data];
}

/*!
 * remove setting from user defaults
 */
- (void)removeSettingForKey:(NSString *)key{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:key];
}

/*!
 * setting exists
 */
- (BOOL)settingExistsForKey:(NSString *)key{
    return [self settingForKey:key] != nil;
}
@end
