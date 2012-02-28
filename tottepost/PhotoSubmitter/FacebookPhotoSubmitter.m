//
//  FacebookPhotoSubmitter.m
//  PhotoSubmitter for Facebook
//
//  Created by ISHITOYA Kentaro on 11/12/13.
//  Copyright (c) 2011 cocotomo. All rights reserved.
//

#import "PhotoSubmitterAPIKey.h"
#import "FacebookPhotoSubmitter.h"
#import "UIImage+Digest.h"
#import "RegexKitLite.h"
#import "PhotoSubmitterAlbumEntity.h"
#import "PhotoSubmitterManager.h"
#import "UIImage+EXIF.h"

#define PS_FACEBOOK_AUTH_TOKEN @"PSFacebookAccessTokenKey"
#define PS_FACEBOOK_AUTH_EXPIRATION_DATE @"PSFacebookExpirationDateKey"

#define PS_FACEBOOK_PHOTO_WIDTH 960
#define PS_FACEBOOK_PHOTO_HEIGHT 720

//-----------------------------------------------------------------------------
//Private Implementations
//-----------------------------------------------------------------------------
@interface FacebookPhotoSubmitter(PrivateImplementation)
- (void) setupInitialState;
- (void) getUserInfomation;
@end

#pragma mark - private implementations
@implementation FacebookPhotoSubmitter(PrivateImplementation)
/*!
 * initializer
 */
-(void)setupInitialState{
    [self setSubmitterIsConcurrent:YES 
                      isSequencial:NO 
                     usesOperation:YES 
                   requiresNetwork:YES 
                  isAlbumSupported:YES];
    
    facebook_ = [[Facebook alloc] initWithAppId:PHOTO_SUBMITTER_FACEBOOK_API_ID andDelegate:self];
    if ([self settingExistsForKey:PS_FACEBOOK_AUTH_TOKEN] 
        && [self settingExistsForKey:PS_FACEBOOK_AUTH_EXPIRATION_DATE]) {
        facebook_.accessToken = [self settingForKey:PS_FACEBOOK_AUTH_TOKEN];
        facebook_.expirationDate = [self settingForKey:PS_FACEBOOK_AUTH_EXPIRATION_DATE];
    }
}

/*!
 * clear facebook access token key
 */
- (void)clearCredentials{
    if ([self settingExistsForKey:PS_FACEBOOK_AUTH_TOKEN]) {
        [self removeSettingForKey:PS_FACEBOOK_AUTH_TOKEN];
        [self removeSettingForKey:PS_FACEBOOK_AUTH_EXPIRATION_DATE];
    } 
    [super clearCredentials];
}

/*!
 * get user information
 */
- (void)getUserInfomation{
    [facebook_ requestWithGraphPath:@"me" andDelegate:self];
}

#pragma mark - FBRequestWithUploadProgressDelegate
/*!
 * facebook request delegate, did load
 */
- (void)request:(FBRequest *)request didLoad:(id)result {
    if([request.url isMatchedByRegex:@"me$"]){
        if ([result isKindOfClass:[NSArray class]]) {
            result = [result objectAtIndex:0];
        }
        NSString *username = [[result objectForKey:@"name"] stringByReplacingOccurrencesOfRegex:@" +" withString:@" "];
        self.username = username;
    }else if([request.url isMatchedByRegex:@"photos$"]){
        [self completeSubmitPhotoWithRequest:request];
    }else if([request.url isMatchedByRegex:@"albums$"] && 
             [request.httpMethod isEqualToString:@"POST"]){
        [self.albumDelegate photoSubmitter:self didAlbumCreated:nil suceeded:YES withError:nil];
    }else if([request.url isMatchedByRegex:@"albums$"] && 
             [request.httpMethod isEqualToString:@"GET"]){
        NSArray *as = [result objectForKey:@"data"];
        NSMutableArray *albums = [[NSMutableArray alloc] init];
        for(NSDictionary *a in as){
            PhotoSubmitterAlbumEntity *album = 
            [[PhotoSubmitterAlbumEntity alloc] initWithId:[a objectForKey:@"id"] name:[a objectForKey:@"name"] privacy:[a objectForKey:@"privacy"]];
            [albums addObject:album];
        }
        self.albumList = albums;
    }else{
        NSLog(@"%s", __PRETTY_FUNCTION__);
    }
    [self clearRequest:request];
};

/*!
 * facebook request delegate, did fail
 */
- (void)request:(FBRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"%@, %@", request.url, error.description);
    if([request.url isMatchedByRegex:@"me$"]){
    }else if([request.url isMatchedByRegex:@"albums$"] && 
             [request.httpMethod isEqualToString:@"GET"]){
    }else if([request.url isMatchedByRegex:@"albums$"] && 
             [request.httpMethod isEqualToString:@"POST"]){
        [self.albumDelegate photoSubmitter:self didAlbumCreated:nil suceeded:NO withError:error];
    }else if([request.url isMatchedByRegex:@"photos$"]){
        [self completeSubmitPhotoWithRequest:request andError:error];
    }
    [self clearRequest:request];
};

/*!
 * facebook request delegate, upload progress
 */
- (void)request:(FBRequest *)request didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite{
    CGFloat progress = (float)totalBytesWritten / (float)totalBytesExpectedToWrite;
    NSString *hash = [self photoForRequest:request];
    [self photoSubmitter:self didProgressChanged:hash progress:progress];
}
@end

//-----------------------------------------------------------------------------
//Public Implementations
//-----------------------------------------------------------------------------
#pragma mark - public PhotoSubmitter Protocol implementations
@implementation FacebookPhotoSubmitter
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
    NSArray *permissions = 
    [NSArray arrayWithObjects:@"publish_stream", @"user_location", @"user_photos", @"offline_access", nil];
    [facebook_ authorize:permissions];
}

/*!
 * logoff from facebook
 */
- (void)onLogout{
    [facebook_ logout:self];   
}

/*!
 * refresh credential
 */
- (void)refreshCredential{
    [facebook_ extendAccessTokenIfNeeded];
}

/*!
 * check url is processable
 */
- (BOOL)isProcessableURL:(NSURL *)url{
    if([url.absoluteString isMatchedByRegex:@"^fb[0-9]+"]){
        return YES;
    }
    return NO;
}

/*!
 * on open url finished
 */
- (BOOL)didOpenURL:(NSURL *)url{
    return [facebook_ handleOpenURL:url];
}

/*!
 * is session valid
 */
- (BOOL)isSessionValid{
    if ([self settingForKey:PS_FACEBOOK_AUTH_TOKEN]) {
        return YES;
    }
    return NO;
}

#pragma mark - photo
/*!
 * submit photo with data, comment and delegate
 */
- (id)onSubmitPhoto:(PhotoSubmitterImageEntity *)photo andOperationDelegate:(id<PhotoSubmitterPhotoOperationDelegate>)delegate{
    CGSize size = CGSizeMake(PS_FACEBOOK_PHOTO_WIDTH, PS_FACEBOOK_PHOTO_HEIGHT);
    if(photo.image.size.width < photo.image.size.height){
        size = CGSizeMake(PS_FACEBOOK_PHOTO_HEIGHT, PS_FACEBOOK_PHOTO_WIDTH);
    }
    
    NSMutableDictionary *params = 
    [NSMutableDictionary dictionaryWithObjectsAndKeys: 
     [photo resizedImage:size], @"source", 
     photo.comment, @"name",
     nil];
    NSString *path = @"me/photos";
    if(self.targetAlbum != nil){
        path = [NSString stringWithFormat:@"%@/photos", self.targetAlbum.albumId];
    }
    FBRequest *request = [facebook_ requestWithGraphPath:path andParams:params andHttpMethod:@"POST" andDelegate:self];
    return request;
}

/*!
 * cancel photo upload
 */
- (id)onCancelPhotoSubmit:(PhotoSubmitterImageEntity *)photo{
    FBRequest *request = (FBRequest *)[self requestForPhoto:photo.photoHash];
    [request.connection cancel];
    return request;
}

#pragma mark - albums
/*!
 * create album
 */
- (void)createAlbum:(NSString *)title withDelegate:(id<PhotoSubmitterAlbumDelegate>)delegate{
    self.albumDelegate = delegate;
    NSMutableDictionary *params = 
    [NSMutableDictionary dictionaryWithObjectsAndKeys: 
     @"", @"message", 
     title, @"name",
     nil];
    NSString *path = @"me/albums";
    FBRequest *request = [facebook_ requestWithGraphPath:path andParams:params andHttpMethod:@"POST" andDelegate:self];
    [self addRequest:request];
}

/*!
 * update album list
 */
- (void)updateAlbumListWithDelegate:(id<PhotoSubmitterDataDelegate>)delegate{
    self.dataDelegate = delegate;
    [facebook_ requestWithGraphPath:@"me/albums" andDelegate:self];
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
    return PhotoSubmitterTypeFacebook;
}

/*!
 * name
 */
- (NSString *)name{
    return @"Facebook";
}

#pragma mark - FBSessionDelegate methods
/*!
 * facebook delegate, did login suceeded
 */
- (void)fbDidLogin {
    [self setSetting:[facebook_ accessToken] forKey:PS_FACEBOOK_AUTH_TOKEN];
    [self setSetting:[facebook_ expirationDate] forKey:PS_FACEBOOK_AUTH_EXPIRATION_DATE];
    [self enable];
    
    [self getUserInfomation];
    [self.authDelegate photoSubmitter:self didAuthorizationFinished:self.type];
}

/*!
 * facebook delegate, if not login
 */
-(void)fbDidNotLogin:(BOOL)cancelled {
    [self clearCredentials];
    [self.authDelegate photoSubmitter:self didLogout:self.type];
    [self.authDelegate photoSubmitter:self didAuthorizationFinished:self.type];
}

/*!
 * facebook delegate, if logout
 */
- (void) fbDidLogout {
    [self clearCredentials];
    [self.authDelegate photoSubmitter:self didLogout:self.type];
}

/*!
 * facebook session invalidated
 */
- (void) fbSessionInvalidated{
    [facebook_ extendAccessTokenIfNeeded];
}

/*!
 * facebook session extended
 */
- (void)fbDidExtendToken:(NSString *)accessToken expiresAt:(NSDate *)expiresAt{
}
@end
