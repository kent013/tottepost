//
//  PhotoSubmitterProtocol.h
//  tottepost
//
//  Created by ISHITOYA Kentaro on 11/12/13.
//  Copyright (c) 2011 cocotomo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PhotoSubmitterAlbumEntity.h"
/*!
 * Submitter Types
 */
typedef enum {
    PhotoSubmitterTypeFacebook,
    PhotoSubmitterTypeTwitter,
    PhotoSubmitterTypeFlickr,
    PhotoSubmitterTypeDropbox
} PhotoSubmitterType;

@protocol PhotoSubmitterAuthenticationDelegate;
@protocol PhotoSubmitterPhotoDelegate;
@protocol PhotoSubmitterOperationDelegate;
@protocol PhotoSubmitterAlbumDelegate;

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
@property (nonatomic, assign) id<PhotoSubmitterAuthenticationDelegate> authDelegate;
@property (nonatomic, assign) id<PhotoSubmitterAlbumDelegate> albumDelegate;
@property (nonatomic, assign) PhotoSubmitterAlbumEntity *targetAlbum;
- (void) login;
- (void) logout;
- (void) disable;
- (void) submitPhoto:(UIImage *)photo;
- (void) submitPhoto:(UIImage *)photo comment:(NSString *)comment;
- (void) submitPhoto:(UIImage *)photo andOperationDelegate:(id<PhotoSubmitterOperationDelegate>)delegate;
- (void) submitPhoto:(UIImage *)photo comment:(NSString *)comment andDelegate:(id<PhotoSubmitterOperationDelegate>)delegate;
- (BOOL) isProcessableURL:(NSURL *)url;
- (BOOL) didOpenURL:(NSURL *)url;
- (void) addPhotoDelegate:(id<PhotoSubmitterPhotoDelegate>)photoDelegate;
- (void) removePhotoDelegate: (id<PhotoSubmitterPhotoDelegate>)photoDelegate;

- (void) updateAlbumListWithDelegate: (id<PhotoSubmitterAlbumDelegate>) delegate;

+ (BOOL) isEnabled;
@end

/*!
 * protocol for authentication delegate
 */
@protocol PhotoSubmitterAuthenticationDelegate <NSObject>
@required
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
@end

/*!
 * protocol for operation
 */
@protocol PhotoSubmitterOperationDelegate <NSObject>
- (void) photoSubmitterDidOperationFinished;
@end

/*!
 * protocol for album
 */
@protocol PhotoSubmitterAlbumDelegate <NSObject>
- (void) photoSubmitter:(id<PhotoSubmitterProtocol>)photoSubmitter didAlbumUpdated: (NSMutableArray *)albums;
@end