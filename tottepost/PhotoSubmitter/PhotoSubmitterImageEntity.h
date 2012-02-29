//
//  PhotoSubmitterImageEntity.h
//  tottepost
//
//  Created by ISHITOYA Kentaro on 12/01/22.
//  Copyright (c) 2012 cocotomo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface PhotoSubmitterImageEntity : NSObject<NSCoding>{
    __strong NSData *data_;
    __strong NSData *autoRotatedData_;
    __strong NSDate *timestamp_;
    __strong NSString *path_;
    __strong NSString *photoHash_;
    __strong UIImage *image_;
    __strong NSMutableDictionary *resizedImages_;
}
@property (strong, nonatomic) NSString *comment;
@property (strong, nonatomic) CLLocation *location;
@property (strong, nonatomic) NSString *path;
@property (strong, nonatomic) NSString *photoHash;
@property (readonly, nonatomic) NSData *data;
@property (readonly, nonatomic) NSString *base64String;
@property (readonly, nonatomic) NSMutableDictionary *metadata;
@property (readonly, nonatomic) UIImage *image;
@property (readonly, nonatomic) NSString *md5;
@property (readonly, nonatomic) NSDate *timestamp;

- (id) initWithData:(NSData *)data;
- (id) initWithImage:(UIImage *)image;
- (void) applyMetadata;
- (UIImage *) resizedImage: (CGSize) size;
- (NSData *) autoRotatedData;
@end
