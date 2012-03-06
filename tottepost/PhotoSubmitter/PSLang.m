//
//  PSLang.m
//  tottepost
//
//  Created by Kentaro ISHITOYA on 12/03/06.
//  Copyright (c) 2012 cocotomo. All rights reserved.
//

#import "PSLang.h"

@implementation PSLang
/*!
 * get localized string
 */
+ (NSString *)localized:(NSString *)key{
    return NSLocalizedStringFromTable(key, @"PhotoSubmitter", nil);
}
@end
