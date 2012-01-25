//
//  SettingIndicatorView.h
//  tottepost
//
//  Created by ISHITOYA Kentaro on 12/01/01.
//  Copyright (c) 2012 cocotomo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingIndicatorView : UIView{
    __strong UILabel *label_;
}
@property (nonatomic, readonly) CGSize contentSize;
- (void) update;
@end
