//
//  PhotoSubmitterProtocol.h
//  tottepost
//
//  Created by ISHITOYA Kentaro on 11/12/13.
//  Copyright (c) 2011 cocotomo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PhotoSubmitterAlbumEntity.h"
#import "PhotoSubmitterImageEntity.h"
/*!
 * Submitter Types
 */
typedef enum {
    PhotoSubmitterTypeFacebook = 0,
    PhotoSubmitterTypeTwitter,
    PhotoSubmitterTypeFlickr,
    PhotoSubmitterTypeDropbox,
    PhotoSubmitterTypeEvernote,
    PhotoSubmitterTypePicasa,
    PhotoSubmitterTypeFile,
} PhotoSubmitterType;

@protocol PhotoSubmitterAuthenticationDelegate;
@protocol PhotoSubmitterPhotoDelegate;
@protocol PhotoSubmitterPhotoOperationDelegate;
@protocol PhotoSubmitterDataDelegate;
@protocol PhotoSubmitterOAuthControllerDelegate;


/*!
 * protocol for submitter
 */
@protocol PhotoSubmitterProtocol <NSObject>
@required
@property (nonatomic, readonly) BOOL isLogined;
@property (nonatomic, readonly) BOOL isEnabled;
@property (nonatomic, readonly) PhotoSubmitterType type;
@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) UIImage *icon;
@property (nonatomic, readonly) UIImage *smallIcon;
@property (nonatomic, readonly) NSString *username;
@property (nonatomic, readonly) NSArray *albumList;
@property (nonatomic, readonly) BOOL isConcurrent;
@property (nonatomic, readonly) BOOL useOperation;
@property (nonatomic, readonly) BOOL isSequencial;
@property (nonatomic, readonly) BOOL requiresNetwork;
@property (nonatomic, assign) id<PhotoSubmitterAuthenticationDelegate> authDelegate;
@property (nonatomic, assign) id<PhotoSubmitterDataDelegate> dataDelegate;
@property (nonatomic, assign) PhotoSubmitterAlbumEntity *targetAlbum;
- (void) login;
- (void) logout;
- (void) disable;
- (void) submitPhoto:(PhotoSubmitterImageEntity *)photo andOperationDelegate:(id<PhotoSubmitterPhotoOperationDelegate>)delegate;
- (void) cancelPhotoSubmit:(PhotoSubmitterImageEntity *)photo;
- (BOOL) isProcessableURL:(NSURL *)url;
- (BOOL) didOpenURL:(NSURL *)url;
- (void) addPhotoDelegate:(id<PhotoSubmitterPhotoDelegate>)photoDelegate;
- (void) removePhotoDelegate: (id<PhotoSubmitterPhotoDelegate>)photoDelegate;

- (void) updateAlbumListWithDelegate: (id<PhotoSubmitterDataDelegate>) delegate;
- (void) updateUsernameWithDelegate: (id<PhotoSubmitterDataDelegate>) delegate;
+ (BOOL) isEnabled;
@end

/*!
 * protocol for authentication delegate
 */
@protocol PhotoSubmitterAuthenticationDelegate <NSObject>
@required
- (void) photoSubmitter:(id<PhotoSubmitterProtocol>)photoSubmitter willBeginAuthorization:(PhotoSubmitterType)type;
- (void) photoSubmitter:(id<PhotoSubmitterProtocol>)photoSubmitter didAuthorizationFinished:(PhotoSubmitterType)type;
- (void) photoSubmitter:(id<PhotoSubmitterProtocol>)photoSubmitter didLogin:(PhotoSubmitterType) type;
- (void) photoSubmitter:(id<PhotoSubmitterProtocol>)photoSubmitter didLogout:(PhotoSubmitterType) type;
@end

/*!
 * protocol for photo delegate
 */
@protocol PhotoSubmitterPhotoDelegate <NSObject>
@required
- (void) photoSubmitter:(id<PhotoSubmitterProtocol>)photoSubmitter willStartUpload:(NSString *)imageHash;
- (void) photoSubmitter:(id<PhotoSubmitterProtocol>)photoSubmitter didSubmitted:(NSString *)imageHash suceeded:(BOOL)suceeded message:(NSString *)message;
- (void) photoSubmitter:(id<PhotoSubmitterProtocol>)photoSubmitter didProgressChanged:(NSString *)imageHash progress:(CGFloat)progress;
- (void) photoSubmitter:(id<PhotoSubmitterProtocol>)photoSubmitter didCanceled:(NSString *)imageHash;
@end

/*!
 * protocol for operation
 */
@protocol PhotoSubmitterPhotoOperationDelegate <NSObject>
- (void) photoSubmitterDidOperationFinished:(BOOL)suceeded;
- (void) photoSubmitterDidOperationCanceled;
@end

/*!
 * protocol for album
 */
@protocol PhotoSubmitterDataDelegate <NSObject>
- (void) photoSubmitter:(id<PhotoSubmitterProtocol>)photoSubmitter didAlbumUpdated: (NSMutableArray *)albums;
- (void) photoSubmitter:(id<PhotoSubmitterProtocol>)photoSubmitter didUsernameUpdated: (NSString *)username;
@end

/*!
 * protocol for request oauth authentication view
 */
@protocol PhotoSubmitterOAuthControllerDelegate <NSObject>
- (UINavigationController *) requestNavigationControllerToPresentAuthenticationView;
@end