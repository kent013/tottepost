//
//  EvernotePhotoSubmitter.h
//  PhotoSubmitter for Evernote
//
//  Created by Kentaro ISHITOYA on 12/02/07.
//  Copyright (c) 2012 cocotomo. All rights reserved.
//

#import "EVNConnect.h"
#import "PhotoSubmitterProtocol.h"
#import "PhotoSubmitter.h"

/*!
 * photo submitter for evernote.
 * get instance with using 
 * [[PhotoSubmitter getInstance] submitterWithType:PhotoSubmitterTypeEvernote]
 */
@interface EvernotePhotoSubmitter : PhotoSubmitter<PhotoSubmitterProtocol, EvernoteSessionDelegate, EvernoteRequestDelegate>{
    __strong Evernote *evernote_;
}
@end
