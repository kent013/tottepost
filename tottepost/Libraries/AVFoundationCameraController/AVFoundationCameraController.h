//
//  AVFoundationCameraController.h
//  AVFoundationCameraController
//
//  Created by ISHITOYA Kentaro on 12/01/02.
//  Copyright (c) 2012 ISHITOYA Kentaro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "FlashButton.h"

@protocol AVFoundationCameraControllerDelegate;

@interface AVFoundationCameraController : UIViewController<UIGestureRecognizerDelegate,FlashButtonDelegate,UIAccelerometerDelegate>{
    __strong AVCaptureDevice *device_;
    __strong AVCaptureSession *session_;
    __strong AVCaptureStillImageOutput *imageOutput_;
    __strong AVCaptureDeviceInput *input_;
    __strong AVCaptureVideoPreviewLayer *previewLayer_;
    __strong CALayer *indicatorLayer_;
    __strong UIButton *shutterButton_;
    __strong FlashButton *flashModeButton_;
    __strong UIButton *cameraDeviceButton_;    
    __strong UIView *cameraControlView_;

    BOOL adjustingExposure_;
    BOOL showsCameraControls_;
    BOOL showsShutterButton_;
    BOOL showsFlashModeButton_;
    BOOL showsCameraDeviceButton_;
    BOOL useTapToFocus_;
    
    CGPoint pointOfInterest_;
    CGRect defaultBounds_;
    CGFloat lastPinchScale_;
    CGFloat scale_;
    CGRect croppedViewRect_;
    CGRect layerRect_;
    
    AVCaptureVideoOrientation videoOrientation_;
    UIDeviceOrientation viewOrientation_;
    UIDeviceOrientation deviceOrientation_;
}

@property(nonatomic, assign) id<AVFoundationCameraControllerDelegate> delegate;
@property(nonatomic, assign) BOOL showsCameraControls;
@property(nonatomic, assign) BOOL showsShutterButton;
@property(nonatomic, assign) BOOL showsFlashModeButton;
@property(nonatomic, assign) BOOL showsCameraDeviceButton;
@property(nonatomic, assign) BOOL useTapToFocus;
@property(nonatomic, readonly) BOOL hasMultipleCameraDevices;
@property(nonatomic, readonly) AVCaptureDevice *backCameraDevice;
@property(nonatomic, readonly) AVCaptureDevice *frontFacingCameraDevice;
@property(nonatomic, readonly) BOOL frontFacingCameraAvailable;
@property(nonatomic, readonly) BOOL backCameraAvailable;


- (id) initWithFrame:(CGRect)frame;
- (void) takePicture;
@end

@protocol AVFoundationCameraControllerDelegate <NSObject>
@optional
/*!
 * delegate with image and metadata
 */
- (void) cameraController:(AVFoundationCameraController *)cameraController didFinishPickingImage:(UIImage *)image;
/*!
 * delegate raw data and metadata
 */
- (void) cameraController:(AVFoundationCameraController *)cameraController didFinishPickingImageData:(NSData *)data;
- (void) cameraController:(AVFoundationCameraController *)cameraController didScaledTo:(CGFloat) scale viewRect:(CGRect)rect;
- (void) didRotatedDeviceOrientation:(UIDeviceOrientation) orientation;
@optional
- (void) cameraControllerDidInitialized:(AVFoundationCameraController *)cameraController;
@end