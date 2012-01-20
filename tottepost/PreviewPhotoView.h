//
//  PreviewPhotoView.h
//  tottepost
//
//  Created by ISHITOYA Kentaro on 11/12/22.
//  Copyright (c) 2011 cocotomo. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PreviewPhotoViewDelegate;

@interface PreviewPhotoView : UIView<UITextViewDelegate>{
    __strong UITextView *commentTextView_;
    __strong UIView *commentBackgroundView_;
    __strong UILabel* textCountview_;
    __strong UIImageView *imageView_;
    __strong UIImage *photo_;
    __weak id<PreviewPhotoViewDelegate> delegate_;
}
@property (weak, nonatomic) id<PreviewPhotoViewDelegate> delegate;
@property (readonly, nonatomic) NSString *comment;
@property (readonly, nonatomic) UIImage *photo;

- (void) updateWithFrame:(CGRect)frame;
- (void) presentWithPhoto:(UIImage *)photo;
- (void) dissmiss;
@end

@protocol PreviewPhotoViewDelegate <NSObject>
- (UIInterfaceOrientation) requestForOrientation;
@end
