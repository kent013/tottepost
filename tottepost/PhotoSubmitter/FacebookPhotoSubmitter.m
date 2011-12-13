//
//  FacebookPhotoSubmitter.m
//  tottepost
//
//  Created by ISHITOYA Kentaro on 11/12/13.
//  Copyright (c) 2011 cocotomo. All rights reserved.
//

#import "FacebookPhotoSubmitter.h"
#import "UIImage+Digest.h"

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
    requests_ = [[NSMutableDictionary alloc] init];
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
    NSString *hash = [requests_ objectForKey:[NSNumber numberWithInt:request.hash]];
	if ([result objectForKey:@"owner"]) {
        [self.photoDelegate photoSubmitter:self didSubmitted:hash suceeded:YES message:@"Photo upload succeeded"];
	} else {
        [self.photoDelegate photoSubmitter:self didSubmitted:hash suceeded:NO message:[result objectForKey:@"name"]];
	}
    [requests_ removeObjectForKey:[NSNumber numberWithInt:request.hash]];
};

/*!
 * facebook request delegate, did fail
 */
- (void)request:(FBRequest *)request didFailWithError:(NSError *)error {
    NSString *hash = [requests_ objectForKey:[NSNumber numberWithInt:request.hash]];
    [self.photoDelegate photoSubmitter:self didSubmitted:hash suceeded:NO message:[error localizedDescription]];
    [requests_ removeObjectForKey:[NSNumber numberWithInt:request.hash]];
};

/*!
 * facebook request delegate, upload progress
 */
- (void)request:(FBRequest *)request didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite{
    CGFloat progress = (float)totalBytesWritten / (float)totalBytesExpectedToWrite;
    NSString *hash = [requests_ objectForKey:[NSNumber numberWithInt:request.hash]];
    [self.photoDelegate photoSubmitter:self didProgressChanged:hash progress:progress];
}
@end

//-----------------------------------------------------------------------------
//Public Implementations
//-----------------------------------------------------------------------------
@implementation FacebookPhotoSubmitter
@synthesize facebook = facebook_;
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
    [requests_ setObject:hash forKey:[NSNumber numberWithInt: request.hash]];
    [self.photoDelegate photoSubmitter:self willStartUpload:hash];
}

/*!
 * login to facebook
 */
-(void)login{
    facebook_ = [[Facebook alloc] initWithAppId:@"206421902773102" andDelegate:self];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"FBAccessTokenKey"] 
        && [defaults objectForKey:@"FBExpirationDateKey"]) {
        facebook_.accessToken = [defaults objectForKey:@"FBAccessTokenKey"];
        facebook_.expirationDate = [defaults objectForKey:@"FBExpirationDateKey"];
    }
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
