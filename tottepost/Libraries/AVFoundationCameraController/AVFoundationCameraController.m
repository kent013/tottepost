//
//  AVFoundationCameraController.m
//  AVFoundationCameraController
//
//  Created by ISHITOYA Kentaro on 12/01/02.
//  Copyright (c) 2012 ISHITOYA Kentaro. All rights reserved.
//

#import <CoreMedia/CoreMedia.h>
#import <ImageIO/ImageIO.h>
#import "AVFoundationCameraController.h"
#import "UIImage+Resize.h"
#import "UIImage+AutoRotation.h"
#import "ScreenStatus.h"
#import "AVFoundationPreset.h"
#import "UIImage+AutoRotation.h"

#define INDICATOR_RECT_SIZE 50.0
#define PICKER_MAXIMUM_ZOOM_SCALE 3 
#define PICKER_PADDING_X 10
#define PICKER_PADDING_Y 10
#define PICKER_SHUTTER_BUTTON_WIDTH 60
#define PICKER_SHUTTER_BUTTON_HEIGHT 30
#define PICKER_FLASHMODE_BUTTON_WIDTH 60
#define PICKER_FLASHMODE_BUTTON_HEIGHT 30
#define PICKER_CAMERADEVICE_BUTTON_WIDTH 60
#define PICKER_CAMERADEVICE_BUTTON_HEIGHT 30
#define ACCELEROMETER_INTERVAL 0.4

NSString *kTempVideoURL = @"kTempVideoURL";

//-----------------------------------------------------------------------------
//Private Implementations
//-----------------------------------------------------------------------------
@interface AVFoundationCameraController(PrivateImplementation)
- (void) setupInitialState:(CGRect)frame andMode:(AVFoundationCameraMode)mode;
- (void) initCameraWithMode:(AVFoundationCameraMode)mode;
- (void) handleTapGesture: (UITapGestureRecognizer *)recognizer;
- (void) handlePinchGesture: (UIPinchGestureRecognizer *)recognizer;
- (void) handleShutterButtonTapped:(UIButton *)sender;
- (void) handleCameraDeviceButtonTapped:(UIButton *)sender;
- (void) setFocus:(CGPoint)point;
- (void) setupAVFoundation:(AVFoundationCameraMode)mode;
- (void) autofocus;
- (void) updateCameraControls;
- (NSData *) cropImageData:(NSData *)data withViewRect:(CGRect)viewRect andScale:(CGFloat)scale;
- (CGRect) normalizeCropRect:(CGRect)rect size:(CGSize)size;
- (AVCaptureConnection *)connectionWithMediaType:(NSString *)mediaType fromConnections:(NSArray *)connections;
- (void) onVideoRecordingTimer;
- (NSURL*) tempVideoURL;
- (void) freezeCaptureForInterval:(NSTimeInterval)interval;
- (void) unfreezeCapture;
- (void) playShutterSound;
- (void) playVideoBeepSound;
- (CGImageRef) imageFromSampleBuffer:(CMSampleBufferRef)sampleBuffer;
- (int) getImageRotationAngle;

- (void) applicationWillResignActive;
- (void) applicationDidEnterBackground;
- (void) applicationDidBecomeActive;

- (void) startRecordingVideoInternal:(NSURL *)url;
@end

@implementation AVFoundationCameraController(PrivateImplementation)
/*!
 * initialize view
 */
-(void)setupInitialState:(CGRect)frame andMode:(AVFoundationCameraMode)mode{    
    isApplicationActive_ = YES;
    NSNotificationCenter *notify = [NSNotificationCenter defaultCenter];
    [notify addObserver:self selector:@selector(applicationWillResignActive)
     name:UIApplicationWillResignActiveNotification object:NULL];
    [notify addObserver:self selector:@selector(applicationDidBecomeActive)
     name:UIApplicationDidBecomeActiveNotification object:NULL];
    [notify addObserver:self selector:@selector(applicationDidEnterBackground)
     name:UIApplicationDidEnterBackgroundNotification object:NULL];

    self.view.frame = frame;
    self.view.backgroundColor = [UIColor clearColor];
    pointOfInterest_ = CGPointMake(frame.size.width / 2, frame.size.height / 2);
    defaultBounds_ = frame;
    scale_ = 1.0;
    croppedViewRect_ = CGRectZero;
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    tapRecognizer.delegate = self;
    [self.view addGestureRecognizer:tapRecognizer];
    UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchGesture:)];
    [self.view addGestureRecognizer:pinchRecognizer];
    shutterButton_ = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [shutterButton_ setTitle:@"Shutter" forState:UIControlStateNormal]; 
    [shutterButton_ addTarget:self action:@selector(handleShutterButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    flashModeButton_ = [[FlashButton alloc] init];
    flashModeButton_.delegate = self;
    cameraDeviceButton_ = [UIButton buttonWithType:UIButtonTypeCustom];
    [cameraDeviceButton_ setBackgroundImage:[UIImage imageNamed:@"camera_change.png"] forState:UIControlStateNormal];
    [cameraDeviceButton_ addTarget:self action:@selector(handleCameraDeviceButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    videoElapsedTimeLabel_ = [[UILabel alloc] initWithFrame:CGRectZero];
    videoElapsedTimeLabel_.backgroundColor = [UIColor clearColor];
    videoElapsedTimeLabel_.textColor = [UIColor whiteColor];
    [videoElapsedTimer_ invalidate];
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        videoElapsedTimeLabel_.font = [UIFont systemFontOfSize:22];
    }else{
        videoElapsedTimeLabel_.font = [UIFont systemFontOfSize:16];
    }
    
    cameraDeviceType_ = AVFoundationCameraDeviceTypeBack;
    stillCameraMethod_ = AVFoundationStillCameraMethodStandard;
    
    photoPreset_ = AVCaptureSessionPresetPhoto;
    videoPreset_ = AVCaptureSessionPresetMedium;
    
    [self initCameraWithMode:mode];
    
    showsCameraControls_ = YES;
    showsShutterButton_ = YES;
    showsIndicator_ = YES;
    useTapToFocus_ = YES;
    showsVideoElapsedTimeLabel_ = YES;
    freezeAfterShutter_ = YES;
    self.freezeInterval = 0.1;
    if(device_.isTorchAvailable){
        showsFlashModeButton_ = YES;
    }
    if(self.hasMultipleCameraDevices){
        showsCameraDeviceButton_ = YES;
    }
    [self updateCameraControls];
    
    [[UIAccelerometer sharedAccelerometer] setUpdateInterval:ACCELEROMETER_INTERVAL];
    [[UIAccelerometer sharedAccelerometer] setDelegate:self];
    
    if(TARGET_IPHONE_SIMULATOR == NO){
        AudioSessionInitialize(NULL, NULL, NULL, NULL);  
        NSError *audioError;
        [[AVAudioSession sharedInstance] setDelegate:self];
        [[AVAudioSession sharedInstance]
         setCategory: AVAudioSessionCategoryPlayback
         error: &audioError];
        UInt32 ssnCate = kAudioSessionCategory_MediaPlayback;  
        AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(ssnCate), &ssnCate);  
        
        UInt32 mixWithOthers = 1;  
        AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryMixWithOthers, sizeof(mixWithOthers), &mixWithOthers);  
        [[AVAudioSession sharedInstance] setActive: YES error: &audioError];
        AudioSessionSetActive(YES);
        
        shutterSoundPlayer_ = [[AVAudioPlayer alloc] initWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"AVFoundationShutter" withExtension:@"wav"] error:nil];
        videoBeepSoundPlayer_ = [[AVAudioPlayer alloc] initWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"AVFoundationVideoBeep" withExtension:@"wav"] error:nil]; 
        [shutterSoundPlayer_ prepareToPlay];
        [videoBeepSoundPlayer_ prepareToPlay];
    }
}

/*!
 * gesture recognizer delegate
 */
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isKindOfClass:[UIButton class]]){
        return FALSE;
    }
    return TRUE;
}

/*!
 * initialize camera
 */
-(void)initCameraWithMode:(AVFoundationCameraMode)mode{
#if TARGET_IPHONE_SIMULATOR
    mode_ = mode;
    return;
#endif
    if(cameraDeviceType_ == AVFoundationCameraDeviceTypeBack){
        device_ = self.backCameraDevice;
    }else{
        device_ = self.frontFacingCameraDevice;
    }
    
    // add layer
    [indicatorLayer_ removeFromSuperlayer];
    indicatorLayer_ = [CALayer layer];
    indicatorLayer_.borderColor = [[UIColor whiteColor] CGColor];
    indicatorLayer_.borderWidth = 1.0;
    indicatorLayer_.frame = 
    CGRectMake(self.view.bounds.size.width/2.0 - INDICATOR_RECT_SIZE/2.0,
               self.view.bounds.size.height/2.0 - INDICATOR_RECT_SIZE/2.0,
               INDICATOR_RECT_SIZE,
               INDICATOR_RECT_SIZE);
    indicatorLayer_.hidden = NO;

    //set mode initializes session
    [self setupAVFoundation:mode];
    
    [device_ addObserver:self
              forKeyPath:@"adjustingExposure"
                 options:NSKeyValueObservingOptionNew
                 context:nil];
    viewOrientation_ = UIDeviceOrientationPortrait;
    if([self.delegate respondsToSelector:@selector(cameraControllerDidInitialized:)]){
        [self.delegate cameraControllerDidInitialized:self];
    }
}

/*!
 * update camera controls
 */
- (void)updateCameraControls{
    [shutterButton_ removeFromSuperview];
    [flashModeButton_ removeFromSuperview];
    [cameraDeviceButton_ removeFromSuperview];
    [videoElapsedTimeLabel_ removeFromSuperview];
    indicatorLayer_.hidden = YES;
    
    CGRect f = self.view.frame;
    if(mode_ == AVFoundationCameraModeVideo ){
        if(showsVideoElapsedTimeLabel_ && [videoElapsedTimeLabel_ isDescendantOfView:self.view] == NO){
            CGSize size = [@"00:00" sizeWithFont:videoElapsedTimeLabel_.font];
            videoElapsedTimeLabel_.frame = CGRectMake(f.size.width - size.width - PICKER_PADDING_X, PICKER_PADDING_Y, size.width, size.height);        
            [self.view addSubview: videoElapsedTimeLabel_];
        }
    }else{
        if(showsCameraControls_ == NO){
            return;
        }
        if(showsShutterButton_ && [shutterButton_ isDescendantOfView:self.view] == NO){
            [shutterButton_ setFrame:CGRectMake((f.size.width - PICKER_SHUTTER_BUTTON_WIDTH) / 2    , f.size.height - PICKER_SHUTTER_BUTTON_HEIGHT - PICKER_PADDING_Y, PICKER_SHUTTER_BUTTON_WIDTH, PICKER_SHUTTER_BUTTON_HEIGHT)];
            [self.view addSubview: shutterButton_];
        }
        if(showsFlashModeButton_ && [flashModeButton_ isDescendantOfView:self.view] == NO){
            flashModeButton_.frame = CGRectMake(PICKER_PADDING_X, PICKER_PADDING_Y, PICKER_FLASHMODE_BUTTON_WIDTH, PICKER_FLASHMODE_BUTTON_HEIGHT);
            [self.view addSubview: flashModeButton_];
        }
        
        if(showsCameraDeviceButton_ && [cameraDeviceButton_ isDescendantOfView:self.view] == NO){
            cameraDeviceButton_.frame = CGRectMake(f.size.width - PICKER_CAMERADEVICE_BUTTON_WIDTH - PICKER_PADDING_X, PICKER_PADDING_Y, PICKER_CAMERADEVICE_BUTTON_WIDTH, PICKER_CAMERADEVICE_BUTTON_HEIGHT);        
            [self.view addSubview: cameraDeviceButton_];
        }
        if(showsIndicator_){
            indicatorLayer_.hidden = NO;
        }
    }
}

/*!
 * focus
 */
- (void) handleTapGesture:(UITapGestureRecognizer *)recognizer
{
    if(mode_ == AVFoundationCameraModeVideo){
        return;
    }
    if(useTapToFocus_ == NO){
        return;
    }
    CGPoint point = [recognizer locationInView:self.view];
    
    indicatorLayer_.frame = CGRectMake(point.x - INDICATOR_RECT_SIZE /2.0,
                                       point.y - INDICATOR_RECT_SIZE /2.0,
                                       INDICATOR_RECT_SIZE,
                                       INDICATOR_RECT_SIZE);
    point.x = (point.x + fabs(previewLayer_.frame.origin.x)) / scale_;
    point.y = (point.y + fabs(previewLayer_.frame.origin.y)) / scale_;
    [self setFocus:point];
}

/*!
 * zoom
 */
- (void)handlePinchGesture:(UIPinchGestureRecognizer *)recognizer {
    if(mode_ == AVFoundationCameraModeVideo){
        return;
    }
    CGFloat pinchScale = recognizer.scale;
    if(recognizer.state == UIGestureRecognizerStateBegan){
        lastPinchScale_ = pinchScale;
        return;
    }
    if(lastPinchScale_ == 0){
        lastPinchScale_ = pinchScale;
        return;
    }
    
    //calculate zoom scale
    CGFloat diff = (pinchScale - lastPinchScale_) * 2;
    CGFloat scale = scale_;
    if(diff > 0){
        scale += 0.08;
    }else{
        scale -= 0.08;
    }
    if(scale > PICKER_MAXIMUM_ZOOM_SCALE){
        scale = PICKER_MAXIMUM_ZOOM_SCALE;
    }else if(scale < 1.0){
        scale = 1.0;
    }
    if(scale_ == scale){
        return;
    }
    scale_ = scale;
    
    //calcurate zoom rect
    CGAffineTransform zt = CGAffineTransformScale(CGAffineTransformIdentity, scale_, scale_);
    CGRect rect = CGRectApplyAffineTransform(defaultBounds_, zt);
    
    if(CGPointEqualToPoint(pointOfInterest_, CGPointZero) || scale == 1.0){
        rect.origin.x = 0;
        rect.origin.y = 0;
    }else{
        rect.origin.x = -((pointOfInterest_.x * scale_) - defaultBounds_.size.width / 2);
        rect.origin.y = -((pointOfInterest_.y * scale_) - defaultBounds_.size.height / 2);
    }
    if(rect.origin.x > 0){
        rect.origin.x = 0;
    }
    if(rect.origin.y > 0){
        rect.origin.y = 0;
    }
    if(rect.origin.x + rect.size.width < defaultBounds_.size.width){
        rect.origin.x = defaultBounds_.size.width - rect.size.width;
    }
    if(rect.origin.y + rect.size.height < defaultBounds_.size.height){
        rect.origin.y = defaultBounds_.size.height - rect.size.height;
    }
    layerRect_ = rect;
    
    //calcurate indicator rect
    CGRect iframe = indicatorLayer_.frame;
    iframe.origin.x = (pointOfInterest_.x * scale_) - fabs(rect.origin.x) - INDICATOR_RECT_SIZE / 2.0;
    iframe.origin.y = (pointOfInterest_.y * scale_) - fabs(rect.origin.y) - INDICATOR_RECT_SIZE / 2.0;
    
    //set frame without animation
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    previewLayer_.frame = rect;    
    indicatorLayer_.frame = iframe;
    [CATransaction commit];
    lastPinchScale_ = pinchScale;
    
    if(scale == 1.0){
        croppedViewRect_ = CGRectZero;
    }else{
        croppedViewRect_ = CGRectMake(fabsf(rect.origin.x), fabsf(rect.origin.y), defaultBounds_.size.width, defaultBounds_.size.height);
    }
    
    if([self.delegate respondsToSelector:@selector(cameraController:didScaledTo:viewRect:)]){
        [self.delegate cameraController:self didScaledTo:scale_ viewRect:croppedViewRect_];
    }
}

/*!
 * autofocus
 */
- (void) autofocus{
    if (adjustingExposure_) {
        return;
    }
    NSError* error = nil;
    if ([device_ lockForConfiguration:&error] == NO) {
        NSLog(@"%s|[ERROR] %@", __PRETTY_FUNCTION__, error);
    }
    if ([device_ isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
        device_.focusMode = AVCaptureFocusModeContinuousAutoFocus;
        
    } else if ([device_ isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        device_.focusMode = AVCaptureFocusModeAutoFocus;
    }
    
    if ([device_ isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
        device_.exposureMode = AVCaptureExposureModeContinuousAutoExposure;
    } else if ([device_ isExposureModeSupported:AVCaptureExposureModeAutoExpose]) {
        device_.exposureMode = AVCaptureExposureModeAutoExpose;
    }
    
    if ([device_ isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance]) {
        device_.whiteBalanceMode = AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance;
    } else if ([device_ isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeAutoWhiteBalance]) {
        device_.whiteBalanceMode = AVCaptureWhiteBalanceModeAutoWhiteBalance;
    }
    [device_ unlockForConfiguration];
}

/*!
 * set focus and exposure point
 */
- (void)setFocus:(CGPoint)p
{
    CGSize viewSize = self.view.bounds.size;
    pointOfInterest_ = p;
    CGPoint pointOfInterest = CGPointMake(p.y / viewSize.height,
                                          1.0 - p.x / viewSize.width);
    NSError* error = nil;
    if ([device_ lockForConfiguration:&error] == NO) {
        NSLog(@"%s|[ERROR] %@", __PRETTY_FUNCTION__, error); 
    }
    
    if ([device_ isFocusPointOfInterestSupported] &&
        [device_ isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        device_.focusPointOfInterest = pointOfInterest;
        device_.focusMode = AVCaptureFocusModeAutoFocus;
    }
    
    if ([device_ isExposurePointOfInterestSupported] &&
        [device_ isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]){
        adjustingExposure_ = YES;
        device_.exposurePointOfInterest = pointOfInterest;
        device_.exposureMode = AVCaptureExposureModeContinuousAutoExposure;
    }
    
    [device_ unlockForConfiguration];
}

/*!
 * observe
 */
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (!adjustingExposure_) {
        return;
    }
    
	if ([keyPath isEqual:@"adjustingExposure"] == NO ||
        [[change objectForKey:NSKeyValueChangeNewKey] boolValue]) {
        return;
    }
    
    adjustingExposure_ = NO;
    
    NSError *error = nil;
    if ([device_ lockForConfiguration:&error]) {
        [device_ setExposureMode:AVCaptureExposureModeLocked];
        [device_ unlockForConfiguration];
    }
    [self performSelector:@selector(autofocus) withObject:nil afterDelay:1];
}

/*!
 * shutter tapped
 */
- (void)handleShutterButtonTapped:(UIButton *)sender{
    [self takePicture];
}

/*!
 * camera device tapped
 */
- (void)handleCameraDeviceButtonTapped:(UIButton *)sender{
    AVFoundationCameraMode modebak = mode_;
    mode_ = AVFoundationCameraModeInvalid;
    if(device_.position == AVCaptureDevicePositionBack){
        cameraDeviceType_ = AVFoundationCameraDeviceTypeFront;
        [self initCameraWithMode:modebak];
    }else{
        cameraDeviceType_ = AVFoundationCameraDeviceTypeBack;
        [self initCameraWithMode:modebak];
    }
    [self updateCameraControls];
}

/*
 * crop image data with data
 * @param data 
 * @param rect crop rect
 */
- (NSData *)cropImageData:(NSData *)data withViewRect:(CGRect)viewRect andScale:(CGFloat)scale{
    if(CGRectEqualToRect(viewRect, CGRectZero)){
        return data;
    }
    
    UIImage *image = [UIImage  imageWithData:data];

    double centerXRate =  pointOfInterest_.x / defaultBounds_.size.width;
    double centerYRate = pointOfInterest_.y / defaultBounds_.size.height;
    int w = image.size.width / scale;
    int h = image.size.height / scale;
    int x,y;
    switch(videoOrientation_){
        case AVCaptureVideoOrientationPortrait:
            x = centerXRate * image.size.width - w / 2;
            y = centerYRate * image.size.height - h / 2;
            break;
        case AVCaptureVideoOrientationLandscapeRight:
            x = centerYRate * image.size.width - w / 2;
            y = image.size.height - centerXRate * image.size.height - h / 2;
            break;
        case AVCaptureVideoOrientationLandscapeLeft:
            x = image.size.width - centerYRate * image.size.width - w / 2;
            y = centerXRate * image.size.height - h / 2;
            break;
        case AVCaptureVideoOrientationPortraitUpsideDown:
            break;
    }
    if(x < 0 ) x = 0;
    if(y < 0 ) y = 0;
    if(x + w > image.size.width) x = image.size.width - w;
    if(y + y > image.size.height) y = image.size.height - h;
    CGRect rect = CGRectMake(x, y, w, h);
    
    image = [[image subImageWithRect:rect] resizedImage:image.size interpolationQuality:kCGInterpolationHigh];
    NSData *croppedData = UIImageJPEGRepresentation(image, 1.0);
    if(croppedData == nil){
        return data;
    }
    CGImageSourceRef croppedImage = CGImageSourceCreateWithData((__bridge CFDataRef)croppedData, NULL);
    
    //read exif data
    CGImageSourceRef cfImage = CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
    NSDictionary *metadata = (__bridge NSDictionary *)CGImageSourceCopyPropertiesAtIndex(cfImage, 0, nil);
    
    //write back exif info
    CGImageSourceRef croppedCFImage = CGImageSourceCreateWithData((__bridge CFDataRef)croppedData, NULL);
    
    NSMutableDictionary *croppedMetadata = [NSMutableDictionary dictionaryWithDictionary:(__bridge NSDictionary *)CGImageSourceCopyPropertiesAtIndex(croppedCFImage, 0, nil)];
    NSMutableDictionary *exifMetadata = [metadata objectForKey:(NSString *)kCGImagePropertyExifDictionary];
    [croppedMetadata setValue:exifMetadata forKey:(NSString *)kCGImagePropertyExifDictionary];
	CGImageDestinationRef dest = CGImageDestinationCreateWithData((__bridge CFMutableDataRef)croppedData, CGImageSourceGetType(croppedImage), 1, NULL);
	CGImageDestinationAddImageFromSource(dest, croppedImage, 0, (__bridge CFDictionaryRef)croppedMetadata);
	CGImageDestinationFinalize(dest);
    
    //release 
	CFRelease(cfImage);
    CFRelease(croppedCFImage);
    CFRelease(croppedImage);
	CFRelease(dest);
    return croppedData;   
}

/*!
 * normalize crop rect
 * @param rect target rect
 * @return CGRect
 */
- (CGRect)normalizeCropRect:(CGRect)rect size:(CGSize)size{
    CGRect rotatedRect = rect;
    if((viewOrientation_ == UIDeviceOrientationPortrait && 
              videoOrientation_ == AVCaptureVideoOrientationLandscapeLeft) ||
             (viewOrientation_ == UIDeviceOrientationPortraitUpsideDown &&
              videoOrientation_ == AVCaptureVideoOrientationLandscapeRight)){
        rotatedRect.origin.x = size.height - rect.origin.y;
        rotatedRect.origin.y = rect.origin.x;
    }else if((viewOrientation_ == UIDeviceOrientationPortrait && 
              videoOrientation_ == AVCaptureVideoOrientationLandscapeRight) ||
             (viewOrientation_ == UIDeviceOrientationPortraitUpsideDown &&
              videoOrientation_ == AVCaptureVideoOrientationLandscapeLeft)){
        rotatedRect.origin.x = rect.origin.y;
        rotatedRect.origin.y = size.height - rect.origin.x;
    }
    
    if(rotatedRect.origin.x < 0){
        rotatedRect.origin.x = 0;
    }
    if(rotatedRect.origin.y < 0){
        rotatedRect.origin.y = 0;
    }
    if(rotatedRect.origin.x + rotatedRect.size.width > size.width){
        rotatedRect.origin.x = size.width - rotatedRect.size.width;
    }
    if(rotatedRect.origin.y + rotatedRect.size.height > size.height){
        rotatedRect.origin.y = size.height - rotatedRect.size.height;
    }
    //NSLog(@"size  :%@", NSStringFromCGSize(size));
    //NSLog(@"before:%@", NSStringFromCGRect(rect));
    //NSLog(@"after :%@", NSStringFromCGRect(rotatedRect));
    return rotatedRect;
}

/*!
 * get capture connection with mediatype
 */
- (AVCaptureConnection *)connectionWithMediaType:(NSString *)mediaType fromConnections:(NSArray *)connections
{
	for ( AVCaptureConnection *connection in connections ) {
		for ( AVCaptureInputPort *port in [connection inputPorts] ) {
			if ( [[port mediaType] isEqual:mediaType] ) {
				return connection;
			}
		}
	}
	return nil;
}

/*!
 * on timer
 */
- (void)onVideoRecordingTimer{
    int minute = -([videoRecordingStartedDate_ timeIntervalSinceNow] + 0.01)/ 60;
    int sec = -(int)([videoRecordingStartedDate_ timeIntervalSinceNow] + 0.01) % 60;
    videoElapsedTimeLabel_.text = [NSString stringWithFormat:@"%02d:%02d", minute, sec];
}

/*!
 * get temp video URL
 */
- (NSURL *)tempVideoURL{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *num = [defaults objectForKey:kTempVideoURL];
    int n = [num intValue];
    if(n > 5){
        n = 0;
    }else{
        n++;
    }
    
    NSString *filename = [NSString stringWithFormat:@"file://%@/tmp/output%d.mov", NSHomeDirectory(), n];
    NSURL *url = [NSURL URLWithString:filename];
    @synchronized(self){
        NSFileManager *manager = [NSFileManager defaultManager];
        if([manager fileExistsAtPath:url.path]){
            [manager removeItemAtURL:url error:nil];
        }
        while([manager fileExistsAtPath:url.path]){
            [NSThread sleepForTimeInterval:1];
        }
        //NSLog(@"deleted");
        [defaults setObject:[NSNumber numberWithInt:n] forKey:kTempVideoURL];
    };
    return url;
}

/*!
 * show freeze photo view
 */
- (void)freezeCaptureForInterval:(NSTimeInterval)interval{
    [session_ stopRunning];
    [self performSelector:@selector(unfreezeCapture) withObject:nil afterDelay:interval];
}

/*!
 * hide freeze photo view
 */
- (void)unfreezeCapture{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if(session_.isRunning == NO){
            [session_ startRunning];
        }
    });
}

/*!
 * play shutter sound
 */
- (void)playShutterSound{
    if(shutterSoundPlayer_.isPlaying){
        [shutterSoundPlayer_ stop];
        shutterSoundPlayer_.currentTime = 0;
    }
    [shutterSoundPlayer_ play];
}

/*!
 * play video sound
 */
- (void)playVideoBeepSound{
    [videoBeepSoundPlayer_ play];
}

/*!
 * get image rotation angle
 */
- (int)getImageRotationAngle{
    if(cameraDeviceType_ == AVFoundationCameraDeviceTypeFront){
        if(videoOrientation_ == 1){
            return -90;
        }else if(videoOrientation_ == 2){
            return 90;
        }else if(videoOrientation_ == 3){
            return 180;
        }
    }else{
        if(videoOrientation_ == 1){
            return -90;
        }else if(videoOrientation_ == 2){
            return 90;
        }else if(videoOrientation_ == 4){
            return 180;
        }
    }
    return 0;
}

/*!
 * create image from sample buffer
 * http://stackoverflow.com/questions/3305862/uiimage-created-from-cmsamplebufferref-not-displayed-in-uiimageview
 */
- (CGImageRef) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer {
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer); 
    CVPixelBufferLockBaseAddress(imageBuffer,0);
    
    uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0);     size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer); 
    size_t width = CVPixelBufferGetWidth(imageBuffer); 
    size_t height = CVPixelBufferGetHeight(imageBuffer); 
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB(); 
    
    CGContextRef newContext = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst); 
    CGImageRef newImage = CGBitmapContextCreateImage(newContext); 
    CGContextRelease(newContext); 
    
    CGColorSpaceRelease(colorSpace); 
    CVPixelBufferUnlockBaseAddress(imageBuffer,0); 
    
    return newImage;
}

/*!
 * application will resign active
 */
- (void)applicationWillResignActive{
    isApplicationActive_ = NO;
    if(self.isRecordingVideo == NO){
        return;
    }
    [self stopRecordingVideo];
}

/*!
 * application did enter background
 */
- (void)applicationDidEnterBackground{
    isApplicationActive_ = NO;
}

/*!
 * application did become active
 */
- (void)applicationDidBecomeActive{
    if(backgroundRecordingId_ != UIBackgroundTaskInvalid){
        backgroundRecordingId_ = UIBackgroundTaskInvalid;
    }
    isApplicationActive_ = YES;
    if(session_.isRunning == NO){
        [session_ startRunning];
    }
}

/*!
 * setup AVFoundation
 */
- (void)setupAVFoundation:(AVFoundationCameraMode)mode{    
    [session_ stopRunning];
    session_ = [[AVCaptureSession alloc] init];
    [session_ beginConfiguration];
    [session_ removeInput:videoInput_];
    [session_ removeInput:audioInput_];
    [session_ removeOutput:videoDataOutput_];
    [session_ removeOutput:stillImageOutput_];
    [session_ removeOutput:movieFileOutput_];
    
    videoInput_ = [[AVCaptureDeviceInput alloc] initWithDevice:device_ error:nil];
    if([session_ canAddInput:videoInput_]){
        [session_ addInput:videoInput_];
    }
    if(mode == AVFoundationCameraModePhoto){
        if(stillCameraMethod_ == AVFoundationStillCameraMethodStandard){
            stillImageOutput_ = [[AVCaptureStillImageOutput alloc] init];
            [stillImageOutput_ setOutputSettings:[[NSDictionary alloc] initWithObjectsAndKeys:
                                                  AVVideoCodecJPEG, AVVideoCodecKey,
                                                  nil]];
            for (AVCaptureConnection* connection in stillImageOutput_.connections) {
                connection.videoOrientation = AVCaptureVideoOrientationPortrait;
            }
            if([session_ canAddOutput:stillImageOutput_]){
                [session_ addOutput:stillImageOutput_];
            }
            for (AVCaptureConnection* connection in stillImageOutput_.connections) {
                connection.videoOrientation = videoOrientation_;
            }            
        }else if(stillCameraMethod_ == AVFoundationStillCameraMethodVideoCapture){
            videoDataOutput_ = [[AVCaptureVideoDataOutput alloc] init];
            [videoDataOutput_ setAlwaysDiscardsLateVideoFrames:YES];
            [videoDataOutput_ setVideoSettings:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey]];
            dispatch_queue_t queue = dispatch_queue_create("com.tottepost.videoDataOutput", NULL);
            [videoDataOutput_ setSampleBufferDelegate:self queue:queue];
            dispatch_release(queue);
            
            if([session_ canAddOutput:videoDataOutput_]){
                [session_ addOutput:videoDataOutput_];
            }
            for (AVCaptureConnection* connection in videoDataOutput_.connections) {
                connection.videoOrientation = AVCaptureVideoOrientationPortrait;
            }
        }
    }else{
        audioInput_ = [[AVCaptureDeviceInput alloc] initWithDevice:self.audioDevice error:nil];
        if([session_ canAddInput:audioInput_]){
            [session_ addInput:audioInput_];
        }
        movieFileOutput_ = [[AVCaptureMovieFileOutput alloc] init];
        if([session_ canAddOutput:movieFileOutput_]){
            [session_ addOutput:movieFileOutput_];
        }
        for (AVCaptureConnection* connection in movieFileOutput_.connections) {
            connection.videoOrientation = AVCaptureVideoOrientationPortrait;
        }
    }
    [session_ commitConfiguration];
    [indicatorLayer_ removeFromSuperlayer];
    [previewLayer_ removeFromSuperlayer];
    previewLayer_ = [AVCaptureVideoPreviewLayer layerWithSession:session_];
    previewLayer_.automaticallyAdjustsMirroring = NO;
    previewLayer_.videoGravity = AVLayerVideoGravityResizeAspectFill;
    previewLayer_.frame = self.view.bounds;
    [self.view.layer addSublayer:previewLayer_];
    [self.view.layer addSublayer:indicatorLayer_];
    
    if(lastMode_ != AVFoundationCameraModeNotInitialized){
        [UIView beginAnimations: @"TransitionAnimation" context:nil];
        [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight
                               forView:self.view
                                 cache:YES];
        [UIView setAnimationDuration:1.0];
        [UIView commitAnimations];
    }
    mode_ = mode;
    [self applyPreset];
    [self autofocus];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if(session_.isRunning == NO){
            [session_ startRunning];
        }
    });
    [self updateCameraControls];
}

/*!
 * start recording
 */
- (void)startRecordingVideoInternal:(NSURL *)url{
    [movieFileOutput_ startRecordingToOutputFileURL:url recordingDelegate:self];
}
@end

//-----------------------------------------------------------------------------
//Public Implementations
//-----------------------------------------------------------------------------
@implementation AVFoundationCameraController
@synthesize delegate;
@synthesize showsCameraControls = showsCameraControls_;
@synthesize showsCameraDeviceButton = showsCameraDeviceButton_;
@synthesize showsFlashModeButton = showsFlashModeButton_;
@synthesize showsShutterButton = showsShutterButton_;
@synthesize showsVideoElapsedTimeLabel = showsVideoElapsedTimeLabel_;
@synthesize showsIndicator = showsIndicator_;
@synthesize useTapToFocus = useTapToFocus_;
@synthesize freezeAfterShutter = freezeAfterShutter_;
@synthesize freezeInterval;
@synthesize mode = mode_;
@synthesize cameraDevicetype = cameraDeviceType_;
@synthesize stillCameraMethod = stillCameraMethod_;
@synthesize isRecordingVideo;
@synthesize photoPreset = photoPreset_;
@synthesize videoPreset = videoPreset_;
@synthesize soundVolume = soundVolume_;

#pragma mark -
#pragma mark public implementation
/*!
 * initializer
 * @param frame
 */
- (id)initWithFrame:(CGRect)frame andMode:(AVFoundationCameraMode)mode{
    self = [super init];
    if(self){
        mode_ = AVFoundationCameraModeNotInitialized;
        lastMode_ = AVFoundationCameraModeNotInitialized;
        [self setupInitialState:frame andMode:mode];
    }
    return self;
}


/*!
 * take picture
 */
-(void)takePicture
{
    if(mode_ == AVFoundationCameraModeVideo){
        NSLog(@"Controller is in video mode. %s", __PRETTY_FUNCTION__);
        return;
    }
    if(session_.isRunning == NO){
        return;
    }
    if(stillCameraMethod_ == AVFoundationStillCameraMethodStandard){
        AVCaptureConnection *videoConnection = nil;
        for (AVCaptureConnection *connection in stillImageOutput_.connections)
        {
            for (AVCaptureInputPort *port in [connection inputPorts])
            {
                if ([[port mediaType] isEqual:AVMediaTypeVideo] )
                {
                    videoConnection = connection;
                    break;
                }
            }
            if (videoConnection) { break; }
        }
        [stillImageOutput_ captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler: ^(CMSampleBufferRef imageSampleBuffer, NSError *error)
         {
             if(freezeAfterShutter_){
                 [self freezeCaptureForInterval:self.freezeInterval];
             }
             NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
             
             UIImage *image = nil;
             if(scale_ != 1.0){
                 imageData = [self cropImageData:imageData withViewRect:croppedViewRect_ andScale:scale_];
             }
             if([self.delegate respondsToSelector:@selector(cameraController:didFinishPickingImage:)]){
                 image = [[UIImage alloc] initWithData:imageData];
                 [self.delegate cameraController:self didFinishPickingImage:image];
             }
             
             if([self.delegate respondsToSelector:@selector(cameraController:didFinishPickingImageData:)]){
                 [self.delegate cameraController:self didFinishPickingImageData:imageData];
             }
         }];
    }else if(stillCameraMethod_ == AVFoundationStillCameraMethodVideoCapture){
        isVideoFrameCapturing_ = YES;
    }
}

/*!
 * start recording video
 */
- (void)startRecordingVideo{
    [self playVideoBeepSound];
    if ([[UIDevice currentDevice] isMultitaskingSupported]) {
        if(backgroundRecordingId_ != UIBackgroundTaskInvalid){
            [[UIApplication sharedApplication] endBackgroundTask:backgroundRecordingId_];
        }
        backgroundRecordingId_ = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
            if (backgroundRecordingId_ != UIBackgroundTaskInvalid) {
                [[UIApplication sharedApplication] endBackgroundTask:backgroundRecordingId_];
                backgroundRecordingId_ = UIBackgroundTaskInvalid;
            }
        }];
    }
    
    [session_ beginConfiguration];
    [session_ removeOutput:movieFileOutput_];
    movieFileOutput_ = nil;
    movieFileOutput_ = [[AVCaptureMovieFileOutput alloc] init];
    if([session_ canAddOutput:movieFileOutput_]){
        [session_ addOutput:movieFileOutput_];
    }
    for (AVCaptureConnection* connection in movieFileOutput_.connections) {
        if ([connection isVideoOrientationSupported]){
            connection.videoOrientation = videoOrientation_;
        }
    }
    [session_ commitConfiguration];
    
    NSURL *url = [self tempVideoURL];
    currentVideoURL_ = url;
    [self performSelector:@selector(startRecordingVideoInternal:) withObject:url afterDelay:2.0];
}

/*!
 * video data output
 */
-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{
    if(isVideoFrameCapturing_){
        isVideoFrameCapturing_ = NO;
        if(freezeAfterShutter_){
            dispatch_async(dispatch_get_main_queue(), ^{
                [self playShutterSound];
                [self freezeCaptureForInterval:self.freezeInterval];
            });
        }
        CVImageBufferRef buffer = CMSampleBufferGetImageBuffer(sampleBuffer);
        CVPixelBufferLockBaseAddress(buffer, 0);
        CGImageRef cgImage = [self imageFromSampleBuffer:sampleBuffer];
        UIImage *sampleImage = [UIImage imageWithCGImage:cgImage];
        CGImageRelease(cgImage);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            int angle = [self getImageRotationAngle];
            UIImage *image = sampleImage;
            if(angle != 0){
                image = [sampleImage UIImageRotateByAngle:angle];
            }
            NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
            
            if(scale_ != 1.0){
                imageData = [self cropImageData:imageData withViewRect:croppedViewRect_ andScale:scale_];
            }
            if([self.delegate respondsToSelector:@selector(cameraController:didFinishPickingImage:)]){
                @synchronized(self){
                    [self.delegate cameraController:self didFinishPickingImage:image];
                }
            }
            
            if([self.delegate respondsToSelector:@selector(cameraController:didFinishPickingImageData:)]){
                @synchronized(self){
                    [self.delegate cameraController:self didFinishPickingImageData:imageData];
                }
            }
        });
        CVPixelBufferUnlockBaseAddress(buffer, 0);
    }
}

/*!
 * stop recording video
 */
- (void)stopRecordingVideo{
    dispatch_async(dispatch_get_main_queue(), ^{
        [videoElapsedTimer_ invalidate];
        videoElapsedTimeLabel_.text = @"";
    });
    if(self.isRecordingVideo){
        [self playVideoBeepSound];
        [movieFileOutput_ stopRecording];
    }
}

/*!
 * returns recording video
 */
-(BOOL)isRecordingVideo{
    return [movieFileOutput_ isRecording];
}

/*!
 * restart session
 */
- (void)restartSession{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if(session_.isRunning == NO){
            [session_ startRunning];
        }
    });
}

/*!
 * did start recording
 */
- (void) captureOutput:(AVCaptureFileOutput *)captureOutput
didStartRecordingToOutputFileAtURL:(NSURL *)fileURL
       fromConnections:(NSArray *)connections{
    videoRecordingStartedDate_ = [NSDate date];
    videoElapsedTimer_ = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(onVideoRecordingTimer) userInfo:nil repeats:YES];
    [videoElapsedTimer_ fire];
    if([self.delegate respondsToSelector:@selector(cameraControllerDidStartRecordingVideo:)]){
        [self.delegate cameraControllerDidStartRecordingVideo:self];
    }    
}

/*!
 * did finish recording
 */
- (void) captureOutput:(AVCaptureFileOutput *)captureOutput
didFinishRecordingToOutputFileAtURL:(NSURL *)anOutputFileURL
                    fromConnections:(NSArray *)connections
                              error:(NSError *)error
{
    /*
    for(AVCaptureInput *input in session_.inputs){
        NSLog(@"%@", input.description);        
    }
    for(AVCaptureOutput *output in session_.outputs){
        NSLog(@"%@", output.description);
    }
    if(error){
        NSLog(@"%s, %@, %@, %@", __PRETTY_FUNCTION__, anOutputFileURL, error.description, [error.userInfo objectForKey:AVErrorRecordingSuccessfullyFinishedKey]);
    }*/ 
    
    if([self.delegate respondsToSelector:@selector(cameraController:didFinishRecordingVideoToOutputFileURL:error:)]){
        currentVideoURL_ = nil;
        [self.delegate cameraController:self didFinishRecordingVideoToOutputFileURL:anOutputFileURL error:error];
    }

    if ([[UIDevice currentDevice] isMultitaskingSupported]) {
        [[UIApplication sharedApplication] endBackgroundTask:backgroundRecordingId_];
        backgroundRecordingId_ = UIBackgroundTaskInvalid;
    }
}   

#pragma mark - public property implementations
/*!
 * set mode
 */
-(void)setMode:(AVFoundationCameraMode)mode{
    if(mode_ == mode){
        return;
    }
    lastMode_ = mode_;
    mode_ = mode;
    [self setupAVFoundation:mode];
}

/*!
 * set still capture mode
 */
- (void)setStillCameraMethod:(AVFoundationStillCameraMethod)stillCameraMethod{
    if(stillCameraMethod_ == stillCameraMethod){
        return;
    }
    if(mode_ != AVFoundationCameraModePhoto){
        return;
    }
    stillCameraMethod_ = stillCameraMethod;
    [session_ beginConfiguration];
    [session_ removeOutput:videoDataOutput_];
    [session_ removeOutput:stillImageOutput_];

    if(stillCameraMethod_ == AVFoundationStillCameraMethodStandard){
        stillImageOutput_ = [[AVCaptureStillImageOutput alloc] init];
        [stillImageOutput_ setOutputSettings:[[NSDictionary alloc] initWithObjectsAndKeys:
                                              AVVideoCodecJPEG, AVVideoCodecKey,
                                              nil]];
        for (AVCaptureConnection* connection in stillImageOutput_.connections) {
            connection.videoOrientation = AVCaptureVideoOrientationPortrait;
        }
        if([session_ canAddOutput:stillImageOutput_]){
            [session_ addOutput:stillImageOutput_];
        }
        for (AVCaptureConnection* connection in stillImageOutput_.connections) {
            connection.videoOrientation = videoOrientation_;
        }            
    }else if(stillCameraMethod_ == AVFoundationStillCameraMethodVideoCapture){
        videoDataOutput_ = [[AVCaptureVideoDataOutput alloc] init];
        [videoDataOutput_ setAlwaysDiscardsLateVideoFrames:YES];
        [videoDataOutput_ setVideoSettings:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey]];
        dispatch_queue_t queue = dispatch_queue_create("com.tottepost.videoDataOutput", NULL);
        [videoDataOutput_ setSampleBufferDelegate:self queue:queue];
        dispatch_release(queue);
        
        if([session_ canAddOutput:videoDataOutput_]){
            [session_ addOutput:videoDataOutput_];
        }
        for (AVCaptureConnection* connection in videoDataOutput_.connections) {
            connection.videoOrientation = AVCaptureVideoOrientationPortrait;
        }
    }
    [session_ commitConfiguration];
}

/*!
 * apply preset
 */
- (void)applyPreset{
    [session_ beginConfiguration];
    if(mode_ == AVFoundationCameraModePhoto){
        session_.sessionPreset = photoPreset_;
    }else{
        session_.sessionPreset = videoPreset_;
    }    
    [session_ commitConfiguration];
}

/*!
 * shows camera controls
 */
- (void)setShowsCameraControls:(BOOL)showsCameraControls{
    showsCameraControls_ = showsCameraControls;
    [self updateCameraControls];
}

/*!
 * shows camera device button
 */
- (void)setShowsCameraDeviceButton:(BOOL)showsCameraDeviceButton{
    showsCameraDeviceButton_ = showsCameraDeviceButton;
    [self updateCameraControls];
}

/*!
 * shows flash mode button
 */
- (void)setShowsFlashModeButton:(BOOL)showsFlashModeButton{
    showsFlashModeButton_ = showsFlashModeButton;
    [self updateCameraControls];
}

/*!
 * shows shutter button
 */
- (void)setShowsShutterButton:(BOOL)showsShutterButton{
    showsShutterButton_ = showsShutterButton;
    [self updateCameraControls];
}

/*!
 * shows video elapsed time label
 */
- (void)setShowsVideoElapsedTimeLabel:(BOOL)showsVideoElapsedTimeLabel{
    showsVideoElapsedTimeLabel = showsVideoElapsedTimeLabel;
    [self updateCameraControls];
}

/*!
 * shows indicator
 */
- (void)setShowsIndicator:(BOOL)showsIndicator{
    showsIndicator_ = showsIndicator;
    [self updateCameraControls];
}

/*!
 * use tap to focus
 */
- (void)setUseTapToFocus:(BOOL)useTapToFocus{
    useTapToFocus_ = useTapToFocus;
    if(useTapToFocus_){
        indicatorLayer_.hidden = NO;
    }else{
        [self autofocus];
        indicatorLayer_.hidden = YES;
    }
}

/*!
 * check the device has multiple video devices
 */
- (BOOL)hasMultipleCameraDevices{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    return devices.count > 1;
}

/*!
 * get front-facing camera device
 */
- (AVCaptureDevice *)frontFacingCameraDevice{
    NSArray *videoDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in videoDevices) {
        if (device.position == AVCaptureDevicePositionFront) {
            return device;
        }
    }
    return nil;
}

/*!
 * get back camera device
 */
- (AVCaptureDevice *)backCameraDevice{
    NSArray *videoDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in videoDevices) {
        if (device.position == AVCaptureDevicePositionBack) {
            return device;
        }
    }
    return nil;
}

/*!
 * get audio device
 */
- (AVCaptureDevice *) audioDevice
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio];
    if ([devices count] > 0) {
        return [devices objectAtIndex:0];
    }
    return nil;
}

/*!
 * check the device has front-facing camera device
 */
- (BOOL)frontFacingCameraAvailable{
    return self.frontFacingCameraDevice != nil;
}

/*!
 * check the device has front-facing camera device
 */
- (BOOL)backCameraAvailable{
    return self.backCameraDevice != nil;
}

/*!
 * set volume
 */
- (void)setSoundVolume:(CGFloat)soundVolume{
    soundVolume_ = soundVolume;
    [shutterSoundPlayer_ setVolume:soundVolume];
    [videoBeepSoundPlayer_ setVolume:soundVolume];
}

#pragma mark -
#pragma mark flashButton delegate

/*!
 * set flash mode
 */
- (void)setFlashMode:(AVCaptureFlashMode)mode{
    AVCaptureDevice* device = self.backCameraDevice;
    [device lockForConfiguration:nil];    
    [device setFlashMode:mode];
    [device unlockForConfiguration];
}

#pragma mark - UIAccelerometerDelegate

/*!
 * Accelerometer delegate
 */
- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration
{
    UIDeviceOrientation deviceOrientation = [ScreenStatus orientation2:acceleration];
    
    if(deviceOrientation_ == deviceOrientation)
        return;
    deviceOrientation_ = deviceOrientation;
    [delegate didRotatedDeviceOrientation:deviceOrientation];
    
    if (deviceOrientation == UIDeviceOrientationPortrait){
        videoOrientation_ = AVCaptureVideoOrientationPortrait;
    }else if (deviceOrientation == UIDeviceOrientationPortraitUpsideDown){
        videoOrientation_ = AVCaptureVideoOrientationPortraitUpsideDown;
    }else if (deviceOrientation == UIDeviceOrientationLandscapeLeft){        
        videoOrientation_ = AVCaptureVideoOrientationLandscapeRight;
    }else if (deviceOrientation == UIDeviceOrientationLandscapeRight){
        videoOrientation_ = AVCaptureVideoOrientationLandscapeLeft;
    }else{
        return;
    }
    [session_ beginConfiguration];
    for (AVCaptureConnection* connection in stillImageOutput_.connections) {
        connection.videoOrientation = videoOrientation_;
    }
    [session_ commitConfiguration];
    
    viewOrientation_ = deviceOrientation;
}
@end
