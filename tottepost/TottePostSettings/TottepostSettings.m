//
//  TottepostSettings.m
//  tottepost
//
//  Created by Kentaro ISHITOYA on 12/03/18.
//  Copyright (c) 2012 cocotomo. All rights reserved.
//

#if ! __has_feature(objc_arc)
#error This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

#import <AVFoundation/AVFoundation.h>
#import "TottepostSettings.h"
#import "PhotoSubmitterSettings.h"

/*!
 * singleton instance
 */
static TottepostSettings* TottepostSettingsSingletonInstance_;

#define TP_KEY_PHOTO_PRESET @"TottepostPhotoPreset"
#define TP_KEY_VIDEO_PRESET @"TottepostVideoPreset"

//-----------------------------------------------------------------------------
//Private Implementations
//-----------------------------------------------------------------------------
@interface TottepostSettings(PrivateImplementation)
- (void) writeSetting:(NSString *)key value:(id)value;
- (id)readSetting:(NSString *)key;
@end

@implementation TottepostSettings(PrivateImplementation)
/*!
 * write settings to user defaults
 */
- (void)writeSetting:(NSString *)key value:(id)value{
    if([value isKindOfClass:[AVFoundationPreset class]]){
        value = [NSKeyedArchiver archivedDataWithRootObject:value];
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:value forKey:key];
    [defaults synchronize];
}

/*!
 * read settings from user defaults
 */
- (id)readSetting:(NSString *)key{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    id value = [defaults valueForKey:key];
    if([value isKindOfClass:[NSData class]]){
        value = [NSKeyedUnarchiver unarchiveObjectWithData: value];
    }
    return value;
}
@end

//-----------------------------------------------------------------------------
//Public Implementations
//----------------------------------------------------------------------------
@implementation TottepostSettings

- (id)init{
    self = [super init];
    if(self){
    }
    return self;
}
#pragma mark -
#pragma mark values
/*!
 * get photo preset
 */
- (AVFoundationPreset *)photoPreset{
    id retval = [self readSetting:TP_KEY_PHOTO_PRESET];
    if([retval isKindOfClass:[AVFoundationPreset class]]){
        return retval;
    }
    if(retval == nil){
        return [AVFoundationPreset presetWithName:AVCaptureSessionPresetPhoto andDesc:@""];
    }
    [self writeSetting:TP_KEY_PHOTO_PRESET value:nil];
    return nil;
}

/*!
 * set photo preset
 */
- (void)setPhotoPreset:(AVFoundationPreset *)photoPreset{
    [self writeSetting:TP_KEY_PHOTO_PRESET value:photoPreset];
}

/*!
 * get video preset
 */
- (AVFoundationPreset *)videoPreset{
    id retval = [self readSetting:TP_KEY_VIDEO_PRESET];
    if([retval isKindOfClass:[AVFoundationPreset class]]){
        return retval;
    }
    if(retval == nil){
        return [AVFoundationPreset presetWithName:AVCaptureSessionPresetMedium andDesc:@""];
    }
    [self writeSetting:TP_KEY_VIDEO_PRESET value:nil];
    return nil;
}

/*!
 * set photo preset
 */
- (void)setVideoPreset:(AVFoundationPreset *)videoPreset{
    [self writeSetting:TP_KEY_VIDEO_PRESET value:videoPreset];
}

#pragma mark -
#pragma mark static methods
/*!
 * singleton method
 */
+ (TottepostSettings *)sharedInstance{
    if(TottepostSettingsSingletonInstance_ == nil){
        TottepostSettingsSingletonInstance_ = [[TottepostSettings alloc] init];
    }
    return TottepostSettingsSingletonInstance_;
}
@end
