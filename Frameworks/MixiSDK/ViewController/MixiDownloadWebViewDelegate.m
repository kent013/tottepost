//
//  MixiDownloadWebViewDelegate.m
//
//  Created by Platform Service Department on 11/08/23.
//  Copyright 2011 mixi Inc. All rights reserved.
//

#import "MixiDownloadWebViewDelegate.h"


@implementation MixiDownloadWebViewDelegate

@synthesize closeTarget=closeTarget_, closeAction=closeAction_;

- (id)initWithCloseTarget:(id)target action:(SEL)action {
    if ((self = [super init])) {
        self.closeTarget = target;
        self.closeAction = action;
    }
    return self;
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if ([[[request URL] host] isEqualToString:@"cancel"]) {
        if (self.closeTarget && self.closeAction) {
            [self.closeTarget performSelector:self.closeAction];
        }
        return NO;
    }
    else if ([[[request URL] scheme] isEqualToString:@"itms"]) {
        NSURL *url = [NSURL URLWithString:[[[request URL] absoluteString] stringByReplacingOccurrencesOfString:@"itms://" withString:@"http://"]];
        [[UIApplication sharedApplication] openURL:url];
        return NO;
    }
    return YES;
}

- (void)dealloc {
    self.closeTarget = nil;
    self.closeAction = nil;
    [super dealloc];
}

@end
