//
//  MixiImageButtonView.m
//
//  Created by Platform Service Department on 11/08/31.
//  Copyright 2011 mixi Inc. All rights reserved.
//

#import "MixiImageButtonView.h"


@implementation MixiImageButtonView

@synthesize target=target_, action=action_, argument=argument_;

- (id)initWithImage:(UIImage *)image {
    self = [super initWithImage:image];
    if (self) {
        self.userInteractionEnabled = YES;
    }
    return self;
}

- (void)addTarget:(id)target action:(SEL)action {
    self.target = target;
    self.action = action;
}

- (void)addTarget:(id)target action:(SEL)action withObject:(id)argument {
    self.target = target;
    self.action = action;
    self.argument = argument;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.target performSelector:self.action withObject:self.argument];
}

- (void)dealloc {
    self.target = nil;
    self.action = nil;
    self.argument = nil;
    [super dealloc];
}

@end
