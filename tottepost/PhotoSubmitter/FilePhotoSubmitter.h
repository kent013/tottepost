//
//  FilePhotoSubmitter.h
//  PhotoSubmitter for Camera Roll
//
//  Created by ISHITOYA Kentaro on 11/12/24.
//  Copyright (c) 2011 cocotomo. All rights reserved.
//

#import "PhotoSubmitterProtocol.h"
#import "PhotoSubmitter.h"

/*!
 * photo submitter for file.
 * get instance with using 
 * [[PhotoSubmitter getInstance] submitterWithType:PhotoSubmitterTypeDropbox]
 */
@interface FilePhotoSubmitter : PhotoSubmitter<PhotoSubmitterProtocol>{
}
@end