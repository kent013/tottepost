//
//  EvernoteRequest.h
//  EVNConnect
//
//  Created by Kentaro ISHITOYA on 12/02/03.
//  Copyright (c) 2012 Kentaro ISHITOYA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "EvernoteNoteStoreClient.h"
#import "EvernoteUserStoreClient.h"
#import "EvernoteProtocol.h"
#import "EvernoteHTTPClient.h"

@class Evernote;
@protocol EvernoteContextDelegate;

@interface EvernoteRequest : NSObject<EvernoteHTTPClientDelegate> {
    __strong EvernoteNoteStoreClient *noteStoreClient_;
    __strong EvernoteUserStoreClient *userStoreClient_;
    __strong NSString *authToken_;
    id<EvernoteContextDelegate> contextDelegate_;
    id<EvernoteStoreClientFactoryDelegate> storeClientFactory_;
}

@property (nonatomic, assign) id<EvernoteRequestDelegate> delegate;
@property (nonatomic, readonly) EvernoteNoteStoreClient *noteStoreClient;
@property (nonatomic, readonly) EvernoteUserStoreClient *userStoreClient;
@property (nonatomic, readonly) NSURL *url;
@property (nonatomic, readonly) NSString *method;

-(id) initWithAuthToken:(NSString *)authToken noteStoreClientFactory:(id<EvernoteStoreClientFactoryDelegate>)storeClientFactory delegate:(id<EvernoteRequestDelegate>) delegate andContextDelegate:(id<EvernoteContextDelegate>)contextDelegate;
-(void) abort;

@end

@protocol EvernoteContextDelegate <NSObject>
- (void)request:(EvernoteRequest *)request didFailWithException:(NSException *)exception;
@end

