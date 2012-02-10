//
//  MixiUrlDelegate.m
//
//  Created by Platform Service Department on 11/06/30.
//  Copyright 2011 mixi Inc. All rights reserved.
//

#import "MixiURLDelegate.h"
#import "MixiDelegate.h"
#import "MixiErrorCodes.h"
#import "JSON.h"

/** \cond PRIVATE */
@interface MixiURLDelegate (Private)
/** [プライベート] サブクラスはこのメソッドを上書きしてJSONを処理します */
- (void)successWithJson:(NSDictionary*)json;
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
        return;
    }
    
    NSString *result = [[[NSString alloc] initWithData:data_ encoding:NSUTF8StringEncoding] autorelease];
    if ([self.delegate respondsToSelector:@selector(mixi:didFinishLoading:)]) {
        [self.delegate mixi:self.mixi didFinishLoading:result];
    }
    
    NSError *error = nil;
    SBJsonParser *parser = [[[SBJsonParser alloc] init] autorelease];
    NSDictionary *json = [parser objectWithString:result];
    if (error) {
        if ([self.delegate respondsToSelector:@selector(mixi:didFailWithError:)]) {
            [self.delegate mixi:self.mixi didFailWithError:error];
        }
    }
    else {
        id jsonError = [json objectForKey:@"error"];
        if (jsonError != nil && ![[NSNull null] isEqual:jsonError]) {
            if ([self.delegate respondsToSelector:@selector(mixi:didFailWithError:)]) {
                error = [NSError errorWithDomain:kMixiErrorDomain code:kMixiAPIErrorInvalidJson userInfo:json];
                [self.delegate mixi:self.mixi didFailWithError:error];
            }
        }
        else {
            [self successWithJson:json];
            if ([self.delegate respondsToSelector:@selector(mixi:didSuccessWithJson:)]) {
                [self.delegate mixi:self.mixi didSuccessWithJson:json];
            }
        }
    }
}

- (void)successWithJson:(NSDictionary*)json {
    // subclass responsibility
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    if ([self.delegate respondsToSelector:@selector(mixi:didFailWithConnection:error:)]) {
        [self.delegate mixi:self.mixi didFailWithConnection:connection error:error];
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
