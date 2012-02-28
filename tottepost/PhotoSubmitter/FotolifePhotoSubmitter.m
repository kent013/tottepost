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

#define PS_FOTOLIFE_AUTH_USERID @"PSFotolifeUserId"
#define PS_FOTOLIFE_AUTH_PASSWORD @"PSFotolifePassword"

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
@end

#pragma mark - private implementations
@implementation FotolifePhotoSubmitter(PrivateImplementation)
/*!
 * initializer
 */
-(void)setupInitialState{
    [self setSubmitterIsConcurrent:YES 
                      isSequencial:NO 
                     usesOperation:YES 
                   requiresNetwork:YES 
                  isAlbumSupported:NO];
    
    [self loadCredentials];
}

/*!
 * clear fotolife access token key
 */
- (void)clearCredentials{
    [self removeSecureSettingForKey:PS_FOTOLIFE_AUTH_USERID];
    [self removeSecureSettingForKey:PS_FOTOLIFE_AUTH_PASSWORD];
    [super clearCredentials];
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
-(void)onLogin{
    PhotoSubmitterAccountTableViewController *controller =
    [[PhotoSubmitterAccountTableViewController alloc] init];
    controller.delegate = self;
    [[[[PhotoSubmitterManager sharedInstance] authControllerDelegate] requestNavigationControllerToPresentAuthenticationView] pushViewController:controller animated:YES];
}

/*!
 * logoff from fotolife
 */
- (void)onLogout{
}

/*!
 * is session valid
 */
- (BOOL)isSessionValid{
    return [self secureSettingExistsForKey:PS_FOTOLIFE_AUTH_USERID];
}


#pragma mark - photo
/*!
 * submit photo with data, comment and delegate
 */
- (id)onSubmitPhoto:(PhotoSubmitterImageEntity *)photo andOperationDelegate:(id<PhotoSubmitterPhotoOperationDelegate>)delegate{
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
    return client;
}

/*!
 * cancel photo upload
 */
- (id)onCancelPhotoSubmit:(PhotoSubmitterImageEntity *)photo{
    AtompubClient *client = (AtompubClient *)[self requestForPhoto:photo.photoHash];
    [client cancel];
    return client;
}

#pragma mark - albums
/*!
 * create album
 */
- (void)createAlbum:(NSString *)title withDelegate:(id<PhotoSubmitterAlbumDelegate>)delegate{
}

/*!
 * update album list
 */
- (void)updateAlbumListWithDelegate:(id<PhotoSubmitterDataDelegate>)delegate{
    //do nothing
}

#pragma mark - username
/*!
 * update username
 */
- (void)updateUsernameWithDelegate:(id<PhotoSubmitterDataDelegate>)delegate{
    self.dataDelegate = delegate;
    [self.dataDelegate photoSubmitter:self didUsernameUpdated:self.username];
}

/*!
 * get username
 */
- (NSString *)username{
    return [self secureSettingForKey:PS_FOTOLIFE_AUTH_USERID];
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
        [self enable];
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
        [self completeSubmitPhotoWithRequest:client];
    }else{
        NSLog(@"%s", __PRETTY_FUNCTION__);
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
        [self completeSubmitPhotoWithRequest:client andError:error];
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

