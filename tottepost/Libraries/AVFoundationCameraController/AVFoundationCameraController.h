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

typedef enum {
    AVFoundationCameraModeVideo,
    AVFoundationCameraModePhoto
} AVFoundationCameraMode;

@protocol AVFoundationCameraControllerDelegate;

@interface AVFoundationCameraController : UIViewController<UIGestureRecognizerDelegate,AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureFileOutputRecordingDelegate, FlashButtonDelegate,UIAccelerometerDelegate>{
    __strong AVCaptureDevice *device_;
    __strong AVCaptureSession *session_;
    __strong AVCaptureStillImageOutput *imageOutput_;
    __strong AVCaptureDeviceInput *imageInput_;
    __strong AVCaptureDeviceInput *audioInput_;
    __strong AVCaptureDeviceInput *videoInput_;
    __strong AVCaptureVideoPreviewLayer *previewLayer_;
    __strong AVCaptureMovieFileOutput *movieFileOutput_;
    __strong CALayer *indicatorLayer_;
    __strong UIButton *shutterButton_;
    __strong FlashButton *flashModeButton_;
    __strong UIButton *cameraDeviceButton_;    
    __strong UIView *cameraControlView_;
    
    __strong UILabel *videoElapsedTimeLabel_;
    __strong NSTimer *videoElapsedTimer_;

    BOOL adjustingExposure_;
    BOOL showsCameraControls_;
    BOOL showsShutterButton_;
    BOOL showsFlashModeButton_;
    BOOL showsCameraDeviceButton_;
    BOOL showsVideoElapsedTimeLabel_;
    BOOL showsIndicator_;
    BOOL useTapToFocus_;
    
    NSDate *videoRecordingStartedDate_;
    
    AVFoundationCameraMode mode_;
    
    CGPoint pointOfInterest_;
    CGRect defaultBounds_;
    CGFloat lastPinchScale_;
    CGFloat scale_;
    CGRect croppedViewRect_;
    CGRect layerRect_;
    
    AVCaptureVideoOrientation videoOrientation_;
    UIDeviceOrientation viewOrientation_;
    UIDeviceOrientation deviceOrientation_;
    UIBackgroundTaskIdentifier backgroundRecordingId_;
}

@property(nonatomic, assign) id<AVFoundationCameraControllerDelegate> delegate;
@property(nonatomic, assign) BOOL showsCameraControls;
@property(nonatomic, assign) BOOL showsShutterButton;
@property(nonatomic, assign) BOOL showsFlashModeButton;
@property(nonatomic, assign) BOOL showsCameraDeviceButton;
@property(nonatomic, assign) BOOL showsIndicator;
@property(nonatomic, assign) BOOL showsVideoElapsedTimeLabel;
@property(nonatomic, assign) BOOL useTapToFocus;
@property(nonatomic, assign) AVFoundationCameraMode mode;
@property(nonatomic, readonly) BOOL hasMultipleCameraDevices;
@property(nonatomic, readonly) AVCaptureDevice *backCameraDevice;
@property(nonatomic, readonly) AVCaptureDevice *frontFacingCameraDevice;
@property(nonatomic, readonly) AVCaptureDevice *audioDevice;
@property(nonatomic, readonly) BOOL frontFacingCameraAvailable;
@property(nonatomic, readonly) BOOL backCameraAvailable;
@property(nonatomic, readonly) BOOL isRecordingVideo;


- (id) initWithFrame:(CGRect)frame andMode:(AVFoundationCameraMode) mode;
- (void) takePicture;
- (void) startRecordingVideo;
- (void) stopRecordingVideo;
@end

@protocol AVFoundationCameraControllerDelegate <NSObject>
@optional
/*!
 * delegate with image and metadata
 */
- (void) cameraController:(AVFoundationCameraController *)cameraController didFinishPickingImage:(UIImage *)image;
/*!
 * capture video
 */
-(void) cameraControllerDidStartRecordingVideo:(AVFoundationCameraController *) controller;
-(void) cameraController:(AVFoundationCameraController *)controller didFinishRecordingVideoToOutputFileURL:(NSURL *)outputFileURL length:(CGFloat)length error:(NSError *)error;
/*!
 * delegate raw data and metadata
 */
- (void) cameraController:(AVFoundationCameraController *)cameraController didFinishPickingImageData:(NSData *)data;
- (void) cameraController:(AVFoundationCameraController *)cameraController didScaledTo:(CGFloat) scale viewRect:(CGRect)rect;
- (void) didRotatedDeviceOrientation:(UIDeviceOrientation) orientation;
- (void) cameraControllerDidInitialized:(AVFoundationCameraController *)cameraController;
@end