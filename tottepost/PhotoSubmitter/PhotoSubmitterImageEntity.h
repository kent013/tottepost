//
//  PhotoSubmitterImageEntity.h
//  tottepost
//
//  Created by ISHITOYA Kentaro on 12/01/22.
//  Copyright (c) 2012 cocotomo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface PhotoSubmitterImageEntity : NSObject{
    __strong NSData *data_;
}
@property (strong, nonatomic) NSString *comment;
@property (strong, nonatomic) CLLocation *location;
@property (readonly, nonatomic) NSData *data;
@property (readonly, nonatomic) NSMutableDictionary *metadata;
@property (readonly, nonatomic) UIImage *image;
@property (readonly, nonatomic) NSString *md5;

- (id) initWithData:(NSData *)data;
- (void) applyMetadata;
@end
