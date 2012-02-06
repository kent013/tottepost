//
//  EvernoteAuth.h
//  EVNConnect
//
//  Created by Kentaro ISHITOYA on 12/02/03.
//  Copyright (c) 2012 Kentaro ISHITOYA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EvernoteProtocol.h"

@interface EvernoteAuth : NSObject{
  @protected
    __strong NSString *callbackScheme_;
    __strong NSString *consumerKey_;
    __strong NSString *consumerSecret_;
    __strong NSString *shardId_;
    __strong NSString *userId_;
    __strong NSString *authToken_;
    __weak id<EvernoteAuthDelegate> delegate_;
    BOOL useSandBox_;
}
@property (nonatomic, readonly) NSString *shardId;
@property (nonatomic, readonly) NSString *userId;
@property (nonatomic, readonly) NSString *authToken;
- (id)initWithConsumerKey:(NSString *)consumerKey consumerSecret:(NSString *)consumerSecret callbackScheme:(NSString *)callbackScheme useSandBox:(BOOL)useSandBox andDelegate:(id<EvernoteAuthDelegate>)delegate;
- (NSURL *) requestTokenURL;
- (NSURL *) authenticationURL;
- (void)evernoteDidLogin;
- (void)evernoteDidNotLogin;
- (void)clearCredential;
- (void)setAuthToken:(NSString *)authToken userId:(NSString *)userId andShardId:(NSString *)shardId;
@end
