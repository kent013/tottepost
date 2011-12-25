//
//  UIImage+GeoTagging.m
//  tottepost
//
//  Created by ISHITOYA Kentaro on 11/12/25.
//  Copyright (c) 2011 cocotomo. All rights reserved.
//

#import <ImageIO/ImageIO.h>
#import "UIImage+GeoTagging.h"

@implementation UIImage (GeoTagging)
/*!
 * tag geolocation to image
 */
-(NSData *) geoTaggedDataWithLocation:(CLLocation *)location{
    NSData *data = UIImageJPEGRepresentation(self, 1.0);
    CGImageSourceRef img = CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
	NSMutableDictionary* exifDict = [[NSMutableDictionary alloc] init];
	NSMutableDictionary* locDict = [[NSMutableDictionary alloc] init];
	NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"yyyy:MM:dd HH:mm:ss"];
	NSString* datetime = [dateFormatter stringFromDate:location.timestamp];
	[exifDict setObject:datetime forKey:(NSString*)kCGImagePropertyExifDateTimeOriginal];
	[exifDict setObject:datetime forKey:(NSString*)kCGImagePropertyExifDateTimeDigitized];
	[locDict setObject:location.timestamp forKey:(NSString*)kCGImagePropertyGPSTimeStamp];
	if (location.coordinate.latitude <0.0){ 
		[locDict setObject:@"S" forKey:(NSString*)kCGImagePropertyGPSLatitudeRef];
	}else{ 
		[locDict setObject:@"N" forKey:(NSString*)kCGImagePropertyGPSLatitudeRef];
	} 
	[locDict setObject:[NSNumber numberWithFloat:location.coordinate.latitude] forKey:(NSString*)kCGImagePropertyGPSLatitude];
	if (location.coordinate.longitude <0.0){ 
		[locDict setObject:@"W" forKey:(NSString*)kCGImagePropertyGPSLongitudeRef];
	}else{ 
		[locDict setObject:@"E" forKey:(NSString*)kCGImagePropertyGPSLongitudeRef];
	} 
	[locDict setObject:[NSNumber numberWithFloat:location.coordinate.longitude] forKey:(NSString*)kCGImagePropertyGPSLongitude];
	NSMutableData* imageData = [[NSMutableData alloc] init];
	CGImageDestinationRef dest = CGImageDestinationCreateWithData((__bridge CFMutableDataRef)imageData, CGImageSourceGetType(img), 1, NULL);
	CGImageDestinationAddImageFromSource(dest, img, 0, 
										 (__bridge CFDictionaryRef)[NSDictionary dictionaryWithObjectsAndKeys:
                                                                    locDict, (NSString*)kCGImagePropertyGPSDictionary,
                                                                    exifDict, (NSString*)kCGImagePropertyExifDictionary, nil]);
	CGImageDestinationFinalize(dest);
	CFRelease(img);
	CFRelease(dest);
    return imageData;
}
@end
