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

#define PS_MIXI_ENABLED @"PSMixiEnabled"

#define PS_MIXI_SETTING_USERNAME @"PSMixiUserName"
#define PS_MIXI_SETTING_ALBUMS @"PSFacebookAlbums"
#define PS_MIXI_SETTING_TARGET_ALBUM @"PSFacebookTargetAlbums"

//-----------------------------------------------------------------------------
//Private Implementations
//-----------------------------------------------------------------------------
@interface MixiPhotoSubmitter(PrivateImplementation)
- (void) setupInitialState;
- (void) clearCredentials;
- (void) getUserInfomation;
@end

@implementation MixiPhotoSubmitter(PrivateImplementation)
#pragma mark - private implementations
/*!
 * initializer
 */
-(void)setupInitialState{
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
 * clear mixi access token key
 */
- (void)clearCredentials{
    [self removeSettingForKey:PS_MIXI_SETTING_USERNAME];
    [self removeSettingForKey:PS_MIXI_SETTING_ALBUMS];
    [self removeSettingForKey:PS_MIXI_SETTING_TARGET_ALBUM];
    [self disable];
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
        [self setComplexSetting:albums forKey:PS_MIXI_SETTING_ALBUMS];
        [self.dataDelegate photoSubmitter:self didAlbumUpdated:albums];
    }else if([url isMatchedByRegex:@"photo/mediaItems/@me/@self"] &&
             [method isEqualToString:@"POST"]){
        NSString *hash = [self photoForRequest:connection];
        
        id<PhotoSubmitterPhotoOperationDelegate> operationDelegate = [self operationDelegateForRequest:connection];
        [self photoSubmitter:self didSubmitted:hash suceeded:YES message:@"Photo upload succeeded"];
        [operationDelegate photoSubmitterDidOperationFinished:YES];
        
        [self clearRequest:connection];
    }else if([url isMatchedByRegex:@"people/@me/@self"]){
        NSString *username = [[data objectForKey:@"entry"] objectForKey:@"displayName"];
        [self setSetting:username forKey:PS_MIXI_SETTING_USERNAME];
        [self.dataDelegate photoSubmitter:self didUsernameUpdated:username];
    }
    //NSLog(@"%@,%@,%@", method,url,data);
}

- (void)mixi:(Mixi *)mixi didFinishLoading:(NSString *)data{
    //NSLog(@"%@", data);
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
        NSString *hash = [self photoForRequest:connection];
        [self photoSubmitter:self didSubmitted:hash suceeded:NO message:[error localizedDescription]];
        id<PhotoSubmitterPhotoOperationDelegate> operationDelegate = [self operationDelegateForRequest:connection];
        [operationDelegate photoSubmitterDidOperationFinished:NO];
        [self clearRequest:connection];
    }else{
        NSLog(@"%s", __PRETTY_FUNCTION__);
    }
    //NSLog(@"%@,%@,%@", url, method, error);    
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
    [self setSetting:@"enabled" forKey:PS_MIXI_ENABLED];
    [self.authDelegate photoSubmitter:self didLogin:self.type];
    
    //[self getUserInfomation];
    [self.authDelegate photoSubmitter:self didAuthorizationFinished:self.type];
    [mixi_ store];
}

/*!
 * authorization canceled
 */
- (void)authorizer:(MixiSDKAuthorizer *)authorizer didCancelWithEndpoint:(NSString *)endpoint{
    [self clearCredentials];
    [self.authDelegate photoSubmitter:self didLogout:self.type];
    [self.authDelegate photoSubmitter:self didAuthorizationFinished:self.type];
}

/*!
 * authorization failed
 */
- (void)authorizer:(MixiSDKAuthorizer *)authorizer didFailWithEndpoint:(NSString *)endpoint error:(NSError *)error{
    [self clearCredentials];
    [self.authDelegate photoSubmitter:self didLogout:self.type];
    [self.authDelegate photoSubmitter:self didAuthorizationFinished:self.type];
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
-(void)login{
    if([mixi_ isAuthorized]){
        [self setSetting:@"enabled" forKey:PS_MIXI_ENABLED];
        [self.authDelegate photoSubmitter:self didLogin:self.type];
    }else{
        [self.authDelegate photoSubmitter:self willBeginAuthorization:self.type];
        MixiSDKAuthorizer *authorizer = (MixiSDKAuthorizer *)mixi_.authorizer;
        [authorizer setParentViewController:[[PhotoSubmitterManager sharedInstance].authControllerDelegate requestNavigationControllerToPresentAuthenticationView]];
        [mixi_ authorize:@"r_profile",@"r_photo", @"w_photo", nil];
    }
}

/*!
 * logoff from facebook
 */
- (void)logout{
    [mixi_ logout];
    [self clearCredentials];
    [self.authDelegate photoSubmitter:self didLogout:self.type];
}

/*!
 * disable
 */
- (void)disable{
    [self removeSettingForKey:PS_MIXI_ENABLED];
    [self.authDelegate photoSubmitter:self didLogout:self.type];
}

/*!
 * check url is processable
 */
- (BOOL)isProcessableURL:(NSURL *)url{
    return NO;
}

/*!
 * on open url finished
 */
- (BOOL)didOpenURL:(NSURL *)url{
    return NO;
}

/*!
 * check is logined
 */
- (BOOL)isLogined{
    if(self.isEnabled == false){
        return NO;
    }
    if ([mixi_ isAuthorized]) {
        return YES;
    }
    return NO;
}

/*!
 * check is enabled
 */
- (BOOL) isEnabled{
    return [MixiPhotoSubmitter isEnabled];
}

/*!
 * isEnabled
 */
+ (BOOL)isEnabled{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:PS_MIXI_ENABLED]) {
        return YES;
    }
    return NO;
}

#pragma mark - photo
/*!
 * submit photo with data, comment and delegate
 */
- (void)submitPhoto:(PhotoSubmitterImageEntity *)photo andOperationDelegate:(id<PhotoSubmitterPhotoOperationDelegate>)delegate{
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
    
    if(delegate.isCancelled){
        return;
    }
    MixiRequest *request = [MixiRequest postRequestWithEndpoint:path body:photo.image params:params];
    NSURLConnection *connection = [mixi_ sendRequest:request delegate:self];
    NSString *hash = photo.md5;
    [self setPhotoHash:hash forRequest:connection];
    [self addRequest:connection];
    [self setOperationDelegate:delegate forRequest:connection];
    [self photoSubmitter:self willStartUpload:hash];
}

/*!
 * cancel photo upload
 */
- (void)cancelPhotoSubmit:(PhotoSubmitterImageEntity *)photo{    
    NSString *hash = photo.md5;
    NSURLConnection *connection = (NSURLConnection *)[self requestForPhoto:hash];
    [connection cancel];
    
    id<PhotoSubmitterPhotoOperationDelegate> operationDelegate = [self operationDelegateForRequest:connection];
    [operationDelegate photoSubmitterDidOperationCanceled];
    [self photoSubmitter:self didCanceled:hash];
    [self clearRequest:connection];
    //TODO
}

/*!
 * invoke method as concurrent?
 */
- (BOOL)isConcurrent{
    return YES;
}

/*!
 * is sequencial? if so, use SequencialQueue
 */
- (BOOL)isSequencial{
    return NO;
}

/*!
 * use NSOperation?
 */
- (BOOL)useOperation{
    return YES;
}

/*!
 * requires network
 */
- (BOOL)requiresNetwork{
    return YES;
}

#pragma mark - albums
/*!
 * is album supported
 */
- (BOOL) isAlbumSupported{
    return YES;
}

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
 * album list
 */
- (NSArray *)albumList{
    return [self complexSettingForKey:PS_MIXI_SETTING_ALBUMS];
}

/*!
 * update album list
 */
- (void)updateAlbumListWithDelegate:(id<PhotoSubmitterDataDelegate>)delegate{
    self.dataDelegate = delegate;
    MixiRequest *request = [MixiRequest requestWithEndpoint:@"/photo/albums/@me/@self"];
    [mixi_ sendRequest:request delegate:self];
}

/*!
 * selected album
 */
- (PhotoSubmitterAlbumEntity *)targetAlbum{
    return [self complexSettingForKey:PS_MIXI_SETTING_TARGET_ALBUM];
}

/*!
 * save selected album
 */
- (void)setTargetAlbum:(PhotoSubmitterAlbumEntity *)targetAlbum{
    [self setComplexSetting:targetAlbum forKey:PS_MIXI_SETTING_TARGET_ALBUM];
}

#pragma mark - username
/*!
 * get username
 */
- (NSString *)username{
    return [self settingForKey:PS_MIXI_SETTING_USERNAME];
}

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

/*!
 * icon image
 */
- (UIImage *)icon{
    return [UIImage imageNamed:@"mixi_32.png"];
}

/*!
 * small icon image
 */
- (UIImage *)smallIcon{
    return [UIImage imageNamed:@"mixi_16.png"];
}
@end
