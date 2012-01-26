//
//  FlashButton.m
//  tottepost
//
//  Created by Ken Watanabe on 12/01/25.
//  Copyright (c) 2012 Ken Watanabe. All rights reserved.
//

#import "FlashButton.h"
#import "TTLang.h"
#import "AVFoundationCameraController.h"

//-----------------------------------------------------------------------------
//Private Implementations
//-----------------------------------------------------------------------------
@interface FlashButton(PrivateImplementation)
- (void) setText;
- (void) open;
- (void) close;
- (void) handleSelectFlashModeButtonTapped:(UIButton*) sender;
- (void) setupInitialState;
@end

@implementation FlashButton(PrivateImplementation)

- (void) setupInitialState{
    ud = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *defaults = [NSMutableDictionary dictionary];
    [defaults setObject:@"0" forKey:@"flashMode"];
    [ud registerDefaults:defaults];
    flashMode_ = [ud integerForKey:@"flashMode"];
    
    UIColor* labelColor = [UIColor colorWithWhite:0.0f alpha:0.8f];
    [self setBackgroundColor:[UIColor colorWithWhite:1.0f alpha:0.3f]];
    [self addTarget:self action:@selector(handleFlashModeButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.layer setCornerRadius:15.0];
    [self setClipsToBounds:YES];
    [self.layer setBorderColor:[[UIColor colorWithWhite:0.0 alpha:0.8] CGColor]];
    [self.layer setBorderWidth:1.0];
    flashImageView_ = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"AVFoundationCameraFlash.png"]];
    flashImageView_.frame = CGRectMake(FLASHIMAGE_PADDING_X, FLASHIMAGE_PADDING_Y
                                       ,FLASHIMAGE_WIDTH, FLASHIMAGE_HEIGHT);
    flashImageView_.alpha = 0.8f;
    label = [[UILabel alloc] initWithFrame:CGRectMake(25, 0, 30, 30)];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:12];
    label.textColor = labelColor;
    [self setText];
        
    UIButton* offButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [offButton setTitle:[TTLang lstr:@"Flash_Off"] forState:UIControlStateNormal];
    offButton.titleLabel.font = [UIFont systemFontOfSize:12];
    [offButton setTitleColor:labelColor forState:UIControlStateNormal];
    offButton.frame = CGRectMake(PICKER_FLASHMODE_BUTTON_WIDTH, 0, 40, PICKER_FLASHMODE_BUTTON_HEIGHT);
    offButton.tag = AVCaptureFlashModeOff;
    [offButton.layer setBorderColor:[[UIColor colorWithWhite:0.0 alpha:0.8] CGColor]];
    [offButton.layer setBorderWidth:1.0];
    [offButton addTarget:self action:@selector(handleSelectFlashModeButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton* onButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [onButton setTitle:[TTLang lstr:@"Flash_On"] forState:UIControlStateNormal];
    [onButton setTitleColor:labelColor forState:UIControlStateNormal];
    onButton.titleLabel.font = [UIFont systemFontOfSize:12];
    onButton.tag = AVCaptureFlashModeOn;
    onButton.frame = CGRectMake(PICKER_FLASHMODE_BUTTON_WIDTH + 39, 0, 40, PICKER_FLASHMODE_BUTTON_HEIGHT);
    [onButton.layer setBorderColor:[[UIColor colorWithWhite:0.0 alpha:0.8] CGColor]];
    [onButton.layer setBorderWidth:1.0];
    [onButton addTarget:self action:@selector(handleSelectFlashModeButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton* autoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [autoButton setTitle:[TTLang lstr:@"Flash_Auto"] forState:UIControlStateNormal];
    [autoButton setTitleColor:labelColor forState:UIControlStateNormal];
    autoButton.titleLabel.font = [UIFont systemFontOfSize:12];
    autoButton.tag = AVCaptureFlashModeAuto;
    autoButton.frame = CGRectMake(PICKER_FLASHMODE_BUTTON_WIDTH + 79, 0, 40, PICKER_FLASHMODE_BUTTON_HEIGHT);
    [autoButton addTarget:self action:@selector(handleSelectFlashModeButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    
    [self addSubview:offButton];
    [self addSubview:onButton];
    [self addSubview:autoButton];    
    [self addSubview:label];
    [self addSubview:flashImageView_];
}


-(void) setText{
    switch (flashMode_) {
        case AVCaptureFlashModeOn:
            label.text = [TTLang lstr:@"Flash_On"];
            break;
        case AVCaptureFlashModeOff:
            label.text = [TTLang lstr:@"Flash_Off"];
            break;
        case AVCaptureFlashModeAuto:
            label.text = [TTLang lstr:@"Flash_Auto"];
            break;            
        default:
            break;
    }
}

- (void)open{    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    [self setFrame:CGRectMake(self.frame.origin.x
                              , self.frame.origin.y
                              , 3 * PICKER_FLASHMODE_BUTTON_WIDTH
                              , self.frame.size.height )];
    [UIView commitAnimations];
    isOpen_ = YES;
}

- (void)close{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    [self setFrame:CGRectMake(self.frame.origin.x
                              , self.frame.origin.y
                              , PICKER_FLASHMODE_BUTTON_WIDTH
                              , self.frame.size.height )];
    [UIView commitAnimations];
    isOpen_ = NO;
}

- (void) handleSelectFlashModeButtonTapped:(UIButton*) sender{
    [self close];
    if(flashMode_ == sender.tag)return;
    flashMode_ = sender.tag;
    [ud setInteger:flashMode_ forKey:@"flashMode"];
    [delegate_ setFlashMode:flashMode_];
    [self setText];
}


@end

@implementation FlashButton
@synthesize flashMode = flashMode_;
@synthesize delegate = delegate_;
@dynamic isOpen;

- (id)init
{
    if([super init])
    {
        [self setupInitialState];
    }
    return self;
}

- (void)handleFlashModeButtonTapped:(UIButton *)sender{
    self.isOpen = !self.isOpen;
}

- (BOOL)isOpen{
    return  isOpen_;  
}
- (void)setIsOpen:(BOOL)isOpen
{
    if(isOpen == isOpen_)return;
    if(isOpen)
        [self open];
    else
        [self close];
}

@end
