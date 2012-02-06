//
//  EvernoteAuth.m
//  EVNConnect
//
//  Created by Kentaro ISHITOYA on 12/02/03.
//  Copyright (c) 2012 Kentaro ISHITOYA. All rights reserved.
//


#import "EvernoteAuth.h"

//-----------------------------------------------------------------------------
//Private Implementations
//-----------------------------------------------------------------------------
@interface EvernoteAuth(PrivateImplementation)
@end

@implementation EvernoteAuth(PrivateImplementation)
@end

//-----------------------------------------------------------------------------
//Public Implementations
//-----------------------------------------------------------------------------
@implementation EvernoteAuth
@synthesize shardId = shardId_;
@synthesize userId = userId_;
@synthesize authToken = authToken_;

/*!
 * initialize
 */
- (id)initWithConsumerKey:(NSString *)consumerKey consumerSecret:(NSString *)consumerSecret callbackScheme:(NSString *)callbackScheme useSandBox:(BOOL)useSandBox andDelegate:(id<EvernoteAuthDelegate>)delegate{
    self = [super init];
    if (self) {
        consumerKey_ = consumerKey;
        consumerSecret_ = consumerSecret;
        callbackScheme_ = callbackScheme;
        delegate_ = delegate;
        useSandBox_ = useSandBox;
    }
    return self;
}

/*!
 * create authentication URL
 */
- (NSURL *) authenticationURL{
    NSString *baseurl = kEvernoteOAuthAuthenticationURL;
    if(useSandBox_){
        baseurl = kEvernoteOAuthSandboxAuthenticationURL;
    }
    return [NSURL URLWithString:baseurl];    
}

/*!
 * create requestTokeURL
 */
- (NSURL *)requestTokenURL{
    NSString *baseurl = kEvernoteOAuthRequestURL;
    if(useSandBox_){
        baseurl = kEvernoteOAuthSandboxRequestURL;
    }
    return [NSURL URLWithString:baseurl];    
}

/*!
 * send did login message
 */
- (void)evernoteDidLogin{
    if ([delegate_ respondsToSelector:@selector(evernoteDidLogin)]) {
        [delegate_ evernoteDidLogin];
    }
    
}

/*!
 * send did not login message
 */
- (void)evernoteDidNotLogin{
    if ([delegate_ respondsToSelector:@selector(evernoteDidNotLogin:)]) {
        [delegate_ evernoteDidNotLogin];
    }
}

/*!
 * set credential info
 */
- (void)setAuthToken:(NSString *)authToken userId:(NSString *)userId andShardId:(NSString *)shardId{
    authToken_ = authToken;
    userId_ = userId;
    shardId_ = shardId;
}

/*!
 * clear credential
 */
- (void)clearCredential{
    authToken_ = nil;
    userId_ = nil;
    shardId_ = nil;
}
@end
