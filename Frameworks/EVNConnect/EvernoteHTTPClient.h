//
//  EvernoteHTTPClient.h
//  EVNConnect
//
//  Created by Kentaro ISHITOYA on 12/02/06.
//  Copyright (c) 2012 Kentaro ISHITOYA. All rights reserved.
//

#import "THTTPClient.h"
#import "EvernoteProtocol.h"

@interface EvernoteHTTPClient : THTTPClient<NSURLConnectionDelegate, NSURLConnectionDataDelegate>{
    __strong NSMutableData *data_;
    __strong NSURLConnection *connection_;
    __strong NSError *error_;
    id target_;
    SEL action_;
}

@property(nonatomic, strong) NSString *method;
@property(nonatomic, assign) id<EvernoteHTTPClientDelegate> delegate;
@property(nonatomic, readonly) NSURL *url;

- (void) setTarget:(id)target action:(SEL)action;
- (id)initWithURL:(NSURL *)aURL andDelegate:(id<EvernoteHTTPClientDelegate>)delegate;
- (id)initWithURL:(NSURL *)aURL userAgent:(NSString *)userAgent timeout:(int)timeout andDelegate:(id<EvernoteHTTPClientDelegate>)delegate;
- (void) abort;
@end
