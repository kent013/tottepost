//
//  PhotoSubmitterFactory.h
//  tottepost
//
//  Created by Kentaro ISHITOYA on 12/02/28.
//  Copyright (c) 2012 cocotomo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PhotoSubmitterProtocol.h"

@interface PhotoSubmitterFactory : NSObject
+ (id<PhotoSubmitterProtocol>)createWithType:(PhotoSubmitterType) type;
@end
