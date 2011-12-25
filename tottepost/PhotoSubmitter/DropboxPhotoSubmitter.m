//
//  DropboxPhotoSubmitter.m
//  tottepost
//
//  Created by ISHITOYA Kentaro on 11/12/22.
//  Copyright (c) 2011 coctomo. All rights reserved.
//

#import "DropboxPhotoSubmitter.h"

#import "PhotoSubmitterAPIKey.h"
#import "DropboxPhotoSubmitter.h"
#import "UIImage+Digest.h"
#import "RegexKitLite.h"
#import "PhotoSubmitterManager.h"
#import "UIImage+GeoTagging.h"

#define PS_DROPBOX_ENABLED @"PSDropboxEnabled"

#define PS_DROPBOX_AUTH_URL @"db-"

#define PS_DROPBOX_API_CHECK_TOKEN @"check_token"
#define PS_DROPBOX_API_REQUEST_TOKEN @"request_token"
#define PS_DROPBOX_API_GET_TOKEN @"get_token"
#define PS_DROPBOX_API_UPLOAD_IMAGE @"upload_image"

#define PS_DROPBOX_SETTING_USERNAME @"DropboxUserName"

//-----------------------------------------------------------------------------
//Private Implementations
//-----------------------------------------------------------------------------
@interface DropboxPhotoSubmitter(PrivateImplementation)
- (void) setupInitialState;
- (void) clearCredentials;
- (void) cleanupCache;
@end

@implementation DropboxPhotoSubmitter(PrivateImplementation)
#pragma mark -
#pragma mark private implementations
/*!
 * initializer
 */
-(void)setupInitialState{
    DBSession* dbSession =
    [[DBSession alloc] initWithAppKey:PHOTO_SUBMITTER_DROPBOX_API_KEY appSecret:PHOTO_SUBMITTER_DROPBOX_API_SECRET root:kDBRootAppFolder];
    dbSession.delegate = self;
    [DBSession setSharedSession:dbSession];
    
    [self cleanupCache];
}

/*!
 * clean up cache
 */
- (void)cleanupCache{
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *dir = [NSString stringWithFormat:@"%@/tmp/", NSHomeDirectory()];
    NSDirectoryEnumerator *enumerator = [manager enumeratorAtPath:dir];
    NSString *file = nil;
    while(file = [enumerator nextObject]){
        if([[file pathExtension] isEqualToString:@"jpg"]){
            NSString *fullpath = [dir stringByAppendingString:file];
            [manager removeItemAtPath:fullpath error:nil];
        }
    }
}

/*!
 * clear Dropbox access token key
 */
- (void)clearCredentials{
    [self removeSettingForKey:PS_DROPBOX_ENABLED];
}

/*!
 * Dropbox delegate, upload finished
 */
- (void)restClient:(DBRestClient*)client uploadedFile:(NSString*)destPath from:(NSString*)srcPath metadata:(DBMetadata*)metadata{
    NSString *hash = [self photoForRequest:client];
    [self photoSubmitter:self didSubmitted:hash suceeded:YES message:@"Photo upload succeeded"];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    [fm removeItemAtPath:srcPath error:nil];
    
    id<PhotoSubmitterOperationDelegate> operationDelegate = [self operationDelegateForRequest:client];
    [operationDelegate photoSubmitterDidOperationFinished];
    
    [self performSelector:@selector(clearRequest:) withObject:client afterDelay:2.0];
}

/*!
 * Dropbox delegate, upload failed
 */
- (void)restClient:(DBRestClient*)client uploadFileFailedWithError:(NSError *)error{
    NSString *hash = [self photoForRequest:client];
    [self photoSubmitter:self didSubmitted:hash suceeded:NO message:[error localizedDescription]];
    id<PhotoSubmitterOperationDelegate> operationDelegate = [self operationDelegateForRequest:client];
    [operationDelegate photoSubmitterDidOperationFinished];
    [self performSelector:@selector(clearRequest:) withObject:client afterDelay:2.0];
}

/*!
 * Dropbox delegate, upload progress
 */
- (void)restClient:(DBRestClient*)client uploadProgress:(CGFloat)progress forFile:(NSString*)destPath from:(NSString*)srcPath{
    NSString *hash = [self photoForRequest:client];
    [self photoSubmitter:self didProgressChanged:hash progress:progress];
}

@end

//-----------------------------------------------------------------------------
//Public Implementations
//-----------------------------------------------------------------------------
@implementation DropboxPhotoSubmitter
@synthesize authDelegate;
@synthesize albumDelegate;
#pragma mark -
#pragma mark public implementations
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

/*!
 * submit photo with comment
 */
- (void)submitPhoto:(UIImage *)photo comment:(NSString *)comment andDelegate:(id<PhotoSubmitterOperationDelegate>)delegate{      
    DBRestClient *restClient = 
    [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
    restClient.delegate = self;

    NSData *image = nil;
    if([PhotoSubmitterManager getInstance].enableGeoTagging){
        image = [photo geoTaggedDataWithLocation:[PhotoSubmitterManager getInstance].location];
    }else{
        image = UIImageJPEGRepresentation(photo, 1.0);
    }
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateFormat  = @"yyyyMMddHHmmssSSSS";
    NSString *dir = [NSString stringWithFormat:@"%@/tmp/", NSHomeDirectory()];
    NSString *filename = [NSString stringWithFormat:@"%@.jpg", [df stringFromDate:[NSDate date]]];
    NSString *path = [dir stringByAppendingString:filename];

    [image writeToFile:path atomically:NO];
    [self addRequest:restClient];
    [self setPhotoHash:path forRequest:restClient];
    [self setOperationDelegate:delegate forRequest:restClient];
    [restClient uploadFile:filename toPath:@"/" withParentRev:nil fromPath:path];
    [self photoSubmitter:self willStartUpload:path];
}    


/*!
 * login to Dropbox
 */
-(void)login{
    if ([[DBSession sharedSession] isLinked]) {
        [self setSetting:@"enabled" forKey:PS_DROPBOX_ENABLED];
        [self.authDelegate photoSubmitter:self didLogin:self.type];
        return;
    }else{
		[[DBSession sharedSession] link];
    }
}

/*!
 * logoff from Dropbox
 */
- (void)logout{  
    [[DBSession sharedSession] unlinkAll];
    [self clearCredentials];
    [self.authDelegate photoSubmitter:self didLogout:self.type];
}

/*!
 * disable
 */
- (void)disable{
    [self removeSettingForKey:PS_DROPBOX_ENABLED];
    [self.authDelegate photoSubmitter:self didLogout:self.type];
}

/*!
 * check is logined
 */
- (BOOL)isLogined{
    if(self.isEnabled == false){
        return NO;
    }
    if ([[DBSession sharedSession] isLinked]) {
        return YES;
    }
    return NO;
}

/*!
 * check is enabled
 */
- (BOOL) isEnabled{
    return [DropboxPhotoSubmitter isEnabled];
}

/*!
 * return type
 */
- (PhotoSubmitterType) type{
    return PhotoSubmitterTypeDropbox;
}

/*!
 * check url is processoble
 */
- (BOOL)isProcessableURL:(NSURL *)url{
    if([url.absoluteString isMatchedByRegex:PS_DROPBOX_AUTH_URL]){
        return YES;    
    }
    return NO;
}

/*!
 * on open url finished
 */
- (BOOL)didOpenURL:(NSURL *)url{
    [[DBSession sharedSession] handleOpenURL:url];
    if([[DBSession sharedSession] isLinked]){
        return YES;
    }
    return NO;
}

/*!
 * name
 */
- (NSString *)name{
    return @"Dropbox";
}

/*!
 * icon image
 */
- (UIImage *)icon{
    return [UIImage imageNamed:@"dropbox_32.png"];
}

/*!
 * small icon image
 */
- (UIImage *)smallIcon{
    return [UIImage imageNamed:@"dropbox_16.png"];
}

/*!
 * get username
 */
- (NSString *)username{
    return [self settingForKey:PS_DROPBOX_SETTING_USERNAME];
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
- (void)updateAlbumListWithDelegate:(id<PhotoSubmitterAlbumDelegate>)delegate{
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

/*!
 * invoke method as concurrent?
 */
- (BOOL)isConcurrent{
    return YES;
}

/*!
 * isEnabled
 */
+ (BOOL)isEnabled{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:PS_DROPBOX_ENABLED]) {
        return YES;
    }
    return NO;
}

#pragma mark -
#pragma mark Dropbox delegate methods
- (void)sessionDidReceiveAuthorizationFailure:(DBSession *)session userId:(NSString *)userId{
    
}
@end
