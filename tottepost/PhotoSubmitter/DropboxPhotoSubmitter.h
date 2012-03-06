//
//  DropboxPhotoSubmitter.h
//  PhotoSubmitter for Dropbox
//
//  Created by ISHITOYA Kentaro on 11/12/22.
//  Copyright (c) 2011 cocotomo. All rights reserved.
//

#import <DropboxSDK/DropboxSDK.h>
#import "PhotoSubmitterProtocol.h"
#import "PhotoSubmitter.h"

/*!
 * photo submitter for dropbox.
 */
@interface DropboxPhotoSubmitter : PhotoSubmitter<PhotoSubmitterInstanceProtocol, DBSessionDelegate, DBRestClientDelegate>{
}
@end
