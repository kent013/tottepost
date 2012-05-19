//
//  FlashButton.h
//  tottepost
//
//  Created by Ken Watanabe on 12/01/25.
//  Copyright (c) 2012 Ken Watanabe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@protocol FlashButtonDelegate;

@interface AVFoundationFlashButton : UIButton{
    __strong UILabel* label;
    __strong UIImageView* flashImageView_;
    __strong UIButton* onButton_;
    __strong UIButton* offButton_;
    __strong UIButton* autoButton_;
    __strong NSUserDefaults* ud;
    __weak id<FlashButtonDelegate> delegate_;

    int closedWidth_;
    AVCaptureFlashMode flashMode_;
    BOOL isOpen_;
}
@property (weak, nonatomic) id<FlashButtonDelegate> delegate;
@property (assign, readonly) AVCaptureFlashMode flashMode;
@property (assign) BOOL isOpen;

@end

@protocol FlashButtonDelegate <NSObject>
- (void) setFlashMode:(AVCaptureFlashMode)mode;
@end

