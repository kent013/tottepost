//
//  PicasaPhotoSubmitter.m
//  tottepost
//
//  Created by Kentaro ISHITOYA on 12/02/10.
//  Copyright (c) 2012 cocotomo. All rights reserved.
//

#import "PhotoSubmitterAPIKey.h"
#import "PicasaPhotoSubmitter.h"
#import "PhotoSubmitterManager.h"
#import "UIImage+Digest.h"
#import "UIImage+EXIF.h"
#import "RegexKitLite.h"
#import "GTMOAuth2ViewControllerTouch.h"
#import "GTMHTTPUploadFetcher.h"

#define PS_PICASA_ENABLED @"PSPicasaEnabled"
#define PS_PICASA_AUTH_URL @"photosubmitter://auth/picasa"
//#define PS_PICASA_SCOPE @"https://picasaweb.google.com/data/"
#define  PS_PICASA_SCOPE @"https://photos.googleapis.com/data/"
#define PS_PICASA_KEYCHAIN_NAME @"PSPicasaKeychain"
#define PS_PICASA_SETTING_USERNAME @"PSPicasaUserName"
#define PS_PICASA_SETTING_ALBUMS @"PSPicasaAlbums"
#define PS_PICASA_SETTING_TARGET_ALBUM @"PSPicasaTargetAlbums"

//-----------------------------------------------------------------------------
//Private Implementations
//-----------------------------------------------------------------------------
@interface PicasaPhotoSubmitter(PrivateImplementation)
- (void) setupInitialState;
- (void) clearCredentials;
- (void) viewController:(GTMOAuth2ViewControllerTouch *)viewController
       finishedWithAuth:(GTMOAuth2Authentication *)auth
                  error:(NSError *)error;
- (void)ticket:(GDataServiceTicket *)ticket
hasDeliveredByteCount:(unsigned long long)numberOfBytesRead
ofTotalByteCount:(unsigned long long)dataLength;
- (void)addPhotoTicket:(GDataServiceTicket *)ticket
     finishedWithEntry:(GDataEntryPhoto *)photoEntry
                 error:(NSError *)error;
@end

@implementation PicasaPhotoSubmitter(PrivateImplementation)
#pragma mark -
#pragma mark private implementations
/*!
 * initializer
 */
-(void)setupInitialState{
    GTMOAuth2Authentication *auth = 
    [GTMOAuth2ViewControllerTouch 
     authForGoogleFromKeychainForName:PS_PICASA_KEYCHAIN_NAME
     clientID:GOOGLE_SUBMITTER_API_KEY
     clientSecret:GOOGLE_SUBMITTER_API_SECRET];
    if([auth canAuthorize]){
        auth_ = auth;
    }
    service_ = [[GDataServiceGooglePhotos alloc] init];
    
    [service_ setShouldCacheResponseData:YES];
    [service_ setServiceShouldFollowNextLinks:YES];
    
    //-lObjC staff.
    [GTMHTTPUploadFetcher alloc];
}

/*!
 * clear Picasa credential
 */
- (void)clearCredentials{
    [GTMOAuth2ViewControllerTouch removeAuthFromKeychainForName:PS_PICASA_KEYCHAIN_NAME];
    [self removeSettingForKey:PS_PICASA_SETTING_USERNAME];
    [self removeSettingForKey:PS_PICASA_SETTING_ALBUMS];
    [self removeSettingForKey:PS_PICASA_SETTING_TARGET_ALBUM];
}

/*!
 * on authenticated
 */
- (void)viewController:(GTMOAuth2ViewControllerTouch *)viewController
      finishedWithAuth:(GTMOAuth2Authentication *)auth
                 error:(NSError *)error {
    if (error != nil) {
        NSLog(@"Authentication error: %@", error);
        NSData *responseData = [[error userInfo] objectForKey:@"data"];        
        if ([responseData length] > 0) {
            NSString *str = 
            [[NSString alloc] initWithData:responseData
                                  encoding:NSUTF8StringEncoding];
            NSLog(@"%@", str);
        }
        [self.authDelegate photoSubmitter:self didLogout:self.type];
        [self.authDelegate photoSubmitter:self didAuthorizationFinished:self.type];
        [self clearCredentials];
    } else {
        auth_ = auth;
        [self setSetting:@"enabled" forKey:PS_PICASA_ENABLED];
        [self.authDelegate photoSubmitter:self didLogin:self.type];
        [self.authDelegate photoSubmitter:self didAuthorizationFinished:self.type]; 
    }
}

/*!
 * gdata request delegate, progress
 */
- (void)ticket:(GDataServiceTicket *)ticket
hasDeliveredByteCount:(unsigned long long)numberOfBytesRead
ofTotalByteCount:(unsigned long long)dataLength {
    CGFloat progress = (float)numberOfBytesRead / (float)dataLength;
    NSString *hash = [self photoForRequest:ticket];
    [self photoSubmitter:self didProgressChanged:hash progress:progress];
}

/*!
 * GData delegate add photo completed
 */
- (void)addPhotoTicket:(GDataServiceTicket *)ticket
     finishedWithEntry:(GDataEntryPhoto *)photoEntry
                 error:(NSError *)error {
    
    NSString *hash = [self photoForRequest:ticket];
    id<PhotoSubmitterPhotoOperationDelegate> operationDelegate = [self operationDelegateForRequest:ticket];
    if (error == nil) {        
        [self photoSubmitter:self didSubmitted:hash suceeded:YES message:@"Photo upload succeeded"];
        [operationDelegate photoSubmitterDidOperationFinished:YES];
        
        [self clearRequest:ticket];
    } else {
        [self photoSubmitter:self didSubmitted:hash suceeded:NO message:[error localizedDescription]];
        [operationDelegate photoSubmitterDidOperationFinished:NO];
    }
    [self clearRequest:ticket];
}
@end

//-----------------------------------------------------------------------------
//Public Implementations
//-----------------------------------------------------------------------------
@implementation PicasaPhotoSubmitter
@synthesize authDelegate;
@synthesize dataDelegate;
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
    [service_ setAuthorizer:auth_];
    
    GDataEntryPhoto *newEntry = [GDataEntryPhoto photoEntry];
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateFormat  = @"yyyyMMddHHmmssSSSS";
    [newEntry setTitleWithString:[df stringFromDate:photo.timestamp]];
    [newEntry setPhotoDescriptionWithString:photo.comment];
    [newEntry setTimestamp:[GDataPhotoTimestamp timestampWithDate:photo.timestamp]];
    
    [newEntry setPhotoData:photo.data];
    
    NSString *hash = photo.md5;    
    NSString *mimeType = @"image/jpeg";
    [newEntry setPhotoMIMEType:mimeType];    
    [newEntry setUploadSlug:hash];
    
    SEL progressSel = @selector(ticket:hasDeliveredByteCount:ofTotalByteCount:);
    [service_ setServiceUploadProgressSelector:progressSel];
    
    NSURL *uploadURL = [NSURL URLWithString:kGDataGooglePhotosDropBoxUploadURL];
    GDataServiceTicket *ticket = 
    [service_ fetchEntryByInsertingEntry:newEntry
                              forFeedURL:uploadURL
                                delegate:self
                       didFinishSelector:@selector(addPhotoTicket:finishedWithEntry:error:)];
    [service_ setServiceUploadProgressSelector:nil];
    
    [self addRequest:ticket];
    [self setPhotoHash:hash forRequest:ticket];
    [self setOperationDelegate:delegate forRequest:ticket];
    [self photoSubmitter:self willStartUpload:hash];
}    

/*!
 * cancel photo upload
 */
- (void)cancelPhotoSubmit:(PhotoSubmitterImageEntity *)photo{
}

/*!
 * login to Picasa
 */
-(void)login{
    if ([auth_ canAuthorize]) {
        [self setSetting:@"enabled" forKey:PS_PICASA_ENABLED];
        [self.authDelegate photoSubmitter:self didLogin:self.type];
        return;
    }else{
        [self.authDelegate photoSubmitter:self willBeginAuthorization:self.type];
        /*auth_ = [GTMOAuth2ViewControllerTouch 
                 authForGoogleFromKeychainForName:PS_PICASA_KEYCHAIN_NAME
                 clientID:GOOGLE_SUBMITTER_API_KEY
                 clientSecret:GOOGLE_SUBMITTER_API_SECRET];*/
        SEL finishedSel = @selector(viewController:finishedWithAuth:error:);        
        GTMOAuth2ViewControllerTouch *viewController = 
        [GTMOAuth2ViewControllerTouch controllerWithScope:PS_PICASA_SCOPE
                                                 clientID:GOOGLE_SUBMITTER_API_KEY
                                             clientSecret:GOOGLE_SUBMITTER_API_SECRET
                                         keychainItemName:PS_PICASA_KEYCHAIN_NAME
                                                 delegate:self
                                         finishedSelector:finishedSel];
        
        [[[PhotoSubmitterManager sharedInstance].oAuthControllerDelegate requestNavigationControllerToPresentAuthenticationView] pushViewController:viewController animated:YES];
    }
}

/*!
 * logoff from Picasa
 */
- (void)logout{  
    if ([[auth_ serviceProvider] isEqual:kGTMOAuth2ServiceProviderGoogle]) {
        [GTMOAuth2ViewControllerTouch revokeTokenForGoogleAuthentication:auth_];
    }
    [self clearCredentials];
    [self removeSettingForKey:PS_PICASA_ENABLED];
    [self.authDelegate photoSubmitter:self didLogout:self.type];
}

/*!
 * disable
 */
- (void)disable{
    [self removeSettingForKey:PS_PICASA_ENABLED];
    [self.authDelegate photoSubmitter:self didLogout:self.type];
}

/*!
 * check is logined
 */
- (BOOL)isLogined{
    if(self.isEnabled == false){
        return NO;
    }
    if ([auth_ canAuthorize]) {
        return YES;
    }
    return NO;
}

/*!
 * check is enabled
 */
- (BOOL) isEnabled{
    return [PicasaPhotoSubmitter isEnabled];
}

/*!
 * return type
 */
- (PhotoSubmitterType) type{
    return PhotoSubmitterTypePicasa;
}

/*!
 * check url is processoble
 */
- (BOOL)isProcessableURL:(NSURL *)url{
    //do nothing
    return NO;
}

/*!
 * on open url finished
 */
- (BOOL)didOpenURL:(NSURL *)url{
    //do nothing
    return NO;
}

/*!
 * name
 */
- (NSString *)name{
    return @"Picasa";
}

/*!
 * icon image
 */
- (UIImage *)icon{
    return [UIImage imageNamed:@"picasa_32.png"];
}

/*!
 * small icon image
 */
- (UIImage *)smallIcon{
    return [UIImage imageNamed:@"picasa_16.png"];
}

/*!
 * get username
 */
- (NSString *)username{
    return [self settingForKey:PS_PICASA_SETTING_USERNAME];
}

/*!
 * albumlist
 */
- (NSArray *)albumList{
    return [self complexSettingForKey:PS_PICASA_SETTING_ALBUMS];
}

/*!
 * update album list
 */
- (void)updateAlbumListWithDelegate:(id<PhotoSubmitterDataDelegate>)delegate{
    self.dataDelegate = delegate;
    //PicasaRequest *request = [picasa_ notebooksWithDelegate:self];
    //[self addRequest:request];
}

/*!
 * selected album
 */
- (PhotoSubmitterAlbumEntity *)targetAlbum{
    return [self complexSettingForKey:PS_PICASA_SETTING_TARGET_ALBUM];
}

/*!
 * save selected album
 */
- (void)setTargetAlbum:(PhotoSubmitterAlbumEntity *)targetAlbum{
    [self setComplexSetting:targetAlbum forKey:PS_PICASA_SETTING_TARGET_ALBUM];
}

/*!
 * update username
 */
- (void)updateUsernameWithDelegate:(id<PhotoSubmitterDataDelegate>)delegate{
    self.dataDelegate = delegate;
    //PicasaRequest *request = [picasa_ userWithDelegate:self];
    //[self addRequest:request];
}

/*!
 * invoke method as concurrent?
 */
- (BOOL)isConcurrent{
    return NO;
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
    if ([defaults objectForKey:PS_PICASA_ENABLED]) {
        return YES;
    }
    return NO;
}
@end
