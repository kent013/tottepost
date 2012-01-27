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

#define FLASHIMAGE_PADDING_X 8
#define FLASHIMAGE_PADDING_Y 8
#define FLASHIMAGE_WIDTH 15
#define FLASHIMAGE_HEIGHT 15

//-----------------------------------------------------------------------------
//Private Implementations
//-----------------------------------------------------------------------------
@interface FlashButton(PrivateImplementation)
- (void) setText;
- (void) open;
- (void) close;
- (void) handleSelectFlashModeButtonTapped:(UIButton*) sender;
- (void) setupInitialState;
- (void) setFrame:(CGRect)frame;
@end

@implementation FlashButton(PrivateImplementation)

/*!
 * initialize view
 */
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
    flashImageView_.alpha = 0.8f;
    label = [[UILabel alloc] initWithFrame:CGRectMake(25, 0, 30, 30)];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:12];
    label.textColor = labelColor;
    [self setText];
        
    offButton_ = [UIButton buttonWithType:UIButtonTypeCustom];
    [offButton_ setTitle:[TTLang lstr:@"Flash_Off"] forState:UIControlStateNormal];
    offButton_.titleLabel.font = [UIFont systemFontOfSize:12];
    [offButton_ setTitleColor:labelColor forState:UIControlStateNormal];
    offButton_.tag = AVCaptureFlashModeOff;
    [offButton_.layer setBorderColor:[[UIColor colorWithWhite:0.0 alpha:0.8] CGColor]];
    [offButton_.layer setBorderWidth:1.0];
    [offButton_ addTarget:self action:@selector(handleSelectFlashModeButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    onButton_ = [UIButton buttonWithType:UIButtonTypeCustom];
    [onButton_ setTitle:[TTLang lstr:@"Flash_On"] forState:UIControlStateNormal];
    [onButton_ setTitleColor:labelColor forState:UIControlStateNormal];
    onButton_.titleLabel.font = [UIFont systemFontOfSize:12];
    onButton_.tag = AVCaptureFlashModeOn;
    [onButton_.layer setBorderColor:[[UIColor colorWithWhite:0.0 alpha:0.8] CGColor]];
    [onButton_.layer setBorderWidth:1.0];
    [onButton_ addTarget:self action:@selector(handleSelectFlashModeButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    autoButton_ = [UIButton buttonWithType:UIButtonTypeCustom];
    [autoButton_ setTitle:[TTLang lstr:@"Flash_Auto"] forState:UIControlStateNormal];
    [autoButton_ setTitleColor:labelColor forState:UIControlStateNormal];
    autoButton_.titleLabel.font = [UIFont systemFontOfSize:12];
    autoButton_.tag = AVCaptureFlashModeAuto;
    [autoButton_ addTarget:self action:@selector(handleSelectFlashModeButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:offButton_];
    [self addSubview:onButton_];
    [self addSubview:autoButton_];    
    [self addSubview:label];
    [self addSubview:flashImageView_];
}

/*!
 * set current flash mode text
 */
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

/*!
 * open button
 */
- (void)open{    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    [super setFrame:CGRectMake(self.frame.origin.x
                              , self.frame.origin.y
                              , 3 * closedWidth_
                              , self.frame.size.height )];
    [UIView commitAnimations];
    isOpen_ = YES;
}

/*!
 * close expanded button 
 */
- (void)close{
    isOpen_ = NO;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    [super setFrame:CGRectMake(self.frame.origin.x
                              , self.frame.origin.y
                              , closedWidth_
                              , self.frame.size.height )];
    [UIView commitAnimations];
}

/*!
 * select flash mode
 */
- (void) handleSelectFlashModeButtonTapped:(UIButton*) sender{
    [self close];
    if(flashMode_ == sender.tag)return;
    flashMode_ = sender.tag;
    [ud setInteger:flashMode_ forKey:@"flashMode"];
    [delegate_ setFlashMode:flashMode_];
    [self setText];
}

/*!
 * set frame
 */
- (void) setFrame:(CGRect)frame{
    if(isOpen_){
        [super setFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width*3, frame.size.height)];
    }else{
        [super setFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height)];        
    }
    flashImageView_.frame = CGRectMake(FLASHIMAGE_PADDING_X, FLASHIMAGE_PADDING_Y
                                       ,FLASHIMAGE_WIDTH, FLASHIMAGE_HEIGHT);
    offButton_.frame = CGRectMake(frame.size.width, 0, frame.size.width*2/3, frame.size.height);
    onButton_.frame = CGRectMake(frame.size.width + frame.size.width*2/3 - 1, 0, frame.size.width*2/3, frame.size.height);
    autoButton_.frame = CGRectMake(frame.size.width + frame.size.width*4/3 -1, 0, frame.size.width*2/3, frame.size.height);
    closedWidth_ = frame.size.width;
}

@end

@implementation FlashButton
@synthesize flashMode = flashMode_;
@synthesize delegate = delegate_;
@dynamic isOpen;

/*!
 * init
 */
- (id)init
{
    if([super init])
    {
        [self setupInitialState];
    }
    return self;
}

/*!
 * open/close button
 */
- (void)handleFlashModeButtonTapped:(UIButton *)sender{
    self.isOpen = !self.isOpen;
}

/*!
 * return button state of open/close
 */
- (BOOL)isOpen{
    return  isOpen_;  
}

/*!
 * set button state of open/close
 */
- (void)setIsOpen:(BOOL)isOpen
{
    if(isOpen == isOpen_)return;
    if(isOpen)
        [self open];
    else
        [self close];
}

@end
