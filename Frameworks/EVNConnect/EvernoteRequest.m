//
//  EvernoteRequest.m
//  EVNConnect
//
//  Created by Kentaro ISHITOYA on 12/02/03.
//  Copyright (c) 2012 Kentaro ISHITOYA. All rights reserved.
//

#import "EvernoteRequest.h"
#import "Evernote.h"

//-----------------------------------------------------------------------------
//Private Implementations
//-----------------------------------------------------------------------------
@interface EvernoteRequest(PrivateImplementation)
@end

@implementation EvernoteRequest(PrivateImplementation)
@end

//-----------------------------------------------------------------------------
//Public Implementations
//-----------------------------------------------------------------------------
@implementation EvernoteRequest
@synthesize noteStoreClient = noteStoreClient_;
@synthesize delegate;
@dynamic url;
@dynamic method;

/*!
 * initialize
 */
- (id)initWithAuthToken:(NSString *)authToken noteStoreClientFactory:(id<EvernoteNoteStoreClientFactoryDelegate>)noteStoreClientFactory delegate:(id<EvernoteRequestDelegate>)inDelegate andContextDelegate:(id<EvernoteContextDelegate>)contextDelegate{
    self = [super init];
    if(self){
        authToken_ = authToken;
        noteStoreClientFactory_ = noteStoreClientFactory;
        contextDelegate_ = contextDelegate;
        self.delegate = inDelegate;
        noteStoreClient_ = [noteStoreClientFactory_ createAsynchronousNoteStoreClientWithDelegate:self];
    }
    return self;
}

/*!
 * cancel operation
 */
-(void)abort{
    [noteStoreClient_.httpClient abort];
}

/*!
 * get url
 */
- (NSURL *)url{
    return noteStoreClient_.httpClient.url;
}

/*!
 * get method
 */
- (NSString *)method{
    return noteStoreClient_.httpClient.method;
}

#pragma mark - EvernoteHTTPClientDelegate
/*!
 * client loading start
 */
- (void)clientLoading:(EvernoteHTTPClient *)client{
    if([self.delegate respondsToSelector:@selector(requestLoading:)]){
        [self.delegate requestLoading:self];
    }
}

/*!
 * did receive first response
 */
- (void)client:(EvernoteHTTPClient *)client didReceiveResponse:(NSURLResponse *)response{
    if([self.delegate respondsToSelector:@selector(request:didReceiveResponse:)]){
        [self.delegate request:self didReceiveResponse:response];
    }
}

/*!
 * progress
 */
- (void)client:(EvernoteHTTPClient *)client didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite{
    if([self.delegate respondsToSelector:@selector(request:didSendBodyData:totalBytesWritten:totalBytesExpectedToWrite:)]){
        [self.delegate request:self didSendBodyData:bytesWritten totalBytesWritten:totalBytesWritten totalBytesExpectedToWrite:totalBytesExpectedToWrite];
    }
}

/*!
 * client did faild with error
 */
- (void)client:(EvernoteHTTPClient *)client didFailWithError:(NSError *)error{
    if([self.delegate respondsToSelector:@selector(request:didFailWithError:)]){
        [self.delegate request:self didFailWithError:error];
    }    
}

/*!
 * did load
 */
- (void)client:(EvernoteHTTPClient *)client didLoad:(id)result{
    if([self.delegate respondsToSelector:@selector(request:didLoad:)]){
        [self.delegate request:self didLoad:result];
    }
}

/*!
 * did load raw response
 */
- (void)client:(EvernoteHTTPClient *)client didLoadRawResponse:(NSData *)data{
    if([self.delegate respondsToSelector:@selector(request:didLoadRawResponse:)]){
        [self.delegate request:self didLoadRawResponse:data];
    }
}
@end