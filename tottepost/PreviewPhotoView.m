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
    
    //comment text view
    commentTextView_ = [[UITextView alloc] initWithFrame:CGRectZero];
    commentTextView_.backgroundColor = [UIColor clearColor];
    commentTextView_.delegate = self;
    commentTextView_.returnKeyType = UIReturnKeyDone;
    
    [commentBackgroundView_ addSubview: commentTextView_];
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
    CGRect tKeyboardRect = [[[aNotification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    tKeyboardRect = [self convertRect:tKeyboardRect fromView:nil];
    
    NSTimeInterval animationDuration = [[[aNotification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    CGRect frame = commentBackgroundView_.frame;
    frame.origin.y = tKeyboardRect.origin.y - commentBackgroundView_.frame.size.height - MAINVIEW_PADDING_Y;
    
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    commentBackgroundView_.frame = frame;
    [UIView commitAnimations];
}

/*!
 * keyboard hidden
 */
- (void)keyboardWillHide:(NSNotification *)aNotification {
    NSTimeInterval animationDuration = [[[aNotification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGRect frame = commentBackgroundView_.frame;    
    frame.origin.y = self.frame.size.height - MAINVIEW_TOOLBAR_HEIGHT - MAINVIEW_COMMENT_VIEW_HEIGHT - MAINVIEW_PADDING_Y;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    commentBackgroundView_.frame = frame;
    [UIView commitAnimations];
}

/*!
 * update coordinates
 */
- (void)updateCoordinates:(CGRect)frame{
    self.frame = frame;
    frame.origin.x = 0;
    frame.origin.y = 0;
    imageView_.frame = frame;
    
    commentBackgroundView_.frame = CGRectMake((frame.size.width - MAINVIEW_COMMENT_VIEW_WIDTH) / 2, frame.size.height - MAINVIEW_TOOLBAR_HEIGHT - MAINVIEW_COMMENT_VIEW_HEIGHT - MAINVIEW_PADDING_Y, MAINVIEW_COMMENT_VIEW_WIDTH, MAINVIEW_COMMENT_VIEW_HEIGHT);
    commentTextView_.frame = CGRectMake(5, 10, MAINVIEW_COMMENT_VIEW_WIDTH - 10, MAINVIEW_COMMENT_VIEW_HEIGHT - 20);
    
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
- (void)presentWithPhoto:(UIImage *)photo{
    commentTextView_.text = @"";
    imageView_.image = photo;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];   
}

/*!
 * hide view
 */
- (void)dissmiss{
    [self removeFromSuperview];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

/*!
 * comment
 */
- (NSString *)comment{
    NSString *comment = nil;
    if(commentTextView_.text != nil && [commentTextView_.text isEqualToString:@""] == false){
        comment = commentTextView_.text;
    }
    return comment;
}

/*!
 * text field delegate
 */
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
	
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
	return YES;
}


/*!
 * photo
 */
- (UIImage *)photo{
    return imageView_.image;
}
@end
