//
//  PreviewPhotoView.m
//  tottepost
//
//  Created by ISHITOYA Kentaro on 11/12/22.
//  Copyright (c) 2011 cocotomo. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "PreviewPhotoView.h"
#import "MainViewControllerConstants.h"
#import "UIImage+AutoRotation.h"

//-----------------------------------------------------------------------------
//Private Implementations
//-----------------------------------------------------------------------------
@interface PreviewPhotoView(PrivateImplementation)
- (void) setupInitialState:(CGRect)frame;
- (void) updateCoordinates:(CGRect)frame;
- (void) didImageViewTapped:(id)sender;
@end

@implementation PreviewPhotoView(PrivateImplementation)
- (void)setupInitialState:(CGRect)frame{
    imageView_ = [[UIImageView alloc] initWithFrame:CGRectZero];
    commentBackgroundView_ = [[UIView alloc] initWithFrame:CGRectZero];
    commentBackgroundView_.backgroundColor = [UIColor colorWithWhite:0.8 alpha:0.6];
    [commentBackgroundView_.layer setCornerRadius:5.0];
    [commentBackgroundView_ setClipsToBounds:YES];
    [commentBackgroundView_.layer setBorderColor:[[UIColor colorWithWhite:0.8 alpha:0.8] CGColor]];
    [commentBackgroundView_.layer setBorderWidth:1.0];
    
    commentTextView_ = [[HPGrowingTextView alloc] initWithFrame:CGRectZero];
//    commentTextView_.contentInset = UIEdgeInsetsMake(0, 5, 0, 5);
    
	commentTextView_.minNumberOfLines = 2;
	commentTextView_.maxNumberOfLines = 9;
	commentTextView_.returnKeyType = UIReturnKeyDone;
	commentTextView_.delegate = self;
    commentTextView_.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 5, 5, 5);
    commentTextView_.internalTextView.backgroundColor = [UIColor clearColor];
    commentTextView_.backgroundColor = [UIColor clearColor];

    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        commentTextView_.font = [UIFont systemFontOfSize:18];
    }
    
    textCountview_ = [[UILabel alloc] initWithFrame:CGRectZero];
    textCountview_.backgroundColor = [UIColor clearColor];
    textCountview_.textColor = [UIColor colorWithWhite:0.1 alpha:0.8];
    textCountview_.textAlignment = UITextAlignmentRight;
    textCountview_.text = [NSString stringWithFormat:@"%d",commentTextView_.text.length];
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        textCountview_.font = [UIFont systemFontOfSize:22];
    }else{
        textCountview_.font = [UIFont systemFontOfSize:16];
    }
    
    [commentBackgroundView_ addSubview: commentTextView_];
    [commentBackgroundView_ addSubview:textCountview_];
    [self addSubview:imageView_];
    [self addSubview:commentBackgroundView_];
    [self updateCoordinates:frame];
    
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] init];
    [recognizer addTarget:self action:@selector(didImageViewTapped:)];
    recognizer.numberOfTapsRequired = 1;
    [imageView_ addGestureRecognizer:recognizer];
    
}

#pragma mark -
#pragma mark keyboard delegate
/*!
 * keyboard shown
 */
- (void)keyboardWillShow:(NSNotification *)aNotification {
    isKeyboardPresented_ = YES;
    commentBackgroundView_.backgroundColor = [UIColor colorWithWhite:0.95 alpha:0.9];
    CGRect tKeyboardRect = [[[aNotification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    tKeyboardRect = [self convertRect:tKeyboardRect fromView:nil];
    
    NSTimeInterval animationDuration = [[[aNotification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    CGRect frame = commentBackgroundView_.frame;
    frame.origin.y = tKeyboardRect.origin.y - commentBackgroundView_.frame.size.height - MAINVIEW_PADDING_Y;
    
    keyboardRect_ = tKeyboardRect;
    
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    commentBackgroundView_.frame = frame;
    [UIView commitAnimations];
}

/*!
 * keyboard hidden
 */
- (void)keyboardWillHide:(NSNotification *)aNotification {
    commentBackgroundView_.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.4];    
    NSTimeInterval animationDuration = [[[aNotification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGRect frame = commentBackgroundView_.frame;
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        frame.origin.y = self.frame.size.height - MAINVIEW_TOOLBAR_HEIGHT - frame.size.height - MAINVIEW_PADDING_Y;
    }else{
        frame.origin.y = self.frame.size.height - MAINVIEW_TOOLBAR_HEIGHT - frame.size.height - MAINVIEW_PADDING_Y;        
    }
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    commentBackgroundView_.frame = frame;
    [UIView commitAnimations];
    isKeyboardPresented_ = NO;
}

/*!
 * update coordinates
 */
- (void)updateCoordinates:(CGRect)frame{
    self.frame = frame;
    frame.origin.x = 0;
    frame.origin.y = 0;
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        imageView_.frame = frame;
        commentBackgroundView_.frame = CGRectMake((frame.size.width - MAINVIEW_COMMENT_VIEW_WIDTH_FOR_IPAD) / 2, frame.size.height - MAINVIEW_TOOLBAR_HEIGHT - MAINVIEW_COMMENT_VIEW_HEIGHT_FOR_IPAD - MAINVIEW_PADDING_Y, MAINVIEW_COMMENT_VIEW_WIDTH_FOR_IPAD, MAINVIEW_COMMENT_VIEW_HEIGHT_FOR_IPAD);
        commentTextView_.frame = CGRectMake(0, 0, MAINVIEW_COMMENT_VIEW_WIDTH_FOR_IPAD, MAINVIEW_COMMENT_VIEW_HEIGHT_FOR_IPAD);
        textCountview_.frame = CGRectMake(MAINVIEW_COMMENT_VIEW_WIDTH_FOR_IPAD - 85, MAINVIEW_COMMENT_VIEW_HEIGHT_FOR_IPAD-30, 80, 30);
    }
    else
    {
        imageView_.frame = CGRectMake(-20, 0, frame.size.width + 40, frame.size.height);
        
        int commentY = 0;
        if(isKeyboardPresented_){
            commentY = keyboardRect_.origin.y - commentBackgroundView_.frame.size.height - MAINVIEW_PADDING_Y;

        }else{
            commentY = frame.size.height - MAINVIEW_TOOLBAR_HEIGHT - MAINVIEW_COMMENT_VIEW_HEIGHT_FOR_IPHONE - MAINVIEW_PADDING_Y;
        }
        commentBackgroundView_.frame = CGRectMake((frame.size.width - MAINVIEW_COMMENT_VIEW_WIDTH_FOR_IPHONE) / 2, commentY, MAINVIEW_COMMENT_VIEW_WIDTH_FOR_IPHONE, MAINVIEW_COMMENT_VIEW_HEIGHT_FOR_IPHONE);
        commentTextView_.frame = CGRectMake(0, 0, MAINVIEW_COMMENT_VIEW_WIDTH_FOR_IPHONE, MAINVIEW_COMMENT_VIEW_HEIGHT_FOR_IPHONE);
        NSString *text = @"000"; 
        CGSize size = [text sizeWithFont:textCountview_.font];
        textCountview_.frame = CGRectMake(MAINVIEW_COMMENT_VIEW_WIDTH_FOR_IPHONE - size.width - 3, MAINVIEW_COMMENT_VIEW_HEIGHT_FOR_IPHONE - size.height, size.width, size.height);
    }
}

/*!
 * did image view tapped
 */
- (void) didImageViewTapped:(id)sender{
	[commentTextView_ resignFirstResponder];   
}

@end

//-----------------------------------------------------------------------------
//Public Implementations
//----------------------------------------------------------------------------
@implementation PreviewPhotoView
@synthesize delegate;
@synthesize photo = photo_;
/*!
 * initialize
 */
-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        [self setupInitialState:frame];
    }
    return self;
}

/*!
 * update coordinate
 */
-(void)updateWithFrame:(CGRect)frame{
    [self updateCoordinates:frame];
}

/*!
 * show view
 */
- (void)presentWithPhoto:(PhotoSubmitterImageEntity *)photo {
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    [self presentWithPhoto:photo videoOrientation:orientation];
}

/*!
 * show view
 */
- (void) presentWithPhoto:(PhotoSubmitterImageEntity *)photo videoOrientation:(UIDeviceOrientation) orientation{
    commentTextView_.text = @"";
    textCountview_.text = [NSString stringWithFormat:@"%d",commentTextView_.text.length];
    
    photo_ = photo;
    
    UIImage *image = photo.image.fixOrientation;
    if(orientation == UIDeviceOrientationLandscapeLeft){
        image = [image UIImageRotateByAngle:270];                
    }else if(orientation == UIDeviceOrientationLandscapeRight){
        image = [image UIImageRotateByAngle:90];                 
    }
    imageView_.image = image.fixOrientation;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];       
}

/*!
 * hide view
 */
- (void)dissmiss{
    if(commentTextView_.text != nil && [commentTextView_.text isEqualToString:@""] == false){
        photo_.comment = commentTextView_.text;
    }
    [self removeFromSuperview];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark -
#pragma mark textView delegate

/*!
 * text field delegate
 */
- (BOOL)growingTextView:(HPGrowingTextView *)growingTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]) {
        [growingTextView resignFirstResponder];
        return NO;
    }
	return YES;
}

/*!
 * did changed text in textView
 */
- (void)growingTextViewDidChange:(HPGrowingTextView *)growingTextView{
    textCountview_.text = [NSString stringWithFormat:@"%d",commentTextView_.text.length];    
}

/*!
 * did changed height in textView
 */
- (void)growingTextView:(HPGrowingTextView *)growingTextView didChangeHeight:(float)height{
    int dh =  height - commentBackgroundView_.frame.size.height;
    if (dh == 0){
        return;
    }
    CGRect r = commentBackgroundView_.frame;

    [UIView beginAnimations:@"ResizeHeight" context:nil];
    commentBackgroundView_.frame = CGRectMake(r.origin.x, r.origin.y - dh, r.size.width,height);
    NSString *text = @"000"; 
    CGSize size = [text sizeWithFont:textCountview_.font];
    textCountview_.frame = CGRectMake(r.size.width - size.width -3, height -size.height, size.width, size.height);
    [UIView commitAnimations];
}

@end
