//
//  TwitterPhotoSubmitter.m
//  PhotoSubmitter for Twitter
//
//  Created by ISHITOYA Kentaro on 11/12/17.
//  Copyright (c) 2011 cocotomo. All rights reserved.
//

#import "TwitterPhotoSubmitter.h"
#import "PhotoSubmitterAPIKey.h"

#define PS_TWITTER_USERNAME @"PSTwitterUsername"

//-----------------------------------------------------------------------------
//Private Implementations
//-----------------------------------------------------------------------------
@interface TwitterPhotoSubmitter(PrivateImplementation)
- (void) setupInitialState;
- (ACAccount *)selectedAccount;
@end

#pragma mark - private implementations
@implementation TwitterPhotoSubmitter(PrivateImplementation)
/*!
 * initializer
 */
-(void)setupInitialState{
    [self setSubmitterIsConcurrent:YES 
                      isSequencial:YES 
                     usesOperation:YES 
                   requiresNetwork:YES 
                  isAlbumSupported:NO];
    
    accountStore_ = [[ACAccountStore alloc] init];
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
    [self completeSubmitPhotoWithRequest:connection andError:error];
}

/*!
 * did finished
 */
-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    [self completeSubmitPhotoWithRequest:connection];    
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
-(void)onLogin{
    ACAccountType *accountType = [accountStore_ accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    [accountStore_ requestAccessToAccountsWithType:accountType withCompletionHandler:^(BOOL granted, NSError *error) {
        if(granted) {
            ACAccount *account = self.selectedAccount;
            
			if (account != nil){
                [self enable];
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
- (void)onLogout{
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
 * is session valid
 */
- (BOOL)isSessionValid{
    return self.isEnabled;
}

/*!
 * check is logined
 */
- (BOOL)isLogined{
    return self.isEnabled;
}

#pragma mark - photo
/*!
 * submit photo
 */
- (id)onSubmitPhoto:(PhotoSubmitterImageEntity *)photo andOperationDelegate:(id<PhotoSubmitterPhotoOperationDelegate>)delegate{
    if(photo.comment == nil){
        photo.comment = @"TottePost Photo";
    }
    
    ACAccount *twitterAccount = [self selectedAccount];
    if (twitterAccount == nil) {
        return nil;
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
    
    if(connection != nil){
        [connection start];
    }    
    return connection;
}

/*!
 * cancel photo upload
 */
- (id)onCancelPhotoSubmit:(PhotoSubmitterImageEntity *)photo{
    NSURLConnection *connection = 
    (NSURLConnection *)[self requestForPhoto:photo.photoHash];
    [connection cancel];
    return connection;
}

#pragma mark - albums
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
@end
