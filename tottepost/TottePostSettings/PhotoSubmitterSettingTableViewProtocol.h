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
#define FSV_SECTION_ACCOUNT 0
#define FSV_ROW_ACCOUNT_NAME 0
#define FSV_ROW_ACCOUNT_LOGOUT 1
#define FSV_BUTTON_TYPE 102

@protocol PhotoSubmitterSettingTableViewProtocol <NSObject>
- (id<PhotoSubmitterProtocol>) submitter;
- (NSString *) type;
@end
