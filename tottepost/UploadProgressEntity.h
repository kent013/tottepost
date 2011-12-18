//
//  UploadProgressEntity.h
//  tottepost
//
//  Created by ISHITOYA Kentaro on 11/12/18.
//  Copyright (c) 2011 cocotomo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PhotoSubmitterManager.h"

@interface UploadProgressEntity : NSObject
@property (nonatomic, assign) CGFloat progress;
@property (nonatomic, assign) PhotoSubmitterType type;
@property (nonatomic, readonly) id<PhotoSubmitterProtocol> submitter;
@property (nonatomic, readonly) NSString *progressHash;
@property (strong, nonatomic) NSString *photoHash;
@property (strong, nonatomic) UIProgressView *progressBar;

- (id)initWithSubmitterType:(PhotoSubmitterType)type photoHash:(NSString *)photoHash;
+ (NSString *) generateProgressHash:(PhotoSubmitterType)type hash:(NSString *)hash;
@end
