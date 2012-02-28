//
//  MinusAuth.m
//  EVNConnect
//
//  Created by Kentaro ISHITOYA on 12/02/03.
//  Copyright (c) 2012 Kentaro ISHITOYA. All rights reserved.
//

#import "MinusAuth.h"
#import "NSString+Join.h"

/*!
 * endpoint urls
 */
static NSString *kMinusOAuthRequestURL = @"https://minus.com/oauth/token";
static NSString *kMinusOAuthAuthenticationURL = @"https://minus.com/oauth/token";
static NSString *kMinusServiceKey = @"MinusService";


//-----------------------------------------------------------------------------
//Private Implementations
//-----------------------------------------------------------------------------
@interface MinusAuth(PrivateImplementation)
-(void)requestAccessWithUsername:(NSString *)username password:(NSString *)password andPermission:(NSArray *)permission;
@end

@implementation MinusAuth(PrivateImplementation)
/*!
 * request for access
 */
-(void)requestAccessWithUsername:(NSString *)username password:(NSString *)password andPermission:(NSArray *)permission{
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:[NSString join:permission glue:@" "], @"scope", nil];
    [[NXOAuth2AccountStore sharedStore] 
     requestAccessToAccountWithType:kMinusServiceKey
     username:username
     password:password
     additionalParameters:params];
}
@end

//-----------------------------------------------------------------------------
//Public Implementations
//-----------------------------------------------------------------------------
#pragma mark - authentication
@implementation MinusAuth
@dynamic credential;

/*!
 * initialize
 */
- (id)initWithClientId:(NSString *)clientId 
          clientSecret:(NSString *)clientSecret
           andDelegate:(id<MinusAuthDelegate>)delegate{
    self = [super init];
    if (self) {
        clientId_ = clientId;
        clientSecret_ = clientSecret;
        delegate_ = delegate; 
        [[NXOAuth2AccountStore sharedStore] 
         setClientID:clientId_
         secret:clientSecret_
         authorizationURL:[NSURL URLWithString:kMinusOAuthAuthenticationURL]
         tokenURL:[NSURL URLWithString:kMinusOAuthAuthenticationURL]
         redirectURL:nil
         forAccountType:kMinusServiceKey];
        
        [[NSNotificationCenter defaultCenter] 
         addObserverForName:NXOAuth2AccountStoreAccountsDidAddNotification
         object:[NXOAuth2AccountStore sharedStore]
         queue:nil
         usingBlock:^(NSNotification *aNotification){
             [self minusDidLogin];
         }];   
        
        [[NSNotificationCenter defaultCenter] 
         addObserverForName:NXOAuth2AccountStoreDidFailToRequestAccessNotification
         object:[NXOAuth2AccountStore sharedStore]
         queue:nil
         usingBlock:^(NSNotification *aNotification){
             NSError *error = [aNotification.userInfo objectForKey:NXOAuth2AccountStoreErrorKey];
             NSLog(@"%@", error);
             [self minusDidNotLogin];
         }];
    }
    return self;
}

/*!
 * login to minus, obtain request token
 */
-(void)loginWithUsername:(NSString *)username password:(NSString *)password andPermission:(NSArray *)permission {
    if([self isSessionValid]){
        [self minusDidLogin];
        return;
    }
    [self requestAccessWithUsername:username password:password andPermission:permission];
}

/*!
 * logout
 */
- (void)logout {
    [self clearCredential];
    if ([delegate_ respondsToSelector:@selector(minusDidLogout)]) {
        [delegate_ minusDidLogout];
    }
}

/*!
 * send did login message
 */
- (void)minusDidLogin{
    if ([delegate_ respondsToSelector:@selector(minusDidLogin)]) {
        [delegate_ minusDidLogin];
    }
    
}

/*!
 * send did login message
 */
- (void)minusDidLogout{
    if ([delegate_ respondsToSelector:@selector(minusDidLogout)]) {
        [delegate_ minusDidLogout];
    }
    
}

/*!
 * send did not login message
 */
- (void)minusDidNotLogin{
    if ([delegate_ respondsToSelector:@selector(minusDidNotLogin:)]) {
        [delegate_ minusDidNotLogin];
    }
}

#pragma mark - credentials
/*!
 * clear access token
 */
- (void)clearCredential{
    for (NXOAuth2Account *account in [[NXOAuth2AccountStore sharedStore] accountsWithAccountType:kMinusServiceKey]) {
        [[NXOAuth2AccountStore sharedStore] removeAccount:account];
    }
}

/*!
 * get credential
 */
- (NXOAuth2Account *)credential{
    for (NXOAuth2Account *account in [[NXOAuth2AccountStore sharedStore] accountsWithAccountType:kMinusServiceKey]) {
        return account;
    }
    return nil;
}

/*!
 * refresh credential
 */
- (void)refreshCredentialWithUsername:(NSString *)username password:(NSString *)password andPermission:(NSArray *)permission{
    [self requestAccessWithUsername:username password:password andPermission:permission];
}

/*!
 * check is session valid
 */
- (BOOL)isSessionValid{
    NXOAuth2Account *credential = self.credential;
    if(credential == nil){
        return NO;
    }
    if([credential.accessToken doesExpire] && [credential.accessToken hasExpired]){
        return NO;
    }
    return YES;
}
@end
