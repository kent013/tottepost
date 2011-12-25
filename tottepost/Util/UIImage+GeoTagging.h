//
//  UIImage+GeoTagging.h
//  tottepost
//
//  Created by ISHITOYA Kentaro on 11/12/25.
//  Copyright (c) 2011 cocotomo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface UIImage (GeoTagging)
-(NSData *) geoTaggedDataWithLocation:(CLLocation *)location;
@end
