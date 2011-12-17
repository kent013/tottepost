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
    NSString *authToken = [defaults objectForKey:@"FlickrOAuthToken"];
    NSString *authTokenSecret = [defaults objectForKey:@"FlickrOAuthTokenSecret"];
    
    if (([authToken length] > 0) && ([authTokenSecret length] > 0)) {
        flickr_.OAuthToken = authToken;
        flickr_.OAuthTokenSecret = authTokenSecret;
    }
}

/*!
 * clear facebook access token key
 */
- (void)clearCredentials{
    flickr_.OAuthToken = nil;
    flickr_.OAuthTokenSecret = nil;  
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"FlickrOAuthToken"];
    [defaults removeObjectForKey:@"FlickrOAuthTokenSecret"];
}

- (void)flickrAPIRequest:(OFFlickrAPIRequest *)inRequest didCompleteWithResponse:(NSDictionary *)inResponseDictionary{
    if ([inRequest.sessionInfo isEqualToString: @"kCheckTokenStep"]) {
		NSLog(@"%@", [inResponseDictionary valueForKeyPath:@"user.username._text"]);
	}
}

- (void)flickrAPIRequest:(OFFlickrAPIRequest *)inRequest didFailWithError:(NSError *)inError{
    
}

- (void)flickrAPIRequest:(OFFlickrAPIRequest *)inRequest imageUploadSentBytes:(NSUInteger)inSentBytes totalBytes:(NSUInteger)inTotalBytes{
    
}

-(void)flickrAPIRequest:(OFFlickrAPIRequest *)inRequest didObtainOAuthRequestToken:(NSString *)inRequestToken secret:(NSString *)inSecret{
    // these two lines are important
    flickr_.OAuthToken = inRequestToken;
    flickr_.OAuthTokenSecret = inSecret;
    
    NSURL *authURL = [flickr_ userAuthorizationURLWithRequestToken:inRequestToken requestedPermission:OFFlickrWritePermission];
    [[UIApplication sharedApplication] openURL:authURL];
}

- (void)flickrAPIRequest:(OFFlickrAPIRequest *)inRequest didObtainOAuthAccessToken:(NSString *)inAccessToken secret:(NSString *)inSecret userFullName:(NSString *)inFullName userName:(NSString *)inUserName userNSID:(NSString *)inNSID{
    flickr_.OAuthToken = inAccessToken;
    flickr_.OAuthTokenSecret = inSecret;  
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:flickr_.OAuthToken forKey:@"FlickrOAuthToken"];
    [defaults setObject:flickr_.OAuthTokenSecret forKey:@"FlickrOAuthTokenSecret"];
    
}
@end

//-----------------------------------------------------------------------------
//Public Implementations
//-----------------------------------------------------------------------------
@implementation FlickrPhotoSubmitter
@synthesize flickr = flickr_;
@synthesize authDelegate;
@synthesize photoDelegate;
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
    NSString *hash = photo.MD5DigestString;
    [self.photoDelegate photoSubmitter:self willStartUpload:hash];
}

/*!
 * login to flickr
 */
-(void)login{  
    OFFlickrAPIRequest *request = [[OFFlickrAPIRequest alloc] initWithAPIContext:flickr_];
    request.delegate = self;
    request.sessionInfo = @"kFetchRequestTokenStep";
    [request fetchOAuthRequestTokenWithCallbackURL:[NSURL URLWithString:@"tottepost://auth"]];
}

/*!
 * logoff from flickr
 */
- (void)logout{  
    [self clearCredentials];
}

/*!
 * check is logined
 */
- (BOOL)isLogined{
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
    NSLog(@"%@", url);
    return YES;
}

/*!
 * on open url finished
 */
- (BOOL)didOpenURL:(NSURL *)url{
    NSString *token = nil;
    NSString *verifier = nil;
    BOOL result = OFExtractOAuthCallback(url, [NSURL URLWithString:@"tottepost://auth"], &token, &verifier);
    
    if (!result) {
        NSLog(@"Cannot obtain token/secret from URL: %@", [url absoluteString]);
        return NO;
    }
    
    
    OFFlickrAPIRequest *request = [[OFFlickrAPIRequest alloc] initWithAPIContext:flickr_];
    request.delegate = self;
    request.sessionInfo = @"kGetAccessTokenStep";
    [request fetchOAuthAccessTokenWithRequestToken:token verifier:verifier];
    return YES;
}

/*!
 * isEnabled
 */
+ (BOOL)isEnabled{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"FBAccessTokenKey"]) {
        return YES;
    }
    return NO;
}
@end
