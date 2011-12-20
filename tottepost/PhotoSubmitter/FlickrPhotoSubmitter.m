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
#import "RegexKitLite.h"

#define PS_FLICKR_ENABLED @"PSFlickrEnabled"

#define PS_FLICKR_AUTH_URL @"photosubmitter://auth/flickr"
#define PS_FLICKR_AUTH_TOKEN @"FlickrOAuthToken"
#define PS_FLICKR_AUTH_TOKEN_SECRET @"FlickrOAuthTokenSecret"

#define PS_FLICKR_API_CHECK_TOKEN @"check_token"
#define PS_FLICKR_API_REQUEST_TOKEN @"request_token"
#define PS_FLICKR_API_GET_TOKEN @"get_token"
#define PS_FLICKR_API_UPLOAD_IMAGE @"upload_image"


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
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *authToken = [defaults objectForKey:PS_FLICKR_AUTH_TOKEN];
    NSString *authTokenSecret = [defaults objectForKey:PS_FLICKR_AUTH_TOKEN_SECRET];
    
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
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:PS_FLICKR_AUTH_TOKEN];
    [defaults removeObjectForKey:PS_FLICKR_AUTH_TOKEN_SECRET];
    [defaults removeObjectForKey:PS_FLICKR_ENABLED];
}

#pragma mark -
#pragma mark flickr delegate methods
/*!
 * on request compleded
 */
- (void)flickrAPIRequest:(OFFlickrAPIRequest *)inRequest didCompleteWithResponse:(NSDictionary *)inResponseDictionary{
    if ([inRequest.sessionInfo isEqualToString: PS_FLICKR_API_CHECK_TOKEN]) {
		NSLog(@"%@", [inResponseDictionary valueForKeyPath:@"user.username._text"]);
	}else if([inRequest.sessionInfo isEqualToString: PS_FLICKR_API_UPLOAD_IMAGE]){
        NSString *hash = [self photoForRequest:inRequest];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.photoDelegate photoSubmitter:self didSubmitted:hash suceeded:YES message:@"Photo upload succeeded"];
        });
        [self removeRequest:inRequest];
        [self removePhotoForRequest:inRequest];  
        [self.operationDelegate photoSubmitterDidOperationFinished];      
    }
}

/*!
 * flickr delegate, request did failed
 */
- (void)flickrAPIRequest:(OFFlickrAPIRequest *)inRequest didFailWithError:(NSError *)inError{
    if([inRequest.sessionInfo isEqualToString: PS_FLICKR_API_UPLOAD_IMAGE]){
        NSString *hash = [self photoForRequest:inRequest];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.photoDelegate photoSubmitter:self didSubmitted:hash suceeded:NO message:inError.localizedDescription];
        });
        [self removeRequest:inRequest];
        [self removePhotoForRequest:inRequest];   
        [self.operationDelegate photoSubmitterDidOperationFinished]; 
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
    [self.photoDelegate photoSubmitter:self didProgressChanged:hash progress:inSentBytes / (float)inTotalBytes];
}

/*!
 * flickr delegate, request oauth
 */
-(void)flickrAPIRequest:(OFFlickrAPIRequest *)inRequest didObtainOAuthRequestToken:(NSString *)inRequestToken secret:(NSString *)inSecret{
    // these two lines are important
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
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:flickr_.OAuthToken forKey:PS_FLICKR_AUTH_TOKEN];
    [defaults setObject:flickr_.OAuthTokenSecret forKey:PS_FLICKR_AUTH_TOKEN_SECRET];
    [defaults setObject:@"enabled" forKey:PS_FLICKR_ENABLED];
    
}
@end

//-----------------------------------------------------------------------------
//Public Implementations
//-----------------------------------------------------------------------------
@implementation FlickrPhotoSubmitter
@synthesize flickr = flickr_;
@synthesize authDelegate;
@synthesize photoDelegate;
@synthesize operationDelegate;
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
 * submit photo
 */
- (void)submitPhoto:(UIImage *)photo{
    return [self submitPhoto:photo comment:nil];
}

/*!
 * submit photo with comment
 */
- (void)submitPhoto:(UIImage *)photo comment:(NSString *)comment{
    OFFlickrAPIRequest *request = [[OFFlickrAPIRequest alloc] initWithAPIContext:flickr_];
    request.delegate = self;
    request.sessionInfo = PS_FLICKR_API_UPLOAD_IMAGE;
    [self addRequest:request];
    
    NSData *JPEGData = UIImageJPEGRepresentation(photo, 1.0);
    [request uploadImageStream:[NSInputStream inputStreamWithData:JPEGData] suggestedFilename:@"TottePost uploads" MIMEType:@"image/jpeg" arguments:[NSDictionary dictionaryWithObjectsAndKeys:@"0", @"is_public", comment, @"title", nil]];
	
    NSString *hash = photo.MD5DigestString;
    [self setPhotoHash:hash forRequest:request];
    [self.photoDelegate photoSubmitter:self willStartUpload:hash];
}

/*!
 * login to flickr
 */
-(void)login{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if([defaults objectForKey:PS_FLICKR_AUTH_TOKEN]){
        [defaults setObject:@"enabled" forKey:PS_FLICKR_ENABLED];
        [self.authDelegate photoSubmitter:self didLogin:self.type];
        return;
    }
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
}

/*!
 * disable
 */
- (void)disable{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:PS_FLICKR_ENABLED];
    [self.authDelegate photoSubmitter:self didLogout:self.type];
}

/*!
 * check is logined
 */
- (BOOL)isLogined{
    if([FlickrPhotoSubmitter isEnabled] == false){
        return NO;
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:PS_FLICKR_AUTH_TOKEN]) {
        return YES;
    }
    return NO;
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
