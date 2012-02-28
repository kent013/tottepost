//
//  TwitterPhotoSubmitter.h
//  PhotoSubmitter for Twitter
//
//  Created by ISHITOYA Kentaro on 11/12/17.
//  Copyright (c) 2011 cocotomo. All rights reserved.
//

#import <Twitter/Twitter.h>
#import <Accounts/Accounts.h>
#import "PhotoSubmitter.h"
#import "PhotoSubmitterProtocol.h"

@interface TwitterPhotoSubmitter : PhotoSubmitter<PhotoSubmitterInstanceProtocol, NSURLConnectionDataDelegate, NSURLConnectionDelegate, UIAlertViewDelegate>{
    ACAccountStore *accountStore_;
}

@property (nonatomic, readonly) NSArray *accounts;
@property (nonatomic, assign) NSString *selectedAccountUsername;
@end
