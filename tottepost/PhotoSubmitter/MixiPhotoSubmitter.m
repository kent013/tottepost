//
//  MixiPhotoSubmitter.m
//  tottepost
//
//  Created by Ken Watanabe on 12/02/12.
//  Copyright (c) 2011 cocotomo. All rights reserved.
//

#import "MixiPhotoSubmitter.h"
#import "PhotoSubmitterAPIKey.h"
#import "UIImage+Digest.h"
#import "NSData+Digest.h"
#import "RegexKitLite.h"
#import "UIImage+EXIF.h"
#import "PhotoSubmitterManager.h"
#import "MixiSDK.h"

//-----------------------------------------------------------------------------
//Private Implementations
//-----------------------------------------------------------------------------
@interface MixiPhotoSubmitter(PrivateImplementation)
- (void) setupInitialState;
- (void) getUserInfomation;
@end

@implementation MixiPhotoSubmitter(PrivateImplementation)
#pragma mark - private implementations
/*!
 * initializer
 */
-(void)setupInitialState{
    [self setSubmitterIsConcurrent:YES 
                      isSequencial:NO 
                     usesOperation:YES 
                   requiresNetwork:YES 
                  isAlbumSupported:YES];
    
    mixi_ = [[Mixi sharedMixi] setupWithType:kMixiApiTypeSelectorGraphApi
                                         clientId:MIXI_SUBMITTER_API_KEY
                                      secret:MIXI_SUBMITTER_API_SECRET];
    MixiSDKAuthorizer *authorizer = [MixiSDKAuthorizer authorizerWithRedirectUrl:@"http://somewhere.else"];
    authorizer.delegate = self;
    mixi_.authorizer = authorizer;
    [mixi_ restore];
    [mixi_ reportOncePerDay];
    if([mixi_ isAccessTokenExpired]){
        [mixi_ refreshAccessTokenWithDelegate:self];
    }
}

/*!
 * get user info
 */
- (void) getUserInfomation{
    MixiRequest *request = [MixiRequest requestWithEndpoint:@"/people/@me/@self"];
    [mixi_ sendRequest:request delegate:self];
}

#pragma mark -
#pragma mark mixi delegate methods
/*!
 * request suceeded
 */
- (void)mixi:(Mixi *)mixi andConnection:(NSURLConnection *)connection didSuccessWithJson:(id)data{
    NSString *url = [connection.currentRequest.URL absoluteString];
    NSString *method = connection.currentRequest.HTTPMethod;
    if([url isMatchedByRegex:@"token"]){
        [mixi_ store];
    }else if([url isMatchedByRegex:@"albums/@me/@self"] && 
             [method isEqualToString:@"POST"]){
        [self.albumDelegate photoSubmitter:self didAlbumCreated:nil suceeded:YES withError:nil];
    }else if([url isMatchedByRegex:@"albums/@me/@self"] && 
             [method isEqualToString:@"GET"]){
        NSArray *as = [data objectForKey:@"entry"];
        NSMutableArray *albums = [[NSMutableArray alloc] init];
        for(NSDictionary *a in as){
            PhotoSubmitterAlbumEntity *album = 
            [[PhotoSubmitterAlbumEntity alloc] initWithId:[a objectForKey:@"id"] name:[a objectForKey:@"title"] privacy:[[a objectForKey:@"privacy"] objectForKey:@"visibility"]];
            [albums addObject:album];
        }
        self.albumList = albums;
    }else if([url isMatchedByRegex:@"photo/mediaItems/@me/@self"] &&
             [method isEqualToString:@"POST"]){
        [self completeSubmitPhotoWithRequest:connection];
    }else if([url isMatchedByRegex:@"people/@me/@self"]){
        NSString *username = [[data objectForKey:@"entry"] objectForKey:@"displayName"];
        self.username = username;
    }
    //NSLog(@"%@,%@,%@", method,url,data);
}

/*!
 * failed
 */
- (void)mixi:(Mixi *)mixi andConnection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    NSString *url = [connection.currentRequest.URL absoluteString];
    NSString *method = connection.currentRequest.HTTPMethod;
    
    if([url isMatchedByRegex:@"albums/@me/@self"] && 
       [method isEqualToString:@"POST"]){
        [self.albumDelegate photoSubmitter:self didAlbumCreated:nil suceeded:NO withError:error];
    }else if([url isMatchedByRegex:@"albums/@me/@self"] && 
             [method isEqualToString:@"GET"]){
    }else if([url isMatchedByRegex:@"photo/mediaItems/@me/@self"] &&
       [method isEqualToString:@"POST"]){
        [self completeSubmitPhotoWithRequest:connection andError:error];
    }else{
        NSLog(@"%s", __PRETTY_FUNCTION__);
    }
    NSLog(@"%@,%@,%@", url, method, error);    
}

/*!
 * progress
 */
- (void)mixi:(Mixi *)mixi andConnection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite{
    CGFloat progress = (float)totalBytesWritten / (float)totalBytesExpectedToWrite;
    NSString *hash = [self photoForRequest:connection];
    [self photoSubmitter:self didProgressChanged:hash progress:progress];
}

#pragma mark - MixiSDKAuthorizerDelegate methods
/*!
 * authorization suceeded
 */
- (void)authorizer:(MixiSDKAuthorizer *)authorizer didSuccessWithEndpoint:(NSString *)endpoint{
    [mixi_ store];
    [self completeLogin];
}

/*!
 * authorization canceled
 */
- (void)authorizer:(MixiSDKAuthorizer *)authorizer didCancelWithEndpoint:(NSString *)endpoint{
    [self completeLoginFailed];
}

/*!
 * authorization failed
 */
- (void)authorizer:(MixiSDKAuthorizer *)authorizer didFailWithEndpoint:(NSString *)endpoint error:(NSError *)error{
    [self completeLoginFailed];
}
@end

//-----------------------------------------------------------------------------
//Public Implementations
//-----------------------------------------------------------------------------
@implementation MixiPhotoSubmitter
@synthesize authDelegate;
@synthesize dataDelegate;
@synthesize albumDelegate;
#pragma mark - public implementations
/*!
 * initialize
 */
- (id)init{
    self = [super init];
    if (self) {
        [self setupInitialState];
    }
    return self;
}

#pragma mark - authorization
/*!
 * login to facebook
 */
-(void)onLogin{
    MixiSDKAuthorizer *authorizer = (MixiSDKAuthorizer *)mixi_.authorizer;
    [authorizer setParentViewController:[[PhotoSubmitterManager sharedInstance].authControllerDelegate requestNavigationControllerToPresentAuthenticationView]];
    [mixi_ authorize:@"r_profile",@"r_photo", @"w_photo", nil];
}

/*!
 * logoff from facebook
 */
- (void)onLogout{
    [mixi_ logout];
    [self completeLogout];
}

/*!
 * refresh credential
 */
- (void)refreshCredential{
    if([mixi_ isAccessTokenExpired]){
        [mixi_ refreshAccessToken];
    }
}
/*!
 * check is logined
 */
- (BOOL)isSessionValid{
    return [mixi_ isAuthorized];
}

#pragma mark - photo
/*!
 * submit photo with data, comment and delegate
 */
- (id)onSubmitPhoto:(PhotoSubmitterImageEntity *)photo andOperationDelegate:(id<PhotoSubmitterPhotoOperationDelegate>)delegate{
    NSMutableDictionary *params = nil;
    if(photo.comment){
        [NSMutableDictionary dictionaryWithObjectsAndKeys: 
         photo.comment, @"title",
         nil];
    }
    NSString *path = @"/photo/mediaItems/@me/@self";
    if(self.targetAlbum != nil){
        path = [NSString stringWithFormat:@"%@/%@", path, self.targetAlbum.albumId];
    }
    
    MixiRequest *request = [MixiRequest postRequestWithEndpoint:path body:photo.image params:params];
    NSURLConnection *connection = [mixi_ sendRequest:request delegate:self];
    if(connection == nil){
        return nil;
    }
    return connection;
}

/*!
 * cancel photo upload
 */
- (id)onCancelPhotoSubmit:(PhotoSubmitterImageEntity *)photo{    
    NSURLConnection *connection = (NSURLConnection *)[self requestForPhoto:photo.photoHash];
    [connection cancel];
    return connection;
}

#pragma mark - albums

/*!
 * create album
 */
- (void)createAlbum:(NSString *)title withDelegate:(id<PhotoSubmitterAlbumDelegate>)delegate{
    self.albumDelegate = delegate;
    NSMutableDictionary *params = 
    [NSMutableDictionary dictionaryWithObjectsAndKeys: 
     title, @"description", 
     title, @"title",
     @"friends", @"visibility",
     nil];
    MixiRequest *request = [MixiRequest postRequestWithEndpoint:@"/photo/albums/@me/@self" params:params];
    [mixi_ sendRequest:request delegate:self];
}

/*!
 * update album list
 */
- (void)updateAlbumListWithDelegate:(id<PhotoSubmitterDataDelegate>)delegate{
    self.dataDelegate = delegate;
    MixiRequest *request = [MixiRequest requestWithEndpoint:@"/photo/albums/@me/@self"];
    [mixi_ sendRequest:request delegate:self];
}

#pragma mark - username
/*!
 * update username
 */
- (void)updateUsernameWithDelegate:(id<PhotoSubmitterDataDelegate>)delegate{
    self.dataDelegate = delegate;
    [self getUserInfomation];
}

#pragma mark - other properties
/*!
 * return type
 */
- (PhotoSubmitterType) type{
    return PhotoSubmitterTypeMixi;
}

/*!
 * name
 */
- (NSString *)name{
    return @"Mixi";
}
@end
