//
//  FacebookPhotoSubmitter.h
//  tottepost
//
//  Created by ISHITOYA Kentaro on 11/12/13.
//  Copyright (c) 2011 cocotomo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Facebook.h"
#import "PhotoSubmitterProtocol.h"

@protocol FacebookPhotoSubmitterDelegate;

/*!
 * photo submitter for facebook.
 * get instance with using 
 * [[PhotoSubmitter getInstance] submitterWithType:PhotoSubmitterTypeFacebook]
 */
@interface FacebookPhotoSubmitter : NSObject<PhotoSubmitterProtocol, FBSessionDelegate, FBRequestDelegate>{
    __strong Facebook *facebook_;
}
@property (nonatomic, readonly) Facebook* facebook;
@property (nonatomic, readonly) PhotoSubmitterType type;
@property (weak, nonatomic) id<PhotoSubmitterAuthenticationDelegate> authDelegate;
@property (weak, nonatomic) id<PhotoSubmitterPhotoDelegate> photoDelegate;
@end
