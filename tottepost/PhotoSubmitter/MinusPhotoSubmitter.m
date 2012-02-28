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

#define PS_MINUS_AUTH_USERID @"PSMinusUserId"
#define PS_MINUS_AUTH_PASSWORD @"PSMinusPassword"

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
    [self setSubmitterIsConcurrent:YES 
                      isSequencial:NO 
                     usesOperation:YES 
                   requiresNetwork:YES 
                  isAlbumSupported:YES];
    
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
    [self removeSecureSettingForKey:PS_MINUS_AUTH_USERID];
    [self removeSecureSettingForKey:PS_MINUS_AUTH_PASSWORD];
    userId_ = nil;
    password_ = nil;
    [super clearCredentials];
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
-(void)onLogin{
    PhotoSubmitterAccountTableViewController *controller =
    [[PhotoSubmitterAccountTableViewController alloc] init];
    controller.delegate = self;
    [[[[PhotoSubmitterManager sharedInstance] authControllerDelegate] requestNavigationControllerToPresentAuthenticationView] pushViewController:controller animated:YES];
}

/*!
 * logoff from Minus
 */
- (void)onLogout{  
    [minus_ logout];
}

/*!
 * refresh credential
 */
- (void)refreshCredential{
    if([minus_ isSessionValid] == NO){
        userId_ = [self secureSettingForKey:PS_MINUS_AUTH_USERID];
        password_ = [self secureSettingForKey:PS_MINUS_AUTH_PASSWORD];
        [minus_ refreshCredentialWithUsername:userId_ password:password_ andPermission:[NSArray arrayWithObjects:@"read_all", @"upload_new", nil]];
    }
}

- (BOOL)isSessionValid{
    return [minus_ isSessionValid];
}

#pragma mark - photo
/*!
 * submit photo with data, comment and delegate
 */
- (id)onSubmitPhoto:(PhotoSubmitterImageEntity *)photo andOperationDelegate:(id<PhotoSubmitterPhotoOperationDelegate>)delegate{
    NSString *folderId = @"";
    if(self.targetAlbum){
        folderId = self.targetAlbum.albumId;
    }
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateFormat  = @"yyyyMMddHHmmss";
    NSString *filename = [NSString stringWithFormat:@"%@.jpg", [df stringFromDate:photo.timestamp]];
    MinusRequest *request = [minus_ createFileWithFolderId:folderId caption:photo.comment filename:filename data:photo.data dataContentType:@"image/jpeg" andDelegate:self];
    return  request;
}    

/*!
 * cancel photo upload
 */
- (id)onCancelPhotoSubmit:(PhotoSubmitterImageEntity *)photo{
    MinusRequest *request = (MinusRequest *)[self requestForPhoto:photo.photoHash];
    [request cancel];
    return request;
}

#pragma mark - album
/*!
 * create album
 */
- (void)createAlbum:(NSString *)title withDelegate:(id<PhotoSubmitterAlbumDelegate>)delegate{
    self.albumDelegate = delegate;
    MinusRequest *request = [minus_ createFolderWithUsername:userId_ name:title isPublic:NO andDelegate:self];
    [self addRequest:request];
}

/*!
 * update album list
 */
- (void)updateAlbumListWithDelegate:(id<PhotoSubmitterDataDelegate>)delegate{
    self.dataDelegate = delegate;
    MinusRequest *request = [minus_ foldersWithUsername:userId_ andDelegate:self];
    [self addRequest:request];
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
    return PhotoSubmitterTypeMinus;
}

/*!
 * name
 */
- (NSString *)name{
    return @"Minus";
}

#pragma mark - MinusConnectSessionDelegate
/*!
 * did login to minus
 */
-(void)minusDidLogin{
    userId_ = [self secureSettingForKey:PS_MINUS_AUTH_USERID];
    password_ = [self secureSettingForKey:PS_MINUS_AUTH_PASSWORD];
    [self getUserInfomation];
    [self completeLogin];
}

/*!
 * did logout from minus
 */
- (void)minusDidLogout{
    [self completeLogout];
}

/*!
 * attempt to login, but not logined
 */
- (void)minusDidNotLogin{
    [self completeLoginFailed];
    
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
        self.username = [result objectForKey:@"display_name"];
    }else if([request.tag isEqualToString:kMinusRequestCreateFile]){
        [self completeSubmitPhotoWithRequest:request];
    }else if([request.tag isEqualToString:kMinusRequestCreateFolder]){
        [self.albumDelegate photoSubmitter:self didAlbumCreated:nil suceeded:YES withError:nil];
        [self clearRequest:request];
    }else if([request.tag isEqualToString:kMinusRequestFoldersWithUsername]){
        NSArray *as = [result objectForKey:@"results"];
        NSMutableArray *albums = [[NSMutableArray alloc] init];
        for(NSDictionary *a in as){
            NSString *privacy = @"private";
            if([a objectForKey:@"is_public"]){
                privacy = @"public";
            }
            PhotoSubmitterAlbumEntity *album = 
            [[PhotoSubmitterAlbumEntity alloc] initWithId:[a objectForKey:@"id"] name:[a objectForKey:@"name"] privacy:privacy];
            [albums addObject:album];
        }
        self.albumList = albums;
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
        [self completeSubmitPhotoWithRequest:request andError:error];
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
