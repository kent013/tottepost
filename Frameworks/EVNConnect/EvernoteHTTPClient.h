//
//  EvernoteHTTPClient.h
//  EVNConnect
//
//  Created by Kentaro ISHITOYA on 12/02/06.
//  Copyright (c) 2012 Kentaro ISHITOYA. All rights reserved.
//

#import "THTTPClient.h"

@protocol EvernoteHTTPClientDelegate;

@interface EvernoteHTTPClient : THTTPClient<NSURLConnectionDelegate, NSURLConnectionDataDelegate>{
    NSMutableData *data_;
    NSURLConnection *connection_;
    NSError *error_;
    BOOL isExecuting_;
}

@property(nonatomic, strong) NSString *method;
@property(nonatomic, weak) id<EvernoteHTTPClientDelegate> delegate;
@property(nonatomic, readonly) NSURL *url;

- (void) fetchAsync;
- (id)initWithURL:(NSURL *)aURL andDelegate:(id<EvernoteHTTPClientDelegate>)delegate;
- (id)initWithURL:(NSURL *)aURL userAgent:(NSString *)userAgent timeout:(int)timeout andDelegate:(id<EvernoteHTTPClientDelegate>)delegate;
- (void) abort;
@end

@protocol EvernoteHTTPClientDelegate <NSObject>
- (void)clientLoading:(EvernoteHTTPClient*)client;
- (void)client:(EvernoteHTTPClient*)client didReceiveResponse:(NSURLResponse*)response;
- (void)client:(EvernoteHTTPClient*)client didFailWithError:(NSError*)error;
- (void)client:(EvernoteHTTPClient*)client didLoad:(id)result;
- (void)client:(EvernoteHTTPClient*)client didLoadRawResponse:(NSData*)data;
- (void)client:(EvernoteHTTPClient*)client didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite;
@end
