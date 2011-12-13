//
//  PhotoSubmitterProtocol.h
//  tottepost
//
//  Created by ISHITOYA Kentaro on 11/12/13.
//  Copyright (c) 2011 cocotomo. All rights reserved.
//

#import <Foundation/Foundation.h>
/*!
 * Submitter Types
 */
typedef enum {
    PhotoSubmitterTypeFacebook,
    PhotoSubmitterTypeTwitter,
    PhotoSubmitterTypeFlickr
} PhotoSubmitterType;

@protocol PhotoSubmitterAuthenticationDelegate;
@protocol PhotoSubmitterPhotoDelegate;

/*!
 * protocol for submitter
 */
@protocol PhotoSubmitterProtocol <NSObject>
@required
@property (nonatomic, readonly) BOOL isLogined;
@property (nonatomic, readonly) PhotoSubmitterType type;
@property (nonatomic, assign) id<PhotoSubmitterAuthenticationDelegate> authDelegate;
@property (nonatomic, assign) id<PhotoSubmitterPhotoDelegate> photoDelegate;
- (void) login;
- (void) logout;
- (void) submitPhoto:(UIImage *)photo;
- (void) submitPhoto:(UIImage *)photo comment:(NSString *)comment;
+ (BOOL) isEnabled;
@end

/*!
 * protocol for delegate
 */
@protocol PhotoSubmitterAuthenticationDelegate <NSObject>
@required
- (void) photoSubmitter:(id<PhotoSubmitterProtocol>)photoSubmitter didLogin:(PhotoSubmitterType) type;
- (void) photoSubmitter:(id<PhotoSubmitterProtocol>)photoSubmitter didLogout:(PhotoSubmitterType) type;
@end

/*!
 * protocol for delegate
 */
@protocol PhotoSubmitterPhotoDelegate <NSObject>
@required
- (void) photoSubmitter:(id<PhotoSubmitterProtocol>)photoSubmitter didSubmitted:(PhotoSubmitterType) type suceeded:(BOOL)suceeded message:(NSString *)message;
@end