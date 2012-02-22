//
//  NSString+Join.h
//  iSticky
//
//  Created by ISHITOYA Kentaro on 10/09/29.
//  Copyright 2010 ISHITOYA Kentaro. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSString (Join)
+ (NSString *) join: (NSArray *) array;
+ (NSString *) join: (NSArray *) array glue:(NSString *) glue;
@end
