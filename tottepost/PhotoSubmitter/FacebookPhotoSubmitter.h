//
//  FacebookPhotoSubmitter.h
//  tottepost
//
//  Created by ISHITOYA Kentaro on 11/12/13.
//  Copyright (c) 2011 cocotomo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Facebook.h"
#import "FBRequest+UploadProgress.h"
#import "PhotoSubmitterProtocol.h"

@protocol FacebookPhotoSubmitterDelegate;

/*!
 * photo submitter for facebook.
 * get instance with using 
 * [[PhotoSubmitter getInstance] submitterWithType:PhotoSubmitterTypeFacebook]
 * or
 * [PhotoSubmitter facebookPhotoSubmitter]
 */
@interface FacebookPhotoSubmitter : NSObject<PhotoSubmitterProtocol, FBSessionDelegate, FBRequestWithUploadProgressDelegate>{
    __strong Facebook *facebook_;
    __strong NSMutableDictionary *requests_;
}
@property (nonatomic, readonly) PhotoSubmitterType type;
@property (weak, nonatomic) id<PhotoSubmitterAuthenticationDelegate> authDelegate;
@property (weak, nonatomic) id<PhotoSubmitterPhotoDelegate> photoDelegate;
@end
