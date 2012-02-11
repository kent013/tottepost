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
@synthesize delegate;
@dynamic url;
@dynamic method;
@dynamic noteStoreClient;
@dynamic userStoreClient;

/*!
 * initialize
 */
- (id)initWithAuthToken:(NSString *)authToken noteStoreClientFactory:(id<EvernoteStoreClientFactoryDelegate>)storeClientFactory delegate:(id<EvernoteRequestDelegate>)inDelegate andContextDelegate:(id<EvernoteContextDelegate>)contextDelegate{
    self = [super init];
    if(self){
        authToken_ = authToken;
        storeClientFactory_ = storeClientFactory;
        contextDelegate_ = contextDelegate;
        self.delegate = inDelegate;
    }
    return self;
}

/*!
 * get EvernoteNoteStoreClient
 */
- (EvernoteNoteStoreClient *)noteStoreClient{
    if(noteStoreClient_ == nil){
        noteStoreClient_ = [storeClientFactory_ createAsynchronousNoteStoreClientWithDelegate:self];
    }
    return noteStoreClient_;
}

/*!
 * get EvernoteUserStoreClient
 */
- (EvernoteUserStoreClient *) userStoreClient{
    if(userStoreClient_ == nil){
        userStoreClient_ = [storeClientFactory_ createAsynchronousUserStoreClientWithDelegate:self];
    }
    return userStoreClient_;
}

/*!
 * cancel operation
 */
-(void)abort{
    if(noteStoreClient_){
        [noteStoreClient_.httpClient abort];
    }
    if(userStoreClient_){
        [userStoreClient_.httpClient abort];
    }
}

/*!
 * get url
 */
- (NSURL *)url{
    if(noteStoreClient_){
        return noteStoreClient_.httpClient.url;
    }
    return userStoreClient_.httpClient.url;
}

/*!
 * get method
 */
- (NSString *)method{
    if(noteStoreClient_){
        return noteStoreClient_.httpClient.method;
    }
    return userStoreClient_.httpClient.method;
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
 * client did failed with error
 */
- (void)client:(EvernoteHTTPClient *)client didFailWithError:(NSError *)error{
    if([self.delegate respondsToSelector:@selector(request:didFailWithError:)]){
        [self.delegate request:self didFailWithError:error];
    }    
}

/*!
 * client did failed with exception
 */
- (void)client:(EvernoteHTTPClient *)client didFailWithException:(NSException *)exception{
    if([self.delegate respondsToSelector:@selector(request:didFailWithException:)]){
        [self.delegate request:self didFailWithException:exception];
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