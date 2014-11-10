//
//  UploadProgressEntity.m
//  tottepost
//
//  Created by ISHITOYA Kentaro on 11/12/18.
//  Copyright (c) 2011 cocotomo. All rights reserved.
//

#import "UploadProgressEntity.h"

//-----------------------------------------------------------------------------
//Private Implementations
//-----------------------------------------------------------------------------
@interface UploadProgressEntity(PrivateImplementation)
@end

@implementation UploadProgressEntity(PrivateImplementation)
@end

//-----------------------------------------------------------------------------
//Public Implementations
//----------------------------------------------------------------------------
@implementation UploadProgressEntity
@synthesize progress;
@synthesize account;
@synthesize contentHash;

/*!
 * initialize
 */
- (id)initWithAccount:(ENGPhotoSubmitterAccount *)inAccount contentHash:(NSString *)inContentHash{
    self = [super init];
    if(self){
        account = inAccount;
        contentHash = inContentHash;
        progress = 0.0;
    }
    return self;
}

/*!
 * set progress
 */
- (void)setProgress:(CGFloat)inProgress{
    progress = inProgress;
}

/*!
 * progress hash
 */
- (NSString *)progressHash{
    return [UploadProgressEntity generateProgressHashWithAccount:account hash:self.contentHash];
}

/*!
 * submitter
 */
- (id<ENGPhotoSubmitterProtocol>)submitter{
    return [ENGPhotoSubmitterManager submitterForAccount:self.account];
}

/*!
 * generate hash
 */
+ (NSString *)generateProgressHashWithAccount:(ENGPhotoSubmitterAccount *)account hash:(NSString *)hash{
    return [account.accountHash stringByAppendingString:hash];
}
@end
