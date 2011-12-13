//
//  FacebookPhotoSubmitter.m
//  tottepost
//
//  Created by ISHITOYA Kentaro on 11/12/13.
//  Copyright (c) 2011 cocotomo. All rights reserved.
//

#import "FacebookPhotoSubmitter.h"
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
    NSLog(@"%@", response.description);
};

/*!
 * facebook request delegate, did load
 */
- (void)request:(FBRequest *)request didLoad:(id)result {
	if ([result isKindOfClass:[NSArray class]]) {
		result = [result objectAtIndex:0];
	}
	if ([result objectForKey:@"owner"]) {
        [self.photoDelegate photoSubmitter:self didSubmitted:self.type suceeded:YES message:@"Photo upload succeeded"];
	} else {
        [self.photoDelegate photoSubmitter:self didSubmitted:self.type suceeded:NO message:[result objectForKey:@"name"]];
	}
};

/*!
 * facebook request delegate, did fail
 */
- (void)request:(FBRequest *)request didFailWithError:(NSError *)error {
    [self.photoDelegate photoSubmitter:self didSubmitted:self.type suceeded:NO message:[error localizedDescription]];
};
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
    [facebook_ requestWithMethodName:@"photos.upload"
                          andParams:params
                      andHttpMethod:@"POST"
                        andDelegate:self];

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
        [NSArray arrayWithObjects:@"publish_stream", @"offline_access",nil];
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
