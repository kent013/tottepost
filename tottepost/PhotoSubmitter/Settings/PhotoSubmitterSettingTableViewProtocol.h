//
//  PhotoSubmitterSettingProtocol.h
//  tottepost
//
//  Created by ISHITOYA Kentaro on 12/01/02.
//  Copyright (c) 2011 cocotomo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PhotoSubmitterProtocol.h"

#define TOTTEPOST_DEFAULT_ALBUM_NAME @"tottepost"
#define SV_SECTION_ACCOUNT 0
#define SV_ROW_ACCOUNT_NAME 0
#define SV_ROW_ACCOUNT_LOGOUT 1
#define SV_BUTTON_TYPE 102

#define SV_SECTION_GENERAL  0
#define SV_SECTION_ACCOUNTS 1

#define SV_GENERAL_COUNT 2
#define SV_GENERAL_COMMENT 0
#define SV_GENERAL_GPS 1

#define SWITCH_NOTFOUND -1

@protocol PhotoSubmitterServiceSettingTableViewProtocol <NSObject>
- (id<PhotoSubmitterProtocol>) submitter;
- (NSString *) type;
@end
