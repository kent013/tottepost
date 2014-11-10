//
//  ProgressTableViewCell.h
//  tottepost
//
//  Created by ISHITOYA Kentaro on 11/12/20.
//  Copyright (c) 2011 cocotomo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ENGPhotoSubmitterProtocol.h"
#import "FBProgressView.h"

@interface ProgressTableViewCell : UITableViewCell{
    FBProgressView *progressView_;
}
@property (strong, readonly) FBProgressView *progressView;

- (id)initWithSubmitter: (id<ENGPhotoSubmitterProtocol>) submitter andSize:(CGSize)size;
- (void)showText:(NSString *)text;
@end
