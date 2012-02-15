//
//  FlickrPhotoSubmitter.h
//  PhotoSubmitter for Flickr
//
//  Created by ISHITOYA Kentaro on 11/12/14.
//  Copyright (c) 2011 cocotomo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PhotoSubmitterProtocol.h"
#import "PhotoSubmitter.h"
#import "ObjectiveFlickr.h"

/*!
 * photo submitter for facebook.
 * get instance with using 
 * [[PhotoSubmitter getInstance] submitterWithType:PhotoSubmitterTypeFlickr]
 * or
 * [PhotoSubmitter flickrPhotoSubmitter]
 */
@interface FlickrPhotoSubmitter : PhotoSubmitter<PhotoSubmitterProtocol, OFFlickrAPIRequestDelegate>{
    __strong OFFlickrAPIContext *flickr_;
    __strong OFFlickrAPIRequest *authRequest_;
}
@end
