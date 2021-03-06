//
//  PreviewPhotoView.h
//  tottepost
//
//  Created by ISHITOYA Kentaro on 11/12/22.
//  Copyright (c) 2011 cocotomo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "ENGPhotoSubmitterImageEntity.h"
#import "HPGrowingTextView.h"

@protocol PreviewPhotoViewDelegate;

@interface PreviewPhotoView : UIView<HPGrowingTextViewDelegate>{
    __strong HPGrowingTextView *commentTextView_;
    __strong UIView *commentBackgroundView_;
    __strong UILabel* textCountview_;
    __strong UIImageView *imageView_;
    
    __strong MPMoviePlayerViewController *moviePlayerView_;
    __strong UIView *movieOverlayView_;
    __strong UILabel *movieTimeLabel_;
    __strong UISlider *movieSlider_;
    __strong NSTimer *movieTimer_;
    BOOL isMovieSeeking_;
    
    __strong ENGPhotoSubmitterContentEntity *content_;
    __weak id<PreviewPhotoViewDelegate> delegate_;
    BOOL isKeyboardPresented_;
    BOOL isApplicationActive_;
    CGRect keyboardRect_;
    CGFloat lastMovieSliderValue_;
}
@property (weak, nonatomic) id<PreviewPhotoViewDelegate> delegate;
@property (readonly, nonatomic) ENGPhotoSubmitterContentEntity *content;

- (void) updateWithFrame:(CGRect)frame;
- (void) presentWithContent:(ENGPhotoSubmitterContentEntity *)content;
- (void) presentWithContent:(ENGPhotoSubmitterContentEntity *)content videoOrientation:(UIDeviceOrientation) orientation;
- (BOOL) dismiss:(BOOL)force;
@end

@protocol PreviewPhotoViewDelegate <NSObject>
- (UIDeviceOrientation) requestForOrientation;
@end
