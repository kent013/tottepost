//
//  CameraModeSwitchView.h
//  tottepost
//
//  Created by Kentaro ISHITOYA on 12/03/16.
//  Copyright (c) 2012 cocotomo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DCRoundSwitch.h"
#import "AVFoundationCameraController.h"

@protocol CameraModeSwitchViewDelegate;

@interface CameraModeSwitchView : UIView{
    __strong DCRoundSwitch *cameraModeSwitch_;
    __strong UIImageView *cameraModePictureImageView_;
    __strong UIImageView *cameraModeVideoImageView_;
}
@property (nonatomic, assign) id<CameraModeSwitchViewDelegate> delegate;
@end

@protocol CameraModeSwitchViewDelegate <NSObject>
- (void)cameraModeSwitchView:(CameraModeSwitchView *)cameraModeSwitchView didModeChangedTo:(AVFoundationCameraMode)mode;
@end