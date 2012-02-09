//
//  EDAMUserStoreClient+PrivateMethods.h
//  Category to show hidden send_*, recv_* methods
//
//  Created by conv.php on 2012/02/09 21:05:08.
//  Copyright (c) 2012 Kentaro ISHITOYA. All rights reserved.
//

#import "UserStore.h"	
@interface EDAMUserStoreClient(PrivateMethods)
- (void) send_checkVersion: (NSString *) clientName : (int16_t) edamVersionMajor : (int16_t) edamVersionMinor;
- (BOOL) recv_checkVersion;
- (void) send_authenticate: (NSString *) username : (NSString *) password : (NSString *) consumerKey : (NSString *) consumerSecret;
- (EDAMAuthenticationResult *) recv_authenticate;
- (void) send_refreshAuthentication: (NSString *) authenticationToken;
- (EDAMAuthenticationResult *) recv_refreshAuthentication;
- (void) send_getUser: (NSString *) authenticationToken;
- (EDAMUser *) recv_getUser;
- (void) send_getPublicUserInfo: (NSString *) username;
- (EDAMPublicUserInfo *) recv_getPublicUserInfo;
- (void) send_getPremiumInfo: (NSString *) authenticationToken;
- (EDAMPremiumInfo *) recv_getPremiumInfo;
@end
