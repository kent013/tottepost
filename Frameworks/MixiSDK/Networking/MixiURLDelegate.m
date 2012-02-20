//
//  MixiUrlDelegate.m
//
//  Created by Platform Service Department on 11/06/30.
//  Copyright 2011 mixi Inc. All rights reserved.
//

#import "MixiURLDelegate.h"
#import "MixiDelegate.h"
#import "MixiErrorCodes.h"
#import "SBJson.h"

/** \cond PRIVATE */
@interface MixiURLDelegate (Private)
/** [プライベート] サブクラスはこのメソッドを上書きしてJSONを処理します */
- (void)successWithJson:(id)json;
@end
/** \endcond */

@implementation MixiURLDelegate

@synthesize mixi=mixi_, 
    delegate=delegate_;

#pragma mark - Initialize

+ (id)delegateWithMixi:(Mixi*)mixi delegate:(id<MixiDelegate>)delegate {
    return [[[self alloc] initWithMixi:mixi delegate:delegate] autorelease];
}

- (id)initWithMixi:(Mixi*)mixi delegate:(id<MixiDelegate>)delegate {
    if ((self = [super init])) {
        self.mixi = mixi;
        self.delegate = delegate;
        data_ = [[NSMutableData alloc] init];
    }
    return self;
}

#pragma mark - NSURLConnection delegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [data_ setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [data_ appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if ([data_ length] == 0 && [self.delegate respondsToSelector:@selector(allowBlankResponse)] && [self.delegate allowBlankResponse]) {
        if ([self.delegate respondsToSelector:@selector(mixi:didFinishLoading:)]) {
            [self.delegate mixi:self.mixi didFinishLoading:@""];
        }
        if ([self.delegate respondsToSelector:@selector(mixi:andConnection:didFinishLoading:)]) {
            [self.delegate mixi:self.mixi andConnection:connection didFinishLoading:@""];
        }
        return;
    }
    
    NSString *result = [[[NSString alloc] initWithData:data_ encoding:NSUTF8StringEncoding] autorelease];
    if ([self.delegate respondsToSelector:@selector(mixi:didFinishLoading:)]) {
        [self.delegate mixi:self.mixi didFinishLoading:result];
    }
    if ([self.delegate respondsToSelector:@selector(mixi:andConnection:didFinishLoading:)]) {
        [self.delegate mixi:self.mixi andConnection:connection didFinishLoading:@""];
    }
    
    NSError *error = nil;
    SBJSON *parser = [[[SBJSON alloc] init] autorelease];
    id json = [parser objectWithString:result error:&error];
    if (error) {
        if ([self.delegate respondsToSelector:@selector(mixi:didFailWithError:)]) {
            [self.delegate mixi:self.mixi didFailWithError:error];
        }
        if ([self.delegate respondsToSelector:@selector(mixi:andConnection:didFailWithError:)]) {
            [self.delegate mixi:self.mixi andConnection:connection didFailWithError:error];
        }
    }
    else {
        id jsonError = [json respondsToSelector:@selector(objectForKey:)] ? [json objectForKey:@"error"] : nil;
        if (jsonError != nil && ![[NSNull null] isEqual:jsonError]) {
            error = [NSError errorWithDomain:kMixiErrorDomain code:kMixiAPIErrorInvalidJson userInfo:json];
            if ([self.delegate respondsToSelector:@selector(mixi:didFailWithError:)]) {
                [self.delegate mixi:self.mixi didFailWithError:error];
            }            
            if ([self.delegate respondsToSelector:@selector(mixi:andConnection:didFailWithError:)]) {
                [self.delegate mixi:self.mixi andConnection:connection didFailWithError:error];
            }
        }
        else {
            [self successWithJson:json];
            if ([self.delegate respondsToSelector:@selector(mixi:didSuccessWithJson:)]) {
                [self.delegate mixi:self.mixi didSuccessWithJson:json];
            }
            if ([self.delegate respondsToSelector:@selector(mixi:andConnection:didSuccessWithJson:)]) {
                [self.delegate mixi:self.mixi andConnection:connection didSuccessWithJson:json];
            }
        }
    }
}

- (void)successWithJson:(id)json {
    // subclass responsibility
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    if ([self.delegate respondsToSelector:@selector(mixi:didFailWithConnection:error:)]) {
        [self.delegate mixi:self.mixi didFailWithConnection:connection error:error];
    }
    if ([self.delegate respondsToSelector:@selector(mixi:andConnection:didFailWithError:)]){
        [self.delegate mixi:self.mixi andConnection:connection didFailWithError:error];
    }
}

/*!
 * progress
 */
- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite{
    if([self.delegate respondsToSelector:@selector(mixi:andConnection:didSendBodyData:totalBytesWritten:totalBytesExpectedToWrite:)]){
        [self.delegate mixi:self.mixi andConnection:connection didSendBodyData:bytesWritten totalBytesWritten:totalBytesWritten totalBytesExpectedToWrite:totalBytesExpectedToWrite];
    }
}


#pragma mark -

- (void)dealloc {
    self.mixi = nil;
    self.delegate = nil;
    if (data_) {
        [data_ release];
        data_ = nil;
    }
    [super dealloc];
}

@end
