//
//  PreviewPhotoView.h
//  tottepost
//
//  Created by ISHITOYA Kentaro on 11/12/22.
//  Copyright (c) 2011 cocotomo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoSubmitterImageEntity.h"
#import "HPGrowingTextView.h"

@protocol PreviewPhotoViewDelegate;

@interface PreviewPhotoView : UIView<HPGrowingTextViewDelegate>{
    __strong HPGrowingTextView *commentTextView_;
    __strong UIView *commentBackgroundView_;
    __strong UILabel* textCountview_;
    __strong UIImageView *imageView_;
    __strong PhotoSubmitterImageEntity *photo_;
    __weak id<PreviewPhotoViewDelegate> delegate_;
    BOOL isKeyboardPresented_;
    CGRect keyboardRect_;
}
@property (weak, nonatomic) id<PreviewPhotoViewDelegate> delegate;
@property (readonly, nonatomic) PhotoSubmitterImageEntity *photo;

- (void) updateWithFrame:(CGRect)frame;
- (void) presentWithPhoto:(PhotoSubmitterImageEntity *)photo;
- (void) presentWithPhoto:(PhotoSubmitterImageEntity *)photo videoOrientation:(UIDeviceOrientation) orientation;
- (BOOL) dismiss:(BOOL)force;
@end

@protocol PreviewPhotoViewDelegate <NSObject>
- (UIDeviceOrientation) requestForOrientation;
@end
