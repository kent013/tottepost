//
//  MixiPhotoSubmitter.m
//  tottepost
//
//  Created by 賢 渡辺 on 12/02/12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MixiPhotoSubmitter.h"

//
//  FlickrPhotoSubmitter.m
//  tottepost
//
//  Created by ISHITOYA Kentaro on 11/12/14.
//  Copyright (c) 2011 cocotomo. All rights reserved.
//

#import "PhotoSubmitterAPIKey.h"
#import "UIImage+Digest.h"
#import "NSData+Digest.h"
#import "RegexKitLite.h"
#import "UIImage+EXIF.h"
#import "PhotoSubmitterManager.h"
#import "MixiSDK.h"

#define PS_FLICKR_ENABLED @"PSFlickrEnabled"

#define PS_FLICKR_AUTH_URL @"photosubmitter://auth/flickr"
#define PS_FLICKR_AUTH_TOKEN @"FlickrOAuthToken"
#define PS_FLICKR_AUTH_TOKEN_SECRET @"FlickrOAuthTokenSecret"

#define PS_FLICKR_API_CHECK_TOKEN @"check_token"
#define PS_FLICKR_API_REQUEST_TOKEN @"request_token"
#define PS_FLICKR_API_GET_TOKEN @"get_token"
#define PS_FLICKR_API_UPLOAD_IMAGE @"upload_image"

#define PS_FLICKR_SETTING_USERNAME @"FlickrUserName"

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
 * clear flickr access token key
 */
- (void)clearCredentials{
}

#pragma mark -
#pragma mark flickr delegate methods
@end

//-----------------------------------------------------------------------------
//Public Implementations
//-----------------------------------------------------------------------------
@implementation MixiPhotoSubmitter
@synthesize authDelegate;
@synthesize dataDelegate;
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
 * logoff from flickr
 */
- (void)logout{  
    [self clearCredentials];
    [self.authDelegate photoSubmitter:self didLogout:self.type];
}

/*!
 * disable
 */
- (void)disable{
    [self removeSettingForKey:PS_FLICKR_ENABLED];
    [self.authDelegate photoSubmitter:self didLogout:self.type];
}

/*!
 * check is logined
 */
- (BOOL)isLogined{
    if(self.isEnabled == false){
        return NO;
    }
    if ([self settingForKey:PS_FLICKR_AUTH_TOKEN]) {
        return YES;
    }
    return NO;
}

/*!
 * check is enabled
 */
- (BOOL) isEnabled{
    return [FlickrPhotoSubmitter isEnabled];
}

/*!
 * return type
 */
- (PhotoSubmitterType) type{
    return PhotoSubmitterTypeFlickr;
}

/*!
 * check url is processoble
 */
- (BOOL)isProcessableURL:(NSURL *)url{
    if([url.absoluteString isMatchedByRegex:PS_FLICKR_AUTH_URL]){
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
        // 認可処理に成功しました
    }
    else if ([apiType isEqualToString:kMixiAppApiTypeRevoke]) {
        // 認可解除処理に成功しました
    }
    else if ([apiType isEqualToString:kMixiAppApiTypeReceiveRequest]) {
        // リクエストAPIによるリクエスト受け取り
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
    return [self settingForKey:PS_FLICKR_SETTING_USERNAME];
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
    if ([defaults objectForKey:PS_FLICKR_ENABLED]) {
        return YES;
    }
    return NO;
}
@end
