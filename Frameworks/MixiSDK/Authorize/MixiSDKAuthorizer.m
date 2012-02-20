//
//  MixiSDKAuthorizer.m
//  iosSDK
//
//  Created by Platform Service Department on 11/11/30.
//  Copyright 2011 mixi Inc. All rights reserved.
//

#import "MixiSDKAuthorizer.h"
#import "Mixi.h"
#import "MixiConfig.h"
#import "MixiConstants.h"
#import "MixiRequest.h"
#import "MixiUtils.h"
#import "MixiWebViewController.h"
#import "MixiUserDefaults.h"
#import "SBJSON.h"

#define kMixiSuccessAuthCodeFile @"connect_authorize_success.html"
#define kMixiTokenEndpointBaseUrl @"https://secure.mixi-platform.com/2"
#define kMixiRevokeRedirectUrl @"file:///__MIXI_URL_SCHEME__:///authorize/revoke#"

/** \cond PRIVATE */
@interface MixiSDKAuthorizer (Private)
- (void)requestToken:(NSString*)query;
- (void)requestRevoke:(NSString*)fragment;
- (NSURL*)tokenURL:(NSArray*)permissions;
- (NSURL*)revokeURL;
- (BOOL)notifySuccessWithEndpoint:(NSString*)endpoint;
- (BOOL)notifyCancelWithEndpoint:(NSString*)endpoint;
- (BOOL)notifyError:(NSError*)error withEndpoint:(NSString*)endpoint;
- (BOOL)dismissIfParentViewControllerExists;
@end
/** \endcond */

@implementation MixiSDKAuthorizer

@synthesize delegate=authorizerDelegate_,
    parentViewController=parentViewController_,
    redirectUrl=redirectUrl_,
    toolbarColor=toolbarColor_;

#pragma mark - Init

+ (id)authorizerWithRedirectUrl:(NSString*)redirectUrl {
    return [[[self alloc] initWithRedirectUrl:redirectUrl] autorelease];
}

+ (id)authorizerWithRedirectUrl:(NSString*)redirectUrl parentViewController:(UIViewController*)parentViewController {
    return [[[self alloc] initWithRedirectUrl:redirectUrl parentViewController:parentViewController] autorelease];
}

- (id)initWithRedirectUrl:(NSString*)redirectUrl {
    return [self initWithRedirectUrl:redirectUrl parentViewController:nil];
}

- (id)initWithRedirectUrl:(NSString*)redirectUrl parentViewController:(UIViewController*)parentViewController {
    if ((self = [self init])) {
        self.redirectUrl = redirectUrl;
        self.parentViewController = parentViewController;
        self.mixi = [Mixi sharedMixi];
        userDefaults_ = [[MixiUserDefaults alloc] initWithConfig:mixi_.config];
    }
    return self;
}

#pragma mark - Authorize

- (MixiWebViewController*)authorizerViewController:(NSArray*)permissions {
    [self checkPermissions:permissions];
    NSURL *url = [self tokenURL:permissions];
    return [[[MixiWebViewController alloc] initWithURL:url delegate:self] autorelease];    
}

- (BOOL)authorizeForPermissions:(NSArray*)permissions {
    MixiWebViewController *vc = [self authorizerViewController:permissions];
    vc.toolbarTitle = @"利用同意";
    if (self.toolbarColor) vc.toolbarColor = self.toolbarColor;
    [self.parentViewController presentModalViewController:vc animated:YES];
    return YES;
}

#pragma mark - Revoke

- (MixiWebViewController*)revokerViewControllerWithError:(NSError**)error {
    NSURL *revokeURL = [self revokeURL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:revokeURL 
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                       timeoutInterval:20];
    [request setHTTPMethod:@"GET"];
    [request setValue:[NSString stringWithFormat:@"OAuth %@", self.accessToken] forHTTPHeaderField:@"Authorization"];
    [request setValue:[MixiRequest userAgent] forHTTPHeaderField:@"User-Agent"];
    
    NSURLResponse *res = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request 
                                         returningResponse:&res
                                                     error:error];
    NSString *html = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
    NSDictionary *header = [(NSHTTPURLResponse*)res allHeaderFields];
    if (*error != nil) {
        return nil;
    }
    else if ([[header objectForKey:@"Www-Authenticate"] isEqualToString:@"OAuth error='invalid_request'"]) {
        *error = [NSError errorWithDomain:kMixiErrorDomain code:kMixiAuthErrorOAuthFailed userInfo:[NSDictionary dictionaryWithObject:@"invalid_request" forKey:@"message"]];
        return nil;
    }
    else if ([html hasPrefix:@"{\""] && [html hasSuffix:@"\"}"]) {
        SBJSON *parser = [[[SBJSON alloc] init] autorelease];
        NSDictionary *json = [parser objectWithString:html error:error];
        if (*error == nil) {
            *error = [NSError errorWithDomain:kMixiErrorDomain code:kMixiAPIErrorReply userInfo:json];
        }
        return nil;
    }
    return [[[MixiWebViewController alloc] initWithHTML:html delegate:self] autorelease];
}

- (BOOL)revokeWithError:(NSError**)error {
    MixiWebViewController *vc = [self revokerViewControllerWithError:error];
    if (vc) {
        vc.toolbarTitle = @"認証取消";
        if (self.toolbarColor) vc.toolbarColor = self.toolbarColor;
        [self.parentViewController presentModalViewController:vc animated:YES];
        return YES;
    }
    else {
        return NO;
    }
}

- (BOOL)revoke {
    NSError *error = nil;
    BOOL ret = [self revokeWithError:&error];
    if (error) {
        [self notifyError:error withEndpoint:kMixiApiRevokeEndpoint];
    }
    return ret;
}

#pragma mark - WebViewDelegate

// SDK内で認可する場合は公式アプリを起動しないようにしておく
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSString *urlString = [[request URL] absoluteString];
    if ([urlString hasPrefix:@"mixi-connect://cancel"]) {
        // revokeをキャンセルされた場合
        [self dismissIfParentViewControllerExists];
        [self notifyCancelWithEndpoint:kMixiApiRevokeEndpoint];
        return NO;
    }
    else {
        NSString *body = [[[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding] autorelease];
        if ([body rangeOfString:@"&deny="].location != NSNotFound) {
            // token取得をキャンセルされた場合
            [self dismissIfParentViewControllerExists];
            [self notifyCancelWithEndpoint:kMixiApiTokenEndpoint];
            return NO;
        }
        else {
            return ![urlString hasPrefix:kMixiAppScheme];
        }
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    NSString *redirectUrl = [[[error userInfo] objectForKey:@"NSErrorFailingURLKey"] absoluteString];
    if ([redirectUrl hasPrefix:[Mixi sharedMixi].config.redirectUrl]) {
        // get token
        [self requestToken:redirectUrl];
    }
    else if ([redirectUrl hasPrefix:kMixiRevokeRedirectUrl]) {
        // revoke
        NSString *fragment = [[redirectUrl stringByReplacingOccurrencesOfString:kMixiRevokeRedirectUrl withString:@""] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [self requestRevoke:fragment];
    }
    else {
        [self notifyError:error withEndpoint:kMixiApiUnknownEndpoint];
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    if (self.parentViewController) {
        MixiWebViewController *vc = (MixiWebViewController*)[self.parentViewController modalViewController];
        NSString *html = [webView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML"];
        if ([html rangeOfString:@"<form action=\"/login.pl\""].location != NSNotFound) {
            vc.toolbarTitle = @"ログイン";
        }
        else if ([[webView.request URL] isFileURL]) {
            vc.toolbarTitle = @"認証取消";
        }
        else {
            vc.toolbarTitle = @"利用同意";
        }
    }
    
    NSString *urlString = [[webView.request URL] absoluteString];
    if ([urlString rangeOfString:kMixiSuccessAuthCodeFile].location != NSNotFound) {
        [self requestToken:[[webView.request URL] query]];
    }    
}

- (void)requestToken:(NSString*)query {
    NSString *authCode = [[query componentsSeparatedByString:@"="] objectAtIndex:1];
    MixiRequest *request = [MixiRequest postRequestWithEndpoint:kMixiApiTokenEndpoint paramsAndKeys:
                            @"authorization_code", @"grant_type",
                            self.mixi.config.clientId, @"client_id",   
                            self.mixi.config.secret, @"client_secret", 
                            authCode, @"code", 
                            [Mixi sharedMixi].config.redirectUrl, @"redirect_uri", 
                            nil];
    //__START__REMOVE_WHEN_RELEASED__
#ifndef DEV
    // __END__REMOVE_WHEN_RELEASED__
    request.endpointBaseUrl = kMixiTokenEndpointBaseUrl;
    //__START__REMOVE_WHEN_RELEASED__
#endif
    // __END__REMOVE_WHEN_RELEASED__
    [self.mixi sendRequest:request delegate:self forced:YES];
}

- (void)requestRevoke:(NSString*)fragment {
    NSError *error = nil;
    SBJSON *parser = [[[SBJSON alloc] init] autorelease];
    NSDictionary *json = [parser objectWithString:fragment error:&error];
    if (error) {
        [self notifyError:error withEndpoint:kMixiApiRevokeEndpoint];
    }
    else {
        if ([json objectForKey:@"error"]) {
            error = [NSError errorWithDomain:kMixiErrorDomain code:kMixiAPIErrorReply userInfo:json];
            [self notifyError:error withEndpoint:kMixiApiRevokeEndpoint];
        }
        else {
            MixiRequest *request = [MixiRequest postRequestWithEndpoint:kMixiApiRevokeEndpoint params:json];
            [self.mixi sendRequest:request delegate:self forced:YES];
        }
    }
}

#pragma mark - MixiDelegate


- (void)mixi:(Mixi*)mixi didSuccessWithJson:(NSDictionary*)data {
    // revokeに成功してもリダイレクト先不正でmixi:didFailWithConnection:error:が実行されるため
    // ここはtoken取得の場合しか通過しない
    [self.mixi setPropertiesFromDictionary:data];
    [self notifySuccessWithEndpoint:kMixiApiTokenEndpoint];
    [self dismissIfParentViewControllerExists];
    
//    if ([self notifySuccessWithEndpoint:kMixiApiTokenEndpoint]) {
//        [self dismissIfParentViewControllerExists];
//    }
}

- (void)mixi:(Mixi*)mixi didFailWithConnection:(NSURLConnection*)connection error:(NSError*)error {
    if (error.code == -1002/*unsupported URL*/ 
        && [[[error.userInfo objectForKey:@"NSErrorFailingURLKey"] absoluteString] isEqualToString:@"mixi-connect://success"]) {
        // success revoking
        if (![self notifySuccessWithEndpoint:kMixiApiRevokeEndpoint]) {
            [self dismissIfParentViewControllerExists];
        }
    }
    else if ([self notifyError:error withEndpoint:kMixiApiUnknownEndpoint]) {
        // do nothing
    }
    else {
        [self dismissIfParentViewControllerExists];
        //__START__REMOVE_WHEN_RELEASED__
        MixiUtilShowError(error);
        //__END__REMOVE_WHEN_RELEASED__
    }
}

- (void)mixi:(Mixi*)mixi didFailWithError:(NSError*)error {
    if ([self notifyError:error withEndpoint:kMixiApiUnknownEndpoint]) {
        // do nothing
    }
    else {
        [self dismissIfParentViewControllerExists];
        //__START__REMOVE_WHEN_RELEASED__
        MixiUtilShowError(error);
        //__END__REMOVE_WHEN_RELEASED__
    }
}

#pragma mark - Private

- (NSURL*)tokenURL:(NSArray*)permissions {
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@?client_id=%@&reponse_code=code&scope=%@&display=touch", 
                                 kMixiConnectAuthorizeURL, mixi_.config.clientId, [permissions componentsJoinedByString:@"%20"]]];
}

- (NSURL*)revokeURL {
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@%@?client_id=%@&token=%@&display=touch", 
                                 kMixiApiBaseUrl, kMixiApiRevokeEndpoint, mixi_.config.clientId, self.refreshToken]];
}

- (BOOL)notifySuccessWithEndpoint:(NSString*)endpoint {
    if (self.delegate && [self.delegate respondsToSelector:@selector(authorizer:didSuccessWithEndpoint:)]) {
        [self.delegate authorizer:self didSuccessWithEndpoint:endpoint];
        return YES;
    }
    else {
        return NO;
    }
}

- (BOOL)notifyCancelWithEndpoint:(NSString*)endpoint {
    if (self.delegate && [self.delegate respondsToSelector:@selector(authorizer:didCancelWithEndpoint:)]) {
        [self.delegate authorizer:self didCancelWithEndpoint:endpoint];
        return YES;
    }
    else {
        return NO;
    }
}

- (BOOL)notifyError:(NSError*)error withEndpoint:(NSString*)endpoint {
    if (self.delegate && [self.delegate respondsToSelector:@selector(authorizer:didFailWithEndpoint:error:)]) {
        [self.delegate authorizer:self didFailWithEndpoint:endpoint error:error];
        return YES;
    }
    else {
        return NO;
    }
}

- (BOOL)dismissIfParentViewControllerExists {
    if (self.parentViewController) {
        [self.parentViewController dismissModalViewControllerAnimated:YES];
        return YES;
    }
    else {
        return NO;
    }
}

@end
