//
//  TwitterPhotoSubmitter.m
//  tottepost
//
//  Created by ISHITOYA Kentaro on 11/12/17.
//  Copyright (c) 2011 cocotomo. All rights reserved.
//

#import "TwitterPhotoSubmitter.h"
#import "PhotoSubmitterAPIKey.h"
#import "UIImage+Digest.h"

#define PS_TWITTER_ENABLED @"PSTwitterEnabled"

//-----------------------------------------------------------------------------
//Private Implementations
//-----------------------------------------------------------------------------
@interface TwitterPhotoSubmitter(PrivateImplementation)
- (void) setupInitialState;
- (void) clearCredentials;
@end

@implementation TwitterPhotoSubmitter(PrivateImplementation)
#pragma mark -
#pragma mark private implementations
/*!
 * initializer
 */
-(void)setupInitialState{
}

/*!
 * clear defaults, on twitter we will not store access token.
 */
- (void)clearCredentials{
    [self removeSettingForKey:PS_TWITTER_ENABLED];
}

#pragma mark -
#pragma mark NSURLConnection delegates
/*!
 * did fail
 */
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    NSString *hash = [self photoForRequest:connection];    
    [self photoSubmitter:self didSubmitted:hash suceeded:NO message:[error localizedDescription]];
    id<PhotoSubmitterOperationDelegate> operationDelegate = [self operationDelegateForRequest:connection];
    [operationDelegate photoSubmitterDidOperationFinished];
    [self clearRequest:connection];

}

/*!
 * did finished
 */
-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    NSString *hash = [self photoForRequest:connection];
    [self photoSubmitter:self didSubmitted:hash suceeded:YES message:@"Photo upload succeeded"];
    id<PhotoSubmitterOperationDelegate> operationDelegate = [self operationDelegateForRequest:connection];
    [operationDelegate photoSubmitterDidOperationFinished];
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
@implementation TwitterPhotoSubmitter
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
 * submit photo with comment
 */
- (void)submitPhoto:(UIImage *)photo comment:(NSString *)comment andDelegate:(id<PhotoSubmitterOperationDelegate>)delegate{
    photo = [self photoPreprocess:photo andComment:comment];
	ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
	
    if(comment == nil){
        comment = @"TottePost Photo";
    }
    NSArray *accountsArray = [accountStore accountsWithAccountType:accountType];
    if ([accountsArray count] > 0) {
        ACAccount *twitterAccount = [accountsArray objectAtIndex:0];
        NSURL *url = 
        [NSURL URLWithString:@"https://upload.twitter.com/1/statuses/update_with_media.json"];
        TWRequest *request = [[TWRequest alloc] initWithURL:url parameters:nil 
                                              requestMethod:TWRequestMethodPOST];
        [request setAccount:twitterAccount];
        NSData *imageData = UIImagePNGRepresentation(photo);
        [request addMultiPartData:imageData 
                         withName:@"media[]" type:@"multipart/form-data"];
        [request addMultiPartData:[comment dataUsingEncoding:NSUTF8StringEncoding] 
                         withName:@"status" type:@"multipart/form-data"];
        
        NSURLConnection *connection = 
          [[NSURLConnection alloc] initWithRequest:request.signedURLRequest delegate:self];
        NSString *imageHash = photo.MD5DigestString;
        
        if(connection){
            [self setPhotoHash:imageHash forRequest:connection];
            [self setOperationDelegate:delegate forRequest:connection];
            [self photoSubmitter:self willStartUpload:imageHash];
        }

    }
}

/*!
 * login to twitter
 */
-(void)login{
	ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    [accountStore requestAccessToAccountsWithType:accountType withCompletionHandler:^(BOOL granted, NSError *error) {
        if(granted) {
            NSArray *accountsArray = [accountStore accountsWithAccountType:accountType];
			if ([accountsArray count] > 0){
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
 * return type
 */
- (PhotoSubmitterType) type{
    return PhotoSubmitterTypeTwitter;
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

/*!
 * get username
 */
- (NSString *)username{
	ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
	
    NSArray *accountsArray = [accountStore accountsWithAccountType:accountType];
    if ([accountsArray count] > 0) {
        ACAccount *twitterAccount = [accountsArray objectAtIndex:0];
        return twitterAccount.username;
    }
    return nil;
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
    [self.dataDelegate photoSubmitter:self didUsernameUpdated:self.username];
}

/*!
 * invoke method as concurrent?
 */
- (BOOL)isConcurrent{
    return YES;
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
@end
