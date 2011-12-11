//
//  MainViewController.h
//  tottepost mainview controller   	
//
//  Created by Ken Watanabe on 11/12/10.
//  Copyright (c) 2011 cocotomo. All rights reserved.
//

#import <UIKit/UIKit.h>

/*!
 * Main view controller
 */
@interface MainViewController : UIViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate>{
    UIImagePickerController* imagePicker_;
    UIBarButtonItem* cameraButton_;
    UIDevice* device_;
    int row;
    int prevRow;
}

- (id)initWithFrame:(CGRect)frame;
- (void) createCameraController;
- (void) viewDidShow: (UIView *)view;

@end
