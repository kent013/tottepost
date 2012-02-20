//
//  MixiUserDefaults.m
//  iosSDK
//
//  Created by yasushi.ando on 11/11/28.
//  Copyright 2011 mixi Inc. All rights reserved.
//

#import "MixiUserDefaults.h"
#import "MixiAuthorizer.h"
#import "MixiConfig.h"
#import "SFHFKeychainUtils.h"

#define kMixiKeychainServiceName @"MixiSDK"

/** \cond PRIVATE */
@interface MixiUserDefaults (Private)
/* ユーザーデフォルトキーを取得 */
- (NSString*)userDefaultsKey;

/* ユーザーデフォルトを取得 */
- (NSUserDefaults*)userDefaults;

/* Keychainにトークンを保存 */
- (BOOL)storeAccessToken:(NSString*)accessToken refreshToken:(NSString*)refreshToken;

/* Keychainからトークンを取得 */
- (NSArray*)restoreTokens;
@end
/** \endcond */


@implementation MixiUserDefaults

@synthesize config=config_;

- (id)initWithConfig:(MixiConfig*)config {
    if ((self = [super init])) {
        self.config = config;
    }
    return self;
}

#pragma mark - UserDefaults

- (NSString*)userDefaultsKey {
    NSAssert(self.config.clientId != nil, @"clientId must not be nil.");
    return [NSString stringWithFormat:@"mixisdk-%@", self.config.clientId];
}

- (NSUserDefaults*)userDefaults {
    NSAssert(self.config.clientId != nil, @"clientId must not be nil.");
    return [[[NSUserDefaults alloc] initWithUser:[self userDefaultsKey]] autorelease];
}

#pragma mark - Store/Restore

- (void)storeAuthorizer:(MixiAuthorizer*)authorizer {
    NSUserDefaults *defaults = [self userDefaults];
    [defaults setObject:self.config.clientId forKey:@"clientId"];
    [defaults setObject:authorizer.accessTokenExpiryDate forKey:@"accessTokenExpiryDate"];
    [defaults setObject:authorizer.expiresIn forKey:@"expiresIn"];
    [defaults setObject:authorizer.state forKey:@"state"];
    if ([defaults synchronize]) {
        [self storeAccessToken:authorizer.accessToken refreshToken:authorizer.refreshToken];
    }
}

- (BOOL)restoreAuthorizer:(MixiAuthorizer*)authorizer {
    NSUserDefaults *defaults = [self userDefaults];
    NSString *clientId = [defaults objectForKey:@"clientId"];
    if (self.config != nil && self.config.clientId != nil && ![self.config.clientId isEqualToString:clientId]) {
        return NO;
    }
    authorizer.accessTokenExpiryDate = [defaults objectForKey:@"accessTokenExpiryDate"];
    authorizer.expiresIn = [defaults objectForKey:@"expiresIn"];
    authorizer.state = [defaults objectForKey:@"state"];
//    NSString *redirectUrl = (NSString*)[defaults objectForKey:@"redirectUrl"];
    if (!authorizer.expiresIn) {
        return NO;
    }
    NSArray *tokens = [self restoreTokens];
    authorizer.accessToken = [tokens objectAtIndex:0];
    authorizer.refreshToken = [tokens objectAtIndex:1];
    return YES;
}

#pragma mark - Clear

- (void)clear {
    NSUserDefaults *defaults = [self userDefaults];
    [defaults removeObjectForKey:@"clientId"];
    [defaults removeObjectForKey:@"expiresIn"];
    [defaults removeObjectForKey:@"state"];
    [defaults removeObjectForKey:@"accessTokenExpiryDate"];
    [self storeAccessToken:nil refreshToken:nil];
}

#pragma mark - KeyChain

- (BOOL)storeAccessToken:(NSString*)accessToken refreshToken:(NSString*)refreshToken {
    return [SFHFKeychainUtils storeUsername:[self userDefaultsKey] 
                                andPassword:[NSString stringWithFormat:@"%@\n%@", accessToken, refreshToken]
                             forServiceName:kMixiKeychainServiceName 
                             updateExisting:YES 
                                      error:nil];
}

- (NSArray*)restoreTokens {
    return [[SFHFKeychainUtils getPasswordForUsername:[self userDefaultsKey] 
                                       andServiceName:kMixiKeychainServiceName 
                                                error:nil] componentsSeparatedByString:@"\n"];
}

@end
