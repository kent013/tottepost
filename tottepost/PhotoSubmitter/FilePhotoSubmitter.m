//
//  FilePhotoSubmitter.m
//  PhotoSubmitter for Camera Roll
//
//  Created by ISHITOYA Kentaro on 11/12/24.
//  Copyright (c) 2011 cocotomo. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import <ImageIO/ImageIO.h>
#import "FilePhotoSubmitter.h"
#import "PhotoSubmitterAPIKey.h"
#import "NSData+Digest.h"
#import "PhotoSubmitterManager.h"
#import "UIImage+EXIF.h"

#define PS_FILE_ENABLED @"PSFileEnabled"

//-----------------------------------------------------------------------------
//Private Implementations
//-----------------------------------------------------------------------------
@interface FilePhotoSubmitter(PrivateImplementation)
- (void) setupInitialState;
- (void) clearCredentials;
@end

@implementation FilePhotoSubmitter(PrivateImplementation)
#pragma mark - private implementations
/*!
 * initializer
 */
-(void)setupInitialState{
}

/*!
 * clear defaults
 */
- (void)clearCredentials{
    [self removeSettingForKey:PS_FILE_ENABLED];
}
@end

//-----------------------------------------------------------------------------
//Public Implementations
//-----------------------------------------------------------------------------
#pragma mark - public PhotoSubmitter Protocol implementations
@implementation FilePhotoSubmitter
@synthesize authDelegate;
@synthesize dataDelegate;
@synthesize albumDelegate;
/*!
 * initialize
 */
- (id)init{
    self = [super init];
    if (self) {
        [self setupInitialState];
    }
    return self;
}

#pragma mark - authorization
/*!
 * login to file
 */
-(void)login{
    [self setSetting:@"enabled" forKey:PS_FILE_ENABLED];
    [self.authDelegate photoSubmitter:self didLogin:self.type];
}

/*!
 * logoff from file
 */
- (void)logout{  
    [self disable];
}

/*!
 * disable
 */
- (void)disable{
    [self clearCredentials];
    [self.authDelegate photoSubmitter:self didLogout:self.type];
}

/*!
 * check url is processoble, we will not use this method in file
 */
- (BOOL)isProcessableURL:(NSURL *)url{
    return NO;
}

/*!
 * on open url finished, we will not use this method in file
 */
- (BOOL)didOpenURL:(NSURL *)url{
    return NO;
}

/*!
 * check is logined
 */
- (BOOL)isLogined{
    return self.isEnabled;
}

/*!
 * check is enabled
 */
- (BOOL) isEnabled{
    return [FilePhotoSubmitter isEnabled];
}

/*!
 * isEnabled
 */
+ (BOOL)isEnabled{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:PS_FILE_ENABLED]) {
        return YES;
    }
    return NO;
}

#pragma mark - photo
/*!
 * submit photo with data, comment and delegate
 */
- (void)submitPhoto:(PhotoSubmitterImageEntity *)photo andOperationDelegate:(id<PhotoSubmitterPhotoOperationDelegate>)delegate{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *hash = photo.md5;
        ALAssetsLibrary *lib = [[ALAssetsLibrary alloc] init];
        [lib writeImageDataToSavedPhotosAlbum:photo.data
                                     metadata:photo.metadata
                              completionBlock:^(NSURL* url, NSError* error){
                                  [self photoSubmitter:self didProgressChanged:hash progress:0.75];
                                  if(error == nil){
                                      [self photoSubmitter:self didSubmitted:hash suceeded:YES message:@"Photo upload succeeded"];
                                  }else{
                                      [self photoSubmitter:self didSubmitted:hash suceeded:NO message:[error localizedDescription]];
                                  }
                                  id<PhotoSubmitterPhotoOperationDelegate> operationDelegate = [self operationDelegateForRequest:hash];
                                  [operationDelegate photoSubmitterDidOperationFinished:YES];
                                  [self clearRequest:hash];
                              }];
        [self photoSubmitter:self willStartUpload:hash];
        [self photoSubmitter:self didProgressChanged:hash progress:0.25];
        [self setOperationDelegate:delegate forRequest:hash];
    });
}

/*!
 * cancel photo upload
 */
- (void)cancelPhotoSubmit:(PhotoSubmitterImageEntity *)photo{
    //do not cancel
}

/*!
 * invoke method as concurrent?
 */
- (BOOL)isConcurrent{
    return NO;
}

/*!
 * is sequencial? if so, use SequencialQueue
 */
- (BOOL)isSequencial{
    return NO;
}

/*!
 * use NSOperation?
 */
- (BOOL)useOperation{
    return NO;
}

/*!
 * requires network
 */
- (BOOL)requiresNetwork{
    return NO;
}

#pragma mark - albums
/*!
 * is album supported
 */
- (BOOL) isAlbumSupported{
    return NO;
}

/*!
 * create album
 */
- (void)createAlbum:(NSString *)title withDelegate:(id<PhotoSubmitterAlbumDelegate>)delegate{
    //do nothing 
}

/*!
 * albumlist
 */
- (NSArray *)albumList{
    return nil;
}

/*!
 * update album list
 */
- (void)updateAlbumListWithDelegate:(id<PhotoSubmitterDataDelegate>)delegate{
    //do nothing
}

/*!
 * selected album
 */
- (PhotoSubmitterAlbumEntity *)targetAlbum{
    return nil;
}

/*!
 * save selected album
 */
- (void)setTargetAlbum:(PhotoSubmitterAlbumEntity *)targetAlbum{
    //do nothing
}

#pragma mark - username
/*!
 * get username
 */
- (NSString *)username{
    return nil;
}

/*!
 * update username
 */
- (void)updateUsernameWithDelegate:(id<PhotoSubmitterDataDelegate>)delegate{
    //do nothing
}

#pragma mark - other properties
/*!
 * return type
 */
- (PhotoSubmitterType) type{
    return PhotoSubmitterTypeFile;
}

/*!
 * name
 */
- (NSString *)name{
    return @"Camera Roll";
}

/*!
 * icon image
 */
- (UIImage *)icon{
    return [UIImage imageNamed:@"file_32.png"];
}

/*!
 * small icon image
 */
- (UIImage *)smallIcon{
    return [UIImage imageNamed:@"file_16.png"];
}
@end
