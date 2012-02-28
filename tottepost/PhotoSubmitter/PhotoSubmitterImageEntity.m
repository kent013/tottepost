//
//  PhotoSubmitterImageEntity.m
//  tottepost
//
//  Created by ISHITOYA Kentaro on 12/01/22.
//  Copyright (c) 2012 cocotomo. All rights reserved.
//

#import <ImageIO/ImageIO.h>
#import "PhotoSubmitterImageEntity.h"
#import "NSData+Digest.h"
#import "UIImage+Resize.h"
#import "UIImage+AutoRotation.h"
#import "NSData+Base64.h"

//-----------------------------------------------------------------------------
//Private Implementations
//-----------------------------------------------------------------------------
@interface PhotoSubmitterImageEntity(PrivateImplementatio)
- (void) applyMetadata:(NSData *)data;
@end

@implementation PhotoSubmitterImageEntity(PrivateImplementation)
- (void)applyMetadata:(NSData *)data{
    CGImageSourceRef img = CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
	NSMutableDictionary* exifDict = [[NSMutableDictionary alloc] init];
	NSMutableDictionary* locDict = [[NSMutableDictionary alloc] init];
	NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"yyyy:MM:dd HH:mm:ss"];
	NSString* datetime = [dateFormatter stringFromDate:timestamp_];
	[exifDict setObject:datetime forKey:(NSString*)kCGImagePropertyExifDateTimeOriginal];
	[exifDict setObject:datetime forKey:(NSString*)kCGImagePropertyExifDateTimeDigitized];
    if(self.comment != nil){
        [exifDict setObject:self.comment forKey:(NSString*)kCGImagePropertyExifUserComment];
    }
    if(self.location != nil){
        [locDict setObject:self.location.timestamp forKey:(NSString*)kCGImagePropertyGPSTimeStamp];
        if (self.location.coordinate.latitude <0.0){ 
            [locDict setObject:@"S" forKey:(NSString*)kCGImagePropertyGPSLatitudeRef];
        }else{ 
            [locDict setObject:@"N" forKey:(NSString*)kCGImagePropertyGPSLatitudeRef];
        } 
        [locDict setObject:[NSNumber numberWithFloat:self.location.coordinate.latitude] forKey:(NSString*)kCGImagePropertyGPSLatitude];
        if (self.location.coordinate.longitude < 0.0){ 
            [locDict setObject:@"W" forKey:(NSString*)kCGImagePropertyGPSLongitudeRef];
        }else{ 
            [locDict setObject:@"E" forKey:(NSString*)kCGImagePropertyGPSLongitudeRef];
        } 
        [locDict setObject:[NSNumber numberWithFloat:self.location.coordinate.longitude] forKey:(NSString*)kCGImagePropertyGPSLongitude];
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
@end

//-----------------------------------------------------------------------------
//Public Implementations
//----------------------------------------------------------------------------
@implementation PhotoSubmitterImageEntity
@synthesize data = data_;
@synthesize timestamp = timestamp_;
@synthesize path = path_;
@synthesize photoHash = photoHash_;
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
        resizedImages_ = [[NSMutableDictionary alloc] init];
    }
    return self;
}

/*!
 * apply metadata
 */
- (void)applyMetadata{
    [self applyMetadata:data_];
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
    if(image_ == nil){
        image_ = [[UIImage imageWithData:self.data] fixOrientation];
    }
    return image_;
}

/*!
 * populate base64 data
 */
- (NSString *)base64String{
    NSString *base64 = [self.data base64EncodedString];
    return [base64 stringByReplacingOccurrencesOfString:@"\r" withString:@""];
}

/*!
 * populate resized image 
 */
- (UIImage *)resizedImage:(CGSize)size{
    if(CGSizeEqualToSize(size, self.image.size)){
        return self.image;
    }
    
    NSString *key = NSStringFromCGSize(size);
    UIImage *resized = [resizedImages_ objectForKey:key];
    if(resized){
        return resized;
    }
    
    resized = [[self.image resizedImage:size
                   interpolationQuality:kCGInterpolationHigh] fixOrientation];
    
    NSData *resizedData = UIImageJPEGRepresentation(resized, 1.0);
    CGImageSourceRef resizedCFImage = CGImageSourceCreateWithData((__bridge CFDataRef)resizedData, NULL);
    
    NSMutableDictionary *metadata = self.metadata;
    NSMutableDictionary *resizedMetadata = [NSMutableDictionary dictionaryWithDictionary:(__bridge NSDictionary *)CGImageSourceCopyPropertiesAtIndex(resizedCFImage, 0, nil)];
    NSMutableDictionary *exifMetadata = [metadata objectForKey:(NSString *)kCGImagePropertyExifDictionary];
    [resizedMetadata setValue:exifMetadata forKey:(NSString *)kCGImagePropertyExifDictionary];
    CGImageDestinationRef dest = CGImageDestinationCreateWithData((__bridge CFMutableDataRef)resizedData, CGImageSourceGetType(resizedCFImage), 1, NULL);
    CGImageDestinationAddImageFromSource(dest, resizedCFImage, 0, (__bridge CFDictionaryRef)resizedMetadata);
    CGImageDestinationFinalize(dest);
    CFRelease(resizedCFImage);
    
    [resizedImages_ setObject:resized forKey:key];
    return resized;
}

/*!
 * populate resized image 
 */
- (NSData *) autoRotatedData{    
    if(autoRotatedData_){
        return autoRotatedData_;
    }
    UIImage *rotatedImage = [[UIImage imageWithData:data_] fixOrientation];
    NSData *rotatedData = UIImageJPEGRepresentation(rotatedImage, 1.0);
    
    [self applyMetadata: rotatedData];
    
    autoRotatedData_ = rotatedData;
    return rotatedData;
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
 * clone and auto rotate image
 */
- (PhotoSubmitterImageEntity *)autoRotatedImageEntity{
    return nil;
}

/*!
 * get photo hash
 */
- (NSString *)photoHash{
    if(photoHash_ == nil){
        photoHash_ = self.md5;
    }
    return photoHash_;
}

/*!
 * encode
 */
- (void)encodeWithCoder:(NSCoder*)coder {
    [coder encodeObject:data_ forKey:@"data"];
    [coder encodeObject:timestamp_ forKey:@"timestamp"];
    [coder encodeObject:path_ forKey:@"path"];
}

/*!
 * init with coder
 */
- (id)initWithCoder:(NSCoder*)coder {
    self = [super init];
    if (self) {
        data_ = [coder decodeObjectForKey:@"data"]; 
        timestamp_ = [coder decodeObjectForKey:@"timestamp"];
        path_ = [coder decodeObjectForKey:@"path"];
        resizedImages_ = [[NSMutableDictionary alloc] init];
    }
    return self;
}
@end
