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

- (void) getUserInfomation{
    MixiRequest *request = [MixiRequest requestWithEndpoint:@"/people/@me"];
    [mixi_ sendRequest:request delegate:self];
}

#pragma mark -
#pragma mark mixi delegate methods

- (void)mixi:(Mixi *)mixi didSuccessWithJson:(id)data{
    if([data objectForKey:@"refresh_token"]){
        [mixi_ store];
    }
    NSLog(@"%@", data);
}
- (void)mixi:(Mixi*)mixi didFinishLoading:(NSString*)data{
    NSLog(@"********DEBUG********* = %@",data);

}

#pragma mark - MixiSDKAuthorizerDelegate methods
- (void)authorizer:(MixiSDKAuthorizer *)authorizer didSuccessWithEndpoint:(NSString *)endpoint{
    [self setSetting:@"enabled" forKey:PS_MIXI_ENABLED];
    [self.authDelegate photoSubmitter:self didLogin:self.type];
    
    //[self getUserInfomation];
    [self.authDelegate photoSubmitter:self didAuthorizationFinished:self.type];
    [mixi_ store];
}

- (void)authorizer:(MixiSDKAuthorizer *)authorizer didCancelWithEndpoint:(NSString *)endpoint{
    [self clearCredentials];
    [self.authDelegate photoSubmitter:self didLogout:self.type];
    [self.authDelegate photoSubmitter:self didAuthorizationFinished:self.type];
}

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
    // TODO
}

/*!
 * cancel photo upload
 */
- (void)cancelPhotoSubmit:(PhotoSubmitterImageEntity *)photo{
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
}

/*!
 * album list
 */
- (NSArray *)albumList{
    return nil;
}

/*!
 * update album list
 */
- (void)updateAlbumListWithDelegate:(id<PhotoSubmitterDataDelegate>)delegate{
}

/*!
 * selected album
 */
- (PhotoSubmitterAlbumEntity *)targetAlbum{
    return nil;
}

/*!
 * save selected album
 */
- (void)setTargetAlbum:(PhotoSubmitterAlbumEntity *)targetAlbum{
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
    return PhotoSubmitterTypeFacebook;
}

/*!
 * name
 */
- (NSString *)name{
    return @"mixi";
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
