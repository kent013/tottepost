//
//  TottepostSettings.h
//  tottepost
//
//  Created by Kentaro ISHITOYA on 12/03/18.
//  Copyright (c) cocotomo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AVFoundationPreset.h"

@interface TottepostSettings : NSObject{
}
@property (nonatomic, assign) AVFoundationPreset *photoPreset;
@property (nonatomic, assign) AVFoundationPreset *videoPreset;
@property (nonatomic, assign) BOOL useSilentMode;
@property (nonatomic, assign) CGFloat shutterSoundVolume; 
@property (nonatomic, assign) BOOL useTooltip;
@property (nonatomic, assign) NSDictionary *tooltipHistory;
+ (TottepostSettings *)sharedInstance;
@end
