//
//  TottePostSettings.m
//  tottepost
//
//  Created by ISHITOYA Kentaro on 11/12/21.
//  Copyright (c) 2011 cocotomo. All rights reserved.
//

#import "TottePostSettings.h"
#import "PhotoSubmitterManager.h"

/*!
 * singleton instance
 */
static TottePostSettings* TottePostSettingsSingletonInstance;

#define TPS_KEY_COMMENT_POST_ENABLED @"commentPostEnabled"
#define TPS_KEY_GPS_ENABLED @"gpsEnabled"
#define TPS_KEY_SUPPORTED_TYPE_INDEXES @"supportedTypeIndexes"
#define TPS_KEY_USER_EMAIL @"TottepostEmailAddress"
#define TPS_KEY_USER_NAME @"TottepostUsername"

//-----------------------------------------------------------------------------
//Private Implementations
//-----------------------------------------------------------------------------
@interface TottePostSettings(PrivateImplementation)
- (void) writeSetting:(NSString *)key value:(id)value;
- (id)readSetting:(NSString *)key;
@end

@implementation TottePostSettings(PrivateImplementation)
/*!
 * write settings to user defaults
 */
- (void)writeSetting:(NSString *)key value:(id)value{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:value forKey:key];
    [defaults synchronize];
}

/*!
 * read settings from user defaults
 */
- (id)readSetting:(NSString *)key{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults valueForKey:key];
}
@end

//-----------------------------------------------------------------------------
//Public Implementations
//----------------------------------------------------------------------------
@implementation TottePostSettings

- (id)init{
    self = [super init];
    if(self){
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSMutableDictionary* defaultValue = [[NSMutableDictionary alloc] init];
        NSArray* supportedTypes = [PhotoSubmitterManager sharedInstance].supportedTypes;
        [defaultValue setObject:supportedTypes forKey:TPS_KEY_SUPPORTED_TYPE_INDEXES];
        [defaults registerDefaults:defaultValue];
        [defaults synchronize];
        
    }
    return self;
}
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
 * set gps enabled
 */
- (void)setGpsEnabled:(BOOL)gpsEnabled{
    [self writeSetting:TPS_KEY_GPS_ENABLED value:[NSNumber numberWithBool:gpsEnabled]];
}

/*!
 * get supported type indexes
 */
- (NSArray *)supportedTypeIndexes{
    return [self readSetting:TPS_KEY_SUPPORTED_TYPE_INDEXES];
}

/*!
 * set supported type indexes
 */
- (void)setSupportedTypeIndexes:(NSArray *)supportedTypeIndexes{
    [self writeSetting:TPS_KEY_SUPPORTED_TYPE_INDEXES value:supportedTypeIndexes];
}

/*!
 * get email address
 */
- (NSString *)emailAddress{
    return [self readSetting:TPS_KEY_USER_EMAIL];
}

/*!
 * set email address
 */
- (void)setEmailAddress:(NSString *)emailAddress{
    [self writeSetting:TPS_KEY_USER_EMAIL value:emailAddress];
}
/*!
 * get username
 */
- (NSString *)username{
    return [self readSetting:TPS_KEY_USER_NAME];
}

/*!
 * set username
 */
- (void)setUsername:(NSString *)username{
    [self writeSetting:TPS_KEY_USER_NAME value:username];
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
