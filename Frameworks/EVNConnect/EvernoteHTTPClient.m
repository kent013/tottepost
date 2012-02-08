//
//  EvernoteHTTPClient.m
//  EVNConnect
//
//  Created by Kentaro ISHITOYA on 12/02/06.
//  Copyright (c) 2012 Kentaro ISHITOYA. All rights reserved.
//

#import "EvernoteHTTPClient.h"
#import "TTransportException.h"
#import "TObjective-C.h"

typedef enum EvernoteConnectionStatus {
    EvernoteConnectionStatusReady,
    EvernoteConnectionStatusConnecting,
    EvernoteConnectionStatusDidFinish
} EvernoteConnectionStatus;

@implementation EvernoteHTTPClient
@synthesize delegate;
@synthesize method;
@dynamic url;

/*!
 * KVO key setting
 */
+ (BOOL)automaticallyNotifiesObserversForKey:(NSString*)key {
    if ([key isEqualToString:@"isExecuting"] || 
        [key isEqualToString:@"isCancelled"]) {
        return YES;
    }
    return [super automaticallyNotifiesObserversForKey:key];
}

/*!
 * initialize
 */
- (id)initWithURL:(NSURL *)aURL andDelegate:(id<EvernoteHTTPClientDelegate>)inDelegate{
    return [self initWithURL:aURL userAgent:nil timeout:0 andDelegate:inDelegate];
}

/*!
 * initialize
 */
- (id)initWithURL:(NSURL *)aURL userAgent:(NSString *)userAgent timeout:(int)timeout andDelegate:(id<EvernoteHTTPClientDelegate>)inDelegate{
    self = [super initWithURL:aURL userAgent:userAgent timeout:timeout];
    if(self){
        self.delegate = inDelegate;
    }
    return self;
}

/*!
 * set target
 */
- (void)setTarget:(id)target action:(SEL)action{
    target_ = target;
    action_ = action;
}

/*!
 * flush
 */
- (void)flush{
    /*if ([NSThread isMainThread] == NO)
    {
        [self performSelectorOnMainThread:@selector(flush) withObject:nil waitUntilDone:YES];
        return;
    }*/
    if([self.delegate respondsToSelector:@selector(clientLoading:)]){
        [self.delegate clientLoading:self];
    }
    [mRequest setHTTPBody: mRequestData];
    
    connection_ = [[NSURLConnection alloc] initWithRequest:mRequest delegate:self startImmediately:NO];
    if(connection_ == nil){
        [self setValue:[NSNumber numberWithBool:NO] forKey:@"isExecuting"];
    }

    [connection_ start];
}

#pragma - NSURLConnection delegates
/*!
 * did receive response
 */
-(void)connection:(NSURLConnection*)connection didReceiveResponse:(NSURLResponse*)response
{
    data_ = [[NSMutableData alloc] init]; // _data being an ivar
    
    NSHTTPURLResponse * httpResponse = (NSHTTPURLResponse *) response;
    if ([httpResponse statusCode] != 200) {
        @throw [TTransportException exceptionWithName: @"TTransportException"
                                               reason: [NSString stringWithFormat: @"Bad response from HTTP server: %d",
                                                        [httpResponse statusCode]]];
    }
    
    if([self.delegate respondsToSelector:@selector(client:didReceiveResponse:)]){
        [self.delegate client:self didReceiveResponse:response];
    }
}

/*!
 * did recieve data
 */
-(void)connection:(NSURLConnection*)connection didReceiveData:(NSData*)data
{
    [data_ appendData:data];
}

/*!
 * progress
 */
- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite{
    if([self.delegate respondsToSelector:@selector(client:didSendBodyData:totalBytesWritten:totalBytesExpectedToWrite:)]){
        [self.delegate client:self didSendBodyData:bytesWritten totalBytesWritten:totalBytesWritten totalBytesExpectedToWrite:totalBytesExpectedToWrite];
    }
}

/*!
 * did fail with error
 */
-(void)connection:(NSURLConnection*)connection didFailWithError:(NSError*)error
{
    error_ = error;
    if([self.delegate respondsToSelector:@selector(client:didFailWithError:)]){
        [self.delegate client:self didFailWithError:error];
    }
}

/*!
 * did finish loading
 */
-(void)connectionDidFinishLoading:(NSURLConnection*)connection
{
    [mRequestData setLength: 0];
    mResponseDataOffset = 0;
    mResponseData = data_;
    data_ = nil;
    if (mResponseData == nil) {
        @throw [TTransportException exceptionWithName: @"TTransportException"
                                               reason: @"Could not make HTTP request"
                                                error: error_];
    }
    
    [target_ performSelector:action_ withObject:data_];
    if([self.delegate respondsToSelector:@selector(client:didLoadRawResponse:)]){
        [self.delegate client:self didLoadRawResponse:mResponseData];
    }
}

/*!
 * cancel operation
 */
- (void)abort{
    [connection_ cancel];
}

/*!
 * url
 */
- (NSURL *)url{
    return mURL;
}
@end
