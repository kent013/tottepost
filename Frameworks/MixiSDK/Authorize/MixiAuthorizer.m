//
//  MixiAuthorizer.m
//  iosSDK
//
//  Created by yasushi.ando on 11/11/28.
//  Copyright 2011 mixi Inc. All rights reserved.
//

#import "MixiAuthorizer.h"

#import "Mixi.h"
#import "MixiConfig.h"
#import "MixiConstants.h"
#import "MixiRefreshTokenURLDelegate.h"
#import "MixiUserDefaults.h"
#import "MixiUtils.h"
#import "SBJSON.h"

/** \cond PRIVATE */
@interface MixiAuthorizer (PRIVATE)
- (void)subclassResponsibility;

/* アクセストークンをリフレッシュするためのリクエストを取得 */
- (NSURLRequest*)requestToRefreshAccessToken;
@end
/** \endcond */

@implementation MixiAuthorizer

@synthesize mixi=mixi_,
    accessToken=accessToken_, 
    refreshToken=refreshToken_, 
    expiresIn=expiresIn_, 
    state=state_,
    accessTokenExpiryDate=accessTokenExpiryDate_;

- (id)initWithMixi:(Mixi *)mixi {
    if ((self = [super init])) {
        self.mixi = mixi;
        userDefaults_ = [[MixiUserDefaults alloc] initWithConfig:mixi_.config];
    }
    return self;
}

- (void)dealloc {
    self.mixi = nil;
    self.accessToken = nil;
    self.refreshToken = nil;
    self.expiresIn = nil;
    self.state = nil;
    self.accessTokenExpiryDate = nil;
    [super dealloc];
}

#pragma mark - Authorize

- (BOOL)authorize:(NSString*)permission, ... {
    NSMutableArray *permissions = [NSMutableArray array];
    [permissions addObject:permission];
	va_list args;
	va_start (args, permission);
	while ((permission = va_arg(args, id))) {
        [permissions addObject:permission];
	}
	va_end (args);
    return [self authorizeForPermissions:permissions];
}

- (BOOL)authorizeForPermission:(NSString*)permission {
    return [self authorizeForPermissions:[permission componentsSeparatedByString:@","]];
}

- (BOOL)authorizeForPermissions:(NSArray*)permissions {
    [self subclassResponsibility];
    return NO;
}

- (void)checkPermissions:(NSArray*)permissions {
    for (NSString *permission in permissions) {
        NSAssert(![permission isEqualToString:@"mixi_apps"], 
                 @"'mixi_apps' scope is deprecated. Use 'mixi_apps2' instead.");
    }
}

#pragma mark - Refresh token

- (NSURLRequest*)requestToRefreshAccessToken {
    NSString *post = [NSString stringWithFormat:@"grant_type=refresh_token&client_id=%@&client_secret=%@&refresh_token=%@",
                      self.mixi.config.clientId, self.mixi.config.secret, self.refreshToken];
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding];    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:kMixiApiRefreshTokenEndpoint]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:postData];
    return request;
}

- (BOOL)refreshAccessToken {
    NSError *error = nil;
    [self refreshAccessTokenWithError:&error];
    return error == nil;
}

- (BOOL)refreshAccessTokenWithError:(NSError**)error {
    if (!self.accessToken || !self.refreshToken) {
        if (error != nil) {
            *error = [NSError errorWithDomain:kMixiErrorDomain
                                         code:kMixiAPIErrorNotAuthorized
                                     userInfo:[NSDictionary dictionaryWithObject:@"A token is nil." forKey:@"message"]];
        }
        return NO;
    }
    NSURLRequest *request = [self requestToRefreshAccessToken];
    NSURLResponse *res;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&res error:error];
    if (error != nil && *error != nil) {
//        if ([[*error domain] isEqualToString:NSURLErrorDomain]) {
//            return [self refreshAccessTokenWithError:error];
//        }
        return NO;
    }
    NSString *jsonString = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
    if (!MixiUtilIsJson(jsonString)) {
        if (error != nil) {
            *error = [NSError errorWithDomain:kMixiErrorDomain
                                         code:kMixiAPIErrorInvalidJson
                                     userInfo:[NSDictionary dictionaryWithObject:jsonString forKey:@"message"]];
        }
        return NO;
    }
    SBJSON *parser = [[[SBJSON alloc] init] autorelease];
    NSDictionary *json = [parser objectWithString:jsonString error:error];
    if (error != nil && *error != nil) {
        return NO;
    }
    if ([json objectForKey:@"error"] != nil) {
        if (error != nil) {
            *error = [NSError errorWithDomain:kMixiErrorDomain
                                         code:kMixiAPIErrorReply
                                     userInfo:json];
        }
        return NO;
    }
    [self setPropertiesFromDictionary:json];
    [self store];
    return YES;
}

- (NSURLConnection*)refreshAccessTokenWithDelegate:(id<MixiDelegate>)delegate {
    NSURLRequest *request = [self requestToRefreshAccessToken];
    MixiRefreshTokenURLDelegate *urlDelegate = [MixiRefreshTokenURLDelegate delegateWithMixi:self.mixi delegate:delegate];
    return [[[NSURLConnection alloc] initWithRequest:request delegate:urlDelegate] autorelease];
}

#pragma mark - Revoke

- (void)clear {
    [userDefaults_ clear];
}

- (void)logout {
    [self clear];
    self.accessToken = nil;
    self.refreshToken = nil;
    self.expiresIn = nil;
    self.state = nil;
    self.accessTokenExpiryDate = nil;
    self.mixi.mixiViewController = nil;
}

- (BOOL)revoke {
    [self subclassResponsibility];
    return NO;
}

- (BOOL)revokeWithError:(NSError**)error {
    [self subclassResponsibility];
    return NO;
}

#pragma mark -

- (void)store {
    [userDefaults_ storeAuthorizer:self];
}

- (BOOL)restore {
    return [userDefaults_ restoreAuthorizer:self];
}

#pragma mark - Check status

- (BOOL)isAuthorized {
    return self.accessToken != nil;
}

- (BOOL)isAccessTokenExpired {
    if (self.accessTokenExpiryDate != nil) {
        return [self.accessTokenExpiryDate compare:[NSDate date]] == NSOrderedAscending;
    }
    else {
        return YES;
    }
}

- (BOOL)isRefreshTokenExpired {
    // 現在のところリフレッシュトークンの期限切れは考える必要がありません
    return NO;
}

#pragma mark - Setter/Getter

- (void)setPropertiesFromDictionary:(NSDictionary*)dict {
     self.accessToken = (NSString*)[dict objectForKey:@"access_token"];
     self.refreshToken = (NSString*)[dict objectForKey:@"refresh_token"];
     self.expiresIn = (NSString*)[dict objectForKey:@"expires_in"];
     self.state = (NSString*)[dict objectForKey:@"state"];
     if (self.expiresIn != nil) {
         self.accessTokenExpiryDate = [NSDate dateWithTimeIntervalSinceNow:[self.expiresIn intValue]];
     }
}

- (void)subclassResponsibility {
    @throw [NSError errorWithDomain:@"MixiSDK" 
                               code:9999 
                           userInfo:[NSDictionary dictionaryWithObject:@"Subclass responsibility" 
                                                                forKey:@"message"]];
}

@end
