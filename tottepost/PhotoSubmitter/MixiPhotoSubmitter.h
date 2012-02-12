//
//  MixiPhotoSubmitter.h
//  tottepost
//
//  Created by 賢 渡辺 on 12/02/12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "PhotoSubmitter.h"
#import "MixiSDK.h"

@interface MixiPhotoSubmitter : PhotoSubmitter<PhotoSubmitterProtocol>{
    __strong Mixi *mixi_;
}
@end
