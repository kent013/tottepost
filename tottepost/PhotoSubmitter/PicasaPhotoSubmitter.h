//
//  PicasaPhotoSubmitter.h
//  tottepost
//
//  Created by Kentaro ISHITOYA on 12/02/10.
//  Copyright (c) 2012 cocotomo. All rights reserved.
//

#import "GData.h"
#import "GTMOAuth2Authentication.h"
#import "PhotoSubmitterProtocol.h"
#import "PhotoSubmitter.h"

/*!
 * photo submitter for evernote.
 * get instance with using 
 * [[PhotoSubmitter getInstance] submitterWithType:PhotoSubmitterTypeEvernote]
 */
@interface PicasaPhotoSubmitter : PhotoSubmitter<PhotoSubmitterProtocol>{
    __strong GTMOAuth2Authentication *auth_;
}
@end
