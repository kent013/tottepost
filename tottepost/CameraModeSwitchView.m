//
//  CameraModeSwitchView.m
//  tottepost
//
//  Created by Kentaro ISHITOYA on 12/03/16.
//  Copyright (c) 2012 cocotomo. All rights reserved.
//

#import "CameraModeSwitchView.h"

static NSString *kFilePhotoSubmitterType = @"FilePhotoSubmitter";

//-----------------------------------------------------------------------------
//Private Implementations
//-----------------------------------------------------------------------------
@interface CameraModeSwitchView(PrivateImplementation)
- (void) setupInitialState: (CGRect)frame;
- (void) didCameraModeSwitchValueChanged:(DCRoundSwitch *)sender;
- (void) handleTapGesture: (UITapGestureRecognizer *)recognizer;
@end

@implementation CameraModeSwitchView(PrivateImplementation)
/*!
 * initialize
 */
- (void)setupInitialState:(CGRect)frame{
    self.frame = frame;
    self.backgroundColor = [UIColor clearColor];
    //camera switch
    cameraModeSwitch_ = [[DCRoundSwitch alloc] initWithFrame:CGRectZero];
    [cameraModeSwitch_ addTarget:self action:@selector(didCameraModeSwitchValueChanged:) forControlEvents:UIControlEventValueChanged];
    cameraModeSwitch_.onText = @"Video";
    cameraModeSwitch_.offText = @"Photo";
    cameraModeSwitch_.on = NO;
    cameraModePictureImageView_ = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"photoMode.png"]];
    cameraModeVideoImageView_ = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"videoMode.png"]];    
    [self addSubview:cameraModePictureImageView_];
    [self addSubview:cameraModeVideoImageView_];
    [self addSubview:cameraModeSwitch_];
    
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    [self addGestureRecognizer:recognizer];
    enabled_ = YES;
}

/*!
 * on mode switch changed, change camera mode
 */
- (void)didCameraModeSwitchValueChanged:(DCRoundSwitch *)sender{
    if([self.delegate respondsToSelector:@selector(cameraModeSwitchView:didModeChangedTo:)] == NO){
        return;
    }
    if(sender.on){
        [self.delegate cameraModeSwitchView:self didModeChangedTo:AVFoundationCameraModeVideo];
    }else{
        [self.delegate cameraModeSwitchView:self didModeChangedTo:AVFoundationCameraModePhoto];
    }
}

/*!
 * handle tap gesture
 */
- (void)handleTapGesture:(UITapGestureRecognizer *)recognizer{
    if(enabled_){
        self.enabled = NO;
        [cameraModeSwitch_ setOn:!cameraModeSwitch_.on animated:YES ignoreControlEvents:NO];
        [self performSelector:@selector(setEnabled:) withObject:[NSNumber numberWithBool:YES] afterDelay:5.0];
    }
}
@end

//-----------------------------------------------------------------------------
//Public Implementations
//----------------------------------------------------------------------------
@implementation CameraModeSwitchView
@synthesize enabled = enabled_;
@synthesize delegate;
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
 * set frame
 */
- (void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    int height = cameraModeVideoImageView_.image.size.height / 2;
    cameraModePictureImageView_.frame = CGRectMake(3, 0, height, height);
    cameraModeVideoImageView_.frame = CGRectMake(self.frame.size.width- height - 3, 0, height, height);
    cameraModeSwitch_.frame = CGRectMake(0, height + 4, self.frame.size.width, 16);
}

/*!
 * set disable
 */
- (void)setEnabled:(BOOL)enabled{
    enabled_ = enabled;
    cameraModeSwitch_.enabled = enabled;
}
@end

