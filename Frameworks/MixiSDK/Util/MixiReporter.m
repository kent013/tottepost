//
//  MixiReporter.m
//
//  Created by Platform Service Department on 11/08/12.
//  Copyright 2011 mixi Inc. All rights reserved.
//

#import "MixiReporter.h"
#import "Mixi.h"
#import "MixiConfig.h"
#import "MixiConstants.h"
#import "MixiRequest.h"

#define kMixiDefaultMaxRetryCount INT_MAX

/** \cond */
@interface MixiReporter (Private)
/* 二度目以降のAPI呼び出し */
- (void)pingNextWithMixi:(Mixi*)mixi;

/* API呼び出し */
- (void)rawPingWithMixi:(Mixi*)mixi;
@end
/** \endcond */

@implementation MixiReporter

@synthesize endpoint=endpoint_,
    maxRetryCount=maxRetryCount_,
    connection=connection_,
    successDate=successDate_;

#pragma mark - Initialize

+ (id)pingReporter {
    return [[[self alloc] initWithEndpoint:kMixiApiPingEndpoint] autorelease];
}

+ (id)mapReporter {
    return [[[self alloc] initWithEndpoint:kMixiApiMapEndpoint] autorelease];
}

- (id)init {
    return [self initWithEndpoint:kMixiApiPingEndpoint];
}

- (id)initWithEndpoint:(NSString*)endpoint {
    if ((self = [super init])) {
        delay_ = 1;
        self.maxRetryCount = kMixiDefaultMaxRetryCount;
        self.endpoint = endpoint;
        self.successDate = [NSDate distantPast];
    }
    return self;
}

- (void)dealloc {
    self.endpoint = nil;
    [self.connection cancel];
    self.connection = nil;
    self.successDate = nil;
    [super dealloc];
}

#pragma mark - Retry

- (int)retry {
    return self.maxRetryCount;
}

- (void)setRetry:(int)retry {
    self.maxRetryCount = retry;
}

- (void)setRetryNever {
    self.maxRetryCount = 0;
}

- (void)setRetryForever {
    self.maxRetryCount = INT_MAX;
}

- (void)setMaxRetryCount:(int)maxRetryCount {
    maxRetryCount_ = maxRetryCount;
    retryCount_ = maxRetryCount;
}

#pragma mark - Ping

- (void)ping {
    [self pingWithMixi:[Mixi sharedMixi]];
}

- (void)pingIfNeededWithMixi:(Mixi*)mixi {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMdd"];
    if (![[dateFormatter stringFromDate:[NSDate date]] isEqualToString:[dateFormatter stringFromDate:self.successDate]]) {
        [self pingWithMixi:mixi];
    }
    [dateFormatter release];
}

- (void)pingWithMixi:(Mixi*)mixi {
    delay_ = 1;
    [self rawPingWithMixi:mixi];
}

- (void)pingNextWithMixi:(Mixi*)mixi {
    if (0 < retryCount_) {
        retryCount_--;
        delay_ *= 2;
        self.connection = nil;    
        [self performSelector:@selector(rawPingWithMixi:) withObject:mixi afterDelay:delay_];    
    }
    else {
        [self cancel];
    }
}

- (void)rawPingWithMixi:(Mixi*)mixi {
//    if (mixi.config.selectorType == kMixiApiTypeSelectorMixiApp) {
//        NSLog(@"Graph APIでは利用できません。mixiアプリでのみ利用可能です。");
//    }
//    else {
        MixiRequest *request = [MixiRequest postRequestWithEndpoint:self.endpoint];
        request.openMixiAppToAuthorizeIfNeeded = NO;
        self.connection = [mixi sendRequest:request delegate:self];
//    }
}

#pragma mark -

- (void)cancel {
    if (self.connection) {
        [self.connection cancel];
    }
    delay_ = 1;
    retryCount_ = self.maxRetryCount;
}

#pragma mark - Getter/Setter

- (void)setConnection:(NSURLConnection *)connection {
    if (self.connection != connection) {
        [self.connection cancel];
        [self.connection release];
        connection_ = [connection retain];
    }
}

#pragma mark - MixiDelegate

- (void)mixi:(Mixi*)mixi didFinishLoading:(NSString*)data {
    delay_ = 1;
    retryCount_ = self.maxRetryCount;
    self.connection = nil;
    self.successDate = [NSDate date];
}

//- (void)mixi:(Mixi*)mixi didCancelWithConnection:(NSURLConnection*)connection {
//    [self pingNextWithMixi:mixi];
//}

- (void)mixi:(Mixi*)mixi didFailWithConnection:(NSURLConnection*)connection error:(NSError*)error {
    [self pingNextWithMixi:mixi];
}

- (void)mixi:(Mixi*)mixi didFailWithError:(NSError*)error {
    [self pingNextWithMixi:mixi];
}

- (BOOL)allowBlankResponse {
    return YES;
}


@end
