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
    if ([defaults objectForKey:@"FBAccessTokenKey"] 
        && [defaults objectForKey:@"FBExpirationDateKey"]) {
        facebook_.accessToken = [defaults objectForKey:@"FBAccessTokenKey"];
        facebook_.expirationDate = [defaults objectForKey:@"FBExpirationDateKey"];
    }
}

/*!
 * clear facebook access token key
 */
- (void)clearCredentials{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"FBAccessTokenKey"]) {
        [defaults removeObjectForKey:@"FBAccessTokenKey"];
        [defaults removeObjectForKey:@"FBExpirationDateKey"];
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
    [defaults setObject:[facebook_ accessToken] forKey:@"FBAccessTokenKey"];
    [defaults setObject:[facebook_ expirationDate] forKey:@"FBExpirationDateKey"];
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
        [self.photoDelegate photoSubmitter:self didSubmitted:hash suceeded:YES message:@"Photo upload succeeded"];
	} else {
        [self.photoDelegate photoSubmitter:self didSubmitted:hash suceeded:NO message:[result objectForKey:@"name"]];
	}
    [self removePhotoForRequest:request];
};

/*!
 * facebook request delegate, did fail
 */
- (void)request:(FBRequest *)request didFailWithError:(NSError *)error {
    NSString *hash = [self photoForRequest:request];
    [self.photoDelegate photoSubmitter:self didSubmitted:hash suceeded:NO message:[error localizedDescription]];
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
 * check is logined
 */
- (BOOL)isLogined{
    return [FacebookPhotoSubmitter isEnabled];
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
