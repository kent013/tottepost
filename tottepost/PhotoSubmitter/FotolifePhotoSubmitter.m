//
//  FotolifePhotoSubmitter.m
//  hatena fotolife
//
//  Created by Kentaro ISHITOYA on 12/02/18.
//  Copyright (c) 2012 cocotomo. All rights reserved.
//

#import "PhotoSubmitterAPIKey.h"
#import "FotolifePhotoSubmitter.h"
#import "PhotoSubmitterAlbumEntity.h"
#import "PhotoSubmitterManager.h"
#import "PhotoSubmitterAccountTableViewController.h"
#import "Atompub.h"
#import "AtomContent.h"

#define PS_FOTOLIFE_ENABLED @"PSFotolifeEnabled"
#define PS_FOTOLIFE_AUTH_USERID @"PSFotolifeUserId"
#define PS_FOTOLIFE_AUTH_PASSWORD @"PSFotolifePassword"
#define PS_FOTOLIFE_SETTING_USERNAME @"PSFotolifeUsername"

#define PS_FOTOLIFE_PHOTO_WIDTH 960
#define PS_FOTOLIFE_PHOTO_HEIGHT 720

//-----------------------------------------------------------------------------
//Private Implementations
//-----------------------------------------------------------------------------
@interface FotolifePhotoSubmitter(PrivateImplementation)
- (void) setupInitialState;
- (void) clearCredentials;
- (void) loadCredentials;
- (WSSECredential *) credential;
- (void) getUserInfomation;
@end

#pragma mark - private implementations
@implementation FotolifePhotoSubmitter(PrivateImplementation)
/*!
 * initializer
 */
-(void)setupInitialState{
    [self loadCredentials];
}

/*!
 * clear fotolife access token key
 */
- (void)clearCredentials{
    if ([self secureSettingExistsForKey:PS_FOTOLIFE_AUTH_USERID]) {
        [self removeSecureSettingForKey:PS_FOTOLIFE_AUTH_USERID];
        [self removeSecureSettingForKey:PS_FOTOLIFE_AUTH_PASSWORD];
        [self removeSettingForKey:PS_FOTOLIFE_SETTING_USERNAME];
    } 
    [self disable];
}

/*!
 * load saved credentials
 */
- (void)loadCredentials{
    if([self secureSettingExistsForKey:PS_FOTOLIFE_AUTH_USERID]){
        userId_ = [self secureSettingForKey:PS_FOTOLIFE_AUTH_USERID];
        password_ = [self secureSettingForKey:PS_FOTOLIFE_AUTH_PASSWORD];
    }
}

/*!
 * create credential object
 */
- (WSSECredential *)credential{
    return [WSSECredential credentialWithUsername:userId_ password:password_];
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
    AtomEntry *entry = [AtomEntry entry];
    if(photo.comment){
        entry.title = photo.comment;
    }else{
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        df.dateFormat  = @"yyyy-MM-dd HH:mm:ss";
        entry.title = [df stringFromDate:photo.timestamp];
    }
    AtomContent *content = [AtomContent content];
    content.type = @"image/jpeg";
    content.mode = @"base64";
    [content setBodyAsTextContent:photo.base64String];
    entry.content = content;
    
    AtomGenerator *generator = [AtomGenerator generator];
    generator.name = @"tottepost";
    generator.version = @"1.0";
    generator.url = [NSURL URLWithString:@"https://github.com/kent013/tottepost"];
    //entry.generator = generator;
        
    AtompubClient *client = [[AtompubClient alloc] init];
    //client.enableDebugOutput = YES;
    client.tag = @"submitPhoto";
    client.delegate = self;
    [client setCredential:[self credential]];
    
    [client startCreatingEntry:entry withURL:[NSURL URLWithString:@"http://f.hatena.ne.jp/atom/post"]];
    
    NSString *hash = photo.md5;
    [self setPhotoHash:hash forRequest:client];
    [self addRequest:client];
    [self setOperationDelegate:delegate forRequest:client];
    [self photoSubmitter:self willStartUpload:hash];    
}

/*!
 * cancel photo upload
 */
- (void)cancelPhotoSubmit:(PhotoSubmitterImageEntity *)photo{
    NSString *hash = photo.md5;
    AtompubClient *client = (AtompubClient *)[self requestForPhoto:hash];
    [client cancel];
    id<PhotoSubmitterPhotoOperationDelegate> operationDelegate = [self operationDelegateForRequest:client];
    [operationDelegate photoSubmitterDidOperationCanceled];
    [self photoSubmitter:self didCanceled:hash];
    [self clearRequest:client];
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
    return NO;
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
    AtompubClient *client = [[AtompubClient alloc] init];
    client.tag = @"login";
    client.delegate = self;
    //client.enableDebugOutput = YES;
    [client setCredential:[WSSECredential credentialWithUsername:userId password:password]];
    [self setSecureSetting:userId forKey:PS_FOTOLIFE_AUTH_USERID];
    [self setSecureSetting:password forKey:PS_FOTOLIFE_AUTH_PASSWORD];
    [self addRequest:client];
    [client startLoadingFeedWithURL:[NSURL URLWithString:@"http://f.hatena.ne.jp/atom"]];
}

#pragma mark - AtompubClientDelegate
/*!
 * did receive feed
 */
- (void)client:(AtompubClient *)client didReceiveFeed:(AtomFeed *)feed{
    if([client.tag isEqualToString:@"login"]){
        [self setSetting:@"enabled" forKey:PS_FOTOLIFE_ENABLED];
        [self.authDelegate photoSubmitter:self didLogin:self.type];
        [self.authDelegate photoSubmitter:self didAuthorizationFinished:self.type];
        userId_ = [self secureSettingForKey:PS_FOTOLIFE_AUTH_USERID];
        password_ = [self secureSettingForKey:PS_FOTOLIFE_AUTH_PASSWORD];
    }else if([client.tag isEqualToString:@"album"]){
        NSLog(@"%@", [feed stringValue]);
    }
    [self clearRequest:client];    
}

/*!
 * create entry
 */
- (void)client:(AtompubClient *)client didCreateEntry:(AtomEntry *)entry withLocation:(NSURL *)location{
    if([client.tag isEqualToString:@"submitPhoto"]){
        NSString *hash = [self photoForRequest:client];
        
        id<PhotoSubmitterPhotoOperationDelegate> operationDelegate = [self operationDelegateForRequest:client];
        [self photoSubmitter:self didSubmitted:hash suceeded:YES message:@"Photo upload succeeded"];
        [operationDelegate photoSubmitterDidOperationFinished:YES];
    }
    [self clearRequest:client];
}

/*!
 * failed with error
 */
- (void)client:(AtompubClient *)client didFailWithError:(NSError *)error{
    if([client.tag isEqualToString:@"login"]){
        [self clearCredentials];
        [self.authDelegate photoSubmitter:self didLogout:self.type];
    }else if([client.tag isEqualToString:@"submitPhoto"]){
        NSString *hash = [self photoForRequest:client];
        [self photoSubmitter:self didSubmitted:hash suceeded:NO message:[error localizedDescription]];
        id<PhotoSubmitterPhotoOperationDelegate> operationDelegate = [self operationDelegateForRequest:client];
        [operationDelegate photoSubmitterDidOperationFinished:NO];
    }
    NSLog(@"%@", error.description);
    [self clearRequest:client];
}

/*!
 * progress
 */
- (void)client:(AtompubClient *)request didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite{
    CGFloat progress = (float)totalBytesWritten / (float)totalBytesExpectedToWrite;
    NSString *hash = [self photoForRequest:request];
    [self photoSubmitter:self didProgressChanged:hash progress:progress];
}
@end

