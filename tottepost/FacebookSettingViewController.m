//
//  FacebookSettingViewController.m
//  tottepost
//
//  Created by ISHITOYA Kentaro on 11/12/12.
//  Copyright (c) 2011 cocotomo. All rights reserved.
//

#import "FacebookSettingViewController.h"
//-----------------------------------------------------------------------------
//Private Implementations
//-----------------------------------------------------------------------------
@interface FacebookSettingViewController(PrivateImplementation)
- (void) setupInitialState;
@end

@implementation FacebookSettingViewController(PrivateImplementation)
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
    if([self.delegate respondsToSelector:@selector(fbDidLogin)]){
        [self.delegate fbDidLogin];
    }
}

/*!
 * facebook delegate, if not login
 */
-(void)fbDidNotLogin:(BOOL)cancelled {
	NSLog(@"did not login");
    if([self.delegate respondsToSelector:@selector(fbDidLogout)]){
        [self.delegate fbDidLogout];
    }
}

/*!
 * facebook delegate, if logout
 */
- (void) fbDidLogout {
    // Remove saved authorization information if it exists
    if([self.delegate respondsToSelector:@selector(fbDidLogout)]){
        [self.delegate fbDidLogout];
    }
}
@end

//-----------------------------------------------------------------------------
//Public Implementations
//-----------------------------------------------------------------------------
@implementation FacebookSettingViewController
@synthesize delegate = delegate_;
@synthesize facebook = facebook_;

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
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"FBAccessTokenKey"]) {
        [defaults removeObjectForKey:@"FBAccessTokenKey"];
        [defaults removeObjectForKey:@"FBExpirationDateKey"];
        [defaults synchronize];
    } 
}

/*!
 * initialize
 */
- (id)init{
    self = [super init];
    if(self){
        [self setupInitialState];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
