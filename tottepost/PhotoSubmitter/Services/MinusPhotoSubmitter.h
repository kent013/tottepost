//
//  MinusPhotoSubmitter.h
//  tottepost
//
//  Created by Kentaro ISHITOYA on 12/02/22.
//  Copyright (c) 2012 cocotomo. All rights reserved.
//

#import "PhotoSubmitter.h"
#import "MinusConnect.h"

/*!
 * photo submitter for minus.
 */
@interface MinusPhotoSubmitter : PhotoSubmitter<PhotoSubmitterInstanceProtocol, PhotoSubmitterPasswordAuthViewDelegate, MinusRequestDelegate, MinusSessionDelegate>{
    __strong MinusConnect *minus_;
    __strong NSString *userId_;
    __strong NSString *password_;
}
@end
