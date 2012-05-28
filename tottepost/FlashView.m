//
//  FlashView.m
//  SketchTest
//
//  Created by Ken Watanabe on 12/05/27.
//

#import "FlashView.h"

@implementation FlashView
@synthesize flashInterval = flashInterval_;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:1.0f alpha:1.0f];
        self.alpha = 0.0f;
        firstAlpha_ = 0.8f;
        flashInterval_ = 0.4f;
   }
    return self;
}

// flash this view
-(void)flash{
    self.alpha = firstAlpha_;
    CGContextRef context = UIGraphicsGetCurrentContext();
    [UIView beginAnimations:nil context:context];
    [UIView setAnimationDuration:flashInterval_];
    self.alpha = 0.0f;
    [UIView commitAnimations];
}

@end
