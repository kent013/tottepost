//
//  ProgressSummaryView.m
//  tottepost
//
//  Created by ISHITOYA Kentaro on 11/12/21.
//  Copyright (c) 2011 cocotomo. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "ProgressSummaryView.h"
#import "PhotoSubmitterManager.h"

//-----------------------------------------------------------------------------
//Private Implementations
//-----------------------------------------------------------------------------
@interface ProgressSummaryView(PrivateImplementation)
- (void)setupInitialState: (CGRect)frame;
- (void)updateLabel;
@end

@implementation ProgressSummaryView(PrivateImplementation)
/*!
 * setup initial state
 */
- (void)setupInitialState:(CGRect)frame{
    self.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.2];
    [self.layer setCornerRadius:5.0];
    [self setClipsToBounds:YES];
    
    [self.layer setBorderColor:[[UIColor colorWithWhite:0.8 alpha:0.4] CGColor]];
    [self.layer setBorderWidth:1.0];
    
    textLabel_ = [[UILabel alloc] initWithFrame:CGRectZero];
    textLabel_.textColor = [UIColor blackColor];
    textLabel_.font = [UIFont systemFontOfSize:10.0];
    textLabel_.backgroundColor = [UIColor clearColor];
    [self addSubview:textLabel_];

    self.alpha = 0.0f; 
}

/*!
 * update Label
 */
- (void)updateLabel{
    if(operationCount_ == 0){
        textLabel_.text = [NSString stringWithFormat:@"nothing to upload.", operationCount_, enabledAppCount_];
    }else{
        textLabel_.text = [NSString stringWithFormat:@"%d ops to %d apps.", operationCount_, enabledAppCount_];
    }
    [textLabel_ sizeToFit];
    [self updateWithFrame:self.frame];
}
@end

//-----------------------------------------------------------------------------
//Public Implementations
//----------------------------------------------------------------------------
@implementation ProgressSummaryView
/*!
 * initialize
 */
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupInitialState:frame];
    }
    return self;
}

/*!
 * update with frame
 */
- (void)updateWithFrame:(CGRect)inFrame{
    self.frame = inFrame;
    CGRect labelFrame = inFrame;
    labelFrame.origin.x = (labelFrame.size.width - textLabel_.frame.size.width) / 2;
    labelFrame.origin.y = 0;
    textLabel_.frame = labelFrame;
}

/*!
 * show view
 */
- (void) show{
    self.alpha = 0.0;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:1.0f];
    self.alpha = 1.0f;
    [UIView commitAnimations];  
    isVisible_ = YES;
}

/*!
 * hide view
 */
- (void) hide{
    self.alpha = 1.0f;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:1.0f];
    self.alpha = 0.0f;
    [UIView commitAnimations];   
    isVisible_ = NO;
}

/*!
 * PhotoSubmitterPhotoDelegate will start upload
 */
- (void)photoSubmitter:(id<PhotoSubmitterProtocol>)photoSubmitter willStartUpload:(NSString *)imageHash{
    operationCount_ = [PhotoSubmitterManager getInstance].uploadOperationCount;
    enabledAppCount_ = [PhotoSubmitterManager getInstance].enabledSubmitterCount;
    [self updateLabel];
    if(operationCount_ != 0 && isVisible_ == NO){
        [self show];
    }
}

/*!
 * PhotoSubmitterPhotoDelegate did submitted
 */
- (void)photoSubmitter:(id<PhotoSubmitterProtocol>)photoSubmitter didSubmitted:(NSString *)imageHash suceeded:(BOOL)suceeded message:(NSString *)message{    
    if(suceeded && photoSubmitter.type != PhotoSubmitterTypeFile){
        operationCount_--;
        enabledAppCount_ = [PhotoSubmitterManager getInstance].enabledSubmitterCount;
        [self updateLabel];
        if(operationCount_ <= 0 && isVisible_){
            [self hide];
        }
    }
}

/*!
 * PhotoSubmitterPhotoDelegate did progress changed
 */
- (void)photoSubmitter:(id<PhotoSubmitterProtocol>)photoSubmitter didProgressChanged:(NSString *)imageHash progress:(CGFloat)progress{
    //do nothing
}
@end
