//
//  ProgressTableViewCell.h
//  tottepost
//
//  Created by ISHITOYA Kentaro on 11/12/20.
//  Copyright (c) 2011 cocotomo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoSubmitterProtocol.h"
#import "FBProgressView.h"

@interface ProgressTableViewCell : UITableViewCell{
    FBProgressView *progressView_;
}
@property (strong, readonly) FBProgressView *progressView;

- (id)initWithSubmitter: (id<PhotoSubmitterProtocol>) submitter andSize:(CGSize)size;
- (void)showText:(NSString *)text;
@end
