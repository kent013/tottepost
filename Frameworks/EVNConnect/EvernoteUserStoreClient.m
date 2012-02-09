//
//  EvernoteUserStoreClient.m
//  Wrapper class of EDAMUserStoreClient
//
//  Created by conv.php on 2012/02/09 21:05:08.
//  Copyright (c) 2012 Kentaro ISHITOYA. All rights reserved.
//

#import "EvernoteUserStoreClient.h"
#import "EvernoteHTTPClient.h"
#import "UserStore.h"
#import "EDAMUserStoreClient+PrivateMethods.h"	
//-----------------------------------------------------------------------------
//Private Implementations
//-----------------------------------------------------------------------------
@interface EvernoteUserStoreClient(PrivateImplementation)
@end

@implementation EvernoteUserStoreClient(PrivateImplementation)
@end
//-----------------------------------------------------------------------------
//Public Implementations
//-----------------------------------------------------------------------------
@implementation EvernoteUserStoreClient
/*!
 * get httpclient
 */
- (EvernoteHTTPClient *)httpClient{
  EvernoteHTTPClient *client = (EvernoteHTTPClient *)[outProtocol transport];
  return client;
}

/*!
 * send checkVersion request
 */
- (void) checkVersion: (NSString *) clientName : (int16_t) edamVersionMajor : (int16_t) edamVersionMinor andDelegate:(id<EvernoteHTTPClientDelegate>) delegate
{
  EvernoteHTTPClient *client = (EvernoteHTTPClient *)[outProtocol transport];
  delegate_ = delegate;
  client.delegate = delegate;
  [client setTarget:self action:@selector(client:checkVersionDidLoad:)];
  @try{
    [self send_checkVersion: clientName : edamVersionMajor : edamVersionMinor];
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
  }
}
/*!
 * recieve checkVersion result
 */
- (void) client:(EvernoteHTTPClient *)client checkVersionDidLoad:(NSData *)result{
  @try{
    BOOL rawRetval = [self recv_checkVersion];
    NSNumber *retval = [NSNumber numberWithBool:rawRetval];

    if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
      [delegate_ client:client didLoad:retval];
    }
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
  }
}


/*!
 * send authenticate request
 */
- (void) authenticate: (NSString *) username : (NSString *) password : (NSString *) consumerKey : (NSString *) consumerSecret andDelegate:(id<EvernoteHTTPClientDelegate>) delegate
{
  EvernoteHTTPClient *client = (EvernoteHTTPClient *)[outProtocol transport];
  delegate_ = delegate;
  client.delegate = delegate;
  [client setTarget:self action:@selector(client:authenticateDidLoad:)];
  @try{
    [self send_authenticate: username : password : consumerKey : consumerSecret];
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
  }
}
/*!
 * recieve authenticate result
 */
- (void) client:(EvernoteHTTPClient *)client authenticateDidLoad:(NSData *)result{
  @try{
    EDAMAuthenticationResult *retval = [self recv_authenticate];

    if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
      [delegate_ client:client didLoad:retval];
    }
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
  }
}


/*!
 * send refreshAuthentication request
 */
- (void) refreshAuthentication: (NSString *) authenticationToken andDelegate:(id<EvernoteHTTPClientDelegate>) delegate
{
  EvernoteHTTPClient *client = (EvernoteHTTPClient *)[outProtocol transport];
  delegate_ = delegate;
  client.delegate = delegate;
  [client setTarget:self action:@selector(client:refreshAuthenticationDidLoad:)];
  @try{
    [self send_refreshAuthentication: authenticationToken];
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
  }
}
/*!
 * recieve refreshAuthentication result
 */
- (void) client:(EvernoteHTTPClient *)client refreshAuthenticationDidLoad:(NSData *)result{
  @try{
    EDAMAuthenticationResult *retval = [self recv_refreshAuthentication];

    if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
      [delegate_ client:client didLoad:retval];
    }
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
  }
}


/*!
 * send getUser request
 */
- (void) getUser: (NSString *) authenticationToken andDelegate:(id<EvernoteHTTPClientDelegate>) delegate
{
  EvernoteHTTPClient *client = (EvernoteHTTPClient *)[outProtocol transport];
  delegate_ = delegate;
  client.delegate = delegate;
  [client setTarget:self action:@selector(client:getUserDidLoad:)];
  @try{
    [self send_getUser: authenticationToken];
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
  }
}
/*!
 * recieve getUser result
 */
- (void) client:(EvernoteHTTPClient *)client getUserDidLoad:(NSData *)result{
  @try{
    EDAMUser *retval = [self recv_getUser];

    if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
      [delegate_ client:client didLoad:retval];
    }
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
  }
}


/*!
 * send getPublicUserInfo request
 */
- (void) getPublicUserInfo: (NSString *) username andDelegate:(id<EvernoteHTTPClientDelegate>) delegate
{
  EvernoteHTTPClient *client = (EvernoteHTTPClient *)[outProtocol transport];
  delegate_ = delegate;
  client.delegate = delegate;
  [client setTarget:self action:@selector(client:getPublicUserInfoDidLoad:)];
  @try{
    [self send_getPublicUserInfo: username];
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
  }
}
/*!
 * recieve getPublicUserInfo result
 */
- (void) client:(EvernoteHTTPClient *)client getPublicUserInfoDidLoad:(NSData *)result{
  @try{
    EDAMPublicUserInfo *retval = [self recv_getPublicUserInfo];

    if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
      [delegate_ client:client didLoad:retval];
    }
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
  }
}


/*!
 * send getPremiumInfo request
 */
- (void) getPremiumInfo: (NSString *) authenticationToken andDelegate:(id<EvernoteHTTPClientDelegate>) delegate
{
  EvernoteHTTPClient *client = (EvernoteHTTPClient *)[outProtocol transport];
  delegate_ = delegate;
  client.delegate = delegate;
  [client setTarget:self action:@selector(client:getPremiumInfoDidLoad:)];
  @try{
    [self send_getPremiumInfo: authenticationToken];
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
  }
}
/*!
 * recieve getPremiumInfo result
 */
- (void) client:(EvernoteHTTPClient *)client getPremiumInfoDidLoad:(NSData *)result{
  @try{
    EDAMPremiumInfo *retval = [self recv_getPremiumInfo];

    if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
      [delegate_ client:client didLoad:retval];
    }
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
  }
}
@end
