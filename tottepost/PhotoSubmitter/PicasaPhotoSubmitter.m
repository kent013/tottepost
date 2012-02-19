//
//  PicasaPhotoSubmitter.m
//  PhotoSubmitter for Picasa
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

#define PS_PICASA_KEYCHAIN_NAME @"PSPicasaKeychain"
#define PS_PICASA_SETTING_USERNAME @"PSPicasaUserName"
#define PS_PICASA_SETTING_ALBUMS @"PSPicasaAlbums"
#define PS_PICASA_SETTING_TARGET_ALBUM @"PSPicasaTargetAlbums"

#define PS_PICASA_SCOPE @"https://photos.googleapis.com/data/"
#define PS_PICASA_PROFILE_SCOPE @"https://www.googleapis.com/auth/userinfo.profile"
#define PS_PICASA_ALBUM_DROPBOX @"Drop Box"

//-----------------------------------------------------------------------------
//Private Implementations
//-----------------------------------------------------------------------------
@interface PicasaPhotoSubmitter(PrivateImplementation)
- (void) setupInitialState;
- (void) clearCredentials;
- (void)fetchSelectedAlbum: (GDataEntryPhotoAlbum *)album;
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
#pragma mark - private implementations
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
 * fetch selected album information
 */
- (void)fetchSelectedAlbum: (GDataEntryPhotoAlbum *)album{
    // fetch the photos feed
    NSURL *feedURL = album.feedLink.URL;
    if (feedURL) {
        GDataServiceTicket *ticket;
        ticket = [service_ fetchFeedWithURL:feedURL
                                   delegate:self
                          didFinishSelector:@selector(photosTicket:finishedWithFeed:error:)];
        [self setPhotoHash:album.identifier forRequest:ticket];
        [self addRequest:ticket];
    }
}

#pragma mark - GTMOAuth2ViewControllerTouch delegate
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

#pragma mark - GDataGoogleServicePhoto delegate methods
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
        if(self.targetAlbum != nil){
            [self removeSettingForKey:self.targetAlbum.albumId];
        }
        [self photoSubmitter:self didSubmitted:hash suceeded:NO message:[error localizedDescription]];
        [operationDelegate photoSubmitterDidOperationFinished:NO];
    }
    [self clearRequest:ticket];
}


/*!
 * album list fetch callback
 */
- (void)albumListFetchTicket:(GDataServiceTicket *)ticket
            finishedWithFeed:(GDataFeedPhotoUser *)feed
                       error:(NSError *)error {
    if (error != nil) {
        return;
    }    
    
    photoFeed_ = feed;
    
    NSMutableArray *albums = [[NSMutableArray alloc] init];
    for (GDataEntryPhotoAlbum *a in photoFeed_) {
        PhotoSubmitterAlbumEntity *album = 
        [[PhotoSubmitterAlbumEntity alloc] initWithId:a.identifier name:[a.title stringValue] privacy:a.access];
        [albums addObject:album];
        [self fetchSelectedAlbum:a];
    }
    [self setComplexSetting:albums forKey:PS_PICASA_SETTING_ALBUMS];
    [self.dataDelegate photoSubmitter:self didAlbumUpdated:albums];
    [self clearRequest:ticket];
}

/*!
 * album creation callback
 */
- (void)createAlbumTicket:(GDataServiceTicket *)ticket
        finishedWithEntry:(GDataEntryPhotoAlbum *)entry
                    error:(NSError *)error {
    if(error == nil){
        PhotoSubmitterAlbumEntity *album = 
        [[PhotoSubmitterAlbumEntity alloc] initWithId:entry.identifier name:[entry.title stringValue] privacy:@""];
        [self fetchSelectedAlbum:entry];
        [self.albumDelegate photoSubmitter:self didAlbumCreated:album suceeded:YES withError:nil];
    }else{
        [self.albumDelegate photoSubmitter:self didAlbumCreated:nil suceeded:NO withError:nil];
    }
    [self clearRequest:ticket];    
}

/*!
 * photo list fetch callback
 */
- (void)photosTicket:(GDataServiceTicket *)ticket
    finishedWithFeed:(GDataFeedPhotoAlbum *)feed
               error:(NSError *)error {
    if(error){
        return;
    }
    NSString *albumIdentifier = [self photoForRequest:ticket];
    NSLog(@"%@, %@", feed.uploadLink.URL, feed.uploadLink.URL.absoluteString);
    [self setSetting:feed.uploadLink.URL.absoluteString forKey:albumIdentifier];
    [self clearRequest:ticket];
}
@end

//-----------------------------------------------------------------------------
//Public Implementations
//-----------------------------------------------------------------------------
#pragma mark - public PhotoSubmitter Protocol implementations
@implementation PicasaPhotoSubmitter
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
 * login to Picasa
 */
-(void)login{
    if ([auth_ canAuthorize]) {
        [self setSetting:@"enabled" forKey:PS_PICASA_ENABLED];
        [self.authDelegate photoSubmitter:self didLogin:self.type];
        return;
    }else{
        [self.authDelegate photoSubmitter:self willBeginAuthorization:self.type];
        SEL finishedSel = @selector(viewController:finishedWithAuth:error:);        
        NSString *scope = [GTMOAuth2Authentication scopeWithStrings:PS_PICASA_SCOPE, PS_PICASA_PROFILE_SCOPE, nil];

        GTMOAuth2ViewControllerTouch *viewController = 
        [GTMOAuth2ViewControllerTouch controllerWithScope:scope
                                                 clientID:GOOGLE_SUBMITTER_API_KEY
                                             clientSecret:GOOGLE_SUBMITTER_API_SECRET
                                         keychainItemName:PS_PICASA_KEYCHAIN_NAME
                                                 delegate:self
                                         finishedSelector:finishedSel];
        
        [[[PhotoSubmitterManager sharedInstance].authControllerDelegate requestNavigationControllerToPresentAuthenticationView] pushViewController:viewController animated:YES];
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
 * isEnabled
 */
+ (BOOL)isEnabled{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:PS_PICASA_ENABLED]) {
        return YES;
    }
    return NO;
}

#pragma mark - photo
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
    [newEntry setUploadSlug:hash];
    
    NSString *mimeType = @"image/jpeg";
    [newEntry setPhotoMIMEType:mimeType];
    
    SEL progressSel = @selector(ticket:hasDeliveredByteCount:ofTotalByteCount:);
    [service_ setServiceUploadProgressSelector:progressSel];
    
    NSURL *uploadURL = nil;
    if(self.targetAlbum == nil || [self.targetAlbum.name isEqualToString:PS_PICASA_ALBUM_DROPBOX]){
        uploadURL = [NSURL URLWithString:kGDataGooglePhotosDropBoxUploadURL];
    }else{
        NSString *url = [self settingForKey:self.targetAlbum.albumId];
        if(url != nil){
            uploadURL = [NSURL URLWithString:url];
        }else{
            [self updateAlbumListWithDelegate:nil];
            //this will fail
            uploadURL = [NSURL URLWithString:self.targetAlbum.albumId];
        }
    }
    
    if(delegate.isCancelled){
        return;
    }
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
    NSString *hash = photo.md5;
    GDataServiceTicket *ticket = (GDataServiceTicket *)[self requestForPhoto:hash];
    [ticket cancelTicket];
    
    id<PhotoSubmitterPhotoOperationDelegate> operationDelegate = [self operationDelegateForRequest:ticket];
    [operationDelegate photoSubmitterDidOperationCanceled];
    [self photoSubmitter:self didCanceled:hash];
    [self clearRequest:ticket];
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
 * use NSOperation ?
 */
- (BOOL)useOperation{
    return YES;
}

/*!
 * requires network
 */
- (BOOL)requiresNetwork{
    return YES;
}

#pragma mark - album
/*!
 * is album supported
 */
- (BOOL) isAlbumSupported{
    return YES;
}

/*!
 * create album
 */
- (void)createAlbum:(NSString *)title withDelegate:(id<PhotoSubmitterAlbumDelegate>)delegate{
    self.albumDelegate = delegate;
    if(photoFeed_ == nil){
        NSLog(@"photoFeed is nil, you must call updateAlbumListWithDelegate before creating album. %s", __PRETTY_FUNCTION__)
        ;
        return [self.albumDelegate photoSubmitter:self didAlbumCreated:nil suceeded:NO withError:nil];
    }
    NSString *description = [NSString stringWithFormat:@"Created %@",
                             [NSDate date]];
    
    NSString *access = kGDataPhotoAccessPrivate;
    
    GDataEntryPhotoAlbum *newAlbum = [GDataEntryPhotoAlbum albumEntry];
    [newAlbum setTitleWithString:title];
    [newAlbum setPhotoDescriptionWithString:description];
    [newAlbum setAccess:access];
    
    NSURL *postLink = [photoFeed_ postLink].URL;        
    GDataServiceTicket *ticket = 
    [service_ fetchEntryByInsertingEntry:newAlbum
                              forFeedURL:postLink
                                delegate:self
                       didFinishSelector:@selector(createAlbumTicket:finishedWithEntry:error:)];
    [self addRequest:ticket];
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
    
    [service_ setAuthorizer:auth_];
    
    NSURL *feedURL = 
    [GDataServiceGooglePhotos photoFeedURLForUserID:auth_.userEmail
                                            albumID:nil
                                          albumName:nil
                                            photoID:nil
                                               kind:nil
                                             access:nil];
    GDataServiceTicket *ticket = 
    [service_ fetchFeedWithURL:feedURL
                      delegate:self
             didFinishSelector:@selector(albumListFetchTicket:finishedWithFeed:error:)];
    [self addRequest:ticket];
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

#pragma mark - username
/*!
 * get username
 */
- (NSString *)username{
    return [self settingForKey:PS_PICASA_SETTING_USERNAME];
}

/*!
 * update username
 */
- (void)updateUsernameWithDelegate:(id<PhotoSubmitterDataDelegate>)delegate{
    self.dataDelegate = delegate;
    [self setSetting:auth_.userEmail forKey:PS_PICASA_SETTING_USERNAME];
    [self.dataDelegate photoSubmitter:self didUsernameUpdated:auth_.userEmail];
}

#pragma mark - other properties
/*!
 * return type
 */
- (PhotoSubmitterType) type{
    return PhotoSubmitterTypePicasa;
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
@end
