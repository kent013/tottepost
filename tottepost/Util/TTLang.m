//
//  TTLang.m
//  tottepost
//
//  Created by ISHITOYA Kentaro on 11/12/29.
//  Copyright (c) cocotomo. All rights reserved.
//

#import "TTLang.h"

@implementation TTLang
/*!
 * get localized string
 */
+ (NSString *)lstr:(NSString *)key{
    return NSLocalizedString(key, @"");
}
@end
