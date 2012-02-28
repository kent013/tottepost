//
//  PhotoSubmitter.m
//  tottepost
//
//  Created by ISHITOYA Kentaro on 11/12/17.
//  Copyright (c) 2011 cocotomo. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <ImageIO/ImageIO.h>
#import "PhotoSubmitter.h"
#import "PhotoSubmitterManager.h"
#import "UIImage+Digest.h"
#import "UIImage+EXIF.h"
#import "PDKeychainBindings.h"

//-----------------------------------------------------------------------------
//Private Implementations
//-----------------------------------------------------------------------------
@interface PhotoSubmitter(PrivateImplementation)
@property (nonatomic, readonly) NSString *keyForEnabled;
@property (nonatomic, readonly) NSString *keyForUsername;
@property (nonatomic, readonly) NSString *keyForAlbums;
@property (nonatomic, readonly) NSString *keyForTargetAlbum;
- (NSString *) getIconImageNameWithSize:(int)size;
- (id<PhotoSubmitterInstanceProtocol>) subclassInstance;
@end

@implementation PhotoSubmitter(PrivateImplementation)
/*!
 * get enabled key
 */
- (NSString *)keyForEnabled{
    return [NSString stringWithFormat:@"PS%@Enabled", self.name];
}

/*!
 * get username key
 */
- (NSString *)keyForUsername{
    return [NSString stringWithFormat:@"PS%@Username", self.name];
}

/*!
 * get albums key
 */
- (NSString *)keyForAlbums{
    return [NSString stringWithFormat:@"PS%@Albums", self.name];
}

/*!
 * get target album key
 */
- (NSString *)keyForTargetAlbum{
    return [NSString stringWithFormat:@"PS%@TargetAlbum", self.name];
}

/*!
 * get icon name
 */
- (NSString *)getIconImageNameWithSize:(int)size{
    return [NSString stringWithFormat:@"%@_%d.png", 
            [self.name lowercaseString], size];
}

/*!
 * get subclass instance
 */
- (id<PhotoSubmitterInstanceProtocol>)subclassInstance{
    assert([self conformsToProtocol:@protocol(PhotoSubmitterInstanceProtocol)]);
    return (id<PhotoSubmitterInstanceProtocol>)self;
}
@end

//-----------------------------------------------------------------------------
//Public Implementations
//-----------------------------------------------------------------------------
@implementation PhotoSubmitter
@synthesize isAlbumSupported = isAlbumSupported_;
@synthesize isConcurrent = isConcurrent_;
@synthesize isSequencial = isSequencial_;
@synthesize useOperation = useOperation_;
@synthesize requiresNetwork = requiresNetwork_;
@synthesize authDelegate;
@synthesize dataDelegate;
@synthesize albumDelegate;

/*!
 * initialize
 */
- (id)init{
    self = [super init];
    if(self){
        photos_ = [[NSMutableDictionary alloc] init];
        requests_ = [[NSMutableDictionary alloc] init];
        operationDelegates_ = [[NSMutableDictionary alloc] init];
        photoDelegates_ = [[NSMutableArray alloc] init];
    }
    return self;
}

/*!
 * setup flags
 */
- (void)setSubmitterIsConcurrent:(BOOL)isConcurrent isSequencial:(BOOL)isSequencial usesOperation:(BOOL)usesOperation requiresNetwork:(BOOL)requiresNetwork isAlbumSupported:(BOOL)isAlbumSupported{
    isConcurrent_ = isConcurrent;
    isSequencial_ = isSequencial;
    useOperation_ = usesOperation;
    requiresNetwork_ = requiresNetwork;
    isAlbumSupported_ = isAlbumSupported;
}

#pragma mark - PhotoSubmitterProtocol methods
#pragma mark - authorization
/*!
 * login
 */
- (void) login{
    id<PhotoSubmitterInstanceProtocol> instance = [self subclassInstance];
    if(self.isSessionValid){
        [self enable];
        [self.authDelegate photoSubmitter:self didLogin:self.type];
        return;
    }
    [self.authDelegate photoSubmitter:self willBeginAuthorization:self.type];
    [instance onLogin];
}

/*!
 * logout and clear settings
 */
- (void)logout{  
    id<PhotoSubmitterInstanceProtocol> instance = [self subclassInstance];
    [instance onLogout];
    [self clearCredentials];
    [self.authDelegate photoSubmitter:self didLogout:self.type];
}

/*!
 * enable
 */
- (void)enable{
    [self setSetting:[NSNumber numberWithBool:YES] forKey:[self keyForEnabled]];
    [self.authDelegate photoSubmitter:self didLogin:self.type];
}

/*!
 * disable
 */
- (void)disable{
    [self removeSettingForKey:self.keyForEnabled];
    [self.authDelegate photoSubmitter:self didLogout:self.type];
}

/*!
 * is session valid
 */
- (BOOL)isSessionValid{
    NSLog(@"Must be implemented in subclass, %s", __PRETTY_FUNCTION__);
    return NO;
}

/*!
 * check is logined
 */
- (BOOL)isLogined{
    return self.isEnabled && self.isSessionValid;
}

/*!
 * isEnabled
 */
- (BOOL)isEnabled{
    return [[self settingForKey:[self keyForEnabled]] boolValue];
}

/*!
 * check url is processable, we will not use this method in twitter
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
 * clear facebook access token key
 */
- (void)clearCredentials{
    [self removeSettingForKey:[self keyForEnabled]];
    [self removeSettingForKey:[self keyForUsername]];
    [self removeSettingForKey:[self keyForAlbums]];
    [self removeSettingForKey:[self keyForTargetAlbum]];
}

/*!
 * refresh credential
 */
- (void)refreshCredential{
    //do nothing
}

#pragma mark - photos
/*!
 * submit photo with data, comment and delegate
 */
- (void) submitPhoto:(PhotoSubmitterImageEntity *)photo andOperationDelegate:(id<PhotoSubmitterPhotoOperationDelegate>)delegate{
    id<PhotoSubmitterInstanceProtocol> instance = [self subclassInstance];
    
    if(delegate.isCancelled){
        return;
    }
    id request = [instance onSubmitPhoto:photo andOperationDelegate:(id<PhotoSubmitterPhotoOperationDelegate>)delegate];
    if(request == nil){
        return;
    }
    [self setPhotoHash:photo.photoHash forRequest:request];
    [self addRequest:request];
    [self setOperationDelegate:delegate forRequest:request];
    [self photoSubmitter:self willStartUpload:photo.photoHash];    
}

/*!
 * cancel photo upload
 */
- (void) cancelPhotoSubmit:(PhotoSubmitterImageEntity *)photo{
    id<PhotoSubmitterInstanceProtocol> instance = [self subclassInstance];
    id request = [instance onCancelPhotoSubmit:photo];
    id<PhotoSubmitterPhotoOperationDelegate> operationDelegate = [self operationDelegateForRequest:request];
    [operationDelegate photoSubmitterDidOperationCanceled];
    [self photoSubmitter:self didCanceled:photo.photoHash];
    [self clearRequest:request];    
}

/*!
 * complete submit photo operation and send message to delegates.
 */
- (void)completeSubmitPhotoWithRequest:(id)request{
    NSString *hash = [self photoForRequest:request];
    
    id<PhotoSubmitterPhotoOperationDelegate> operationDelegate = [self operationDelegateForRequest:request];
    [self photoSubmitter:self didSubmitted:hash suceeded:YES message:@"Photo upload succeeded"];
    [operationDelegate photoSubmitterDidOperationFinished:YES];
    
    //delay for Dropbox
    [self performSelector:@selector(clearRequest:) withObject:request afterDelay:2.0];
}

/*!
 * complete submit photo operation and send error message to delegates.
 */
- (void)completeSubmitPhotoWithRequest:(id)request andError:(NSError *)error{
    NSString *hash = [self photoForRequest:request];
    [self photoSubmitter:self didSubmitted:hash suceeded:NO message:[error localizedDescription]];
    id<PhotoSubmitterPhotoOperationDelegate> operationDelegate = [self operationDelegateForRequest:request];
    [operationDelegate photoSubmitterDidOperationFinished:NO];
    
    //delay for Dropbox
    [self performSelector:@selector(clearRequest:) withObject:request afterDelay:2.0];
}

#pragma mark - albums
/*!
 * album list
 */
- (NSArray *)albumList{
    id albums = [self complexSettingForKey:[self keyForAlbums]];
    if([albums isKindOfClass:[NSArray class]]){
        return albums;
    }
    [self removeSettingForKey:[self keyForAlbums]];
    return nil;
}

/*!
 * set album list
 */
- (void) setAlbumList:(NSArray *)albumList{
    [self setComplexSetting:albumList forKey:[self keyForAlbums]];
    [self.dataDelegate photoSubmitter:self didAlbumUpdated:albumList];
}

/*!
 * selected album
 */
- (PhotoSubmitterAlbumEntity *)targetAlbum{
    return [self complexSettingForKey:[self keyForTargetAlbum]];
}

/*!
 * save selected album
 */
- (void)setTargetAlbum:(PhotoSubmitterAlbumEntity *)targetAlbum{
    [self setComplexSetting:targetAlbum forKey:[self keyForTargetAlbum]];
}

/*!
 * create album
 */
- (void)createAlbum:(NSString *)title withDelegate:(id<PhotoSubmitterAlbumDelegate>)delegate{
    //do nothing 
    self.albumDelegate = delegate;
}

/*!
 * update album list
 */
- (void)updateAlbumListWithDelegate:(id<PhotoSubmitterDataDelegate>)delegate{
    //do nothing
    self.dataDelegate = delegate;
}

#pragma mark - username
/*!
 * set username
 */
- (void)setUsername:(NSString *)username{
    [self setSetting:username forKey:[self keyForUsername]];
    [self.dataDelegate photoSubmitter:self didUsernameUpdated:username];
}

/*!
 * get username
 */
- (NSString *)username{
    return [self settingForKey:[self keyForUsername]];
    //do nothing
}

/*!
 * update username
 */
- (void)updateUsernameWithDelegate:(id<PhotoSubmitterDataDelegate>)delegate{
    //do nothing
    self.dataDelegate = delegate;
}

#pragma mark - other properties
/*!
 * return type
 */
- (PhotoSubmitterType) type{
    NSLog(@"Must be implemented in subclass, %s", __PRETTY_FUNCTION__);
    return PhotoSubmitterTypeInvalid;
}

/*!
 * name
 */
- (NSString *)name{
    NSLog(@"Must be implemented in subclass, %s", __PRETTY_FUNCTION__);
    return nil;
}

/*!
 * display name
 */
- (NSString *)displayName{
    return self.name; 
}

/*!
 * icon image
 */
- (UIImage *)icon{
    return [UIImage imageNamed:[self getIconImageNameWithSize:32]];
}

/*!
 * small icon image
 */
- (UIImage *)smallIcon{
    return [UIImage imageNamed:[self getIconImageNameWithSize:16]];
}

#pragma mark - UTILITY METHODS
#pragma mark - request methods
/*!
 * add request
 */
- (void)addRequest:(NSObject *)request{
    [requests_ setObject:request forKey:[NSNumber numberWithInt:request.hash]];
}

/*!
 * remove request
 */
- (void)removeRequest:(NSObject *)request{
    [requests_ removeObjectForKey:[NSNumber numberWithInt:request.hash]];
}

#pragma mark -
#pragma mark photo delegate methods
/*!
 * add request
 */
- (void)addPhotoDelegate:(id<PhotoSubmitterPhotoDelegate>)photoDelegate{
    [photoDelegates_ addObject:photoDelegate];
}

/*!
 * remove request
 */
- (void)removePhotoDelegate: (id<PhotoSubmitterPhotoDelegate>)photoDelegate{
    [photoDelegates_ removeObject:photoDelegate];
}

/*!
 * call will start upload delegate method
 */
- (void) photoSubmitter:(id<PhotoSubmitterProtocol>)photoSubmitter willStartUpload:(NSString *)imageHash{
    for(id<PhotoSubmitterPhotoDelegate> delegate in photoDelegates_){
        [delegate photoSubmitter:photoSubmitter willStartUpload:imageHash];
    }
}

/*!
 * call did submitted delegate method
 */
- (void) photoSubmitter:(id<PhotoSubmitterProtocol>)photoSubmitter didSubmitted:(NSString *)imageHash suceeded:(BOOL)suceeded message:(NSString *)message{
    for(id<PhotoSubmitterPhotoDelegate> delegate in photoDelegates_){
        [delegate photoSubmitter:photoSubmitter didSubmitted:imageHash suceeded:suceeded message:message];
    }
}

/*!
 * call did progress changed delegate method
 */
- (void) photoSubmitter:(id<PhotoSubmitterProtocol>)photoSubmitter didProgressChanged:(NSString *)imageHash progress:(CGFloat)progress{
    for(id<PhotoSubmitterPhotoDelegate> delegate in photoDelegates_){
        [delegate photoSubmitter:photoSubmitter didProgressChanged:imageHash progress:progress];
    }    
}

/*!
 * call did photo submitter canceled delegate methods
 */
- (void)photoSubmitter:(id<PhotoSubmitterProtocol>)photoSubmitter didCanceled:(NSString *)imageHash{
    for(id<PhotoSubmitterPhotoDelegate> delegate in photoDelegates_){
        [delegate photoSubmitter:photoSubmitter didCanceled:imageHash];
    }        
}

#pragma mark -
#pragma mark operation delegates
/*!
 * set operation
 */
- (void)setOperationDelegate:(id<PhotoSubmitterPhotoOperationDelegate>)operation forRequest:(NSObject *)request{
    if(operation != nil){
        [operationDelegates_ setObject:operation forKey:[NSNumber numberWithInt:request.hash]];
    }
}

/*!
 * remove operation
 */
- (void)removeOperationDelegateForRequest:(NSObject *)request{
    [operationDelegates_ removeObjectForKey:[NSNumber numberWithInt:request.hash]];
}

/*!
 * operation for request
 */
- (id<PhotoSubmitterPhotoOperationDelegate>)operationDelegateForRequest:(NSObject *)request{
    return [operationDelegates_ objectForKey:[NSNumber numberWithInt:request.hash]];
}

#pragma mark -
#pragma mark photo hash methods
/*!
 * set photo hash
 */
- (void)setPhotoHash:(NSString *)photoHash forRequest:(NSObject *)request{
    [photos_ setObject:photoHash forKey:[NSNumber numberWithInt:request.hash]];
}


/*!
 * remove photo hash
 */
- (void)removePhotoForRequest:(NSObject *)request{
    [photos_ removeObjectForKey:[NSNumber numberWithInt:request.hash]];
}

/*!
 * get photo hash
 */
- (NSString *)photoForRequest:(NSObject *)request{
    return [photos_ objectForKey:[NSNumber numberWithInt:request.hash]];
}

/*!
 * get request
 */
- (NSObject *)requestForPhoto:(NSString *)photoHash{
    NSArray *key = [photos_ allKeysForObject:photoHash];
    if(key.count == 0){
        return nil;
    }
    return [requests_ objectForKey:[key lastObject]];
}

#pragma mark -
#pragma mark util methods
/*!
 * clear request data
 */
- (void)clearRequest:(NSObject *)request{
    [self removeRequest:request];
    [self removeOperationDelegateForRequest:request];
    [self removePhotoForRequest:request];
}

#pragma mark - setting methods

/*!
 * write setting to user defaults
 */
- (void)setSetting:(id)value forKey:(NSString *)key{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:value forKey:key];
    [defaults synchronize];
}

/*!
 * read setting from user defaults
 */
- (id)settingForKey:(NSString *)key{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults valueForKey:key];
}
/*!
 * write complex setting to user defaults
 */
- (void)setComplexSetting:(id)value forKey:(NSString *)key{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:value];
    [defaults setValue:data forKey:key];
    [defaults synchronize];
}

/*!
 * read complex setting from user defaults
 */
- (id)complexSettingForKey:(NSString *)key{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [defaults valueForKey:key];
    if(data == nil){
        return nil;
    }
    return [NSKeyedUnarchiver unarchiveObjectWithData:data];
}

/*!
 * remove setting from user defaults
 */
- (void)removeSettingForKey:(NSString *)key{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:key];
    [defaults synchronize];
}

/*!
 * setting exists
 */
- (BOOL)settingExistsForKey:(NSString *)key{
    return [self settingForKey:key] != nil;
}

#pragma mark - secure setting methods

/*!
 * write setting to user bindings
 */
- (void)setSecureSetting:(id)value forKey:(NSString *)key{
    PDKeychainBindings *bindings = [PDKeychainBindings sharedKeychainBindings];
    [bindings setObject:value forKey:key];
}

/*!
 * read setting from user bindings
 */
- (id)secureSettingForKey:(NSString *)key{
    PDKeychainBindings *bindings = [PDKeychainBindings sharedKeychainBindings];
    return [bindings objectForKey:key];
}

/*!
 * remove setting from user bindings
 */
- (void)removeSecureSettingForKey:(NSString *)key{
    PDKeychainBindings *bindings = [PDKeychainBindings sharedKeychainBindings];
    [bindings removeObjectForKey:key];
}

/*!
 * setting exists
 */
- (BOOL)secureSettingExistsForKey:(NSString *)key{
    return [self secureSettingForKey:key] != nil;
}
@end
