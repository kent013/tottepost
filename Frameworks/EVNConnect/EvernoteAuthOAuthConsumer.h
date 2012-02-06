//
//  EvernoteAuthOAuthConsumer.h
//  EVNConnect
//
//  Created by Kentaro ISHITOYA on 12/02/03.
//  Copyright (c) 2012 Kentaro ISHITOYA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EvernoteAuth.h"
#import "OAConsumer.h"
#import "OADataFetcher.h"
#import "OAMutableURLRequest.h"

@interface EvernoteAuthOAuthConsumer : EvernoteAuth<EvernoteAuthProtocol>{
    __strong OAConsumer *consumer_;
	__strong OAToken *accessToken_;
}
@end
