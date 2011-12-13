//
//  FacebookPhotoSubmitter.m
//  tottepost
//
//  Created by ISHITOYA Kentaro on 11/12/13.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
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
-(void)setupInitialState{
}

/*!
 * facebook delegate, did login suceeded
 */
- (void)fbDidLogin {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[facebook_ accessToken] forKey:@"FBAccessTokenKey"];
    [defaults setObject:[facebook_ expirationDate] forKey:@"FBExpirationDateKey"];
    [defaults synchronize];
    if([self.delegate respondsToSelector:@selector(facebookPhotoSubmitterDidLogin)]){
        [self.delegate facebookPhotoSubmitterDidLogin];
    }
}

/*!
 * facebook delegate, if not login
 */
-(void)fbDidNotLogin:(BOOL)cancelled {
    [self clearCredentials];
    if([self.delegate respondsToSelector:@selector(facebookPhotoSubmitterDidLogout)]){
        [self.delegate facebookPhotoSubmitterDidLogout];
    }
}

/*!
 * facebook delegate, if logout
 */
- (void) fbDidLogout {
    [self clearCredentials];
    if([self.delegate respondsToSelector:@selector(facebookPhotoSubmitterDidLogout)]){
        [self.delegate facebookPhotoSubmitterDidLogout];
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
@end

//-----------------------------------------------------------------------------
//Public Implementations
//-----------------------------------------------------------------------------
@implementation FacebookPhotoSubmitter
@synthesize facebook = facebook_;
@synthesize delegate;

/*!
 * submit photo
 */
- (BOOL)submitPhoto:(UIImage *)photo{
    return [self submitPhoto:photo comment:nil];
}

/*!
 * submit photo with comment
 */
- (BOOL)submitPhoto:(UIImage *)photo comment:(NSString *)comment{
    return NO;
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
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"FBAccessTokenKey"]) {
        return YES;
    }
    return NO;
}
@end
