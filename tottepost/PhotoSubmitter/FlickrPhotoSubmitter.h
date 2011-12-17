//
//  FlickrPhotoSubmitter.h
//  tottepost
//
//  Created by ISHITOYA Kentaro on 11/12/14.
//  Copyright (c) 2011 cocotomo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PhotoSubmitterProtocol.h"
#import "ObjectiveFlickr.h"

/*!
 * photo submitter for facebook.
 * get instance with using 
 * [[PhotoSubmitter getInstance] submitterWithType:PhotoSubmitterTypeFlickr]
 * or
 * [PhotoSubmitter flickrPhotoSubmitter]
 */
@interface FlickrPhotoSubmitter : NSObject<PhotoSubmitterProtocol, OFFlickrAPIRequestDelegate>{
    __strong OFFlickrAPIContext *flickr_;
}
@property (nonatomic, readonly) OFFlickrAPIContext* flickr;
@property (nonatomic, readonly) PhotoSubmitterType type;
@end
