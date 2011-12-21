//
//  PreviewPhotoView.h
//  tottepost
//
//  Created by ISHITOYA Kentaro on 11/12/22.
//  Copyright (c) 2011 cocotomo. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PreviewPhotoViewDelegate;

@interface PreviewPhotoView : UIView{
    __strong UITextView *commentTextView_;
    __strong UIView *commentBackgroundView_;
    __strong UIImageView *imageView_;
}
@property (weak, nonatomic) id<PreviewPhotoViewDelegate> delegate;
@property (readonly, nonatomic) NSString *comment;
@property (readonly, nonatomic) UIImage *photo;

- (void) updateWithFrame:(CGRect)frame;
- (void) presentWithPhoto:(UIImage *)photo;
- (void) dissmiss;
@end
