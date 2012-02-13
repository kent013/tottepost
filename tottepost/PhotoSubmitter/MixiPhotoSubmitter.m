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

#define PS_MIXI_AUTH_URL @"photosubmitter://auth/mixi"
#define PS_MIXI_AUTH_TOKEN @"MixiOAuthToken"
#define PS_MIXI_AUTH_TOKEN_SECRET @"MixiOAuthTokenSecret"

#define PS_MIXI_API_CHECK_TOKEN @"check_token"
#define PS_MIXI_API_REQUEST_TOKEN @"request_token"
#define PS_MIXI_API_GET_TOKEN @"get_token"
#define PS_MIXI_API_UPLOAD_IMAGE @"upload_image"

#define PS_MIXI_SETTING_USERNAME @"MixiUserName"

//-----------------------------------------------------------------------------
//Private Implementations
//-----------------------------------------------------------------------------
@interface MixiPhotoSubmitter(PrivateImplementation)
- (void) setupInitialState;
- (void) clearCredentials;
@end

@implementation MixiPhotoSubmitter(PrivateImplementation)
#pragma mark -
#pragma mark private implementations
/*!
 * initializer
 */
-(void)setupInitialState{
    mixi_ = [[Mixi sharedMixi] setupWithType:kMixiApiTypeSelectorGraphApi 
                                         clientId:MIXI_SUBMITTER_API_KEY
                                           secret:MIXI_SUBMITTER_API_SECRET];
    [mixi_ restore];
    [mixi_ reportOncePerDay];
}

/*!
 * clear mixi access token key
 */
- (void)clearCredentials{
}

#pragma mark -
#pragma mark mixi delegate methods
@end

//-----------------------------------------------------------------------------
//Public Implementations
//-----------------------------------------------------------------------------
@implementation MixiPhotoSubmitter
@synthesize authDelegate;
@synthesize dataDelegate;
@synthesize albumDelegate;
#pragma mark -
#pragma mark public implementations
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

/*!
 * submit photo with data, comment and delegate
 */
- (void)submitPhoto:(PhotoSubmitterImageEntity *)photo andOperationDelegate:(id<PhotoSubmitterPhotoOperationDelegate>)delegate{
}

/*!
 * cancel photo upload
 */
- (void)cancelPhotoSubmit:(PhotoSubmitterImageEntity *)photo{
}

/*!
 * login to mixi
 */
-(void)login{
     [mixi_ authorizeForPermission:@"mixi_apps2"];
}

/*!
 * logoff from mixi
 */
- (void)logout{  
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
 * check is logined
 */
- (BOOL)isLogined{
    if(self.isEnabled == false){
        return NO;
    }
    if ([self settingForKey:PS_MIXI_AUTH_TOKEN]) {
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
 * return type
 */
- (PhotoSubmitterType) type{
    return PhotoSubmitterTypeMixi;
}

/*!
 * check url is processoble
 */
- (BOOL)isProcessableURL:(NSURL *)url{
    if([url.absoluteString isMatchedByRegex:PS_MIXI_AUTH_URL]){
        return YES;    
    }
    return NO;
}

/*!
 * on open url finished
 */
- (BOOL)didOpenURL:(NSURL *)url{
    NSError *error = nil;
    NSString *apiType = [[Mixi sharedMixi] application:nil openURL:url sourceApplication:nil annotation:nil error:&error];
    if (error) {
        NSLog(@"Cannot obtain token/secret from URL: %@", [url absoluteString]);
        return NO;
    }
    else if ([apiType isEqualToString:kMixiAppApiTypeToken]) {
    }
    else if ([apiType isEqualToString:kMixiAppApiTypeRevoke]) {
    }
    else if ([apiType isEqualToString:kMixiAppApiTypeReceiveRequest]) {
    }
    
    return YES;
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

/*!
 * get username
 */
- (NSString *)username{
    return [self settingForKey:PS_MIXI_SETTING_USERNAME];
}

/*!
 * is album supported
 */
- (BOOL) isAlbumSupported{
    return NO;
}

/*!
 * create album
 */
- (void)createAlbum:(NSString *)title withDelegate:(id<PhotoSubmitterAlbumDelegate>)delegate{
    //do nothing 
}

/*!
 * albumlist
 */
- (NSArray *)albumList{
    return nil;
}

/*!
 * update album list
 */
- (void)updateAlbumListWithDelegate:(id<PhotoSubmitterDataDelegate>)delegate{
    self.dataDelegate = delegate;
    //do nothing
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
    //do nothing
}

/*!
 * update username
 */
- (void)updateUsernameWithDelegate:(id<PhotoSubmitterDataDelegate>)delegate{
    self.dataDelegate = delegate;
    //do nothing
}

/*!
 * invoke method as concurrent?
 */
- (BOOL)isConcurrent{
    return YES;
}

/*!
 * use NSOperation ?
 */
- (BOOL)useOperation{
    return YES;
}

/*!
 * is sequencial? if so, use SequencialQueue
 */
- (BOOL)isSequencial{
    return NO;
}

/*!
 * requires network
 */
- (BOOL)requiresNetwork{
    return YES;
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
@end
