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
#import "PhotoSubmitterManager.h"
#import "PSLang.h"

//-----------------------------------------------------------------------------
//Private Implementations
//-----------------------------------------------------------------------------
@interface PreviewPhotoView(PrivateImplementation)
- (void) setupInitialState:(CGRect)frame;
- (void) updateCoordinates:(CGRect)frame;
- (void) didContentViewTapped:(id)sender;
- (void) didMoviePlayerViewTapped:(id)sender;
- (void) didMovieSliderValueChanged:(UISlider *)slider;
- (void) didMovieSliderTouchUp:(UISlider *)slider;
- (void) didMovieSliderTouchDown:(UISlider *)slider;
- (void) updateMovieTimeLabel;

- (void) applicationWillResignActive;
- (void) applicationDidEnterBackground;
- (void) applicationDidBecomeActive;
@end

@implementation PreviewPhotoView(PrivateImplementation)
- (void)setupInitialState:(CGRect)frame{    
    isApplicationActive_ = YES;
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(applicationWillResignActive)
     name:UIApplicationWillResignActiveNotification 
     object:NULL];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(applicationDidBecomeActive)
     name:UIApplicationDidBecomeActiveNotification 
     object:NULL];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(applicationDidEnterBackground)
     name:UIApplicationDidEnterBackgroundNotification 
     object:NULL];

    imageView_ = [[UIImageView alloc] initWithFrame:CGRectZero];
    
    commentBackgroundView_ = [[UIView alloc] initWithFrame:CGRectZero];
    commentBackgroundView_.backgroundColor = [UIColor colorWithWhite:0.8 alpha:0.6];
    [commentBackgroundView_.layer setCornerRadius:5.0];
    [commentBackgroundView_ setClipsToBounds:YES];
    [commentBackgroundView_.layer setBorderColor:[[UIColor colorWithWhite:0.8 alpha:0.8] CGColor]];
    [commentBackgroundView_.layer setBorderWidth:1.0];
    
    commentTextView_ = [[HPGrowingTextView alloc] initWithFrame:CGRectZero];
    
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

    movieOverlayView_ = [[UIView alloc] initWithFrame:CGRectZero];
    movieTimeLabel_ = [[UILabel alloc] initWithFrame:CGRectZero];
    movieSlider_ = [[UISlider alloc] initWithFrame:CGRectZero];
    movieSlider_.alpha = 0.9;
    [movieSlider_ addTarget:self action:@selector(didMovieSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [movieSlider_ addTarget:self action:@selector(didMovieSliderTouchDown:) forControlEvents:UIControlEventTouchDown];
    [movieSlider_ addTarget:self action:@selector(didMovieSliderTouchUp:) forControlEvents:UIControlEventTouchUpInside];
    [movieSlider_ addTarget:self action:@selector(didMovieSliderTouchUp:) forControlEvents:UIControlEventTouchUpOutside];
    
    movieTimeLabel_.text = @"00:00";
    movieTimeLabel_.font = [UIFont systemFontOfSize:12.0];
    movieTimeLabel_.textColor = [UIColor whiteColor];
    movieTimeLabel_.backgroundColor = [UIColor clearColor];
    [movieOverlayView_ addSubview:movieTimeLabel_];    
    [movieOverlayView_ addSubview:movieSlider_];
    
    [commentBackgroundView_ addSubview: commentTextView_];
    [commentBackgroundView_ addSubview:textCountview_];
    [self addSubview:imageView_];
    [self addSubview:commentBackgroundView_];
    [self updateCoordinates:frame];
    
    UITapGestureRecognizer *recognizer1 = [[UITapGestureRecognizer alloc] init];
    [recognizer1 addTarget:self action:@selector(didContentViewTapped:)];
    recognizer1.numberOfTapsRequired = 1;
    [self addGestureRecognizer:recognizer1];
    
    UITapGestureRecognizer *recognizer2 = [[UITapGestureRecognizer alloc] init];
    [recognizer2 addTarget:self action:@selector(didMoviePlayerViewTapped:)];
    recognizer2.numberOfTapsRequired = 1;
    [movieOverlayView_ addGestureRecognizer:recognizer2];
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
        textCountview_.frame = CGRectMake(MAINVIEW_COMMENT_VIEW_WIDTH_FOR_IPAD - 165, MAINVIEW_COMMENT_VIEW_HEIGHT_FOR_IPAD-30, 160, 30);
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
        NSString *text = @"000 / 000"; 
        CGSize size = [text sizeWithFont:textCountview_.font];
        textCountview_.frame = CGRectMake(MAINVIEW_COMMENT_VIEW_WIDTH_FOR_IPHONE - size.width - 3, MAINVIEW_COMMENT_VIEW_HEIGHT_FOR_IPHONE - size.height, size.width, size.height);
    }
    movieOverlayView_.frame = imageView_.frame;
    CGSize s = [@"00:00" sizeWithFont:movieTimeLabel_.font];
    movieSlider_.frame = CGRectMake(movieOverlayView_.frame.size.width / 4 + s.width + 3, 10, movieOverlayView_.frame.size.width / 2 - s.width - 3, 20);
    movieTimeLabel_.frame = CGRectMake(movieOverlayView_.frame.size.width / 4, movieSlider_.frame.origin.y + 3, s.width, s.height);
}

/*!
 * did image view tapped
 */
- (void) didContentViewTapped:(id)sender{
	[commentTextView_ resignFirstResponder];   
}

/*!
 * did movie player view tapped
 */
- (void) didMoviePlayerViewTapped:(id)sender{
	[commentTextView_ resignFirstResponder];
    if(moviePlayerView_.moviePlayer.playbackState == MPMoviePlaybackStatePlaying){
        [moviePlayerView_.moviePlayer pause];
    }else{
        [moviePlayerView_.moviePlayer play];
    }
    [self onMovieTimer];
}

/*!
 * on timer
 */
- (void)onMovieTimer{
    if(isMovieSeeking_){
        return;
    }
    CGFloat value = moviePlayerView_.moviePlayer.currentPlaybackTime / moviePlayerView_.moviePlayer.playableDuration;
    if(value > 1.0 || value < 0 || isnan(value)){
        value = 0;
    }
    movieSlider_.value = value;
    [self updateMovieTimeLabel];
}

/*!
 * update movie time label
 */
- (void)updateMovieTimeLabel{
    int minute = moviePlayerView_.moviePlayer.currentPlaybackTime / 60;
    int sec = (int)(moviePlayerView_.moviePlayer.currentPlaybackTime) % 60;
    if(minute >= 0 && minute < 60 && sec >= 0 && sec < 60){
        movieTimeLabel_.text = [NSString stringWithFormat:@"%02d:%02d", minute, sec];
    }else{  
        movieTimeLabel_.text = @"00:00";
    }
}

/*!
 * on slider changed
 */
- (void)didMovieSliderValueChanged:(UISlider *)slider{    moviePlayerView_.moviePlayer.currentPlaybackTime = moviePlayerView_.moviePlayer.playableDuration * slider.value;
    [self updateMovieTimeLabel];
}

/*!
 * slider touch down
 */
- (void)didMovieSliderTouchDown:(UISlider *)slider{
    [moviePlayerView_.moviePlayer pause];   
    //[moviePlayerView_.moviePlayer beginSeekingForward];
    isMovieSeeking_ = YES;
}

/*!
 * slider touch up
 */
- (void)didMovieSliderTouchUp:(UISlider *)slider{
    isMovieSeeking_ = NO;
    //[moviePlayerView_.moviePlayer endSeeking];
    [moviePlayerView_.moviePlayer play];    
}


/*!
 * application will resign active
 */
- (void)applicationWillResignActive{
    isApplicationActive_ = NO;
    if(content_.isVideo){
        [moviePlayerView_.moviePlayer pause];
    }
}

/*!
 * application did enter background
 */
- (void)applicationDidEnterBackground{
    isApplicationActive_ = NO;
    if(content_.isVideo){
        [moviePlayerView_.moviePlayer pause];
    }
}

/*!
 * application did become active
 */
- (void)applicationDidBecomeActive{
    isApplicationActive_ = YES;
}
@end

//-----------------------------------------------------------------------------
//Public Implementations
//----------------------------------------------------------------------------
@implementation PreviewPhotoView
@synthesize delegate;
@synthesize content = content_;
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
- (void)presentWithContent:(PhotoSubmitterContentEntity *)content {
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    [self presentWithContent:content videoOrientation:orientation];
}

/*!
 * show view
 */
- (void) presentWithContent:(PhotoSubmitterContentEntity *)content videoOrientation:(UIDeviceOrientation) orientation{
    commentTextView_.text = @"";
    
    int max = [PhotoSubmitterManager sharedInstance].maxCommentLength;
    if(max){
        textCountview_.text = [NSString stringWithFormat:@"%d/%d",commentTextView_.text.length, max];    
    }else{
        textCountview_.text = [NSString stringWithFormat:@"%d",commentTextView_.text.length];
    }
    
    content_ = content;
    
    [imageView_ removeFromSuperview];
    [moviePlayerView_.view removeFromSuperview];
    [commentBackgroundView_ removeFromSuperview];
    [movieOverlayView_ removeFromSuperview];
    [movieTimer_ invalidate];
    
    if(content.isPhoto){
        PhotoSubmitterImageEntity *photo = (PhotoSubmitterImageEntity *)content;
        UIImage *image = photo.image.fixOrientation;
        if(orientation == UIDeviceOrientationLandscapeLeft){
            image = [image UIImageRotateByAngle:270];                
        }else if(orientation == UIDeviceOrientationLandscapeRight){
            image = [image UIImageRotateByAngle:90];                 
        }
        imageView_.image = image.fixOrientation;
        [self addSubview:imageView_];      
    }else if(content.isVideo){
        PhotoSubmitterVideoEntity *video = (PhotoSubmitterVideoEntity *)content;
        moviePlayerView_ = [[MPMoviePlayerViewController alloc] initWithContentURL:video.url];
        moviePlayerView_.moviePlayer.controlStyle = MPMovieControlStyleNone;
        //moviePlayerView_.moviePlayer.controlStyle = MPMovieControlStyleFullscreen;
        moviePlayerView_.moviePlayer.scalingMode = MPMovieScalingModeAspectFit;
        //[moviePlayerView_.moviePlayer setFullscreen:YES];
        //moviePlayerView_.view.frame = frame;
        [self addSubview:moviePlayerView_.view];
        if(isApplicationActive_){
            [moviePlayerView_.moviePlayer play];
        }else{
            [moviePlayerView_.moviePlayer pause];
        }
        CGRect frame = moviePlayerView_.view.frame;
        frame.origin.y = -40;
        moviePlayerView_.view.frame = frame;
        [self addSubview:movieOverlayView_];
        
        movieTimer_ = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(onMovieTimer) userInfo:nil repeats:YES];
        [movieTimer_ fire];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil]; 
    [self addSubview:commentBackgroundView_];
}

/*!
 * hide view
 */
- (BOOL)dismiss:(BOOL)force{
    [movieTimer_ invalidate];
    [moviePlayerView_.moviePlayer stop];
    [moviePlayerView_.view removeFromSuperview];
    [self removeFromSuperview];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];

    if(force == NO){
        int max = [PhotoSubmitterManager sharedInstance].maxCommentLength;
        if(max && commentTextView_.text.length > max){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[PSLang localized:@"Alert_Error"] 
                                                            message:[PSLang localized:@"Alert_Comment_Too_Long"]
                                                           delegate:nil 
                                                  cancelButtonTitle:@"OK" 
                                                  otherButtonTitles:nil];
            [alert show]; 
            return NO;
        }
        if(commentTextView_.text != nil && [commentTextView_.text isEqualToString:@""] == false){
            content_.comment = commentTextView_.text;
        }
    }
    return YES;
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
    int max = [PhotoSubmitterManager sharedInstance].maxCommentLength;
    if(max){
        textCountview_.text = [NSString stringWithFormat:@"%d/%d",commentTextView_.text.length, max];    
    }else{
        textCountview_.text = [NSString stringWithFormat:@"%d",commentTextView_.text.length];
    }
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
    NSString *text = @"000 / 000"; 
    CGSize size = [text sizeWithFont:textCountview_.font];
    textCountview_.frame = CGRectMake(r.size.width - size.width -3, height -size.height, size.width, size.height);
    [UIView commitAnimations];
}

@end
