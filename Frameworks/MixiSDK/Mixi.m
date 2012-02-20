//
//  Mixi.m
//
//  Created by Platform Service Department on 11/06/29.
//  Copyright 2011 mixi Inc. All rights reserved.
//

#import "Mixi.h"
#import "MixiADBannerView.h"
#import "MixiAppAuthorizer.h"
#import "MixiSDKAuthorizer.h"
#import "MixiConfig.h"
#import "MixiConstants.h"
#import "MixiDelegate.h"
#import "MixiRefreshTokenURLDelegate.h"
#import "MixiReporter.h"
#import "MixiRequest.h"
#import "MixiSDKAuthorizer.h"
#import "MixiURLConnection.h"
#import "MixiURLDelegate.h"
#import "MixiUtils.h"
#import "MixiViewController.h"
#import "Reachability.h"
#import "SBJson.h"
#import "SFHFKeychainUtils.h"

/** \cond PRIVATE */
@interface Mixi (Private)
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
@end
/** \endcond */


@implementation Mixi

@synthesize config=config_, 
    permissions=permissions_,
    autoRefreshToken=autoRefreshToken_,
    mixiViewController=mixiViewController_,
    authorizer=authorizer_,
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

- (id)setupWithType:(MixiApiType)type clientId:(NSString*)clientId secret:(NSString*)secret redirectUrl:(NSString*)redirectUrl {
    return [self setupWithConfig:[MixiConfig configWithType:type clientId:clientId secret:secret redirectUrl:redirectUrl]];
}

- (id)setupWithConfig:(MixiConfig*)config {
    self.config = config;
    self.authorizer = [[[MixiAppAuthorizer alloc] init] autorelease];
    return self;
}

- (void)reportOncePerDay {
    if (self.config.selectorType == kMixiApiTypeSelectorMixiApp) {
        [self.uuReporter performSelector:@selector(pingIfNeededWithMixi:) withObject:self afterDelay:1];
//        [self.uuReporter pingIfNeededWithMixi:self];
    }
}

- (void)setPropertiesFromDictionary:(NSDictionary*)dict {
    [self.authorizer setPropertiesFromDictionary:dict];
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
                [self refreshAccessTokenWithError:error];
                if (error == nil || *error == nil) {
                    [self store];
                }
                else {
                    [self logout];
                }
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
    return [self.authorizer authorizeForPermissions:permissions];
}

- (NSString*)retrieveTokensFromURL:(NSURL*)url sourceApplication:(NSString*)sourceApplication error:(NSError**)error {
    if (sourceApplication == nil || [sourceApplication isEqualToString:kMixiApplicationId]) {
        // 古いiOS SDKではsourceApplicationを取ることができないので、
        // sourceApplicationがnilの場合は呼び出し元をチェックしません。
        // つまりこのチェックは気休めで、現時点ではほとんど意味がありません。
        NSDictionary *params = MixiUtilParseURLOptions(url);
        [self setPropertiesFromDictionary:params];
        return self.authorizer.accessToken;
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

#pragma mark - Refresh

- (BOOL)refreshAccessToken {
    return [self.authorizer refreshAccessToken];
}

- (BOOL)refreshAccessTokenWithError:(NSError**)error {
    return [self.authorizer refreshAccessTokenWithError:error];
}

- (NSURLConnection*)refreshAccessTokenWithDelegate:(id<MixiDelegate>)delegate {
    return [self.authorizer refreshAccessTokenWithDelegate:delegate];
}

#pragma mark - Revoke

- (void)clear {
    [self.authorizer clear];
}

- (void)logout {
    [self.authorizer logout];
}

- (BOOL)revoke {
    return [self.authorizer revoke];
}

- (BOOL)revokeWithError:(NSError**)error {
    return [self.authorizer revokeWithError:error];
}

#pragma mark - Store/Restore

- (void)store {
    [self.authorizer store];
}

- (BOOL)restore {
    return [self.authorizer restore];
}

#pragma mark - Status

- (BOOL)isMixiAppInstalled {
    return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@:///", kMixiAppScheme]]];
}

- (BOOL)isAuthorized {
    return [self.authorizer isAuthorized];
}

- (BOOL)isAccessTokenExpired {
    return [self.authorizer isAccessTokenExpired];
}

- (BOOL)isRefreshTokenExpired {
    return [self.authorizer isRefreshTokenExpired];
}

- (BOOL)isUsingSDKAuthorizer {
    return [self.authorizer isMemberOfClass:[MixiSDKAuthorizer class]];
}

- (BOOL)isUsingAppAuthorizer {
    return [self.authorizer isMemberOfClass:[MixiAppAuthorizer class]];
}


#pragma mark - API

- (NSURLConnection*)sendRequest:(MixiRequest*)request delegate:(id<MixiDelegate>)delegate forced:(BOOL)forced {
    if (!MixiUtilIsReachable()) {
        if (delegate != nil && [delegate respondsToSelector:@selector(mixi:didFailWithError:)]) {
            [delegate mixi:self didFailWithError:[self buildErrorUnreachable]];
        }
        return nil;
    }
    
    if (!forced && [self.authorizer isAccessTokenExpired]) {
        if (![self.authorizer isRefreshTokenExpired] && self.autoRefreshToken && [self.authorizer refreshAccessToken]) {
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
    
    SBJSON *parser = [[[SBJSON alloc] init] autorelease];
    NSDictionary *json = [parser objectWithString:result error:error];
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

- (void)setAuthorizer:(MixiAuthorizer *)authorizer {
    if (self.authorizer != authorizer) {
        [authorizer_ release];
        authorizer.mixi = self;
        authorizer_ = [authorizer retain];
        if ([authorizer respondsToSelector:@selector(redirectUrl)]) {
            self.config.redirectUrl = [(MixiSDKAuthorizer*)authorizer redirectUrl];
        }
    }
}

- (NSString*)description {
    return [NSString stringWithFormat:@"accessToken_:%@, refreshToken_:%@, permissions_:%@, config_:{%@}",
            self.authorizer.accessToken, self.authorizer.refreshToken, self.permissions, self.config];
}

- (void)dealloc {
    self.config = nil;
    if (permissions_ != nil) {
        [permissions_ release];
        permissions_ = nil;
    }
    self.mixiViewController = nil;
    self.authorizer = nil;
    self.uuReporter = nil;
    if (adView_ != nil) {
        [adView_ release];
        adView_ = nil;
    }
    [super dealloc];
}

#pragma mark - Private methods

- (NSError*)buildErrorUnreachable {
    return [NSError errorWithDomain:kMixiErrorDomain 
                               code:kMixiConnectionErrorUnreachable 
                           userInfo:[NSDictionary dictionaryWithObject:@"Network unreachable." 
                                                                forKey:@"message"]];
}

@end
