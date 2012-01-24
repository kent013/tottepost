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

#define PS_FLICKR_API_CHECK_TOKEN @"check_token"
#define PS_FLICKR_API_REQUEST_TOKEN @"request_token"
#define PS_FLICKR_API_GET_TOKEN @"get_token"
#define PS_FLICKR_API_UPLOAD_IMAGE @"upload_image"

#define PS_FLICKR_SETTING_USERNAME @"FlickrUserName"

//-----------------------------------------------------------------------------
//Private Implementations
//-----------------------------------------------------------------------------
@interface FlickrPhotoSubmitter(PrivateImplementation)
- (void) setupInitialState;
- (void) clearCredentials;
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
	}else if([inRequest.sessionInfo isEqualToString: PS_FLICKR_API_UPLOAD_IMAGE]){
        NSString *hash = [self photoForRequest:inRequest];
        [self photoSubmitter:self didSubmitted:hash suceeded:YES message:@"Photo upload succeeded"];
        id<PhotoSubmitterPhotoOperationDelegate> operationDelegate = [self operationDelegateForRequest:inRequest];
        [operationDelegate photoSubmitterDidOperationFinished:YES];
        [self clearRequest:inRequest];
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
    }else{
        NSLog(@"flickr error:%@", inError);
        [self clearCredentials];
        [self.authDelegate photoSubmitter:self didLogout:self.type];
    }
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
    [authRequest_ callAPIMethodWithGET:@"flickr.test.login" arguments:nil];
    [self.authDelegate photoSubmitter:self didLogin:self.type];
    [self.authDelegate photoSubmitter:self didAuthorizationFinished:self.type];
    
}
@end

//-----------------------------------------------------------------------------
//Public Implementations
//-----------------------------------------------------------------------------
@implementation FlickrPhotoSubmitter
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
    OFFlickrAPIRequest *request = [[OFFlickrAPIRequest alloc] initWithAPIContext:flickr_];
    request.delegate = self;
    request.sessionInfo = PS_FLICKR_API_UPLOAD_IMAGE;
    [self addRequest:request];
    
    [request uploadImageStream:[NSInputStream inputStreamWithData:photo.data] suggestedFilename:@"TottePost uploads" MIMEType:@"image/jpeg" arguments:[NSDictionary dictionaryWithObjectsAndKeys:@"0", @"is_public", photo.comment, @"title", nil]];
	
    NSString *hash = photo.md5;
    [self setPhotoHash:hash forRequest:request];
    [self setOperationDelegate:delegate forRequest:request];
    [self photoSubmitter:self willStartUpload:hash];
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
 * albumlist
 */
- (NSArray *)albumList{
    return nil;
}

/*!
 * update album list
 */
- (void)updateAlbumListWithDelegate:(id<PhotoSubmitterDataDelegate>)delegate{
    self.dataDelegate = delegate;
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
 * update username
 */
- (void)updateUsernameWithDelegate:(id<PhotoSubmitterDataDelegate>)delegate{
    self.dataDelegate = delegate;
    authRequest_.sessionInfo = PS_FLICKR_API_CHECK_TOKEN;
    [authRequest_ callAPIMethodWithGET:@"flickr.test.login" arguments:nil];
    //do nothing
}

/*!
 * invoke method as concurrent?
 */
- (BOOL)isConcurrent{
    return YES;
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
