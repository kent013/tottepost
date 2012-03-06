//
//  TottePostSettings.h
//  tottepost
//
//  Created by ISHITOYA Kentaro on 11/12/21.
//  Copyright (c) 2011 cocotomo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PhotoSubmitterSettings : NSObject{
}
@property (nonatomic, assign) BOOL commentPostEnabled;
@property (nonatomic, assign) BOOL gpsEnabled;
@property (nonatomic, assign) NSDictionary *submitterEnabledDates;
+ (PhotoSubmitterSettings *)getInstance;
@end


