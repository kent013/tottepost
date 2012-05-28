//
//  FlashView.h
//  SketchTest
//
//  Created by Ken Watanabe on 12/05/27.
//

#import <UIKit/UIKit.h>

@interface FlashView : UIImageView{
    NSTimeInterval flashInterval_;
    float firstAlpha_;
}

- (void) flash;

@property (nonatomic,assign) NSTimeInterval flashInterval;

@end
