//
//  TottePostSettings.m
//  tottepost
//
//  Created by ISHITOYA Kentaro on 11/12/21.
//  Copyright (c) 2011 cocotomo. All rights reserved.
//

#import "TottePostSettings.h"

/*!
 * singleton instance
 */
static TottePostSettings* TottePostSettingsSingletonInstance;

#define TPS_KEY_COMMENT_POST_ENABLED @"commentPostEnabled"
#define TPS_KEY_GPS_ENABLED @"gpsEnabled"

//-----------------------------------------------------------------------------
//Private Implementations
//-----------------------------------------------------------------------------
@interface TottePostSettings(PrivateImplementation)
- (void) writeSetting:(NSString *)key value:(NSValue *)value;
- (NSValue *)readSetting:(NSString *)key;
@end

@implementation TottePostSettings(PrivateImplementation)
/*!
 * write settings to user defaults
 */
- (void)writeSetting:(NSString *)key value:(NSValue *)value{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:value forKey:key];
    [defaults synchronize];
}

/*!
 * read settings from user defaults
 */
- (NSValue *)readSetting:(NSString *)key{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults valueForKey:key];
}
@end

//-----------------------------------------------------------------------------
//Public Implementations
//----------------------------------------------------------------------------
@implementation TottePostSettings
#pragma mark -
#pragma mark values
/*!
 * get comment post enabled
 */
- (BOOL)commentPostEnabled{
    NSNumber *value = (NSNumber *)[self readSetting:TPS_KEY_COMMENT_POST_ENABLED];
    if(value == nil){
        return NO;
    }
    return [value boolValue];
}

/*!
 * set comment post enabled
 */
- (void)setCommentPostEnabled:(BOOL)commentPostEnabled{
    [self writeSetting:TPS_KEY_COMMENT_POST_ENABLED value:[NSNumber numberWithBool:commentPostEnabled]];
}

/*!
  * get gps enabled
  */
- (BOOL)gpsEnabled{
    NSNumber *value = (NSNumber *)[self readSetting:TPS_KEY_GPS_ENABLED];
    if(value == nil){
        return NO;
    }
    return [value boolValue];
}

/*!
 * set comment post enabled
 */
- (void)setGpsEnabled:(BOOL)gpsEnabled{
    [self writeSetting:TPS_KEY_GPS_ENABLED value:[NSNumber numberWithBool:gpsEnabled]];
}

#pragma mark -
#pragma mark static methods
/*!
 * singleton method
 */
+ (TottePostSettings *)getInstance{
    if(TottePostSettingsSingletonInstance == nil){
        TottePostSettingsSingletonInstance = [[TottePostSettings alloc] init];
    }
    return TottePostSettingsSingletonInstance;
}
@end
