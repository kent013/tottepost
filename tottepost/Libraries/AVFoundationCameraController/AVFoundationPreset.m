//
//  AVFoundationPreset.m
//  tottepost
//
//  Created by Kentaro ISHITOYA on 12/03/17.
//  Copyright (c) 2012 cocotomo. All rights reserved.
//

#if ! __has_feature(objc_arc)
#error This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

#import <AVFoundation/AVFoundation.h>
#import "AVFoundationPreset.h"
#import "UIDevice-Hardware.h"

static NSArray *AVFoundationPresetAvaliablePhotoPresets_;
static NSArray *AVFoundationPresetAvaliableVideoPresets_;

//-----------------------------------------------------------------------------
//Private Implementations
//-----------------------------------------------------------------------------
@interface AVFoundationPreset(PrivateImplementatio)
@end

@implementation AVFoundationPreset(PrivateImplementation)
@end

//-----------------------------------------------------------------------------
//Public Implementations
//----------------------------------------------------------------------------
@implementation AVFoundationPreset
@synthesize name;
@synthesize desc;
/*!
 * init with name and description
 */
- (id)initWithName:(NSString *)inName andDesc:(NSString *)inDesc{
    self = [super init];
    if(self){
        self.name = inName;
        self.desc = inDesc;
    }
    return self;
}

/*!
 * encode
 */
- (void)encodeWithCoder:(NSCoder*)coder {
    [coder encodeObject:self.name forKey:@"name"];
    [coder encodeObject:self.desc forKey:@"desc"];
}

/*!
 * init with coder
 */
- (id)initWithCoder:(NSCoder*)coder {
    self = [super init];
    if (self) {
        self.name = [coder decodeObjectForKey:@"name"];
        self.desc = [coder decodeObjectForKey:@"desc"];
    }
    return self;
}

/*!
 * get preset
 */
+ (id)presetWithName:(NSString *)inName andDesc:(NSString *)inDesc{
    return [[AVFoundationPreset alloc] initWithName:inName andDesc:inDesc];
}

/*!
 * available photo presets
 */
+ (NSArray *)availablePhotoPresets{
    if(AVFoundationPresetAvaliablePhotoPresets_){
        return AVFoundationPresetAvaliablePhotoPresets_;
    }
    NSMutableArray *ps = [[NSMutableArray alloc] init];
    if(AVCaptureSessionPresetPhoto != nil){
        [ps addObject:[AVFoundationPreset presetWithName:AVCaptureSessionPresetPhoto andDesc:@"Photo"]];
    }
    if(AVCaptureSessionPresetHigh != nil){
        [ps addObject:[AVFoundationPreset presetWithName:AVCaptureSessionPresetHigh andDesc:@"High"]];
    }
    if(AVCaptureSessionPresetMedium != nil){
        [ps addObject:[AVFoundationPreset presetWithName:AVCaptureSessionPresetMedium andDesc:@"Medium"]];
    }
    if(AVCaptureSessionPresetLow != nil){
        [ps addObject:[AVFoundationPreset presetWithName:AVCaptureSessionPresetLow andDesc:@"Low"]];
    }
    AVFoundationPresetAvaliablePhotoPresets_ = ps;
    return AVFoundationPresetAvaliablePhotoPresets_;
}

/*!
 * available video presets
 */
+ (NSArray *)availableVideoPresets{
    if(AVFoundationPresetAvaliableVideoPresets_){
        return AVFoundationPresetAvaliableVideoPresets_;
    }
    NSMutableArray *ps = [[NSMutableArray alloc] init];
    if(AVCaptureSessionPresetHigh != nil){
        [ps addObject:[AVFoundationPreset presetWithName:AVCaptureSessionPresetHigh andDesc:@"High"]];
    }
    if(AVCaptureSessionPresetMedium != nil){
        [ps addObject:[AVFoundationPreset presetWithName:AVCaptureSessionPresetMedium andDesc:@"Medium"]];
    }
    if(AVCaptureSessionPresetLow != nil){
        [ps addObject:[AVFoundationPreset presetWithName:AVCaptureSessionPresetLow andDesc:@"Low"]];
    }
    AVFoundationPresetAvaliableVideoPresets_ = ps;
    return AVFoundationPresetAvaliableVideoPresets_;
}
@end
