//
//  EvernotePhotoSubmitter.m
//  tottepost
//
//  Created by Kentaro ISHITOYA on 12/02/07.
//  Copyright (c) 2012 cocotomo. All rights reserved.
//

#import "PhotoSubmitterAPIKey.h"
#import "EvernotePhotoSubmitter.h"
#import "UIImage+Digest.h"
#import "RegexKitLite.h"
#import "PhotoSubmitterManager.h"
#import "UIImage+EXIF.h"

#define PS_EVERNOTE_ENABLED @"PSEvernoteEnabled"
#define PS_EVERNOTE_AUTH_URL @"photosubmitter://auth/evernote"
#define PS_EVERNOTE_SETTING_USERNAME @"EvernoteUserName"
#define PS_EVERNOTE_SETTING_ALBUMS @"EvernoteAlbums"
#define PS_EVERNOTE_SETTING_TARGET_ALBUM @"EvernoteTargetAlbums"

//-----------------------------------------------------------------------------
//Private Implementations
//-----------------------------------------------------------------------------
@interface EvernotePhotoSubmitter(PrivateImplementation)
- (void) setupInitialState;
- (void) clearCredentials;
@end

@implementation EvernotePhotoSubmitter(PrivateImplementation)
#pragma mark -
#pragma mark private implementations
/*!
 * initializer
 */
-(void)setupInitialState{
    evernote_ = 
    [[Evernote alloc] initWithAuthType:EvernoteAuthTypeOAuthConsumer
                           consumerKey:EVERNOTE_SUBMITTER_API_KEY
                        consumerSecret:EVERNOTE_SUBMITTER_API_SECRET
                        callbackScheme:PS_EVERNOTE_AUTH_URL
                            useSandBox:EVERNOTE_SUBMITTER_API_SANDBOX 
                           andDelegate:self];
    [evernote_ loadCredential];
}

/*!
 * clear Evernote access token key
 */
- (void)clearCredentials{
    [evernote_ clearCredential];
    [self removeSettingForKey:PS_EVERNOTE_SETTING_USERNAME];
    [self removeSettingForKey:PS_EVERNOTE_SETTING_ALBUMS];
    [self removeSettingForKey:PS_EVERNOTE_SETTING_TARGET_ALBUM];
}
@end

//-----------------------------------------------------------------------------
//Public Implementations
//-----------------------------------------------------------------------------
@implementation EvernotePhotoSubmitter
@synthesize authDelegate;
@synthesize dataDelegate;
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
 * submit photo with data, comment and delegate
 */
- (void)submitPhoto:(PhotoSubmitterImageEntity *)photo andOperationDelegate:(id<PhotoSubmitterPhotoOperationDelegate>)delegate{
    
    EDAMResource *photoResource = 
    [evernote_ createResourceFromImageData:photo.autoRotatedData andMime:@"image/jpeg"];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateFormat  = @"yyyy/MM/dd HH:mm:ss.SSSS";
    
    NSString *notebookGuid;
    if(self.targetAlbum != nil){
        notebookGuid = self.targetAlbum.albumId;
    }else{
        EDAMNotebook *notebook = [evernote_ notebookNamed:@"tottepost"];
        if(notebook == nil){
            notebook = [evernote_ createNotebookWithTitle:@"tottepost"];
        }
        notebookGuid = notebook.guid;
    }
    
    EvernoteRequest *request = 
      [evernote_ createNoteInNotebook:notebookGuid
                                title:[df stringFromDate:[NSDate date]]
                              content:photo.comment 
                                 tags:nil
                            resources:[NSArray arrayWithObject:photoResource]
                          andDelegate:self];    
    NSString *hash = photo.md5;
    [self addRequest:request];
    [self setPhotoHash:hash forRequest:request];
    [self setOperationDelegate:delegate forRequest:request];
    [self photoSubmitter:self willStartUpload:hash];
    
}    

/*!
 * cancel photo upload
 */
- (void)cancelPhotoSubmit:(PhotoSubmitterImageEntity *)photo{
    NSString *hash = photo.md5;
    EvernoteRequest *request = (EvernoteRequest *)[self requestForPhoto:hash];
    NSLog(@"%@", request.description);
    [request abort];
    
    id<PhotoSubmitterPhotoOperationDelegate> operationDelegate = [self operationDelegateForRequest:request];
    [operationDelegate photoSubmitterDidOperationCanceled];
    [self photoSubmitter:self didCanceled:hash];
    [self clearRequest:request];
}

/*!
 * login to Evernote
 */
-(void)login{
    if ([evernote_ isSessionValid]) {
        [self setSetting:@"enabled" forKey:PS_EVERNOTE_ENABLED];
        [self.authDelegate photoSubmitter:self didLogin:self.type];
        return;
    }else{
        [self.authDelegate photoSubmitter:self willBeginAuthorization:self.type];
        [evernote_ login];
    }
}

/*!
 * logoff from Evernote
 */
- (void)logout{  
    [evernote_ logout];
    [self clearCredentials];
    [self removeSettingForKey:PS_EVERNOTE_ENABLED];
    [self.authDelegate photoSubmitter:self didLogout:self.type];
}

/*!
 * disable
 */
- (void)disable{
    [self removeSettingForKey:PS_EVERNOTE_ENABLED];
    [self.authDelegate photoSubmitter:self didLogout:self.type];
}

/*!
 * check is logined
 */
- (BOOL)isLogined{
    if(self.isEnabled == false){
        return NO;
    }
    if ([evernote_ isSessionValid]) {
        return YES;
    }
    return NO;
}

/*!
 * check is enabled
 */
- (BOOL) isEnabled{
    return [EvernotePhotoSubmitter isEnabled];
}

/*!
 * return type
 */
- (PhotoSubmitterType) type{
    return PhotoSubmitterTypeEvernote;
}

/*!
 * check url is processoble
 */
- (BOOL)isProcessableURL:(NSURL *)url{
    if([url.absoluteString isMatchedByRegex:PS_EVERNOTE_AUTH_URL]){
        return YES;    
    }
    return NO;
}

/*!
 * on open url finished
 */
- (BOOL)didOpenURL:(NSURL *)url{
    [evernote_ handleOpenURL:url];
    BOOL result = NO;
    if([evernote_ isSessionValid]){
        [self setSetting:@"enabled" forKey:PS_EVERNOTE_ENABLED];
        [self.authDelegate photoSubmitter:self didLogin:self.type];
        result = YES;
    }else{
        [self.authDelegate photoSubmitter:self didLogout:self.type];
    }
    [self.authDelegate photoSubmitter:self didAuthorizationFinished:self.type];
    return result;
}

/*!
 * name
 */
- (NSString *)name{
    return @"Evernote";
}

/*!
 * icon image
 */
- (UIImage *)icon{
    return [UIImage imageNamed:@"evernote_32.png"];
}

/*!
 * small icon image
 */
- (UIImage *)smallIcon{
    return [UIImage imageNamed:@"evernote_16.png"];
}

/*!
 * get username
 */
- (NSString *)username{
    return [self settingForKey:PS_EVERNOTE_SETTING_USERNAME];
}

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
    self.albumDelegate = delegate;
    EvernoteRequest *request = 
    [evernote_ createNotebookWithTitle:title andDelegate:self];
    [self addRequest:request];
}

/*!
 * albumlist
 */
- (NSArray *)albumList{
    return [self complexSettingForKey:PS_EVERNOTE_SETTING_ALBUMS];
}

/*!
 * update album list
 */
- (void)updateAlbumListWithDelegate:(id<PhotoSubmitterDataDelegate>)delegate{
    self.dataDelegate = delegate;
    EvernoteRequest *request = [evernote_ notebooksWithDelegate:self];
    [self addRequest:request];
}

/*!
 * selected album
 */
- (PhotoSubmitterAlbumEntity *)targetAlbum{
    return [self complexSettingForKey:PS_EVERNOTE_SETTING_TARGET_ALBUM];
}

/*!
 * save selected album
 */
- (void)setTargetAlbum:(PhotoSubmitterAlbumEntity *)targetAlbum{
    [self setComplexSetting:targetAlbum forKey:PS_EVERNOTE_SETTING_TARGET_ALBUM];
}

/*!
 * update username
 */
- (void)updateUsernameWithDelegate:(id<PhotoSubmitterDataDelegate>)delegate{
    self.dataDelegate = delegate;
    EvernoteRequest *request = [evernote_ userWithDelegate:self];
    [self addRequest:request];
}

/*!
 * invoke method as concurrent?
 */
- (BOOL)isConcurrent{
    return YES;
}

/*!
 * use NSOperation ?
 */
- (BOOL)useOperation{
    return YES;
}

/*!
 * is sequencial? if so, use SequencialQueue
 */
- (BOOL)isSequencial{
    return NO;
}

/*!
 * requires network
 */
- (BOOL)requiresNetwork{
    return YES;
}

/*!
 * isEnabled
 */
+ (BOOL)isEnabled{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:PS_EVERNOTE_ENABLED]) {
        return YES;
    }
    return NO;
}

#pragma mark -
#pragma mark EvernoteRequestDelegate methods
/*!
 * Evernote delegate, upload finished
 */
- (void)request:(EvernoteRequest *)request didLoad:(id)result{
    if([request.method isEqualToString:@"createNote"]){
        NSString *hash = [self photoForRequest:request];
        [self photoSubmitter:self didSubmitted:hash suceeded:YES message:@"Photo upload succeeded"];
        id<PhotoSubmitterPhotoOperationDelegate> operationDelegate = [self operationDelegateForRequest:request];
        [operationDelegate photoSubmitterDidOperationFinished:YES];
    }else if([request.method isEqualToString:@"listNotebooks"]){
        NSArray *as = (NSArray *)result;
        NSMutableArray *albums = [[NSMutableArray alloc] init];
        for(EDAMNotebook *a in as){
            PhotoSubmitterAlbumEntity *album = 
            [[PhotoSubmitterAlbumEntity alloc] initWithId:a.guid name:a.name privacy:@""];
            [albums addObject:album];
        }
        [self setComplexSetting:albums forKey:PS_EVERNOTE_SETTING_ALBUMS];
        [self.dataDelegate photoSubmitter:self didAlbumUpdated:albums];
    }else if([request.method isEqualToString:@"createNotebook"]){
        EDAMNotebook *notebook = (EDAMNotebook *)result;
        PhotoSubmitterAlbumEntity *album = 
        [[PhotoSubmitterAlbumEntity alloc] initWithId:notebook.guid name:notebook.name privacy:@""];
        [self.albumDelegate photoSubmitter:self didAlbumCreated:album suceeded:YES withError:nil];
    }else if([request.method isEqualToString:@"getUser"]){
        EDAMUser *user = (EDAMUser *)result;
        [self setSetting:user.name forKey:PS_EVERNOTE_SETTING_USERNAME];
        [self.dataDelegate photoSubmitter:self didUsernameUpdated:user.name];
    }
    
    [self clearRequest:request];
    NSLog(@"%@", request.method);
}

/*!
 * Evernote delegate, upload failed
 */
- (void)request:(EvernoteRequest *)request didFailWithError:(NSError *)error{
    if([request.method isEqualToString:@"createNotebook"]){
        [self.albumDelegate photoSubmitter:self didAlbumCreated:nil suceeded:NO withError:error];
    }
    if([request.method isEqualToString:@"createNote"] == NO){
        return;
    }
    NSString *hash = [self photoForRequest:request];
    [self photoSubmitter:self didSubmitted:hash suceeded:NO message:[error localizedDescription]];
    id<PhotoSubmitterPhotoOperationDelegate> operationDelegate = [self operationDelegateForRequest:request];
    [operationDelegate photoSubmitterDidOperationFinished:NO];
    [self clearRequest:request];
}

/*!
 * Evernote delegate, failed with exception
 */
- (void)request:(EvernoteRequest *)request didFailWithException:(NSException *)exception{
    if([request.method isEqualToString:@"createNote"] == NO){
        return;
    }
    NSString *hash = [self photoForRequest:request];
    [self photoSubmitter:self didSubmitted:hash suceeded:NO message:exception.description];
    NSLog(@"%s, %@", __PRETTY_FUNCTION__, exception.description);
    id<PhotoSubmitterPhotoOperationDelegate> operationDelegate = [self operationDelegateForRequest:request];
    [operationDelegate photoSubmitterDidOperationFinished:NO];
    [self clearRequest:request];
}

/*!
 * Evernote delegate, upload progress
 */
- (void)request:(EvernoteRequest *)request didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite{
    if([request.method isEqualToString:@"createNote"] == NO){
        return;
    }

    CGFloat progress = (float)totalBytesWritten / (float)totalBytesExpectedToWrite;
    NSString *hash = [self photoForRequest:request];
    [self photoSubmitter:self didProgressChanged:hash progress:progress];
}

#pragma mark - EvernoteSessionDelegate methods
/*!
 * Evernote delegate, account info loaded
 */
- (void)evernoteDidLogin{
    [self setSetting:@"enabled" forKey:PS_EVERNOTE_ENABLED];
    [evernote_ saveCredential]; 
    [self.authDelegate photoSubmitter:self didLogin:self.type];
}

/*!
 * when the load account finished
 */
- (void)evernoteDidNotLogin{
    [self clearCredentials];
    [self.authDelegate photoSubmitter:self didLogout:self.type];
}

/*!
 * logout
 */
- (void)evernoteDidLogout{
    [self clearCredentials];    
}
@end
