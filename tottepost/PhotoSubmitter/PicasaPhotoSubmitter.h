//
//  PicasaPhotoSubmitter.h
//  PhotoSubmitter for Picasa
//
//  Created by Kentaro ISHITOYA on 12/02/10.
//  Copyright (c) 2012 cocotomo. All rights reserved.
//

#import "GData.h"
#import "GTMOAuth2Authentication.h"
#import "PhotoSubmitterProtocol.h"
#import "PhotoSubmitter.h"

/*!
 * photo submitter for picasa.
 * get instance with using 
 * [[PhotoSubmitter getInstance] submitterWithType:PhotoSubmitterTypePicasa]
 */
@interface PicasaPhotoSubmitter : PhotoSubmitter<PhotoSubmitterInstanceProtocol>{
    __strong GDataServiceGooglePhotos *service_;
    __strong GTMOAuth2Authentication *auth_;
    __strong GDataFeedPhotoUser *photoFeed_;
}
@end
