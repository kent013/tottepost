//
//  DropboxPhotoSubmitter.m
//  PhotoSubmitter for Dropbox
//
//  Created by ISHITOYA Kentaro on 11/12/22.
//  Copyright (c) 2011 coctomo. All rights reserved.
//

#import "PhotoSubmitterAPIKey.h"
#import "DropboxPhotoSubmitter.h"
#import "UIImage+Digest.h"
#import "RegexKitLite.h"
#import "PhotoSubmitterManager.h"
#import "UIImage+EXIF.h"

#define PS_DROPBOX_AUTH_URL @"db-"

#define PS_DROPBOX_API_CHECK_TOKEN @"check_token"
#define PS_DROPBOX_API_REQUEST_TOKEN @"request_token"
#define PS_DROPBOX_API_GET_TOKEN @"get_token"
#define PS_DROPBOX_API_UPLOAD_IMAGE @"upload_image"

//-----------------------------------------------------------------------------
//Private Implementations
//-----------------------------------------------------------------------------
@interface DropboxPhotoSubmitter(PrivateImplementation)
- (void) setupInitialState;
- (void) cleanupCache;
@end

#pragma mark - private implementations
@implementation DropboxPhotoSubmitter(PrivateImplementation)
/*!
 * initializer
 */
-(void)setupInitialState{
    [self setSubmitterIsConcurrent:YES 
                      isSequencial:NO 
                     usesOperation:YES 
                   requiresNetwork:YES 
                  isAlbumSupported:YES];
    
    DBSession* dbSession = [[DBSession alloc] initWithAppKey:PHOTO_SUBMITTER_DROPBOX_API_KEY appSecret:PHOTO_SUBMITTER_DROPBOX_API_SECRET root:kDBRootAppFolder];
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

#pragma mark - DBRestClientDelegate methods
#pragma mark - upload file
/*!
 * Dropbox delegate, upload finished
 */
- (void)restClient:(DBRestClient*)client uploadedFile:(NSString*)destPath from:(NSString*)srcPath metadata:(DBMetadata*)metadata{
    NSFileManager *fm = [NSFileManager defaultManager];
    [fm removeItemAtPath:srcPath error:nil];
    [self completeSubmitPhotoWithRequest:client];
}

/*!
 * Dropbox delegate, upload failed
 */
- (void)restClient:(DBRestClient*)client uploadFileFailedWithError:(NSError *)error{
    [self completeSubmitPhotoWithRequest:client andError:error];
}

/*!
 * Dropbox delegate, upload progress
 */
- (void)restClient:(DBRestClient*)client uploadProgress:(CGFloat)progress forFile:(NSString*)destPath from:(NSString*)srcPath{
    NSString *hash = [self photoForRequest:client];
    [self photoSubmitter:self didProgressChanged:hash progress:progress];
}

#pragma mark - load account info
/*!
 * Dropbox delegate, account info loaded
 */
- (void)restClient:(DBRestClient *)client loadedAccountInfo:(DBAccountInfo *)info{
    self.username = info.displayName;    
    [self performSelector:@selector(clearRequest:) withObject:client afterDelay:2.0];
}

/*!
 * when the load account finished
 */
- (void)restClient:(DBRestClient *)client loadAccountInfoFailedWithError:(NSError *)error{
    NSLog(@"%@", error.description);
    [self performSelector:@selector(clearRequest:) withObject:client afterDelay:2.0];
}

#pragma mark - load metadata
/*!
 * when the metadata loaded
 */
- (void)restClient:(DBRestClient *)client loadedMetadata:(DBMetadata *)metadata{
    NSMutableArray *albums = [[NSMutableArray alloc] init];
    for (DBMetadata *m in metadata.contents){
        if(m.isDirectory && m.isDeleted == NO){
            PhotoSubmitterAlbumEntity *album = 
            [[PhotoSubmitterAlbumEntity alloc] initWithId:m.hash name:m.path privacy:@""];
            [albums addObject:album];
        }
    } 
    PhotoSubmitterAlbumEntity *album = 
    [[PhotoSubmitterAlbumEntity alloc] initWithId:@"/" name:@"/" privacy:@""];
    [albums addObject:album];
    
    self.albumList = albums;    
    [self performSelector:@selector(clearRequest:) withObject:client afterDelay:2.0];
}

/*!
 * when the metadata load failed
 */
- (void)restClient:(DBRestClient *)client loadMetadataFailedWithError:(NSError *)error{
    [self performSelector:@selector(clearRequest:) withObject:client afterDelay:2.0];   
}

#pragma mark - create folder
/*!
 * create folder
 */
- (void)restClient:(DBRestClient *)client createdFolder:(DBMetadata *)folder{
    PhotoSubmitterAlbumEntity *album = 
    [[PhotoSubmitterAlbumEntity alloc] initWithId:folder.hash name:folder.path privacy:@""];    
    [self.albumDelegate photoSubmitter:self didAlbumCreated:album suceeded:YES withError:nil];
    [self performSelector:@selector(clearRequest:) withObject:client afterDelay:2.0];
}

/*!
 * create folder failed
 */
- (void)restClient:(DBRestClient *)client createFolderFailedWithError:(NSError *)error{
    [self.albumDelegate photoSubmitter:self didAlbumCreated:nil suceeded:NO withError:error];
    [self performSelector:@selector(clearRequest:) withObject:client afterDelay:2.0];
}
@end

//-----------------------------------------------------------------------------
//Public Implementations
//-----------------------------------------------------------------------------
#pragma mark - public implementations
@implementation DropboxPhotoSubmitter
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
 * login to Dropbox
 */
-(void)onLogin{
    [[DBSession sharedSession] link];
    [self completeLogin];
}

/*!
 * logoff from Dropbox
 */
- (void)onLogout{  
    [[DBSession sharedSession] unlinkAll];
    [self completeLogout];
}

/*!
 * refresh credential
 */
- (void)refreshCredential{
    if([[DBSession sharedSession] isLinked] == NO){
        [[DBSession sharedSession] link];
    }
}

/*!
 * check url is processable
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
    BOOL result = NO;
    if([[DBSession sharedSession] isLinked]){
        [self enable];
        result = YES;
    }else{
        [self.authDelegate photoSubmitter:self didLogout:self.type];
    }
    [self.authDelegate photoSubmitter:self didAuthorizationFinished:self.type];
    return result;
}

/*!
 * is session valid
 */
- (BOOL)isSessionValid{
    return [[DBSession sharedSession] isLinked];
}

#pragma mark - photo
/*!
 * submit photo
 */
- (id)onSubmitPhoto:(PhotoSubmitterImageEntity *)photo andOperationDelegate:(id<PhotoSubmitterPhotoOperationDelegate>)delegate{
    DBRestClient *restClient = 
    [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
    restClient.delegate = self;
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateFormat  = @"yyyyMMddHHmmssSSSS";
    NSString *dir = [NSString stringWithFormat:@"%@/tmp/", NSHomeDirectory()];
    NSString *filename = [NSString stringWithFormat:@"%@.jpg", [df stringFromDate:photo.timestamp]];
    NSString *path = [dir stringByAppendingString:filename];
    photo.path = path;
    
    NSString *toPath = @"/";
    if(self.targetAlbum){
        toPath = self.targetAlbum.name;
    }
    photo.photoHash = path;
    [photo.data writeToFile:path atomically:NO];
    [restClient uploadFile:filename toPath:toPath withParentRev:nil fromPath:path];
    return restClient;
}    

/*!
 * cancel photo upload
 */
- (id)onCancelPhotoSubmit:(PhotoSubmitterImageEntity *)photo{
    DBRestClient *request = (DBRestClient *)[self requestForPhoto:photo.photoHash];
    [request cancelFileUpload:photo.photoHash];
    return request;
}

#pragma mark - album
/*!
 * create album
 */
- (void)createAlbum:(NSString *)title withDelegate:(id<PhotoSubmitterAlbumDelegate>)delegate{
    self.albumDelegate = delegate;
    DBRestClient *restClient = 
    [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
    restClient.delegate = self;
    [restClient createFolder:[NSString stringWithFormat:@"/%@", title]];
    [self addRequest:restClient];
}

/*!
 * update album list
 */
- (void)updateAlbumListWithDelegate:(id<PhotoSubmitterDataDelegate>)delegate{
    self.dataDelegate = delegate;
    DBRestClient *restClient = 
    [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
    restClient.delegate = self;
    [restClient loadMetadata:@"/"];
    [self addRequest:restClient];
}

#pragma mark - username
/*!
 * update username
 */
- (void)updateUsernameWithDelegate:(id<PhotoSubmitterDataDelegate>)delegate{
    self.dataDelegate = delegate;
    if([DBSession sharedSession].isLinked){
        DBRestClient *restClient = 
        [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        restClient.delegate = self;
        [restClient loadAccountInfo];
        [self addRequest:restClient];
    }
    //do nothing
}

#pragma mark - other properties
/*!
 * return type
 */
- (PhotoSubmitterType) type{
    return PhotoSubmitterTypeDropbox;
}

/*!
 * name
 */
- (NSString *)name{
    return @"Dropbox";
}

#pragma mark - DBSessionDelegate methods
/*!
 * authorization failed
 */
- (void)sessionDidReceiveAuthorizationFailure:(DBSession *)session userId:(NSString *)userId{       
    [self completeLoginFailed];
}
@end
