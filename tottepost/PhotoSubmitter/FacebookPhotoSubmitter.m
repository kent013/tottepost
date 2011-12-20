//
//  FacebookPhotoSubmitter.m
//  tottepost
//
//  Created by ISHITOYA Kentaro on 11/12/13.
//  Copyright (c) 2011 cocotomo. All rights reserved.
//

#import "PhotoSubmitterAPIKey.h"
#import "FacebookPhotoSubmitter.h"
#import "UIImage+Digest.h"
#import "RegexKitLite.h"

#define PS_FACEBOOK_ENABLED @"PSFacebookEnabled"
#define PS_FACEBOOK_AUTH_TOKEN @"FBAccessTokenKey"
#define PS_FACEBOOK_AUTH_EXPIRATION_DATE @"FBExpirationDateKey"

//-----------------------------------------------------------------------------
//Private Implementations
//-----------------------------------------------------------------------------
@interface FacebookPhotoSubmitter(PrivateImplementation)
- (void) setupInitialState;
- (void) clearCredentials;
@end

@implementation FacebookPhotoSubmitter(PrivateImplementation)
#pragma mark -
#pragma mark private implementations
/*!
 * initializer
 */
-(void)setupInitialState{
    facebook_ = [[Facebook alloc] initWithAppId:PHOTO_SUBMITTER_FACEBOOK_API_ID andDelegate:self];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:PS_FACEBOOK_AUTH_TOKEN] 
        && [defaults objectForKey:PS_FACEBOOK_AUTH_EXPIRATION_DATE]) {
        facebook_.accessToken = [defaults objectForKey:PS_FACEBOOK_AUTH_TOKEN];
        facebook_.expirationDate = [defaults objectForKey:PS_FACEBOOK_AUTH_EXPIRATION_DATE];
    }
}

/*!
 * clear facebook access token key
 */
- (void)clearCredentials{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:PS_FACEBOOK_AUTH_TOKEN]) {
        [defaults removeObjectForKey:PS_FACEBOOK_AUTH_TOKEN];
        [defaults removeObjectForKey:PS_FACEBOOK_AUTH_EXPIRATION_DATE];
        [defaults synchronize];
    } 
}

#pragma mark -
#pragma mark facebook delegates
/*!
 * facebook delegate, did login suceeded
 */
- (void)fbDidLogin {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[facebook_ accessToken] forKey:PS_FACEBOOK_AUTH_TOKEN];
    [defaults setObject:[facebook_ expirationDate] forKey:PS_FACEBOOK_AUTH_EXPIRATION_DATE];
    [defaults setObject:@"enabled" forKey:PS_FACEBOOK_ENABLED];
    [defaults synchronize];
    [self.authDelegate photoSubmitter:self didLogin:self.type];
}

/*!
 * facebook delegate, if not login
 */
-(void)fbDidNotLogin:(BOOL)cancelled {
    [self clearCredentials];
    [self.authDelegate photoSubmitter:self didLogout:self.type];
}

/*!
 * facebook delegate, if logout
 */
- (void) fbDidLogout {
    [self clearCredentials];
    [self.authDelegate photoSubmitter:self didLogout:self.type];
}

/*!
 * facebook request delegate, did receive response
 */
- (void)request:(FBRequest *)request didReceiveResponse:(NSURLResponse *)response {
};

/*!
 * facebook request delegate, did load
 */
- (void)request:(FBRequest *)request didLoad:(id)result {
	if ([result isKindOfClass:[NSArray class]]) {
		result = [result objectAtIndex:0];
	}
    NSString *hash = [self photoForRequest:request];
	if ([result objectForKey:@"owner"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.photoDelegate photoSubmitter:self didSubmitted:hash suceeded:YES message:@"Photo upload succeeded"];
        });
	} else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.photoDelegate photoSubmitter:self didSubmitted:hash suceeded:NO message:[result objectForKey:@"name"]];
        });
	}
    [self.operationDelegate photoSubmitterDidOperationFinished];
    [self removePhotoForRequest:request];
};

/*!
 * facebook request delegate, did fail
 */
- (void)request:(FBRequest *)request didFailWithError:(NSError *)error {
    NSString *hash = [self photoForRequest:request];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.photoDelegate photoSubmitter:self didSubmitted:hash suceeded:NO message:[error localizedDescription]];
    });
    [self.operationDelegate photoSubmitterDidOperationFinished];
    [self removePhotoForRequest:request];
};

/*!
 * facebook request delegate, upload progress
 */
- (void)request:(FBRequest *)request didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite{
    CGFloat progress = (float)totalBytesWritten / (float)totalBytesExpectedToWrite;
    NSString *hash = [self photoForRequest:request];
    [self.photoDelegate photoSubmitter:self didProgressChanged:hash progress:progress];
}
@end

//-----------------------------------------------------------------------------
//Public Implementations
//-----------------------------------------------------------------------------
@implementation FacebookPhotoSubmitter
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
    NSMutableDictionary *params = 
      [NSMutableDictionary dictionaryWithObjectsAndKeys: 
       photo, @"picture", 
       comment, @"caption",
       nil];
    FBRequest *request =
      [facebook_ requestWithMethodName:@"photos.upload"
                             andParams:params
                         andHttpMethod:@"POST"
                           andDelegate:self];
    NSString *hash = photo.MD5DigestString;
    [self setPhotoHash:hash forRequest:request];
    [self.photoDelegate photoSubmitter:self willStartUpload:hash];
}

/*!
 * login to facebook
 */
-(void)login{
    if (![facebook_ isSessionValid]) {
        NSArray *permissions = 
        [NSArray arrayWithObjects:@"publish_stream", @"offline_access", nil];
        [facebook_ authorize:permissions];
    }else{
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:@"enabled" forKey:PS_FACEBOOK_ENABLED];
        [self.authDelegate photoSubmitter:self didLogin:self.type];
    }
}

/*!
 * logoff from facebook
 */
- (void)logout{
    [facebook_ logout:self];   
    [self clearCredentials];
}

/*!
 * disable
 */
- (void)disable{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:PS_FACEBOOK_ENABLED];
    [self.authDelegate photoSubmitter:self didLogout:self.type];
}

/*!
 * check is logined
 */
- (BOOL)isLogined{
    if([FacebookPhotoSubmitter isEnabled] == false){
        return NO;
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:PS_FACEBOOK_AUTH_TOKEN]) {
        return YES;
    }
    return NO;
}

/*!
 * return type
 */
- (PhotoSubmitterType) type{
    return PhotoSubmitterTypeFacebook;
}

/*!
 * check url is processoble
 */
- (BOOL)isProcessableURL:(NSURL *)url{
    if([url.absoluteString isMatchedByRegex:@"^fb[0-9]+://authorize/"]){
        return YES;
    }
    return NO;
}

/*!
 * on open url finished
 */
- (BOOL)didOpenURL:(NSURL *)url{
    return [facebook_ handleOpenURL:url];
}

/*!
 * name
 */
- (NSString *)name{
    return @"Facebook";
}

/*!
 * icon image
 */
- (UIImage *)icon{
    return [UIImage imageNamed:@"facebook_32.png"];
}

/*!
 * small icon image
 */
- (UIImage *)smallIcon{
    return [UIImage imageNamed:@"facebook_16.png"];
}

/*!
 * isEnabled
 */
+ (BOOL)isEnabled{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:PS_FACEBOOK_ENABLED]) {
        return YES;
    }
    return NO;
}
@end
