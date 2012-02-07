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
 * flush
 */
- (void)flush{
    if([self.delegate respondsToSelector:@selector(clientLoading:)]){
        [self.delegate clientLoading:self];
    }
    [mRequest setHTTPBody: mRequestData];
    
    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(fetchAsync) object:nil];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperation:operation];
    [operation waitUntilFinished];
    
    // phew!
    [mRequestData setLength: 0];
    mResponseDataOffset = 0;
    mResponseData = data_;
    data_ = nil;
    if (mResponseData == nil && isCancelled == NO) {
        @throw [TTransportException exceptionWithName: @"TTransportException"
                                               reason: @"Could not make HTTP request"
                                                error: error_];
    }
    if([self.delegate respondsToSelector:@selector(client:didLoad:)]){
        [self.delegate client:self didLoad:mResponseData];
    }
    if([self.delegate respondsToSelector:@selector(client:didLoadRawResponse:)]){
        [self.delegate client:self didLoadRawResponse:mResponseData];
    }
}

/*!
 * request with asynchronus
 */
- (void)fetchAsync{    
    if ([NSThread isMainThread] == NO)
    {
        [self performSelectorOnMainThread:@selector(fetchAsync) withObject:nil waitUntilDone:YES];
        return;
    }

    // make the HTTP request
    [self setValue:[NSNumber numberWithBool:YES] forKey:@"isExecuting"];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:mRequest delegate:self startImmediately:NO];
    if(connection == nil){
        [self setValue:[NSNumber numberWithBool:NO] forKey:@"isExecuting"];
    }
    NSLog(@"operation will call, %@", self.hash);
    [connection start];
    do{
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1]];
        //[[NSRunLoop mainRunLoop] runMode:NSDefaultRunLoopMode
        //                         beforeDate:[NSDate distantFuture]];
        if(isCancelled){
            [self finish];
            break;
        }
    } while (isExecuting);
    NSLog(@"operation did called %@", self.hash);
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
    [self finish];
    if([self.delegate respondsToSelector:@selector(client:didFailWithError:)]){
        [self.delegate client:self didFailWithError:error];
    }
}

/*!
 * did finish loading
 */
-(void)connectionDidFinishLoading:(NSURLConnection*)connection
{
    [self finish];
}

/*!
 * finish operation
 */
- (void)finish{
    [self setValue:[NSNumber numberWithBool:NO] forKey:@"isExecuting"];
}

/*!
 * cancel operation
 */
- (void)abort{
    //[operation_ abort];
    [self setValue:[NSNumber numberWithBool:YES] forKey:@"isCancelled"];
}

/*!
 * url
 */
- (NSURL *)url{
    return mURL;
}
@end
