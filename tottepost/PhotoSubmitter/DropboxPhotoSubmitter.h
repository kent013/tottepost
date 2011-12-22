//
//  DropboxPhotoSubmitter.h
//  tottepost
//
//  Created by ISHITOYA Kentaro on 11/12/22.
//  Copyright (c) 2011 cocotomo. All rights reserved.
//

#import <DropboxSDK/DropboxSDK.h>
#import "PhotoSubmitterProtocol.h"
#import "PhotoSubmitter.h"

/*!
 * photo submitter for dropbox.
 * get instance with using 
 * [[PhotoSubmitter getInstance] submitterWithType:PhotoSubmitterTypeDropbox]
 */
@interface DropboxPhotoSubmitter : PhotoSubmitter<PhotoSubmitterProtocol, DBSessionDelegate, DBRestClientDelegate>{
}
@end
