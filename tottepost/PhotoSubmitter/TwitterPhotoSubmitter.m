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
 * clear flickr access token key
 */
- (void)clearCredentials{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:PS_TWITTER_ENABLED];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    NSString *hash = [self photoForRequest:connection];    
    [self.photoDelegate photoSubmitter:self didSubmitted:hash suceeded:NO message:[error localizedDescription]];
    [self removePhotoForRequest:connection];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    NSString *hash = [self photoForRequest:connection];
    [self.photoDelegate photoSubmitter:self didSubmitted:hash suceeded:YES message:@"Photo upload succeeded"];
    [self removePhotoForRequest:connection];
    
}

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite{
    CGFloat progress = (float)totalBytesWritten / (float)totalBytesExpectedToWrite;
    NSString *hash = [self photoForRequest:connection];
    [self.photoDelegate photoSubmitter:self didProgressChanged:hash progress:progress];
}

@end

//-----------------------------------------------------------------------------
//Public Implementations
//-----------------------------------------------------------------------------
@implementation TwitterPhotoSubmitter
@synthesize authDelegate;
@synthesize photoDelegate;
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
 * submit photo
 */
- (void)submitPhoto:(UIImage *)photo{
    return [self submitPhoto:photo comment:nil];
}

/*!
 * submit photo with comment
 */
- (void)submitPhoto:(UIImage *)photo comment:(NSString *)comment{
	ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
	
    if(comment == nil){
        comment = @"TottePost Photo";
    }
    [accountStore requestAccessToAccountsWithType:accountType withCompletionHandler:^(BOOL granted, NSError *error) {
        if(granted) {
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
                NSLog(@"%@", request.signedURLRequest);
                NSURLConnection *connection = 
                  [[NSURLConnection alloc] initWithRequest:request.signedURLRequest delegate:self];
                NSString *hash = photo.MD5DigestString;
                if(connection){
                    [self.photoDelegate photoSubmitter:self willStartUpload:hash];
                    [self setPhotoHash:hash forRequest:connection];
                }
			}
        }
	}];
}

/*!
 * login to flickr
 */
-(void)login{
	ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    [accountStore requestAccessToAccountsWithType:accountType withCompletionHandler:^(BOOL granted, NSError *error) {
        if(granted) {
            NSArray *accountsArray = [accountStore accountsWithAccountType:accountType];
			if ([accountsArray count] > 0){
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults setObject:@"enabled" forKey:PS_TWITTER_ENABLED];                
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
 * logoff from flickr
 */
- (void)logout{  
    [self clearCredentials];
}

/*!
 * disable
 */
- (void)disable{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:PS_TWITTER_ENABLED];
    [self.authDelegate photoSubmitter:self didLogout:self.type];
}

/*!
 * check is logined
 */
- (BOOL)isLogined{
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
