//
//  EvernotePhotoSubmitter.m
//  PhotoSubmitter for Evernote
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

#define PS_EVERNOTE_AUTH_URL @"photosubmitter://auth/evernote"

//-----------------------------------------------------------------------------
//Private Implementations
//-----------------------------------------------------------------------------
@interface EvernotePhotoSubmitter(PrivateImplementation)
- (void) setupInitialState;
- (void) clearCredentials;
@end

@implementation EvernotePhotoSubmitter(PrivateImplementation)
#pragma mark - private implementations
/*!
 * initializer
 */
-(void)setupInitialState{
    [self setSubmitterIsConcurrent:YES 
                      isSequencial:NO 
                     usesOperation:YES 
                   requiresNetwork:YES 
                  isAlbumSupported:YES];
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
    [super clearCredentials];
}
@end

//-----------------------------------------------------------------------------
//Public Implementations
//-----------------------------------------------------------------------------
#pragma mark - public PhotoSubmitter Protocol implementations
@implementation EvernotePhotoSubmitter
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
 * login to Evernote
 */
-(void)onLogin{
    [evernote_ login];
}

/*!
 * logoff from Evernote
 */
- (void)onLogout{  
    [evernote_ logout];
}

/*!
 * refresh credential
 */
- (void)refreshCredential{
    if([evernote_ isSessionValid] == NO){
        [evernote_ refreshCredential];
    }
}

/*!
  * check url is processable
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
    return [evernote_ isSessionValid];
}

#pragma mark - photo
/*!
 * submit photo
 */
- (id)onSubmitPhoto:(PhotoSubmitterImageEntity *)photo andOperationDelegate:(id<PhotoSubmitterPhotoOperationDelegate>)delegate{
    
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
    return request;
    
}    

/*!
 * cancel photo upload
 */
- (id)onCancelPhotoSubmit:(PhotoSubmitterImageEntity *)photo{
    EvernoteRequest *request = (EvernoteRequest *)[self requestForPhoto:photo.photoHash];
    [request abort];
    return request;
}

#pragma mark - album
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
 * update album list
 */
- (void)updateAlbumListWithDelegate:(id<PhotoSubmitterDataDelegate>)delegate{
    self.dataDelegate = delegate;
    EvernoteRequest *request = [evernote_ notebooksWithDelegate:self];
    [self addRequest:request];
}

#pragma mark - username
/*!
 * update username
 */
- (void)updateUsernameWithDelegate:(id<PhotoSubmitterDataDelegate>)delegate{
    self.dataDelegate = delegate;
    EvernoteRequest *request = [evernote_ userWithDelegate:self];
    [self addRequest:request];
}

#pragma mark - other properties
/*!
 * return type
 */
- (PhotoSubmitterType) type{
    return PhotoSubmitterTypeEvernote;
}

/*!
 * name
 */
- (NSString *)name{
    return @"Evernote";
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
        self.albumList = albums;
    }else if([request.method isEqualToString:@"createNotebook"]){
        EDAMNotebook *notebook = (EDAMNotebook *)result;
        PhotoSubmitterAlbumEntity *album = 
        [[PhotoSubmitterAlbumEntity alloc] initWithId:notebook.guid name:notebook.name privacy:@""];
        [self.albumDelegate photoSubmitter:self didAlbumCreated:album suceeded:YES withError:nil];
    }else if([request.method isEqualToString:@"getUser"]){
        EDAMUser *user = (EDAMUser *)result;
        self.username = user.name;
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
    [evernote_ saveCredential]; 
    [self enable];
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
