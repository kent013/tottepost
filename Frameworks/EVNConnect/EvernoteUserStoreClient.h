//
//  EvernoteUserStoreClient.m
//  Wrapper class of EDAMUserStoreClient
//
//  Created by conv.php on 2012/02/09 21:05:08.
//  Copyright (c) 2012 Kentaro ISHITOYA. All rights reserved.
//


#import "UserStore.h"
#import "EvernoteProtocol.h"

@interface EvernoteUserStoreClient : EDAMUserStoreClient{
    __weak id<EvernoteHTTPClientDelegate> delegate_;
}
@property (nonatomic, readonly) EvernoteHTTPClient *httpClient;
- (void) checkVersion: (NSString *) clientName : (int16_t) edamVersionMajor : (int16_t) edamVersionMinor andDelegate:(id<EvernoteHTTPClientDelegate>) delegate;
- (void) authenticate: (NSString *) username : (NSString *) password : (NSString *) consumerKey : (NSString *) consumerSecret andDelegate:(id<EvernoteHTTPClientDelegate>) delegate;
- (void) refreshAuthentication: (NSString *) authenticationToken andDelegate:(id<EvernoteHTTPClientDelegate>) delegate;
- (void) getUser: (NSString *) authenticationToken andDelegate:(id<EvernoteHTTPClientDelegate>) delegate;
- (void) getPublicUserInfo: (NSString *) username andDelegate:(id<EvernoteHTTPClientDelegate>) delegate;
- (void) getPremiumInfo: (NSString *) authenticationToken andDelegate:(id<EvernoteHTTPClientDelegate>) delegate;
@end
