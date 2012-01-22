//
//  PreviewPhotoView.h
//  tottepost
//
//  Created by ISHITOYA Kentaro on 11/12/22.
//  Copyright (c) 2011 cocotomo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoSubmitterImageEntity.h"

@protocol PreviewPhotoViewDelegate;

@interface PreviewPhotoView : UIView<UITextViewDelegate>{
    __strong UITextView *commentTextView_;
    __strong UIView *commentBackgroundView_;
    __strong UILabel* textCountview_;
    __strong UIImageView *imageView_;
    __strong PhotoSubmitterImageEntity *photo_;
    __weak id<PreviewPhotoViewDelegate> delegate_;
}
@property (weak, nonatomic) id<PreviewPhotoViewDelegate> delegate;
@property (readonly, nonatomic) PhotoSubmitterImageEntity *photo;

- (void) updateWithFrame:(CGRect)frame;
- (void) presentWithPhoto:(PhotoSubmitterImageEntity *)photo;
- (void) dissmiss;
@end

@protocol PreviewPhotoViewDelegate <NSObject>
- (UIInterfaceOrientation) requestForOrientation;
@end
