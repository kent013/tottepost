//
//  PhotoSubmitterImageEntity.m
//  tottepost
//
//  Created by ISHITOYA Kentaro on 12/01/22.
//  Copyright (c) 2012 cocotomo. All rights reserved.
//

#import "PhotoSubmitterImageEntity.h"
#import "NSData+Digest.h"
#import "UIImage+Resize.h"
#import <ImageIO/ImageIO.h>

//-----------------------------------------------------------------------------
//Private Implementations
//-----------------------------------------------------------------------------
@interface PhotoSubmitterImageEntity(PrivateImplementation)
@end

@implementation PhotoSubmitterImageEntity(PrivateImplementation)
@end

//-----------------------------------------------------------------------------
//Public Implementations
//----------------------------------------------------------------------------
@implementation PhotoSubmitterImageEntity
@synthesize data = data_;
@synthesize timestamp = timestamp_;
@synthesize comment;
@synthesize location;

/*!
 * init with data
 */
- (id)initWithData:(NSData *)inData{
    self = [super init];
    if(self){
        data_ = inData;
        timestamp_ = [NSDate date];
    }
    return self;
}

/*!
 * apply metadata
 */
- (void)applyMetadata{
    CGImageSourceRef img = CGImageSourceCreateWithData((__bridge CFDataRef)data_, NULL);
	NSMutableDictionary* exifDict = [[NSMutableDictionary alloc] init];
	NSMutableDictionary* locDict = [[NSMutableDictionary alloc] init];
	NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"yyyy:MM:dd HH:mm:ss"];
	NSString* datetime = [dateFormatter stringFromDate:timestamp_];
	[exifDict setObject:datetime forKey:(NSString*)kCGImagePropertyExifDateTimeOriginal];
	[exifDict setObject:datetime forKey:(NSString*)kCGImagePropertyExifDateTimeDigitized];
    if(comment != nil){
        [exifDict setObject:comment forKey:(NSString*)kCGImagePropertyExifUserComment];
    }
    if(location != nil){
        [locDict setObject:location.timestamp forKey:(NSString*)kCGImagePropertyGPSTimeStamp];
        if (location.coordinate.latitude <0.0){ 
            [locDict setObject:@"S" forKey:(NSString*)kCGImagePropertyGPSLatitudeRef];
        }else{ 
            [locDict setObject:@"N" forKey:(NSString*)kCGImagePropertyGPSLatitudeRef];
        } 
        [locDict setObject:[NSNumber numberWithFloat:location.coordinate.latitude] forKey:(NSString*)kCGImagePropertyGPSLatitude];
        if (location.coordinate.longitude < 0.0){ 
            [locDict setObject:@"W" forKey:(NSString*)kCGImagePropertyGPSLongitudeRef];
        }else{ 
            [locDict setObject:@"E" forKey:(NSString*)kCGImagePropertyGPSLongitudeRef];
        } 
        [locDict setObject:[NSNumber numberWithFloat:location.coordinate.longitude] forKey:(NSString*)kCGImagePropertyGPSLongitude];
    }
	CGImageDestinationRef dest = CGImageDestinationCreateWithData((__bridge CFMutableDataRef)data_, CGImageSourceGetType(img), 1, NULL);
    
    NSMutableDictionary *metadata = 
    [NSDictionary dictionaryWithObjectsAndKeys:
     locDict,  (NSString*)kCGImagePropertyGPSDictionary,
     exifDict, (NSString*)kCGImagePropertyExifDictionary, nil];
	CGImageDestinationAddImageFromSource(dest, img, 0, (__bridge CFDictionaryRef)metadata);
	CGImageDestinationFinalize(dest);
	CFRelease(img);
	CFRelease(dest);
}

/*!
 * md5 hash
 */
- (NSString *)md5{
    return self.data.MD5DigestString;
}

/*!
 * populate image
 */
- (UIImage *)image{
    return [UIImage imageWithData:self.data];
}

/*!
 * populate image 960
 */
- (UIImage *)image960{
    CGSize origSize = self.image.size;
    CGSize size;
    if(origSize.width > origSize.height){
        size.width = 960;
        size.height = 720;
    }else{
        size.height = 960;
        size.width = 720;
    }
    return [[UIImage imageWithData:self.data] resizedImage:size interpolationQuality:kCGInterpolationHigh];
}

/*!
 * extract metadata from image data
 */
- (NSMutableDictionary *)metadata{
    CGImageSourceRef cfImage = CGImageSourceCreateWithData((__bridge CFDataRef)data_, NULL);
    NSDictionary *metadata = (__bridge NSDictionary *)CGImageSourceCopyPropertiesAtIndex(cfImage, 0, nil);
    CFRelease(cfImage);
    return [NSMutableDictionary dictionaryWithDictionary:metadata];
}

/*!
 * encode
 */
- (void)encodeWithCoder:(NSCoder*)coder {
    [coder encodeObject:data_ forKey:@"data"];
    [coder encodeObject:timestamp_ forKey:@"timestamp"];
}

/*!
 * init with coder
 */
- (id)initWithCoder:(NSCoder*)coder {
    self = [super init];
    if (self) {
        data_ = [coder decodeObjectForKey:@"data"]; 
        timestamp_ = [coder decodeObjectForKey:@"timestamp"];
    }
    return self;
}
@end
