//
//  UIImage+AutoRotation.m
//  iSticky
//
//  Created by ISHITOYA Kentaro on 11/10/18.
//  Copyright (c) 2011 cocotomo. All rights reserved.
//

#import "UIImage+AutoRotation.h"

@implementation UIImage (AutoRotation)

/*!
 * return cgimage rotated specified angle
 */
- (CGImageRef)CGImageRotatedByAngle:(CGFloat)angle
{
    CGFloat angleInRadians = angle * (M_PI / 180);
    CGImageRef imgRef = self.CGImage;
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    

    CGRect imgRect = CGRectMake(0, 0, width, height);
    CGAffineTransform transform = CGAffineTransformMakeRotation(angleInRadians);
    CGRect rotatedRect = CGRectApplyAffineTransform(imgRect, transform);
    
    CGContextRef bmContext = CGBitmapContextCreate(NULL,
                                                   rotatedRect.size.width,
                                                   rotatedRect.size.height,
                                                   8,
                                                   0,
                                                   CGImageGetColorSpace(imgRef),
                                                   CGImageGetAlphaInfo(imgRef));
    CGContextSetInterpolationQuality(bmContext, kCGInterpolationNone);
    CGContextTranslateCTM(bmContext,
                          +(rotatedRect.size.width/2),
                          +(rotatedRect.size.height/2));
    CGContextRotateCTM(bmContext, angleInRadians);
    CGRect drawRect = CGRectMake(-width/2, -height/2, width, height);
    CGContextDrawImage(bmContext, drawRect, imgRef);
    
    CGImageRef rotatedImage = CGBitmapContextCreateImage(bmContext);
    CFRelease(bmContext);
    
    return rotatedImage;
}

/*!
 * return rotated image
 */
-(CGImageRef)CGImageAutoRotated{
    switch (self.imageOrientation) {
        case UIImageOrientationDown:
            return [self CGImageRotatedByAngle:180.0];
        case UIImageOrientationLeft:
            return [self CGImageRotatedByAngle:90.0];
        case UIImageOrientationRight:
            return [self CGImageRotatedByAngle:270.0];
        default:
            return self.CGImage;
    }
}

/*!
 * return rotated image
 */
-(UIImage *)UIImageAutoRotated{
    UIImage* image = [UIImage imageWithCGImage: self.CGImageAutoRotated];
    return image;
}

@end