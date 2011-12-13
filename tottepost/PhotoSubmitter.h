//
//  PhotoSubmitter.h
//  tottepost
//
//  Created by ISHITOYA Kentaro on 11/12/13.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PhotoSubmitterProtocol.h"
#import "FacebookPhotoSubmitter.h"

/*!
 * 履歴がどこから追加されたのかを表す列挙子
 */
typedef enum {
    PhotoSubmitterTypeFacebook,
    PhotoSubmitterTypeTwitter,
    PhotoSubmitterTypeFlickr
} PhotoSubmitterType;

/*!
 * photo submitter aggregation class
 */
@interface PhotoSubmitter : NSObject{
    @protected 
    __strong NSMutableDictionary *submitters_;
}
- (BOOL) submitPhoto:(UIImage *)photo;
- (BOOL) submitPhoto:(UIImage *)photo comment:(NSString *)comment;

- (id<PhotoSubmitterProtocol>) submitterWithType:(PhotoSubmitterType)type;
+ (PhotoSubmitter *)getInstance;
+ (FacebookPhotoSubmitter *)facebookPhotoSubmitter;
@end