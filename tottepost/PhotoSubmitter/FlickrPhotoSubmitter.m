//
//  FlickrPhotoSubmitter.m
//  tottepost
//
//  Created by ISHITOYA Kentaro on 11/12/14.
//  Copyright (c) 2011 cocotomo. All rights reserved.
//

#import "PhotoSubmitterAPIKey.h"
#import "FlickrPhotoSubmitter.h"
#import "UIImage+Digest.h"
#import "NSData+Digest.h"
#import "RegexKitLite.h"
#import "UIImage+EXIF.h"
#import "PhotoSubmitterManager.h"

#define PS_FLICKR_ENABLED @"PSFlickrEnabled"

#define PS_FLICKR_AUTH_URL @"photosubmitter://auth/flickr"
#define PS_FLICKR_AUTH_TOKEN @"FlickrOAuthToken"
#define PS_FLICKR_AUTH_TOKEN_SECRET @"FlickrOAuthTokenSecret"

#define PS_FLICKR_API_CHECK_TOKEN @"flickr.test.login"
#define PS_FLICKR_API_REQUEST_TOKEN @"request_token"
#define PS_FLICKR_API_GET_TOKEN @"get_token"
#define PS_FLICKR_API_UPLOAD_IMAGE @"upload_image"
#define PS_FLICKR_API_CREATE_PHOTOSET @"flickr.photosets.create"
#define PS_FLICKR_API_PHOTOSET_LIST @"flickr.photosets.getList"
#define PS_FLICKR_API_ADD_PHOTOSET_PHOTO @"flickr.photosets.addPhoto"
#define PS_FLICKR_API_REMOVE_PHOTOSET_PHOTO @"flickr.photosets.removePhoto"
#define PS_FLICKR_API_RECENTLY_UPLOADED @"flickr.photos.recentlyUpdated"

#define PS_FLICKR_SETTING_USERNAME @"FlickrUserName"
#define PS_FLICKR_SETTING_DUMMY_PHOTO_ID @"FlickrDummyPrimaryPhotoId"
#define PS_FLICKR_SETTING_ALBUM_DUMMY_PHOTO_ID @"FlickerAlbumDummyPhotoId"
#define PS_FLICKR_SETTING_ALBUMS @"FlickrAlbums"
#define PS_FLICKR_SETTING_TARGET_ALBUM @"FlickrTargetAlbums"

//-----------------------------------------------------------------------------
//Private Implementations
//-----------------------------------------------------------------------------
@interface FlickrPhotoSubmitter(PrivateImplementation)
- (void) setupInitialState;
- (void) clearCredentials;
- (void) fetchDummyPrimaryPhoto;
- (void) removeDummyPrimaryPhoto:(NSString*)photoId albumId:(NSString *)albumId;
- (void) addPhotoToPhotoSet:(NSString *)photoId;
- (NSString *) photosetDummyPhotoKey:(NSString*)photosetId;
@end

@implementation FlickrPhotoSubmitter(PrivateImplementation)
#pragma mark -
#pragma mark private implementations
/*!
 * initializer
 */
-(void)setupInitialState{
    flickr_ = [[OFFlickrAPIContext alloc] initWithAPIKey:PHOTO_SUBMITTER_FLICKR_API_KEY sharedSecret:PHOTO_SUBMITTER_FLICKR_API_SECRET];        
    
    NSString *authToken = [self settingForKey:PS_FLICKR_AUTH_TOKEN];
    NSString *authTokenSecret = [self settingForKey:PS_FLICKR_AUTH_TOKEN_SECRET];
    
    if (([authToken length] > 0) && ([authTokenSecret length] > 0)) {
        flickr_.OAuthToken = authToken;
        flickr_.OAuthTokenSecret = authTokenSecret;
    }
}

/*!
 * clear flickr access token key
 */
- (void)clearCredentials{
    flickr_.OAuthToken = nil;
    flickr_.OAuthTokenSecret = nil;  
    [self removeSettingForKey:PS_FLICKR_AUTH_TOKEN];
    [self removeSettingForKey:PS_FLICKR_AUTH_TOKEN_SECRET];
    [self removeSettingForKey:PS_FLICKR_ENABLED];
    [self removeSettingForKey:PS_FLICKR_SETTING_USERNAME];
    [self removeSettingForKey:PS_FLICKR_SETTING_ALBUMS];
    [self removeSettingForKey:PS_FLICKR_SETTING_TARGET_ALBUM];
    [self removeSettingForKey:PS_FLICKR_SETTING_DUMMY_PHOTO_ID];
}

#pragma mark -
#pragma mark flickr delegate methods
/*!
 * on request compleded
 */
- (void)flickrAPIRequest:(OFFlickrAPIRequest *)inRequest didCompleteWithResponse:(NSDictionary *)inResponseDictionary{
    if ([inRequest.sessionInfo isEqualToString: PS_FLICKR_API_CHECK_TOKEN]) {
        NSString *username = [inResponseDictionary valueForKeyPath:@"user.username._text"];
        [self setSetting:username forKey:PS_FLICKR_SETTING_USERNAME];
        [self.dataDelegate photoSubmitter:self didUsernameUpdated:username];
        
    }else if([inRequest.sessionInfo isEqualToString: PS_FLICKR_API_PHOTOSET_LIST]){
        NSDictionary *photosets = [[inResponseDictionary objectForKey:@"photosets"] objectForKey:@"photoset"];
        NSMutableArray *albums = [[NSMutableArray alloc] init];
        for(NSDictionary *photoset in photosets){
            PhotoSubmitterAlbumEntity *album = 
            [[PhotoSubmitterAlbumEntity alloc] initWithId:[photoset objectForKey:@"id"] name:[[photoset objectForKey:@"title"] objectForKey:@"_text"] privacy:@""];
            [albums addObject:album];
        }
        [self setComplexSetting:albums forKey:PS_FLICKR_SETTING_ALBUMS];
        [self.dataDelegate photoSubmitter:self didAlbumUpdated:albums];
        [self clearRequest:inRequest];
        
    }else if([inRequest.sessionInfo isEqualToString: PS_FLICKR_API_CREATE_PHOTOSET]){
        NSDictionary *photoset = [inResponseDictionary objectForKey:@"photoset"];
        PhotoSubmitterAlbumEntity *album = [[PhotoSubmitterAlbumEntity alloc] initWithId:[photoset objectForKey:@"id"] name:[photoset objectForKey:@"id"] privacy:@""];
        [self.albumDelegate photoSubmitter:self didAlbumCreated:album suceeded:YES withError:nil];
        [self clearRequest:inRequest];
        
        [self setSetting:[self settingForKey:PS_FLICKR_SETTING_DUMMY_PHOTO_ID] forKey:[self photosetDummyPhotoKey:album.albumId]];
        
    }else if([inRequest.sessionInfo isEqualToString:PS_FLICKR_API_ADD_PHOTOSET_PHOTO]){
        NSString *albumId = self.targetAlbum.albumId;
        NSString *photoId = [self settingForKey:[self photosetDummyPhotoKey:albumId]];
        if(photoId){
            [self removeDummyPrimaryPhoto:photoId albumId:albumId];
        }
        [self clearRequest:inRequest];
        
    }else if([inRequest.sessionInfo isEqualToString: PS_FLICKR_API_RECENTLY_UPLOADED]){
        NSArray *photos = [[inResponseDictionary objectForKey:@"photos"] objectForKey:@"photo"];
        if(photos.count > 0){
            NSString *photoId = [[photos objectAtIndex:0] objectForKey:@"id"];
            [self setSetting:photoId forKey:PS_FLICKR_SETTING_DUMMY_PHOTO_ID];
        }
        [self clearRequest:inRequest];
        
    }else if([inRequest.sessionInfo isEqualToString: PS_FLICKR_API_REMOVE_PHOTOSET_PHOTO]){
        [self clearRequest:inRequest];
        [self removeSettingForKey:[self photosetDummyPhotoKey:self.targetAlbum.albumId]];
        
	}else if([inRequest.sessionInfo isEqualToString: PS_FLICKR_API_UPLOAD_IMAGE]){
        NSString *hash = [self photoForRequest:inRequest];
        [self photoSubmitter:self didSubmitted:hash suceeded:YES message:@"Photo upload succeeded"];
        id<PhotoSubmitterPhotoOperationDelegate> operationDelegate = [self operationDelegateForRequest:inRequest];
        [operationDelegate photoSubmitterDidOperationFinished:YES];
        
        NSString *photoId = [[inResponseDictionary objectForKey:@"photoid"] objectForKey:@"_text"];
        if([self settingForKey:PS_FLICKR_SETTING_DUMMY_PHOTO_ID] == nil){
            [self setSetting:photoId forKey:PS_FLICKR_SETTING_DUMMY_PHOTO_ID];
        }
        [self clearRequest:inRequest];
        
        [self performSelectorOnMainThread:@selector(addPhotoToPhotoSet:) withObject:photoId waitUntilDone:NO];
    }
}

/*!
 * flickr delegate, request did failed
 */
- (void)flickrAPIRequest:(OFFlickrAPIRequest *)inRequest didFailWithError:(NSError *)inError{
    if([inRequest.sessionInfo isEqualToString: PS_FLICKR_API_UPLOAD_IMAGE]){
        NSString *hash = [self photoForRequest:inRequest];
        [self photoSubmitter:self didSubmitted:hash suceeded:NO message:inError.localizedDescription];
        id<PhotoSubmitterPhotoOperationDelegate> operationDelegate = [self operationDelegateForRequest:inRequest];
        [operationDelegate photoSubmitterDidOperationFinished:NO];   
        [self clearRequest:inRequest];
    }else if([inRequest.sessionInfo isEqualToString:PS_FLICKR_API_ADD_PHOTOSET_PHOTO]){
        [self clearRequest:inRequest];
    }else if([inRequest.sessionInfo isEqualToString:PS_FLICKR_API_CREATE_PHOTOSET]){
        [self.albumDelegate photoSubmitter:self didAlbumCreated:nil suceeded:NO withError:inError];        
        [self clearRequest:inRequest];
    }else if([inRequest.sessionInfo isEqualToString: PS_FLICKR_API_PHOTOSET_LIST]){
        [self clearRequest:inRequest];
    }else if([inRequest.sessionInfo isEqualToString: PS_FLICKR_API_RECENTLY_UPLOADED]){
        [self clearRequest:inRequest];
    }else if([inRequest.sessionInfo isEqualToString: PS_FLICKR_API_REMOVE_PHOTOSET_PHOTO]){
        [self clearRequest:inRequest];
    }else{
        NSLog(@"flickr error:%@", inError);
        [self clearCredentials];
        [self.authDelegate photoSubmitter:self didLogout:self.type];
    }
    NSLog(@"%@, %@, %s", inRequest.sessionInfo, inError.description, __PRETTY_FUNCTION__);
}

/*!
 * flickr delegate, progress
 */
- (void)flickrAPIRequest:(OFFlickrAPIRequest *)inRequest imageUploadSentBytes:(NSUInteger)inSentBytes totalBytes:(NSUInteger)inTotalBytes{
    NSString * hash = [self photoForRequest:inRequest];
    [self photoSubmitter:self didProgressChanged:hash progress:inSentBytes / (float)inTotalBytes];
}

/*!
 * flickr delegate, request oauth
 */
-(void)flickrAPIRequest:(OFFlickrAPIRequest *)inRequest didObtainOAuthRequestToken:(NSString *)inRequestToken secret:(NSString *)inSecret{
    flickr_.OAuthToken = inRequestToken;
    flickr_.OAuthTokenSecret = inSecret;
    
    NSURL *authURL = [flickr_ userAuthorizationURLWithRequestToken:inRequestToken requestedPermission:OFFlickrWritePermission];
    [[UIApplication sharedApplication] openURL:authURL];
}

/*!
 * flickr delegate, request access token
 */
- (void)flickrAPIRequest:(OFFlickrAPIRequest *)inRequest didObtainOAuthAccessToken:(NSString *)inAccessToken secret:(NSString *)inSecret userFullName:(NSString *)inFullName userName:(NSString *)inUserName userNSID:(NSString *)inNSID{
    flickr_.OAuthToken = inAccessToken;
    flickr_.OAuthTokenSecret = inSecret;  
    [self setSetting:flickr_.OAuthToken forKey:PS_FLICKR_AUTH_TOKEN];
    [self setSetting:flickr_.OAuthTokenSecret forKey:PS_FLICKR_AUTH_TOKEN_SECRET];
    [self setSetting:@"enabled" forKey:PS_FLICKR_ENABLED];
    
    authRequest_.sessionInfo = PS_FLICKR_API_CHECK_TOKEN;
    [authRequest_ callAPIMethodWithGET:PS_FLICKR_API_CHECK_TOKEN arguments:nil];
    [self.authDelegate photoSubmitter:self didLogin:self.type];
    [self.authDelegate photoSubmitter:self didAuthorizationFinished:self.type];
    
    //fetch dummy primary photo id to create photoset
    if([self settingForKey:PS_FLICKR_SETTING_DUMMY_PHOTO_ID] == nil){
        [self fetchDummyPrimaryPhoto];
    }
}

/*!
 * add photo to selected photoset 
 */
- (void)addPhotoToPhotoSet:(NSString *)photoId{
    if(self.targetAlbum == nil){
        return;
    }
    
    OFFlickrAPIRequest *request = [[OFFlickrAPIRequest alloc] initWithAPIContext:flickr_];
    request.delegate = self;
    request.sessionInfo = PS_FLICKR_API_ADD_PHOTOSET_PHOTO;
    
    NSDictionary *params = 
    [NSDictionary dictionaryWithObjectsAndKeys:
     self.targetAlbum.albumId, @"photoset_id", 
     photoId, @"photo_id", nil];
    [request callAPIMethodWithPOST:PS_FLICKR_API_ADD_PHOTOSET_PHOTO arguments:params];
    [self addRequest:request];
}

/*!
 * get photo for dummy primary photo
 */
- (void)fetchDummyPrimaryPhoto{
    OFFlickrAPIRequest *request = [[OFFlickrAPIRequest alloc] initWithAPIContext:flickr_];
    request.delegate = self;
    request.sessionInfo = PS_FLICKR_API_RECENTLY_UPLOADED;
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [request callAPIMethodWithGET:PS_FLICKR_API_RECENTLY_UPLOADED arguments:[NSMutableDictionary dictionaryWithObjectsAndKeys:[df stringFromDate:[NSDate dateWithTimeIntervalSince1970:0]], @"min_date", @"1", @"per_page", @"page", @"1", nil]];
    [self addRequest:request];
}

/*!
 * remove primary photo from photoset
 */
- (void)removeDummyPrimaryPhoto:(NSString *)photoId albumId:(NSString *)albumId{
    if(photoId == nil || albumId == nil){
        return;
    }
    OFFlickrAPIRequest *request = [[OFFlickrAPIRequest alloc] initWithAPIContext:flickr_];
    request.delegate = self;
    request.sessionInfo = PS_FLICKR_API_REMOVE_PHOTOSET_PHOTO;
    
    [request callAPIMethodWithPOST:PS_FLICKR_API_REMOVE_PHOTOSET_PHOTO arguments:[NSMutableDictionary dictionaryWithObjectsAndKeys:albumId, @"photoset_id", photoId, @"photo_id", nil]];
    [self addRequest:request];
    
}

/*!
 * get photoset dummy primary photo key
 */
- (NSString *)photosetDummyPhotoKey:(NSString *)photosetId{
    return [NSString stringWithFormat:@"%@%@", PS_FLICKR_SETTING_ALBUM_DUMMY_PHOTO_ID, photosetId];
}
@end

//-----------------------------------------------------------------------------
//Public Implementations
//-----------------------------------------------------------------------------
@implementation FlickrPhotoSubmitter
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
    OFFlickrAPIRequest *request = [[OFFlickrAPIRequest alloc] initWithAPIContext:flickr_];
    request.delegate = self;
    request.sessionInfo = PS_FLICKR_API_UPLOAD_IMAGE;

    if(delegate.isCancelled){
        return;
    }
    [request uploadImageStream:[NSInputStream inputStreamWithData:photo.data] suggestedFilename:@"TottePost uploads" MIMEType:@"image/jpeg" arguments:[NSDictionary dictionaryWithObjectsAndKeys:@"0", @"is_public", photo.comment, @"title", nil]];
    
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
    OFFlickrAPIRequest *request = (OFFlickrAPIRequest *)[self requestForPhoto:hash];
    [request cancel];
    
    id<PhotoSubmitterPhotoOperationDelegate> operationDelegate = [self operationDelegateForRequest:request];
    [operationDelegate photoSubmitterDidOperationCanceled];
    [self photoSubmitter:self didCanceled:hash];
    [self clearRequest:request];
}

/*!
 * login to flickr
 */
-(void)login{
    if([self settingExistsForKey:PS_FLICKR_AUTH_TOKEN]){
        [self setSetting:@"enabled" forKey:PS_FLICKR_ENABLED];
        [self.authDelegate photoSubmitter:self didLogin:self.type];
        return;
    }
    [self.authDelegate photoSubmitter:self willBeginAuthorization:self.type];
    authRequest_ = [[OFFlickrAPIRequest alloc] initWithAPIContext:flickr_];
    authRequest_.delegate = self;
    authRequest_.sessionInfo = PS_FLICKR_API_REQUEST_TOKEN;
    [authRequest_ fetchOAuthRequestTokenWithCallbackURL:[NSURL URLWithString:PS_FLICKR_AUTH_URL]];
}

/*!
 * logoff from flickr
 */
- (void)logout{  
    [self clearCredentials];
    [self.authDelegate photoSubmitter:self didLogout:self.type];
}

/*!
 * disable
 */
- (void)disable{
    [self removeSettingForKey:PS_FLICKR_ENABLED];
    [self.authDelegate photoSubmitter:self didLogout:self.type];
}

/*!
 * check is logined
 */
- (BOOL)isLogined{
    if(self.isEnabled == false){
        return NO;
    }
    if ([self settingForKey:PS_FLICKR_AUTH_TOKEN]) {
        return YES;
    }
    return NO;
}

/*!
 * check is enabled
 */
- (BOOL) isEnabled{
    return [FlickrPhotoSubmitter isEnabled];
}

/*!
 * return type
 */
- (PhotoSubmitterType) type{
    return PhotoSubmitterTypeFlickr;
}

/*!
 * check url is processoble
 */
- (BOOL)isProcessableURL:(NSURL *)url{
    if([url.absoluteString isMatchedByRegex:PS_FLICKR_AUTH_URL]){
        return YES;    
    }
    return NO;
}

/*!
 * on open url finished
 */
- (BOOL)didOpenURL:(NSURL *)url{
    NSString *token = nil;
    NSString *verifier = nil;
    BOOL result = OFExtractOAuthCallback(url, [NSURL URLWithString:PS_FLICKR_AUTH_URL], &token, &verifier);
    
    if (!result) {
        NSLog(@"Cannot obtain token/secret from URL: %@", [url absoluteString]);
        return NO;
    }
    
    authRequest_ = [[OFFlickrAPIRequest alloc] initWithAPIContext:flickr_];
    authRequest_.delegate = self;
    authRequest_.sessionInfo = PS_FLICKR_API_GET_TOKEN;
    [authRequest_ fetchOAuthAccessTokenWithRequestToken:token verifier:verifier];
    return YES;
}

/*!
 * name
 */
- (NSString *)name{
    return @"Flickr";
}

/*!
 * icon image
 */
- (UIImage *)icon{
    return [UIImage imageNamed:@"flickr_32.png"];
}

/*!
 * small icon image
 */
- (UIImage *)smallIcon{
    return [UIImage imageNamed:@"flickr_16.png"];
}

/*!
 * get username
 */
- (NSString *)username{
    return [self settingForKey:PS_FLICKR_SETTING_USERNAME];
}

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
    if([self settingForKey:PS_FLICKR_SETTING_DUMMY_PHOTO_ID] == nil){
        NSLog(@"You needed to post one single photo before create albums.");
    }
    self.albumDelegate = delegate;
    
    OFFlickrAPIRequest *request = [[OFFlickrAPIRequest alloc] initWithAPIContext:flickr_];
    request.delegate = self;
    request.sessionInfo = PS_FLICKR_API_CREATE_PHOTOSET;
    [self addRequest:request];
    NSDictionary *param = 
      [NSDictionary dictionaryWithObjectsAndKeys:
       title, @"title", 
       [self settingForKey: PS_FLICKR_SETTING_DUMMY_PHOTO_ID], @"primary_photo_id",
       nil];
    [request callAPIMethodWithGET:PS_FLICKR_API_CREATE_PHOTOSET arguments:param];
    [self addRequest:request];
}

/*!
 * albumlist
 */
- (NSArray *)albumList{
    return [self complexSettingForKey:PS_FLICKR_SETTING_ALBUMS];
}

/*!
 * update album list
 */
- (void)updateAlbumListWithDelegate:(id<PhotoSubmitterDataDelegate>)delegate{
    self.dataDelegate = delegate;
    
    OFFlickrAPIRequest *request = [[OFFlickrAPIRequest alloc] initWithAPIContext:flickr_];
    request.delegate = self;
    request.sessionInfo = PS_FLICKR_API_PHOTOSET_LIST;
    [self addRequest:request];
    
    [request callAPIMethodWithGET:PS_FLICKR_API_PHOTOSET_LIST arguments:nil];
    
    [self addRequest:request];
}

/*!
 * selected album
 */
- (PhotoSubmitterAlbumEntity *)targetAlbum{
    return [self complexSettingForKey:PS_FLICKR_SETTING_TARGET_ALBUM];
}

/*!
 * save selected album
 */
- (void)setTargetAlbum:(PhotoSubmitterAlbumEntity *)targetAlbum{
    [self setComplexSetting:targetAlbum forKey:PS_FLICKR_SETTING_TARGET_ALBUM];
}

/*!
 * update username
 */
- (void)updateUsernameWithDelegate:(id<PhotoSubmitterDataDelegate>)delegate{
    self.dataDelegate = delegate;
    authRequest_.sessionInfo = PS_FLICKR_API_CHECK_TOKEN;
    [authRequest_ callAPIMethodWithGET:PS_FLICKR_API_CHECK_TOKEN arguments:nil];
    //do nothing
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
    if ([defaults objectForKey:PS_FLICKR_ENABLED]) {
        return YES;
    }
    return NO;
}
@end
