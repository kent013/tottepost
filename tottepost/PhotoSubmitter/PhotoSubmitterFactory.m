//
//  PhotoSubmitterFactory.m
//  tottepost
//
//  Created by Kentaro ISHITOYA on 12/02/28.
//  Copyright (c) 2012 cocotomo. All rights reserved.
//

#import "PhotoSubmitterFactory.h"
#import "FacebookPhotoSubmitter.h"
#import "FlickrPhotoSubmitter.h"
#import "TwitterPhotoSubmitter.h"
#import "DropboxPhotoSubmitter.h"
#import "EvernotePhotoSubmitter.h"
#import "PicasaPhotoSubmitter.h"
#import "PhotoSubmitterOperation.h"
#import "MixiPhotoSubmitter.h"
#import "FilePhotoSubmitter.h"
#import "FotolifePhotoSubmitter.h"
#import "MinusPhotoSubmitter.h"

@implementation PhotoSubmitterFactory
/*!
 * create submitter
 * you may add case clause when you created new submitter
 */
+ (id<PhotoSubmitterProtocol>)createWithType:(PhotoSubmitterType)type{
    id <PhotoSubmitterProtocol> submitter = nil;
    switch (type) {
        case PhotoSubmitterTypeFacebook:
            submitter = [[FacebookPhotoSubmitter alloc] init];
            break;
        case PhotoSubmitterTypeTwitter:
            submitter = [[TwitterPhotoSubmitter alloc] init];
            break;
        case PhotoSubmitterTypeFlickr:
            submitter = [[FlickrPhotoSubmitter alloc] init];
            break;
        case PhotoSubmitterTypeDropbox:
            submitter = [[DropboxPhotoSubmitter alloc] init];
            break;
        case PhotoSubmitterTypeEvernote:
            submitter = [[EvernotePhotoSubmitter alloc] init];
            break;
        case PhotoSubmitterTypePicasa:
            submitter = [[PicasaPhotoSubmitter alloc] init];
            break;
        case PhotoSubmitterTypeMixi:
            submitter = [[MixiPhotoSubmitter alloc] init];
            break;
        case PhotoSubmitterTypeFotolife:
            submitter = [[FotolifePhotoSubmitter alloc] init];
            break;
        case PhotoSubmitterTypeMinus:
            submitter = [[MinusPhotoSubmitter alloc] init];
            break;
        case PhotoSubmitterTypeFile:
            submitter = [[FilePhotoSubmitter alloc] init];
            break;
        default:
            break;
    }
    return submitter;
}
@end
