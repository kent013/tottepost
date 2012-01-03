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
    
    //comment text view
    commentTextView_ = [[UITextView alloc] initWithFrame:CGRectZero];
    commentTextView_.backgroundColor = [UIColor clearColor];
    commentTextView_.delegate = self;
    commentTextView_.returnKeyType = UIReturnKeyDone;
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        commentTextView_.font = [UIFont systemFontOfSize:18];
    
    textCountview_ = [[UILabel alloc] initWithFrame:CGRectZero];
    textCountview_.backgroundColor = [UIColor clearColor];
    textCountview_.textColor = [UIColor colorWithWhite:0.1 alpha:0.6];
    textCountview_.textAlignment = UITextAlignmentRight;
    textCountview_.text = [NSString stringWithFormat:@"%d",commentTextView_.text.length];
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        textCountview_.font = [UIFont systemFontOfSize:22];
    else
        textCountview_.font = [UIFont systemFontOfSize:16];
    
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
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        frame.origin.y = self.frame.size.height - MAINVIEW_TOOLBAR_HEIGHT - MAINVIEW_COMMENT_VIEW_HEIGHT_FOR_IPAD - MAINVIEW_PADDING_Y;
    else
        frame.origin.y = self.frame.size.height - MAINVIEW_TOOLBAR_HEIGHT - MAINVIEW_COMMENT_VIEW_HEIGHT_FOR_IPHONE - MAINVIEW_PADDING_Y;        
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
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        imageView_.frame = frame;
        commentBackgroundView_.frame = CGRectMake((frame.size.width - MAINVIEW_COMMENT_VIEW_WIDTH_FOR_IPAD) / 2, frame.size.height - MAINVIEW_TOOLBAR_HEIGHT - MAINVIEW_COMMENT_VIEW_HEIGHT_FOR_IPAD - MAINVIEW_PADDING_Y, MAINVIEW_COMMENT_VIEW_WIDTH_FOR_IPAD, MAINVIEW_COMMENT_VIEW_HEIGHT_FOR_IPAD);
        commentTextView_.frame = CGRectMake(5, 10, MAINVIEW_COMMENT_VIEW_WIDTH_FOR_IPAD - 10, MAINVIEW_COMMENT_VIEW_HEIGHT_FOR_IPAD - 20);
        textCountview_.frame = CGRectMake(MAINVIEW_COMMENT_VIEW_WIDTH_FOR_IPAD - 85, MAINVIEW_COMMENT_VIEW_HEIGHT_FOR_IPAD-30, 80, 30);
    }
    else
    {
        imageView_.frame = CGRectMake(0, 0, frame.size.width, frame.size.height - MAINVIEW_TOOLBAR_HEIGHT);
        commentBackgroundView_.frame = CGRectMake((frame.size.width - MAINVIEW_COMMENT_VIEW_WIDTH_FOR_IPHOEN) / 2, frame.size.height - MAINVIEW_TOOLBAR_HEIGHT - MAINVIEW_COMMENT_VIEW_HEIGHT_FOR_IPHONE - MAINVIEW_PADDING_Y, MAINVIEW_COMMENT_VIEW_WIDTH_FOR_IPHOEN, MAINVIEW_COMMENT_VIEW_HEIGHT_FOR_IPHONE);
        commentTextView_.frame = CGRectMake(5, 10, MAINVIEW_COMMENT_VIEW_WIDTH_FOR_IPHOEN - 10, MAINVIEW_COMMENT_VIEW_HEIGHT_FOR_IPHONE - 20);
        textCountview_.frame = CGRectMake(MAINVIEW_COMMENT_VIEW_WIDTH_FOR_IPHOEN - 53, MAINVIEW_COMMENT_VIEW_HEIGHT_FOR_IPHONE -20, 50, 20);
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
- (void)presentWithPhoto:(UIImage *)photo{
    commentTextView_.text = @"";
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        photo_ = photo.UIImageAutoRotated;
        if(photo.imageOrientation != UIImageOrientationRight)
            imageView_.image = [photo UIImageRotateByAngle:270];
        else
            imageView_.image = photo;
    }
    else
    {
        photo_ = photo.UIImageAutoRotated;
        imageView_.image = photo_;
    }
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

#pragma mark -
#pragma mark textView delegate

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
 * did changed text in textView
 */
- (void)textViewDidChange:(UITextView *)textView
{
    textCountview_.text = [NSString stringWithFormat:@"%d",commentTextView_.text.length];
}
@end
