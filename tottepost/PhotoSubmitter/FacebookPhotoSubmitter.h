//
//  FacebookPhotoSubmitter.h
//  tottepost
//
//  Created by ISHITOYA Kentaro on 11/12/13.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
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
@interface FacebookPhotoSubmitter : NSObject<PhotoSubmitterProtocol, FBSessionDelegate>{
    __strong Facebook *facebook_;
}
@property (nonatomic, readonly) Facebook* facebook;
@property (weak, nonatomic) id<FacebookPhotoSubmitterDelegate> delegate;
@end


/*!
 * facebook setting view controller delegate
 */
@protocol FacebookPhotoSubmitterDelegate <NSObject>
@required
- (void) facebookPhotoSubmitterDidLogin;
- (void) facebookPhotoSubmitterDidLogout;
@end
