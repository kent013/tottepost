//
//  TwitterPhotoSubmitter.m
//  PhotoSubmitter for Twitter
//
//  Created by ISHITOYA Kentaro on 11/12/17.
//  Copyright (c) 2011 cocotomo. All rights reserved.
//

#import "TwitterPhotoSubmitter.h"
#import "PhotoSubmitterAPIKey.h"
#import "UIImage+Digest.h"

#define PS_TWITTER_ENABLED @"PSTwitterEnabled"
#define PS_TWITTER_USERNAME @"PSTwitterUsername"

//-----------------------------------------------------------------------------
//Private Implementations
//-----------------------------------------------------------------------------
@interface TwitterPhotoSubmitter(PrivateImplementation)
- (void) setupInitialState;
- (void) clearCredentials;
- (ACAccount *)selectedAccount;
@end

#pragma mark - private implementations
@implementation TwitterPhotoSubmitter(PrivateImplementation)
/*!
 * initializer
 */
-(void)setupInitialState{
    accountStore_ = [[ACAccountStore alloc] init];
}

/*!
 * clear defaults, on twitter we will not store access token.
 */
- (void)clearCredentials{
    [self removeSettingForKey:PS_TWITTER_ENABLED];
}

/*!
 * get selected account
 */
- (ACAccount *)selectedAccount{
    NSArray *accountsArray = self.accounts;
    for(ACAccount *account in accountsArray){
        if([account.username isEqualToString:self.selectedAccountUsername]){
            return account;
        }
    }
    if(accountsArray.count != 0){
        ACAccount *account = [accountsArray objectAtIndex:0];
        self.selectedAccountUsername = account.username;
        return account;
    }
    return nil;
}
#pragma mark - NSURLConnection delegates
/*!
 * did fail
 */
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    NSString *hash = [self photoForRequest:connection];    
    [self photoSubmitter:self didSubmitted:hash suceeded:NO message:[error localizedDescription]];
    id<PhotoSubmitterPhotoOperationDelegate> operationDelegate = [self operationDelegateForRequest:connection];
    [operationDelegate photoSubmitterDidOperationFinished:NO];
    [self clearRequest:connection];

}

/*!
 * did finished
 */
-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    NSString *hash = [self photoForRequest:connection];
    if(hash == nil){
        return;
    }
    [self photoSubmitter:self didSubmitted:hash suceeded:YES message:@"Photo upload succeeded"];
    id<PhotoSubmitterPhotoOperationDelegate> operationDelegate = [self operationDelegateForRequest:connection];
    [operationDelegate photoSubmitterDidOperationFinished:YES];
    [self clearRequest:connection];
    
}

/*!
 * progress
 */
- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite{
    CGFloat progress = (float)totalBytesWritten / (float)totalBytesExpectedToWrite;
    NSString *hash = [self photoForRequest:connection];
    [self photoSubmitter:self didProgressChanged:hash progress:progress];
}
@end

//-----------------------------------------------------------------------------
//Public Implementations
//-----------------------------------------------------------------------------
#pragma mark - public PhotoSubmitter Protocol implementations
@implementation TwitterPhotoSubmitter
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
 * login to twitter
 */
-(void)login{
    [self.authDelegate photoSubmitter:self willBeginAuthorization:self.type];
    ACAccountType *accountType = [accountStore_ accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    [accountStore_ requestAccessToAccountsWithType:accountType withCompletionHandler:^(BOOL granted, NSError *error) {
        if(granted) {
            ACAccount *account = self.selectedAccount;
            
			if (account != nil){
                [self setSetting:@"enabled" forKey:PS_TWITTER_ENABLED];                
                [self.authDelegate photoSubmitter:self didLogin:self.type];
            }else{
                UIAlertView* alert = 
                [[UIAlertView alloc] initWithTitle:@"Information"
                                           message:@"Twitter account is not avaliable. do you want to configure it?"
                                          delegate:self
                                 cancelButtonTitle:@"Cancel"
                                 otherButtonTitles:@"Configure", nil];
                [alert show];
                [self.authDelegate photoSubmitter:self didLogout:self.type];
            }
        }else{
            [self.authDelegate photoSubmitter:self didLogout:self.type];
        }
        [self.authDelegate photoSubmitter:self didAuthorizationFinished:self.type];
    }];
}

/*!
 * alert delegate
 */
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if(buttonIndex == 1){
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=TWITTER"]];
    }
}

/*!
 * logoff from twitter
 */
- (void)logout{  
    [self clearCredentials];
    [self.authDelegate photoSubmitter:self didLogout:self.type];
}

/*!
 * disable
 */
- (void)disable{
    [self removeSettingForKey:PS_TWITTER_ENABLED];
    [self.authDelegate photoSubmitter:self didLogout:self.type];
}

/*!
 * check url is processoble, we will not use this method in twitter
 */
- (BOOL)isProcessableURL:(NSURL *)url{
    return NO;
}

/*!
 * on open url finished, we will not use this method in twitter
 */
- (BOOL)didOpenURL:(NSURL *)url{
    return NO;
}

/*!
 * get account list
 */
- (NSArray *)accounts{
    ACAccountType *accountType = [accountStore_ accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    return [accountStore_ accountsWithAccountType:accountType];    
}

/*!
 * set selected username
 */
- (NSString *)selectedAccountUsername{
    return [self settingForKey:PS_TWITTER_USERNAME];
}

/*!
 * set selected username
 */
- (void)setSelectedAccountUsername:(NSString *)selectedAccountUsername{
    return [self setSetting:selectedAccountUsername forKey:PS_TWITTER_USERNAME];
}

/*!
 * check is logined
 */
- (BOOL)isLogined{
    return self.isEnabled;
}

/*!
 * check is enabled
 */
- (BOOL) isEnabled{
    return [TwitterPhotoSubmitter isEnabled];
}

/*!
 * isEnabled
 */
+ (BOOL)isEnabled{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:PS_TWITTER_ENABLED]) {
        return YES;
    }
    return NO;
}

#pragma mark - photo
/*!
 * submit photo with data, comment and delegate
 */
- (void)submitPhoto:(PhotoSubmitterImageEntity *)photo andOperationDelegate:(id<PhotoSubmitterPhotoOperationDelegate>)delegate{
    if(photo.comment == nil){
        photo.comment = @"TottePost Photo";
    }
    
    ACAccount *twitterAccount = [self selectedAccount];
    if (twitterAccount == nil) {
        return;
    }
    
    NSURL *url = 
    [NSURL URLWithString:@"https://upload.twitter.com/1/statuses/update_with_media.json"];
    TWRequest *request = [[TWRequest alloc] initWithURL:url parameters:nil 
                                          requestMethod:TWRequestMethodPOST];
    
    [request setAccount:twitterAccount];
    [request addMultiPartData:photo.data 
                     withName:@"media[]" type:@"multipart/form-data"];
    [request addMultiPartData:[photo.comment dataUsingEncoding:NSUTF8StringEncoding] 
                     withName:@"status" type:@"multipart/form-data"];
    
    NSURLConnection *connection = 
    [[NSURLConnection alloc] initWithRequest:request.signedURLRequest delegate:self startImmediately:NO];
    NSString *imageHash = photo.md5;
    
    if(connection == nil || delegate.isCancelled){
        return;
    }
    
    [connection start];
    [self setPhotoHash:imageHash forRequest:connection];
    [self addRequest:connection];
    [self setOperationDelegate:delegate forRequest:connection];
    [self photoSubmitter:self willStartUpload:imageHash];
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
    return YES;
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
#pragma mark - username
/*!
 * get username
 */
- (NSString *)username{ 
    return self.selectedAccount.username;
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
    return PhotoSubmitterTypeTwitter;
}

/*!
 * name
 */
- (NSString *)name{
    return @"Twitter";
}

/*!
 * icon image
 */
- (UIImage *)icon{
    return [UIImage imageNamed:@"twitter_32.png"];
}

/*!
 * small icon image
 */
- (UIImage *)smallIcon{
    return [UIImage imageNamed:@"twitter_16.png"];
}
@end
