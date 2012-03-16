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
@synthesize type;
@synthesize contentHash;

/*!
 * initialize
 */
- (id)initWithSubmitterType:(NSString *)inType contentHash:(NSString *)inPhotoHash{
    self = [super init];
    if(self){
        type = inType;
        contentHash = inPhotoHash;
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
    return [UploadProgressEntity generateProgressHash:self.type hash:self.contentHash];
}

/*!
 * submitter
 */
- (id<PhotoSubmitterProtocol>)submitter{
    return [PhotoSubmitterManager submitterForType:self.type];
}

/*!
 * generate hash
 */
+ (NSString *)generateProgressHash:(NSString *)type hash:(NSString *)hash{
    return [[PhotoSubmitterManager submitterForType:type].name stringByAppendingString:hash];
}
@end
