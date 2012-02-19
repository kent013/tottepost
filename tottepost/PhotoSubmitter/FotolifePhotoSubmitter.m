//
//  FotolifePhotoSubmitter.m
//  hatena fotolife
//
//  Created by Kentaro ISHITOYA on 12/02/18.
//  Copyright (c) 2012 cocotomo. All rights reserved.
//

#import "PhotoSubmitterAPIKey.h"
#import "FotolifePhotoSubmitter.h"
#import "UIImage+Digest.h"
#import "RegexKitLite.h"
#import "PhotoSubmitterAlbumEntity.h"
#import "PhotoSubmitterManager.h"
#import "UIImage+EXIF.h"
#import "PhotoSubmitterAccountTableViewController.h"
#import "Atompub.h"
#import "PDKeychainBindings.h"

#define PS_FOTOLIFE_ENABLED @"PSFotolifeEnabled"
#define PS_FOTOLIFE_AUTH_USERID @"PSFotolifeUserId"
#define PS_FOTOLIFE_AUTH_PASSWORD @"PSFotolifePassword"
#define PS_FOTOLIFE_SETTING_USERNAME @"PSFotolifeUsername"
#define PS_FOTOLIFE_SETTING_ALBUMS @"PSFotolifeAlbums"
#define PS_FOTOLIFE_SETTING_TARGET_ALBUM @"PSFotolifeTargetAlbums"

#define PS_FOTOLIFE_PHOTO_WIDTH 960
#define PS_FOTOLIFE_PHOTO_HEIGHT 720

//-----------------------------------------------------------------------------
//Private Implementations
//-----------------------------------------------------------------------------
@interface FotolifePhotoSubmitter(PrivateImplementation)
- (void) setupInitialState;
- (void) clearCredentials;
- (void) loadCredentials;
- (void) getUserInfomation;
@end

#pragma mark - private implementations
@implementation FotolifePhotoSubmitter(PrivateImplementation)
/*!
 * initializer
 */
-(void)setupInitialState{
}

/*!
 * clear fotolife access token key
 */
- (void)clearCredentials{
    if ([self secureSettingExistsForKey:PS_FOTOLIFE_AUTH_USERID]) {
        [self removeSecureSettingForKey:PS_FOTOLIFE_AUTH_USERID];
        [self removeSecureSettingForKey:PS_FOTOLIFE_AUTH_PASSWORD];
        [self removeSettingForKey:PS_FOTOLIFE_SETTING_USERNAME];
        [self removeSettingForKey:PS_FOTOLIFE_SETTING_ALBUMS];
        [self removeSettingForKey:PS_FOTOLIFE_SETTING_TARGET_ALBUM];
    } 
    [self disable];
}

- (void)loadCredentials{
    if([self secureSettingExistsForKey:PS_FOTOLIFE_AUTH_USERID]){
        userId_ = [self secureSettingForKey:PS_FOTOLIFE_AUTH_USERID];
        password_ = [self secureSettingForKey:PS_FOTOLIFE_AUTH_PASSWORD];
    }
}

/*!
 * get user information
 */
- (void)getUserInfomation{
        //[fotolife_ requestWithGraphPath:@"me" andDelegate:self];
}
@end

//-----------------------------------------------------------------------------
//Public Implementations
//-----------------------------------------------------------------------------
#pragma mark - public PhotoSubmitter Protocol implementations
@implementation FotolifePhotoSubmitter
@synthesize authDelegate;
@synthesize dataDelegate;
@synthesize albumDelegate;
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
 * login to fotolife
 */
-(void)login{
    if([self secureSettingExistsForKey:PS_FOTOLIFE_AUTH_USERID]){
        [self setSetting:@"enabled" forKey:PS_FOTOLIFE_ENABLED];
        [self.authDelegate photoSubmitter:self didLogin:self.type];
    }else{
        [self.authDelegate photoSubmitter:self willBeginAuthorization:self.type];
        PhotoSubmitterAccountTableViewController *controller =
        [[PhotoSubmitterAccountTableViewController alloc] init];
        controller.delegate = self;
        [[[[PhotoSubmitterManager sharedInstance] authControllerDelegate] requestNavigationControllerToPresentAuthenticationView] pushViewController:controller animated:YES];
    }
}

/*!
 * logoff from fotolife
 */
- (void)logout{  
    [self clearCredentials];
}

/*!
 * disable
 */
- (void)disable{
    [self removeSettingForKey:PS_FOTOLIFE_ENABLED];
    [self.authDelegate photoSubmitter:self didLogout:self.type];
}

/*!
 * check url is processoble
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
    if ([self secureSettingExistsForKey:PS_FOTOLIFE_AUTH_USERID]) {
        return YES;
    }
    return NO;
}

/*!
 * check is enabled
 */
- (BOOL) isEnabled{
    return [FotolifePhotoSubmitter isEnabled];
}

/*!
 * isEnabled
 */
+ (BOOL)isEnabled{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:PS_FOTOLIFE_ENABLED]) {
        return YES;
    }
    return NO;
}

#pragma mark - photo
/*!
 * submit photo with data, comment and delegate
 */
- (void)submitPhoto:(PhotoSubmitterImageEntity *)photo andOperationDelegate:(id<PhotoSubmitterPhotoOperationDelegate>)delegate{
    CGSize size = CGSizeMake(PS_FOTOLIFE_PHOTO_WIDTH, PS_FOTOLIFE_PHOTO_HEIGHT);
    if(photo.image.size.width < photo.image.size.height){
        size = CGSizeMake(PS_FOTOLIFE_PHOTO_HEIGHT, PS_FOTOLIFE_PHOTO_WIDTH);
    }
}

/*!
 * cancel photo upload
 */
- (void)cancelPhotoSubmit:(PhotoSubmitterImageEntity *)photo{
    NSString *hash = photo.md5;
    FBRequest *request = (FBRequest *)[self requestForPhoto:hash];
    [request.connection cancel];
    
    id<PhotoSubmitterPhotoOperationDelegate> operationDelegate = [self operationDelegateForRequest:request];
    [operationDelegate photoSubmitterDidOperationCanceled];
    [self photoSubmitter:self didCanceled:hash];
    [self clearRequest:request];
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
    return [self complexSettingForKey:PS_FOTOLIFE_SETTING_ALBUMS];
}

/*!
 * update album list
 */
- (void)updateAlbumListWithDelegate:(id<PhotoSubmitterDataDelegate>)delegate{
    self.dataDelegate = delegate;
}

/*!
 * selected album
 */
- (PhotoSubmitterAlbumEntity *)targetAlbum{
    return [self complexSettingForKey:PS_FOTOLIFE_SETTING_TARGET_ALBUM];
}

/*!
 * save selected album
 */
- (void)setTargetAlbum:(PhotoSubmitterAlbumEntity *)targetAlbum{
    [self setComplexSetting:targetAlbum forKey:PS_FOTOLIFE_SETTING_TARGET_ALBUM];
}

#pragma mark - username
/*!
 * get username
 */
- (NSString *)username{
    return [self secureSettingForKey:PS_FOTOLIFE_AUTH_USERID];
}

/*!
 * update username
 */
- (void)updateUsernameWithDelegate:(id<PhotoSubmitterDataDelegate>)delegate{
    self.dataDelegate = delegate;
    [self.dataDelegate photoSubmitter:self didUsernameUpdated:self.username];
}

#pragma mark - other properties
/*!
 * return type
 */
- (PhotoSubmitterType) type{
    return PhotoSubmitterTypeFotolife;
}

/*!
 * name
 */
- (NSString *)name{
    return @"Fotolife";
}

/*!
 * icon image
 */
- (UIImage *)icon{
    return [UIImage imageNamed:@"fotolife_32.png"];
}

/*!
 * small icon image
 */
- (UIImage *)smallIcon{
    return [UIImage imageNamed:@"fotolife_16.png"];
}

#pragma mark - PhotoSubmitterPasswordAuthDelegate
- (void)passwordAuthView:(UIView *)passwordAuthView didPresentUserId:(NSString *)userId password:(NSString *)password{
    AtompubClient *client = [[AtompubClient alloc] init];
    client.tag = @"login";
    client.delegate = self;
    [client setCredential:[WSSECredential credentialWithUsername:userId password:password]];
    [self setSecureSetting:userId forKey:PS_FOTOLIFE_AUTH_USERID];
    [self setSecureSetting:password forKey:PS_FOTOLIFE_AUTH_PASSWORD];
    [self addRequest:client];
    [client startLoadingFeedWithURL:[NSURL URLWithString:@"http://f.hatena.ne.jp/atom/feed"]];
}

#pragma mark - AtompubClientDelegate
- (void)client:(AtompubClient *)client didReceiveFeed:(AtomFeed *)feed{
    if([client.tag isEqualToString:@"login"]){
        [self setSetting:@"enabled" forKey:PS_FOTOLIFE_ENABLED];
        [self.authDelegate photoSubmitter:self didLogin:self.type];
        [self.authDelegate photoSubmitter:self didAuthorizationFinished:self.type];
    }
    [self clearRequest:client];
}

- (void)client:(AtompubClient *)client didFailWithError:(NSError *)error{
    if([client.tag isEqualToString:@"login"]){
        [self clearCredentials];
        [self.authDelegate photoSubmitter:self didLogout:self.type];
    }
    [self clearRequest:client];
}
@end

