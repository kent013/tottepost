//
//  MinusAuth.h
//  EVNConnect
//
//  Created by Kentaro ISHITOYA on 12/02/03.
//  Copyright (c) 2012 Kentaro ISHITOYA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MinusProtocol.h"
#import "NXOAuth2.h"

@protocol MinusAuthDelegate;

/*!
 * minus auth object
 */
@interface MinusAuth : NSObject{
  @protected
    __strong NSString *clientId_;
    __strong NSString *clientSecret_;
    
    __strong NSMutableData *data_;
    id<MinusAuthDelegate> delegate_;
}

@property (nonatomic, readonly) NXOAuth2Account *credential;

- (id)initWithClientId:(NSString *)clientId 
          clientSecret:(NSString *)clientSecret 
           andDelegate:(id<MinusAuthDelegate>)delegate;
- (void)loginWithUsername:(NSString *)username password:(NSString *)password andPermission:(NSArray *)permission;
- (void)logout;
- (void)minusDidLogin;
- (void)minusDidLogout;
- (void)minusDidNotLogin;
- (void)clearCredential;
- (void)refreshCredentialWithUsername:(NSString *)username password:(NSString *)password  andPermission:(NSArray *)permission;
- (BOOL)isSessionValid;
@end

/*!
 * delegate for consumer engine
 */
@protocol MinusAuthDelegate <NSObject>
- (void)minusDidLogin;
- (void)minusDidNotLogin;
- (void)minusDidLogout;
@end