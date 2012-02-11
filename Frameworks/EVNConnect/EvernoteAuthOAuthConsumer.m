//
//  EvernoteAuthOAuthConsumer.m
//  EVNConnect
//
//  Created by Kentaro ISHITOYA on 12/02/03.
//  Copyright (c) 2012 Kentaro ISHITOYA. All rights reserved.
//

#import "EvernoteAuthOAuthConsumer.h"
#import "OAPlaintextSignatureProvider.h"
#import "NSString+URLEncoding.h"
//-----------------------------------------------------------------------------
//Private Implementations
//-----------------------------------------------------------------------------
@interface EvernoteAuthOAuthConsumer(PrivateImplementation)
- (void) requestTokenTicket:(OAServiceTicket *)ticket didFinishGetRequestToken:(NSData *)data;
- (void) requestTokenTicket:(OAServiceTicket *)ticket didFailWithError:(NSError *)error;
- (void) requestTokenTicket:(OAServiceTicket *)ticket didFinishFetchAccessToken:(NSData *)data;
@end

@implementation EvernoteAuthOAuthConsumer(PrivateImplementation)
/*!
 * create authentication URL
 */
- (NSURL *) authenticationURL{
    NSURL *url = [super authenticationURL];
    NSString *address = [NSString stringWithFormat:
                         @"%@?oauth_token=%@&format=mobile",
                         url.absoluteString,
                         accessToken_.key];
    return [NSURL URLWithString:address];
}

/*!
 * server responds request token
 */
- (void) requestTokenTicket:(OAServiceTicket *)ticket didFinishGetRequestToken:(NSData *)data {
    if (ticket.didSucceed){        
        NSString *responseBody = 
        [[NSString alloc] initWithData:data 
                              encoding:NSUTF8StringEncoding];
		
        accessToken_ = [[OAToken alloc] initWithHTTPResponseBody:responseBody];
		[[UIApplication sharedApplication] openURL:[self authenticationURL]];
    } else {
        NSLog(@"%s,%@", __PRETTY_FUNCTION__, ticket.body);
        [self evernoteDidNotLogin];
	}
}

/*!
 * failed to obtain request token
 */
- (void) requestTokenTicket:(OAServiceTicket *)ticket didFailWithError:(NSError *)error {
    NSLog(@"%s,%@", __PRETTY_FUNCTION__, ticket.body);
    [self evernoteDidNotLogin];
}

/*!
 * after authentication
 */
- (void) requestTokenTicket:(OAServiceTicket *)ticket didFinishFetchAccessToken:(NSData *)data {
    if (ticket.didSucceed){
        NSString *responseBody = 
        [[NSString alloc] initWithData:data 
                              encoding:NSUTF8StringEncoding];
		
        accessToken_ = [accessToken_ initWithHTTPResponseBody:responseBody];
        
        NSArray *pairs = [responseBody componentsSeparatedByString:@"&"];
        for (NSString *pair in pairs) {
            NSArray *elements = [pair componentsSeparatedByString:@"="];
            NSString *key = [elements objectAtIndex:0];
            NSString *value = [[elements objectAtIndex:1] decodedURLString];
            if([key isEqualToString:@"edam_shard"]){
                shardId_ = value;
            }else if([key isEqualToString:@"edam_userId"]){
                userId_ = value;
            }else if([key isEqualToString:@"oauth_token"]){
                authToken_ = value;
            }
        }
        NSLog(@"%@", responseBody);
        [self evernoteDidLogin];
    } else {
        NSLog(@"%s,%@", __PRETTY_FUNCTION__, ticket.body);
        [self evernoteDidNotLogin];
	}
}
@end

//-----------------------------------------------------------------------------
//Public Implementations
//----------------------------------------------------------------------------
@implementation EvernoteAuthOAuthConsumer
@dynamic authToken;
@dynamic userId;

/*!
 * initialize
 */
- (id)initWithConsumerKey:(NSString *)consumerKey consumerSecret:(NSString *)consumerSecret callbackScheme:(NSString *)callbackScheme useSandBox:(BOOL)useSandBox andDelegate:(id<EvernoteAuthDelegate>)delegate{
    self = [super initWithConsumerKey:consumerKey consumerSecret:consumerSecret callbackScheme:callbackScheme useSandBox:useSandBox andDelegate:delegate];
    if (self) {
    }
    return self;
}

/*!
 * login to evernote, obtain request token
 */
-(void)login {
    if([self isSessionValid]){
        [self evernoteDidLogin];
        return;
    }
	consumer_ = [[OAConsumer alloc] initWithKey:consumerKey_
                                         secret:consumerSecret_];
	OADataFetcher *fetcher = [[OADataFetcher alloc] init];
	OAMutableURLRequest *request = 
    [[OAMutableURLRequest alloc] initWithURL:[self requestTokenURL]
                                    consumer:consumer_
                                       token:nil
                                       realm:nil
                           signatureProvider:[[OAPlaintextSignatureProvider alloc] init]];
    
	[request setHTTPMethod:@"POST"];
    
    NSMutableArray *params = [NSMutableArray arrayWithCapacity:3];
    [params addObject:[OARequestParameter requestParameter:@"oauth_callback" value:callbackScheme_]];
    [request setParameters:params];
	
	[fetcher fetchDataWithRequest:request 
						 delegate:self
				didFinishSelector:@selector(requestTokenTicket:didFinishGetRequestToken:)
				  didFailSelector:@selector(requestTokenTicket:didFailWithError:)];
}

/*!
 * user login finished
 */
- (BOOL) handleOpenURL:(NSURL *)url {
	accessToken_ = [accessToken_ initWithHTTPResponseBody:url.query];
    
    NSArray *pairs = [url.query componentsSeparatedByString:@"&"];
    for (NSString *pair in pairs) {
        NSArray *elements = [pair componentsSeparatedByString:@"="];
        if ([[elements objectAtIndex:0] isEqualToString:@"oauth_verifier"]) {
            accessToken_.verifier = [elements objectAtIndex:1];
        }
    }
    
	OADataFetcher *fetcher = [[OADataFetcher alloc] init];
	
	OAMutableURLRequest *request = 
    [[OAMutableURLRequest alloc] initWithURL:[self requestTokenURL]
                                    consumer:consumer_
                                       token:accessToken_
                                       realm:nil
                           signatureProvider:[[OAPlaintextSignatureProvider alloc] init]];
    
    [request setHTTPMethod:@"POST"];
    
	[fetcher fetchDataWithRequest:request 
						 delegate:self
				didFinishSelector:@selector(requestTokenTicket:didFinishFetchAccessToken:)
				  didFailSelector:@selector(requestTokenTicket:didFailWithError:)];
    return YES;
}

/*!
 * logout
 */
- (void)logout {
    [self clearCredential];
    if ([delegate_ respondsToSelector:@selector(evernoteDidLogout)]) {
        [delegate_ evernoteDidLogout];
    }
}

/*!
 * check is session valid
 */
- (BOOL)isSessionValid {
    return (authToken_ != nil);
}

/*!
 * get auth token
 */
- (NSString *)authToken{
    return authToken_;
}

/*!
 * get user id
 */
- (NSString *)userId{
    return userId_;
}

/*!
 * get shard id
 */
-(NSString *)shardId{
    return shardId_;
}
@end
