//
//  MainViewController.h
//  tottepost mainview controller   	
//
//  Created by Ken Watanabe on 11/12/10.
//  Copyright (c) 2011 cocotomo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SettingViewController.h"
#import "Facebook.h"

/*!
 * Main view controller
 */
@interface MainViewController : UIViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate>{
@protected
    __strong SettingViewController *settingViewController_;
    __strong UINavigationController *settingNavigationController_;
    __strong UIImagePickerController* imagePicker_;
    __strong UIBarButtonItem* cameraButton_;
    __strong UIButton *settingButton_;
    __strong UIView *imagePickerOverlayView_;
    UIDevice* device_;
    int row;
    int prevRow;
}

@property (nonatomic, readonly) Facebook *facebook;

- (id) initWithFrame:(CGRect)frame;
- (void) createCameraController;
- (void) viewDidShow: (UIView *)view;

@end
