//
//  MixiPhotoSubmitter.h
//  tottepost
//
//  Created by Ken Watanabe on 12/02/12.
//  Copyright (c) 2012 cocotomo. All rights reserved.
//

#import "PhotoSubmitter.h"
#import "MixiSDK.h"

@interface MixiPhotoSubmitter : PhotoSubmitter<PhotoSubmitterProtocol>{
    __strong Mixi *mixi_;
}
@end
