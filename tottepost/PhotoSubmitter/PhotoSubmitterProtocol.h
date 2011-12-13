//
//  PhotoSubmitterProtocol.h
//  tottepost
//
//  Created by ISHITOYA Kentaro on 11/12/13.
//  Copyright (c) 2011 cocotomo. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 * protocol for submitter
 */
@protocol PhotoSubmitterProtocol <NSObject>
@optional
- (void) login;
- (void) logout;
- (BOOL) isLogined;
@required
- (BOOL) submitPhoto:(UIImage *)photo;
- (BOOL) submitPhoto:(UIImage *)photo comment:(NSString *)comment;
@end