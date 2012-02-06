//
//  Evernote.h
//  EVNConnect
//
//  Created by Kentaro ISHITOYA on 12/02/03.
//  Copyright (c) 2012 Kentaro ISHITOYA. All rights reserved.
//

#import "EvernoteProtocol.h"
#import "EvernoteRequest.h"

@protocol EvernoteSessionDelegate;

/*!
 * evernote wrapper class
 */
@interface Evernote : NSObject<EvernoteAuthDelegate, EvernoteContextDelegate>{
    __strong NSMutableSet *requests_;
    __strong id<EvernoteAuthProtocol> authConsumer_;
    __weak id<EvernoteSessionDelegate> sessionDelegate_;
    EvernoteAuthType authType_;

    BOOL useSandbox_;
}
@property(nonatomic, weak) id<EvernoteSessionDelegate> sessionDelegate;

#pragma - authentication
- (id)initWithAuthType:(EvernoteAuthType) authType
           consumerKey:(NSString*)consumerKey
        consumerSecret:(NSString*)consumerSecret
        callbackScheme:(NSString*)callbackScheme
            useSandBox:(BOOL) useSandbox
           andDelegate:(id<EvernoteSessionDelegate>)delegate;
- (EvernoteRequest *) requestWithDelegate:(id<EvernoteRequestDelegate>)delegate;

- (BOOL)handleOpenURL:(NSURL *)url;
- (void)login;
- (void)logout;
- (BOOL)isSessionValid;
- (void)saveCredential;
- (void)loadCredential;
- (void)clearCredential;
@end

@protocol EvernoteSessionDelegate <NSObject>
- (void)evernoteDidLogin;
- (void)evernoteDidNotLogin;
- (void)evernoteDidLogout;

@end
