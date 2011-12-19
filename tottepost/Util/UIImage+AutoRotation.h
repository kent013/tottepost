//
//  UIImage+AutoRotation.h
//  iSticky
//
//  Created by ISHITOYA Kentaro on 11/10/18.
//  Copyright (c) 2011 cocotomo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (AutoRotation)
- (CGImageRef)CGImageRotatedByAngle :(CGFloat)angle;
- (CGImageRef)CGImageAutoRotated;
- (UIImage*) UIImageAutoRotated;
@end
