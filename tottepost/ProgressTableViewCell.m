//
//  ProgressTableViewCell.m
//  tottepost
//
//  Created by ISHITOYA Kentaro on 11/12/20.
//  Copyright (c) 2011 cocotomo. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "ProgressTableViewCell.h"

//-----------------------------------------------------------------------------
//Private Implementations
//-----------------------------------------------------------------------------
@interface ProgressTableViewCell(PrivateImplementation)
- (void)setupInitialState:(id<ENGPhotoSubmitterProtocol>) submitter andSize:(CGSize)size;
@end

@implementation ProgressTableViewCell(PrivateImplementation)
- (void)setupInitialState:(id<ENGPhotoSubmitterProtocol>)submitter andSize:(CGSize)size{
    [self.layer setCornerRadius:5.0];
    [self setClipsToBounds:YES];
    
    [self.layer setBorderColor:[[UIColor colorWithWhite:0.8 alpha:0.4] CGColor]];
    [self.layer setBorderWidth:1.0];
    
    self.imageView.image = submitter.smallIcon;
    progressView_ = [[FBProgressView alloc] init];
    progressView_.progressViewStyle = FBProgressViewStyleWhite;
    progressView_.lineWidth = 0;
    progressView_.color = [UIColor colorWithWhite:1.0 alpha:0.6];
    progressView_.frame = CGRectMake(self.imageView.image.size.width + 10, (size.height - 10) / 2.0, size.width - 15 - self.imageView.image.size.width, 10);
    [self.contentView addSubview:progressView_];
    
    self.textLabel.textColor = [UIColor blackColor];
    self.textLabel.font = [UIFont systemFontOfSize:8.0];
}
@end

//-----------------------------------------------------------------------------
//Public Implementations
//----------------------------------------------------------------------------
@implementation ProgressTableViewCell
@synthesize progressView = progressView_;

- (id)initWithSubmitter: (id<ENGPhotoSubmitterProtocol>) submitter andSize:(CGSize)size
{
    self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    if (self) {
        [self setupInitialState:submitter andSize:size];
    }
    return self;
}

/*!
 * show text
 */
- (void) showText:(NSString *)text{
    [progressView_ removeFromSuperview];
    self.textLabel.text = text;
}
@end
