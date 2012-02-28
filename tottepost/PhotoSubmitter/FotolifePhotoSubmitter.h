//
//  FotolifePhotoSubmitter.h
//  tottepost
//
//  Created by Kentaro ISHITOYA on 12/02/18.
//  Copyright (c) 2012 cocotomo. All rights reserved.
//

#import "PhotoSubmitterProtocol.h"
#import "PhotoSubmitter.h"
#import "AtompubClientDelegate.h"

/*!
 * photo submitter for hatena fotolife.
 * Hatena Fotolife is a japanese photo service.
 * see http://f.hatena.ne.jp/
 * and http://developer.hatena.ne.jp/ja/documents/fotolife/apis/atom
 * for more details.
 *
 * get instance with using 
 * [[PhotoSubmitter getInstance] submitterWithType:PhotoSubmitterTypeFacebook]
 * or
 * [PhotoSubmitter facebookPhotoSubmitter]
 */
@interface FotolifePhotoSubmitter : PhotoSubmitter<PhotoSubmitterInstanceProtocol, PhotoSubmitterPasswordAuthViewDelegate, AtompubClientDelegate>{
    __strong NSString *userId_;
    __strong NSString *password_;
}
@end
