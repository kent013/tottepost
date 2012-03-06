//
//  TTLang.h
//  tottepost
//
//  Created by ISHITOYA Kentaro on 11/12/29.
//  Copyright (c) 2011 cocotomo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TTLang : NSObject
/*!
 * get localized string
 */
+ (NSString *)localized:(NSString *)key;
@end
