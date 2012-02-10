//
//  Mixi.m
//
//  Created by Platform Service Department on 11/06/29.
//  Copyright 2011 mixi Inc. All rights reserved.
//

#pragma GCC diagnostic ignored "-Wmissing-prototypes"

#import "Mixi.h"
#import "MixiADBannerView.h"
#import "MixiConfig.h"
#import "MixiConstants.h"
#import "MixiDelegate.h"
#import "MixiRefreshTokenURLDelegate.h"
#import "MixiReporter.h"
#import "MixiRequest.h"
#import "MixiURLConnection.h"
#import "MixiURLDelegate.h"
#import "MixiUtils.h"
#import "MixiViewController.h"
#import "Reachability.h"
#import "JSON.h"
#import "SFHFKeychainUtils.h"

#define kMixiKeychainServiceName @"MixiSDK"

/** \cond PRIVATE */
@interface Mixi (Private)
/* トークンを取得するためのURLを取得 */
- (NSURL*)tokenURL:(NSArray*)permissions;

/* 認可状態を解除するためのURLを取得 */
- (NSURL*)revokeURL;

/* アクセストークンをリフレッシュするためのリクエストを取得 */
- (NSURLRequest*)requestToRefreshAccessToken;

/* 認可状態を解除するためのリクエストを取得 */
- (MixiRequest*)buildRevokeRequest;

/* オフラインエラー作成 */
- (NSError*)buildErrorUnreachable;

/* ユーザーデフォルトをクリア */
- (void)clearUserDefaults;

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


@implementation Mixi

@synthesize config=config_, 
    permissions=permissions_,
    accessToken=accessToken_, 
    refreshToken=refreshToken_, 
    expiresIn=expiresIn_, 
    state=state_,
    accessTokenExpiryDate=accessTokenExpiryDate_,
    returnScheme=returnScheme_,
    autoRefreshToken=autoRefreshToken_,
    mixiViewController=mixiViewController_,
    uuReporter=uuReporter_;

#pragma mark - Singleton

static Mixi *sharedMixi = nil;

+ (Mixi*)sharedMixi {
	@synchronized(self) {
        srand((unsigned) time(NULL));
		if (sharedMixi == nil) {
			sharedMixi = [[self alloc] init];
            sharedMixi.autoRefreshToken = YES;
            sharedMixi.uuReporter = [MixiReporter pingReporter];
		}
	}
	return sharedMixi;
}

+ (id)allocWithZone:(NSZone *)zone {
	@synchronized(self) {
		if (sharedMixi == nil) {
			sharedMixi = [super allocWithZone:zone];
			return sharedMixi;
		}
	}
	return nil;
}

- (id)copyWithZone:(NSZone*)zone {
	return self;
}

- (id)retain {
	return self;
}

- (unsigned)retainCount {
	return UINT_MAX;
}

- (oneway void)release {
}

- (id)autorelease {
	return self;
}

#pragma mark - Setup

- (id)setupWithClientId:(NSString*)clientId secret:(NSString*)secret {
    return [self setupWithType:kMixiApiTypeSelectorGraphApi clientId:clientId secret:secret];
}

- (id)setupWithClientId:(NSString*)clientId secret:(NSString*)secret appId:(NSString*)appId {
    NSLog(@"appId is ignored. Please use setupWithClientId:secret: method instead.");
    return [self setupWithType:kMixiApiTypeSelectorGraphApi clientId:clientId secret:secret];
}

- (id)setupWithType:(MixiApiType)type clientId:(NSString*)clientId secret:(NSString*)secret {
    return [self setupWithConfig:[MixiConfig configWithType:type clientId:clientId secret:secret]];
}

- (id)setupWithType:(MixiApiType)type clientId:(NSString*)clientId secret:(NSString*)secret appId:(NSString*)appId {
    NSLog(@"appId is ignored. Please use setupWithType:lientId:secret: method instead.");
    return [self setupWithConfig:[MixiConfig configWithType:type clientId:clientId secret:secret]];
}

- (id)setupWithConfig:(MixiConfig*)config {
    self.config = config;
    self.returnScheme = MixiUtilFirstBundleURLScheme();
    return self;
}

- (void)reportOncePerDay {
    if (self.config.selectorType == kMixiApiTypeSelectorMixiApp) {
        [self.uuReporter performSelector:@selector(pingIfNeededWithMixi:) withObject:self afterDelay:1];
//        [self.uuReporter pingIfNeededWithMixi:self];
    }
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

#pragma mark -

- (NSString*)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation error:(NSError**)error 
{
    if ([[url path] isEqualToString:@"/error"]) {
        if (error != nil) {
            *error = [self retrieveErrorFromURL:url];
        }
    }
    else if ([[url path] isEqualToString:@"/cancel"]) {
        if (error != nil) {
            *error = [NSError errorWithDomain:kMixiErrorDomain 
                                         code:kMixiCancelled
                                     userInfo:[NSDictionary dictionaryWithObject:@"Your request cancelled." forKey:@"message"]];
        }
    }
    else if ([[url host] isEqualToString:@"token"]) {
        UIPasteboard *pasteboard = [UIPasteboard pasteboardWithName:self.config.pbkey create:NO];
        if (pasteboard == nil) {
            if (error != nil) {
                *error = [NSError errorWithDomain:kMixiErrorDomain
                                             code:kMixiTokenErrorCannotRetrieve
                                         userInfo:[NSDictionary dictionaryWithObject:@"Any token cannot be retrieved." forKey:@"message"]];
            }
        }
        else {
            url = (NSURL*)[pasteboard valueForPasteboardType:@"public.url"];
            [self retrieveTokensFromURL:url sourceApplication:sourceApplication error:error];
            if (error == nil || *error == nil) {
                [self store];
            }
        }
        return kMixiAppApiTypeToken;
    }
    else if ([[url host] isEqualToString:@"run"] && [[url query] hasPrefix:@"mixi_request_id="]) {
        return kMixiAppApiTypeReceiveRequest;
    }
    return [url host];
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
    for (NSString *permission in permissions) {
        NSAssert(![permission isEqualToString:@"mixi_apps"], 
                 @"'mixi_apps' scope is deprecated. Use 'mixi_apps2' instead.");
//        if ([permission isEqualToString:@"mixi_apps"]) {
//            NSLog(@"WARNING!! 'mixi_apps' scope is deprecated. Use 'mixi_apps2' instead.");
//        }
    }
    
    NSURL *url = [self tokenURL:permissions];
    UIApplication *app = [UIApplication sharedApplication];
    if ([app canOpenURL:url]) {
        if (![permissions isEqualToArray:permissions_]) {
            if (permissions_ != nil) {
                [permissions_ release];
            }
            permissions_ = [permissions retain];
        }
        [self.uuReporter cancel];
        [app openURL:url];
        return YES;
    }
    else {
        return NO;
    }
}

- (NSString*)retrieveTokensFromURL:(NSURL*)url sourceApplication:(NSString*)sourceApplication error:(NSError**)error {
    if (sourceApplication == nil || [sourceApplication isEqualToString:kMixiApplicationId]) {
        // 古いiOS SDKではsourceApplicationを取ることができないので、
        // sourceApplicationがnilの場合は呼び出し元をチェックしません。
        // つまりこのチェックは気休めで、現時点ではほとんど意味がありません。
        NSDictionary *params = MixiUtilParseURLOptions(url);
        [self setPropertiesFromDictionary:params];
        return self.accessToken;
    }
    else {
        if (error != nil) {
            *error = [NSError errorWithDomain:NSStringFromClass([self class]) 
                                         code:kMixiAppErrorInvalidSource
                                     userInfo:[NSDictionary dictionaryWithObject:@"The SDK is called by other application than the official mixi app." 
                                                                          forKey:@"message"]];
        }
        return nil;
    }
}

- (NSError*)retrieveErrorFromURL:(NSURL*)url {
    NSDictionary *params = MixiUtilParseURLOptions(url);
    NSString *errorCode = [params objectForKey:@"code"];
    NSString *errorMessage = [[params objectForKey:@"message"] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return [NSError errorWithDomain:kMixiErrorDomain
                               code:[errorCode intValue] 
                           userInfo:[NSDictionary dictionaryWithObject:errorMessage forKey:@"message"]];
}

- (BOOL)isAuthorized {
    return self.accessToken != nil;
}

#pragma mark - Refresh token

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

- (NSURLRequest*)requestToRefreshAccessToken {
    NSString *post = [NSString stringWithFormat:@"grant_type=refresh_token&client_id=%@&client_secret=%@&refresh_token=%@",
                      self.config.clientId, self.config.secret, self.refreshToken];
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
    SBJsonParser *parser = [[[SBJsonParser alloc] init] autorelease];
    NSDictionary *json = [parser objectWithString:jsonString];
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
    MixiRefreshTokenURLDelegate *urlDelegate = [MixiRefreshTokenURLDelegate delegateWithMixi:self delegate:delegate];
    return [[[NSURLConnection alloc] initWithRequest:request delegate:urlDelegate] autorelease];
}

#pragma mark - Revoke

- (void)clear {
    NSUserDefaults *defaults = [self userDefaults];
    [defaults removeObjectForKey:@"clientId"];
    [defaults removeObjectForKey:@"expiresIn"];
    [defaults removeObjectForKey:@"state"];
    [defaults removeObjectForKey:@"accessTokenExpiryDate"];
    [self storeAccessToken:nil refreshToken:nil];
}

- (void)logout {
    [self clear];
    self.accessToken = nil;
    self.refreshToken = nil;
    self.expiresIn = nil;
    self.state = nil;
    self.accessTokenExpiryDate = nil;
    self.mixiViewController = nil;
}

- (BOOL)revoke {
    NSURL *url = [self revokeURL];
    UIApplication *app = [UIApplication sharedApplication];
    if ([app canOpenURL:url]) {
        [self.uuReporter cancel];
        [app openURL:url];
        return YES;
    }
    else {
        return NO;
    }
}

#pragma mark - Store/Restore

- (NSString*)userDefaultsKey {
    NSAssert(self.config.clientId != nil, @"clientId must not be nil.");
    return [NSString stringWithFormat:@"mixisdk-%@", self.config.clientId];
}

- (NSUserDefaults*)userDefaults {
    NSAssert(self.config.clientId != nil, @"clientId must not be nil.");
    return [[[NSUserDefaults alloc] initWithUser:[self userDefaultsKey]] autorelease];
}

- (void)store {
    NSUserDefaults *defaults = [self userDefaults];
    [defaults setObject:self.config.clientId forKey:@"clientId"];
    [defaults setObject:self.accessTokenExpiryDate forKey:@"accessTokenExpiryDate"];
    [defaults setObject:self.expiresIn forKey:@"expiresIn"];
    [defaults setObject:self.state forKey:@"state"];
    if ([defaults synchronize]) {
        [self storeAccessToken:self.accessToken refreshToken:self.refreshToken];
    }
}

- (BOOL)restore {
    NSUserDefaults *defaults = [self userDefaults];
    NSString *clientId = [defaults objectForKey:@"clientId"];
    if (self.config != nil && self.config.clientId != nil && ![self.config.clientId isEqualToString:clientId]) {
        return NO;
    }
    self.accessTokenExpiryDate = [defaults objectForKey:@"accessTokenExpiryDate"];
    self.expiresIn = [defaults objectForKey:@"expiresIn"];
    self.state = [defaults objectForKey:@"state"];
    if (!self.expiresIn) {
        return NO;
    }
    NSArray *tokens = [self restoreTokens];
    self.accessToken = [tokens objectAtIndex:0];
    self.refreshToken = [tokens objectAtIndex:1];
    return YES;
}

- (BOOL)storeAccessToken:(NSString*)accessToken refreshToken:(NSString*)refreshToken {
    return [SFHFKeychainUtils storeUsername:[self userDefaultsKey] 
                                andPassword:[NSString stringWithFormat:@"%@\n%@", self.accessToken, self.refreshToken]
                             forServiceName:kMixiKeychainServiceName 
                             updateExisting:YES 
                                      error:nil];
}

- (NSArray*)restoreTokens {
    return [[SFHFKeychainUtils getPasswordForUsername:[self userDefaultsKey] 
                                      andServiceName:kMixiKeychainServiceName 
                                               error:nil] componentsSeparatedByString:@"\n"];
}

#pragma mark - API

- (NSURLConnection*)sendRequest:(MixiRequest*)request delegate:(id<MixiDelegate>)delegate forced:(BOOL)forced {
    if (!MixiUtilIsReachable()) {
        if (delegate != nil && [delegate respondsToSelector:@selector(mixi:didFailWithError:)]) {
            [delegate mixi:self didFailWithError:[self buildErrorUnreachable]];
        }
        return nil;
    }
    
    if (!forced && [self isAccessTokenExpired]) {
        if (![self isRefreshTokenExpired] && self.autoRefreshToken && [self refreshAccessToken]) {
            [self store];
            return [self sendRequest:request delegate:delegate forced:YES];
        }
        else {
            if (request.openMixiAppToAuthorizeIfNeeded) {
                [self authorizeForPermissions:permissions_];
            }
            else if (delegate != nil && [delegate respondsToSelector:@selector(mixi:didFailWithError:)]) {
                NSError *error = [NSError errorWithDomain:kMixiErrorDomain 
                                                     code:kMixiTokenErrorExpired 
                                                 userInfo:[NSDictionary dictionaryWithObject:@"The access token has been expired." 
                                                                                      forKey:@"message"]];
                [delegate mixi:self didFailWithError:error];
            }
            return nil;
        }
    }
    else {
        NSURLRequest *urlRequest = [request constructURLRequest:self];
        MixiURLDelegate *urlDelegate = [MixiURLDelegate delegateWithMixi:self delegate:delegate];
        return [[[NSURLConnection alloc] initWithRequest:urlRequest delegate:urlDelegate] autorelease];
    }
}

- (NSURLConnection*)sendRequest:(MixiRequest*)request delegate:(id<MixiDelegate>)delegate {
    return [self sendRequest:request delegate:delegate forced:NO];
}

- (NSString*)rawSendSynchronousRequest:(MixiRequest*)request error:(NSError**)error {
    if (!MixiUtilIsReachable()) {
        if (error != nil) {
            *error = [self buildErrorUnreachable];
        }
        return nil;
    }
    
    NSURLRequest *urlRequest = [request constructURLRequest:self];
    NSURLResponse *response = nil;
    NSData *data = [MixiURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:error];
    if (error != nil && *error != nil) {
        return nil;
    }
    return [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
}

- (NSDictionary*)sendSynchronousRequest:(MixiRequest*)request error:(NSError**)error {
    if (!MixiUtilIsReachable()) {
        if (error != nil) {
            *error = [self buildErrorUnreachable];
        }
        return nil;
    }
    
    NSString *result = [self rawSendSynchronousRequest:request error:error];
    if (error != nil && *error != nil) {
        return nil;
    }
    
    SBJsonParser *parser = [[[SBJsonParser alloc] init] autorelease];
    NSDictionary *json = [parser objectWithString:result];
    if (error != nil && *error != nil) {
        return nil;
    }
    else {
        if ([json objectForKey:@"error"]) {
            if (error != nil) {
                *error = [NSError errorWithDomain:kMixiErrorDomain code:kMixiAPIErrorInvalidJson userInfo:json];
            }
            return nil;
        }
        else {
            return json;
        }
    }
}

#pragma mark - ViewController

- (MixiViewController*)buildViewControllerWithRequest:(MixiRequest*)request delegate:(id<MixiDelegate>)delegate {
    return [[[MixiViewController alloc] initWithMixi:self request:request delegate:delegate] autorelease];
}

#pragma mark -

- (NSString*)description {
    return [NSString stringWithFormat:@"accessToken_:%@, refreshToken_:%@, permissions_:%@, config_:{%@}",
            self.accessToken, self.refreshToken, self.permissions, self.config];
}

- (void)dealloc {
    self.config = nil;
    if (permissions_ != nil) {
        [permissions_ release];
        permissions_ = nil;
    }
    self.accessToken = nil;
    self.refreshToken = nil;
    self.expiresIn = nil;
    self.state = nil;
    self.accessTokenExpiryDate = nil;
    self.returnScheme = nil;
    self.mixiViewController = nil;
    self.uuReporter = nil;
    if (adView_ != nil) {
        [adView_ release];
        adView_ = nil;
    }
    [super dealloc];
}

#pragma mark - Private methods

- (NSURL*)tokenURL:(NSArray*)permissions {
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@#%@=%@&%@=%@&%@=%@", kMixiAppTokenUri, 
                                 kMixiSDKClientIdKey, self.config.clientId, 
                                 kMixiSDKPermissionsKey, [permissions componentsJoinedByString:@"%20"],
                                 kMixiSDKReturnSchemeKey, self.returnScheme]];
}

- (NSURL*)revokeURL {
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@#%@=%@&%@=%@&%@=%@", kMixiAppRevokeUri, 
                                 kMixiSDKClientIdKey, self.config.clientId,
                                 kMixiSDKTokenKey, self.refreshToken,
                                 kMixiSDKReturnSchemeKey, self.returnScheme]];
}

- (NSError*)buildErrorUnreachable {
    return [NSError errorWithDomain:kMixiErrorDomain 
                               code:kMixiConnectionErrorUnreachable 
                           userInfo:[NSDictionary dictionaryWithObject:@"Network unreachable." 
                                                                forKey:@"message"]];
}

@end
