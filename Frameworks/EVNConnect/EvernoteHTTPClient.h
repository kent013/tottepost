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
    NSMutableData *data_;
    NSError *error_;
    BOOL isExecuting;
    BOOL isCancelled;
}

@property(nonatomic, strong) NSString *method;
@property(nonatomic, weak) id<EvernoteHTTPClientDelegate> delegate;
@property(nonatomic, readonly) NSURL *url;

- (void) fetchAsync;
- (id)initWithURL:(NSURL *)aURL andDelegate:(id<EvernoteHTTPClientDelegate>)delegate;
- (id)initWithURL:(NSURL *)aURL userAgent:(NSString *)userAgent timeout:(int)timeout andDelegate:(id<EvernoteHTTPClientDelegate>)delegate;
- (void) finish;
- (void) abort;
@end
