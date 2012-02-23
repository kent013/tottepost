//
//  MinusPhotoSubmitter.m
//  PhotoSubmitter for Minus
//
//  Created by Kentaro ISHITOYA on 12/02/22.
//  Copyright (c) 2012 cocotomo. All rights reserved.
//

#import "MinusPhotoSubmitter.h"
#import "PhotoSubmitterAPIKey.h"
#import "PhotoSubmitterAccountTableViewController.h"
#import "PhotoSubmitterManager.h"

#define PS_MINUS_ENABLED @"PSMinusEnabled"
#define PS_MINUS_AUTH_USERID @"PSMinusUserId"
#define PS_MINUS_AUTH_PASSWORD @"PSMinusPassword"
#define PS_MINUS_SETTING_USERNAME @"PSMinusUserName"
#define PS_MINUS_SETTING_ALBUMS @"PSMinusAlbums"
#define PS_MINUS_SETTING_TARGET_ALBUM @"PSMinusTargetAlbum"

//-----------------------------------------------------------------------------
//Private Implementations
//-----------------------------------------------------------------------------
@interface MinusPhotoSubmitter(PrivateImplementation)
- (void) setupInitialState;
- (void) clearCredentials;
- (void) loadCredentials;
- (void) getUserInfomation;
@end

#pragma mark - private implementations
@implementation MinusPhotoSubmitter(PrivateImplementation)
/*!
 * initializer
 */
-(void)setupInitialState{
    minus_ = [[MinusConnect alloc] 
              initWithClientId:MINUS_SUBMITTER_CLIENT_ID
              clientSecret:MINUS_SUBMITTER_CLIENT_SECRET
              andDelegate:self];
    [self loadCredentials];
}

/*!
 * clear Minus access token key
 */
- (void)clearCredentials{
    if ([self secureSettingExistsForKey:PS_MINUS_AUTH_USERID]) {
        [self removeSecureSettingForKey:PS_MINUS_AUTH_USERID];
        [self removeSecureSettingForKey:PS_MINUS_AUTH_PASSWORD];
        [self removeSettingForKey:PS_MINUS_SETTING_USERNAME];
        userId_ = nil;
        password_ = nil;
    } 
    [self disable];
}

/*!
 * load saved credentials
 */
- (void)loadCredentials{
    if([self secureSettingExistsForKey:PS_MINUS_AUTH_USERID]){
        userId_ = [self secureSettingForKey:PS_MINUS_AUTH_USERID];
        password_ = [self secureSettingForKey:PS_MINUS_AUTH_PASSWORD];
    }
}

/*!
 * get user information
 */
- (void)getUserInfomation{
    MinusRequest *request = [minus_ activeUserWithDelegate:self];
    [self addRequest:request];
}
@end

//-----------------------------------------------------------------------------
//Public Implementations
//-----------------------------------------------------------------------------
#pragma mark - public implementations
@implementation MinusPhotoSubmitter
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
 * login to Minus
 */
-(void)login{
    if ([minus_ isSessionValid]) {
        [self setSetting:@"enabled" forKey:PS_MINUS_ENABLED];
        [self.authDelegate photoSubmitter:self didLogin:self.type];
        return;
    }else{
        [self.authDelegate photoSubmitter:self willBeginAuthorization:self.type];
        PhotoSubmitterAccountTableViewController *controller =
        [[PhotoSubmitterAccountTableViewController alloc] init];
        controller.delegate = self;
        [[[[PhotoSubmitterManager sharedInstance] authControllerDelegate] requestNavigationControllerToPresentAuthenticationView] pushViewController:controller animated:YES];
        [self.authDelegate photoSubmitter:self willBeginAuthorization:self.type];
    }
}

/*!
 * logoff from Minus
 */
- (void)logout{  
    [minus_ logout];
    [self clearCredentials];
    [self.authDelegate photoSubmitter:self didLogout:self.type];
}

/*!
 * disable
 */
- (void)disable{
    [self removeSettingForKey:PS_MINUS_ENABLED];
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
    if ([minus_ isSessionValid]) {
        return YES;
    }
    return NO;
}

/*!
 * check is enabled
 */
- (BOOL) isEnabled{
    return [MinusPhotoSubmitter isEnabled];
}

/*!
 * isEnabled
 */
+ (BOOL)isEnabled{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:PS_MINUS_ENABLED]) {
        return YES;
    }
    return NO;
}

#pragma mark - photo
/*!
 * submit photo with data, comment and delegate
 */
- (void)submitPhoto:(PhotoSubmitterImageEntity *)photo andOperationDelegate:(id<PhotoSubmitterPhotoOperationDelegate>)delegate{
    if(delegate.isCancelled){
        return;
    }
    NSString *folderId = @"";
    if(self.targetAlbum){
        folderId = self.targetAlbum.albumId;
    }
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateFormat  = @"yyyyMMddHHmmss";
    NSString *filename = [NSString stringWithFormat:@"%@.jpg", [df stringFromDate:photo.timestamp]];
    MinusRequest *request = [minus_ createFileWithFolderId:folderId caption:photo.comment filename:filename data:photo.data dataContentType:@"image/jpeg" andDelegate:self];
    
    NSString *hash = photo.md5;
    [self addRequest:request];
    [self setPhotoHash:hash forRequest:request];
    [self setOperationDelegate:delegate forRequest:request];
    [self photoSubmitter:self willStartUpload:hash];
}    

/*!
 * cancel photo upload
 */
- (void)cancelPhotoSubmit:(PhotoSubmitterImageEntity *)photo{
    NSString *hash = photo.path;
    MinusRequest *request = (MinusRequest *)[self requestForPhoto:hash];
    [request cancel];
    
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

#pragma mark - album

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
    MinusRequest *request = [minus_ createFolderWithUsername:userId_ name:title isPublic:NO andDelegate:self];
    [self addRequest:request];
}

/*!
 * albumlist
 */
- (NSArray *)albumList{
    return [self complexSettingForKey:PS_MINUS_SETTING_ALBUMS];
}

/*!
 * update album list
 */
- (void)updateAlbumListWithDelegate:(id<PhotoSubmitterDataDelegate>)delegate{
    self.dataDelegate = delegate;
    MinusRequest *request = [minus_ foldersWithUsername:userId_ andDelegate:self];
    [self addRequest:request];
}

/*!
 * selected album
 */
- (PhotoSubmitterAlbumEntity *)targetAlbum{
    return [self complexSettingForKey:PS_MINUS_SETTING_TARGET_ALBUM];
}

/*!
 * save selected album
 */
- (void)setTargetAlbum:(PhotoSubmitterAlbumEntity *)targetAlbum{
    [self setComplexSetting:targetAlbum forKey:PS_MINUS_SETTING_TARGET_ALBUM];
}

#pragma mark - username
/*!
 * get username
 */
- (NSString *)username{
    return [self settingForKey:PS_MINUS_SETTING_USERNAME];
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
    return PhotoSubmitterTypeMinus;
}

/*!
 * name
 */
- (NSString *)name{
    return @"Minus";
}

/*!
 * icon image
 */
- (UIImage *)icon{
    return [UIImage imageNamed:@"minus_32.png"];
}

/*!
 * small icon image
 */
- (UIImage *)smallIcon{
    return [UIImage imageNamed:@"minus_16.png"];
}

#pragma mark - MinusConnectSessionDelegate
/*!
 * did login to minus
 */
-(void)minusDidLogin{
    [self setSetting:@"enabled" forKey:PS_MINUS_ENABLED];
    [self.authDelegate photoSubmitter:self didLogin:self.type];
    [self.authDelegate photoSubmitter:self didAuthorizationFinished:self.type];
    userId_ = [self secureSettingForKey:PS_MINUS_AUTH_USERID];
    password_ = [self secureSettingForKey:PS_MINUS_AUTH_PASSWORD];
    [self getUserInfomation];
}

/*!
 * did logout from minus
 */
- (void)minusDidLogout{
    [self clearCredentials];
    [self.authDelegate photoSubmitter:self didLogout:self.type];
}

/*!
 * attempt to login, but not logined
 */
- (void)minusDidNotLogin{
    [self clearCredentials];
    [self.authDelegate photoSubmitter:self didLogout:self.type];
}

#pragma mark - PhotoSubmitterPasswordAuthDelegate
/*!
 * did canceled
 */
- (void)didCancelPasswordAuthView:(UIViewController *)passwordAuthViewController{
    [self disable];
}

/*!
 * did present user id
 */
- (void)passwordAuthView:(UIView *)passwordAuthView didPresentUserId:(NSString *)userId password:(NSString *)password{
    [self setSecureSetting:userId forKey:PS_MINUS_AUTH_USERID];
    [self setSecureSetting:password forKey:PS_MINUS_AUTH_PASSWORD];
    [minus_ loginWithUsername:userId password:password andPermission:[NSArray arrayWithObjects:@"read_all", @"upload_new", nil]];

}

#pragma mark - PhotoSubmitterMinusRequestDelegate
/*!
 * did load
 */
- (void)request:(MinusRequest *)request didLoad:(id)result{
    if([request.tag isEqualToString:kMinusRequestActiveUser]){
        if ([result isKindOfClass:[NSArray class]]) {
            result = [result objectAtIndex:0];
        }
        NSString *username = [result objectForKey:@"display_name"];
        [self setSetting:username forKey:PS_MINUS_SETTING_USERNAME];
        [self.dataDelegate photoSubmitter:self didUsernameUpdated:username];
    }else if([request.tag isEqualToString:kMinusRequestCreateFile]){
        NSString *hash = [self photoForRequest:request];
        
        id<PhotoSubmitterPhotoOperationDelegate> operationDelegate = [self operationDelegateForRequest:request];
        [self photoSubmitter:self didSubmitted:hash suceeded:YES message:@"Photo upload succeeded"];
        [operationDelegate photoSubmitterDidOperationFinished:YES];
        
        [self clearRequest:request];
    }else if([request.tag isEqualToString:kMinusRequestCreateFolder]){
        [self.albumDelegate photoSubmitter:self didAlbumCreated:nil suceeded:YES withError:nil];
        [self clearRequest:request];
    }else if([request.tag isEqualToString:kMinusRequestFoldersWithUsername]){
        NSArray *as = [result objectForKey:@"results"];
        NSMutableArray *albums = [[NSMutableArray alloc] init];
        for(NSDictionary *a in as){
            NSString *privacy = @"public";
            if([a objectForKey:@"is_public"]){
                privacy = @"private";
            }
            PhotoSubmitterAlbumEntity *album = 
            [[PhotoSubmitterAlbumEntity alloc] initWithId:[a objectForKey:@"id"] name:[a objectForKey:@"name"] privacy:privacy];
            [albums addObject:album];
        }
        [self setComplexSetting:albums forKey:PS_MINUS_SETTING_ALBUMS];
        [self.dataDelegate photoSubmitter:self didAlbumUpdated:albums];
    }else{
        NSLog(@"%s", __PRETTY_FUNCTION__);
    }
}

/*!
 * request failed
 */
- (void)request:(MinusRequest *)request didFailWithError:(NSError *)error{
    NSLog(@"%@", error);
    if([request.tag isEqualToString:kMinusRequestActiveUser]){
    }else if([request.tag isEqualToString:kMinusRequestCreateFile]){
        NSString *hash = [self photoForRequest:request];
        [self photoSubmitter:self didSubmitted:hash suceeded:NO message:[error localizedDescription]];
        id<PhotoSubmitterPhotoOperationDelegate> operationDelegate = [self operationDelegateForRequest:request];
        [operationDelegate photoSubmitterDidOperationFinished:NO];
        [self clearRequest:request];
    }else if([request.tag isEqualToString:kMinusRequestCreateFolder]){
    }else if([request.tag isEqualToString:kMinusRequestFoldersWithUsername]){
        [self.albumDelegate photoSubmitter:self didAlbumCreated:nil suceeded:NO withError:error];
    }else{
        NSLog(@"%s", __PRETTY_FUNCTION__);
    }
    [self clearRequest:request];
}

/*!
 * progress
 */
- (void)request:(MinusRequest *)request didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite{
    if([request.tag isEqualToString:kMinusRequestCreateFile]){
        CGFloat progress = (float)totalBytesWritten / (float)totalBytesExpectedToWrite;
        NSString *hash = [self photoForRequest:request];
        [self photoSubmitter:self didProgressChanged:hash progress:progress];
    }
}
@end
