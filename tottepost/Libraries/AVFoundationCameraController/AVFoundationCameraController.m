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

//-----------------------------------------------------------------------------
//Private Implementations
//-----------------------------------------------------------------------------
@interface AVFoundationCameraController(PrivateImplementation)
- (void) setupInitialState:(CGRect)frame;
- (void) initCamera:(AVCaptureDevice *)cameraDevice;
- (void) handleTapGesture: (UITapGestureRecognizer *)recognizer;
- (void) handlePinchGesture: (UIPinchGestureRecognizer *)recognizer;
- (void) handleShutterButtonTapped:(UIButton *)sender;
- (void) handleCameraDeviceButtonTapped:(UIButton *)sender;
- (void) setFocus:(CGPoint)point;
- (void) autofocus;
- (void) updateCameraControls;
- (NSData *) cropImageData:(NSData *)data withViewRect:(CGRect)viewRect andScale:(CGFloat)scale;
- (CGRect) normalizeCropRect:(CGRect)rect size:(CGSize)size;
- (AVCaptureConnection *)connectionWithMediaType:(NSString *)mediaType fromConnections:(NSArray *)connections;
- (void) onVideoRecordingTimer;
@end

@implementation AVFoundationCameraController(PrivateImplementation)
/*!
 * initialize view
 */
-(void)setupInitialState:(CGRect)frame{
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
    [videoElapsedTimer_ invalidate];
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        videoElapsedTimeLabel_.font = [UIFont systemFontOfSize:22];
    }else{
        videoElapsedTimeLabel_.font = [UIFont systemFontOfSize:16];
    }
    
    [self initCamera:self.backCameraDevice];
    showsCameraControls_ = YES;
    showsShutterButton_ = YES;
    showsIndicator_ = YES;
    useTapToFocus_ = YES;
    showsVideoElapsedTimeLabel_ = YES;
    if(device_.isTorchAvailable){
        showsFlashModeButton_ = YES;
    }
    if(self.hasMultipleCameraDevices){
        showsCameraDeviceButton_ = YES;
    }
    [self updateCameraControls];
    
    [[UIAccelerometer sharedAccelerometer] setUpdateInterval:ACCELEROMETER_INTERVAL];
    [[UIAccelerometer sharedAccelerometer] setDelegate:self];
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
-(void)initCamera:(AVCaptureDevice *)cameraDevice{
#if TARGET_IPHONE_SIMULATOR
    return;
#endif
    session_ = [[AVCaptureSession alloc] init];
    device_ = cameraDevice;
    [session_ beginConfiguration];
    session_.sessionPreset = AVCaptureSessionPresetPhoto;
    [session_ commitConfiguration];
    
    [self autofocus];
    
    [device_ addObserver:self
              forKeyPath:@"adjustingExposure"
                 options:NSKeyValueObservingOptionNew
                 context:nil];
    
    //setup video
    videoInput_ = [[AVCaptureDeviceInput alloc] initWithDevice:device_ error:nil];
    audioInput_ = [[AVCaptureDeviceInput alloc] initWithDevice:self.audioDevice error:nil];
    movieFileOutput_ = [[AVCaptureMovieFileOutput alloc] init];
    
    //setup image
    imageOutput_ = [[AVCaptureStillImageOutput alloc] init];
    [imageOutput_ setOutputSettings:[[NSDictionary alloc] initWithObjectsAndKeys:
                                     AVVideoCodecJPEG, AVVideoCodecKey,
                                     nil]];
    for (AVCaptureConnection* connection in imageOutput_.connections) {
        connection.videoOrientation = AVCaptureVideoOrientationPortrait;
    }
    
    if ([session_ canAddInput:videoInput_]) {
        [session_ addInput:videoInput_];
    }
    if ([session_ canAddInput:audioInput_]) {
        [session_ addInput:audioInput_];
    }
    if ([session_ canAddOutput:movieFileOutput_]){
        [session_ addOutput:movieFileOutput_];
    }
    if ([session_ canAddOutput:imageOutput_]){
        [session_ addOutput:imageOutput_];
    }
    
    //setup preview
    previewLayer_ = [AVCaptureVideoPreviewLayer layerWithSession:session_];
    previewLayer_.automaticallyAdjustsMirroring = NO;
    previewLayer_.videoGravity = AVLayerVideoGravityResizeAspectFill;
    previewLayer_.frame = self.view.bounds;
    [self.view.layer addSublayer:previewLayer_];
    
    [session_ startRunning];
    
    // add layer
    indicatorLayer_ = [CALayer layer];
    indicatorLayer_.borderColor = [[UIColor whiteColor] CGColor];
    indicatorLayer_.borderWidth = 1.0;
    indicatorLayer_.frame = 
    CGRectMake(self.view.bounds.size.width/2.0 - INDICATOR_RECT_SIZE/2.0,
               self.view.bounds.size.height/2.0 - INDICATOR_RECT_SIZE/2.0,
               INDICATOR_RECT_SIZE,
               INDICATOR_RECT_SIZE);
    indicatorLayer_.hidden = NO;
    [self.view.layer addSublayer:indicatorLayer_];
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
            CGSize size = [@"00/00" sizeWithFont:videoElapsedTimeLabel_.font];
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
    if(device_.position == AVCaptureDevicePositionBack){
        [self initCamera:self.frontFacingCameraDevice];
    }else{
        [self initCamera:self.backCameraDevice];
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
    NSLog(@"%f", [videoElapsedTimer_.fireDate timeIntervalSinceNow]);
    int minute = [videoElapsedTimer_.fireDate timeIntervalSinceNow] / 60;
    int sec = (int)[videoElapsedTimer_.fireDate timeIntervalSinceNow] % 60;
    videoElapsedTimeLabel_.text = [NSString stringWithFormat:@"%02d:%02d", minute, sec];
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
@synthesize mode = mode_;
@synthesize isRecordingVideo;

#pragma mark -
#pragma mark public implementation
/*!
 * initializer
 * @param frame
 */
- (id)initWithFrame:(CGRect)frame andMode:(AVFoundationCameraMode)mode{
    self = [super init];
    if(self){
        mode_ = mode;
        [self setupInitialState:frame];
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
    session_.sessionPreset = AVCaptureSessionPresetPhoto;
	AVCaptureConnection *videoConnection = nil;
	for (AVCaptureConnection *connection in imageOutput_.connections)
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
    
	[imageOutput_ captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler: ^(CMSampleBufferRef imageSampleBuffer, NSError *error)
     {
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
}

/*!
 * start recording video
 */
- (void)startRecordingVideo{
    session_.sessionPreset = AVCaptureSessionPresetMedium;
    if ([[UIDevice currentDevice] isMultitaskingSupported]) {
        backgroundRecordingId_ = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{}];
    }
    AVCaptureConnection *videoConnection = [self connectionWithMediaType:AVMediaTypeVideo fromConnections:[movieFileOutput_ connections]];
    if ([videoConnection isVideoOrientationSupported]){
        [videoConnection setVideoOrientation:videoOrientation_];
    }
    
    
    NSString *filename = [NSString stringWithFormat:@"file://%@/tmp/output.mp4", NSHomeDirectory()];
    NSURL *url = [NSURL URLWithString:filename];
    NSFileManager *manager = [NSFileManager defaultManager];
    NSError *error;
    [manager removeItemAtURL:url error:&error];
    NSLog(@"%@", error.description);
    [movieFileOutput_ startRecordingToOutputFileURL:url recordingDelegate:self];
}

/*!
 * stop recording video
 */
- (void)stopRecordingVideo{
    [movieFileOutput_ stopRecording];
    if ([[UIDevice currentDevice] isMultitaskingSupported]) {
        [[UIApplication sharedApplication] endBackgroundTask:backgroundRecordingId_];
    }	
}

/*!
 * returns recording video
 */
-(BOOL)isRecordingVideo
{
    return [movieFileOutput_ isRecording];
}

/*!
 * did start recording
 */
- (void) captureOutput:(AVCaptureFileOutput *)captureOutput
didStartRecordingToOutputFileAtURL:(NSURL *)fileURL
       fromConnections:(NSArray *)connections{
    videoElapsedTimer_ = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(onVideoRecordingTimer) userInfo:nil repeats:YES];
    [videoElapsedTimer_ fire];
    if([self.delegate respondsToSelector:@selector(cameraControllerDidStartRecording:)]){
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
    if([self.delegate respondsToSelector:@selector(cameraController:didFinishRecordingToOutputFileURL:length:error:)]){
        [self.delegate cameraController:self didFinishRecordingVideoToOutputFileURL:anOutputFileURL length:videoElapsedTimer_.timeInterval error:error];
    }
    [videoElapsedTimer_ invalidate];
    if(error){
        NSLog(@"%s, %@", __PRETTY_FUNCTION__, error.description);
    }
}        

#pragma mark - public property implementations
/*!
 * set mode
 */
-(void)setMode:(AVFoundationCameraMode)mode{
    mode_ = mode;
    [self updateCameraControls];
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
    for (AVCaptureConnection* connection in imageOutput_.connections) {
        connection.videoOrientation = videoOrientation_;
    }
    
    viewOrientation_ = deviceOrientation;
}
@end
