//
//  MixiUtils.m
//
//  Created by Platform Service Department on 11/07/01.
//  Copyright 2011 mixi Inc. All rights reserved.
//

#import "MixiUtils.h"
#import "Mixi.h"
#import "MixiConstants.h"
#import "MixiWebViewController.h"
#import "MixiDownloadWebViewDelegate.h"
#import "Reachability.h"

#pragma GCC diagnostic ignored "-Wmissing-prototypes"

NSString* MixiUtilEncodeURIComponent(NSString* aString) {
    return [((NSString*)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                (CFStringRef)aString,
                                                                NULL,
                                                                (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                kCFStringEncodingUTF8)) autorelease];
}

BOOL MixiUtilIsReachable() {
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    return NotReachable != [reachability currentReachabilityStatus];
}

BOOL MixiUtilIsJson(NSString *s) {
    return ([s hasPrefix:@"{"] && [s hasSuffix:@"}"]) 
        || ([s hasPrefix:@"["] && [s hasSuffix:@"]"]) 
        || ([s hasPrefix:@"("] && [s hasSuffix:@")"]);
}

NSArray* MixiUtilBundleURLSchemes() {
    NSArray *urlTypes = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleURLTypes"];
    NSDictionary *urlType = [urlTypes objectAtIndex:0];
    return [urlType objectForKey:@"CFBundleURLSchemes"];
}

NSString* MixiUtilFirstBundleURLScheme() {
    NSArray *urlSchemes = MixiUtilBundleURLSchemes();
    if ([urlSchemes count] == 0) return nil;
    return [urlSchemes objectAtIndex:0];
}

NSDictionary* MixiUtilParseURLOptions(NSURL* url) {
    return MixiUtilParseURLOptionsByString(url, @"#");
}

NSDictionary* MixiUtilParseURLOptionsByString(NSURL* url, NSString* sep) {
    return MixiUtilParseURLStringOptionsByString([url absoluteString], sep);
}

NSDictionary* MixiUtilParseURLStringOptions(NSString* url) {
    return MixiUtilParseURLStringOptionsByString(url, @"#");
}

NSDictionary* MixiUtilParseURLStringOptionsByString(NSString* url, NSString* sep) {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    NSArray *parts = [url componentsSeparatedByString:sep];
    if ([parts count] < 2) return params;
    NSString *paramsStr = (NSString*)[parts lastObject];
    NSArray *pairs = [paramsStr componentsSeparatedByString:@"&"];
    for (NSString *pair in pairs) {
        NSArray *keyValue = [pair componentsSeparatedByString:@"="];
        [params setValue:[keyValue objectAtIndex:1] forKey:[keyValue objectAtIndex:0]];
    }
    return params;
}

void MixiUtilShowError(NSError* error) {
    NSString *errorMessage = [[error userInfo] objectForKey:@"message"];
    if (!errorMessage) errorMessage = [[error userInfo] description];
        MixiUtilShowErrorMessage(errorMessage);
}

void MixiUtilShowErrorMessage(NSString* errorMessage) {
    MixiUtilShowMessageTitle(errorMessage, @"Error");
}

void MixiUtilShowMessageTitle(NSString* message, NSString* title) {
    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:title 
                                                     message:message
                                                    delegate:nil 
                                           cancelButtonTitle:@"OK" 
                                           otherButtonTitles:nil] autorelease];
    [alert show]; 
}

MixiWebViewController* MixiUtilDownloadViewController(id target, SEL action) {
    MixiWebViewController *vc = [[[MixiWebViewController alloc] initWithURL:kMixiOfficialAppDownloadURL] autorelease];
    vc.delegate = [[MixiDownloadWebViewDelegate alloc] initWithCloseTarget:target action:action];
    return vc;
}

void MixiUtilDissmissRequestViewIfNeeded() {
    Mixi *mixi = [Mixi sharedMixi];
    if (mixi.mixiViewController) [mixi.mixiViewController dismissModalViewControllerAnimated:YES];
}

NSString* MixiUtilGetRequestIdFromURL(NSURL* url) {
    return [[url query] stringByReplacingOccurrencesOfString:@"mixi_request_id=" withString:@""];
}
