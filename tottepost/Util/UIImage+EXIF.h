//
//  UIImage+GeoTagging.h
//  tottepost
//
//  Created by ISHITOYA Kentaro on 11/12/25.
//  Copyright (c) 2011 cocotomo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface UIImage (EXIF)
-(NSData *) geoTaggedDataWithLocation:(CLLocation *)location andComment:(NSString *)comment;
@end
