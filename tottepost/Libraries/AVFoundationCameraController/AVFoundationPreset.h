//
//  AVFoundationPreset.h
//  tottepost
//
//  Created by Kentaro ISHITOYA on 12/03/17.
//  Copyright (c) 2012 cocotomo. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum{
    AVFoundationPresetTypePhoto,
    AVFoundationPresetTypeVideo
} AVFoundationPresetType;

@interface AVFoundationPreset : NSObject<NSCoding>
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *desc;

- (id)initWithCoder:(NSCoder*)coder;
- (void)encodeWithCoder:(NSCoder*)coder;
- (id)initWithName:(NSString *)name andDesc:(NSString *)description;
+ (id)presetWithName:(NSString *)name andDesc:(NSString *)description;
+ (NSArray *) availablePhotoPresets;
+ (NSArray *) availableVideoPresets;
@end
