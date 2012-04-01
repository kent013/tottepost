//
//  CMPopTipViewManager.h
//  tottepost
//
//  Created by Kentaro ISHITOYA on 12/04/01.
//  Copyright (c) 2012 cocotomo. All rights reserved.
//

#import "CMPopTipView.h"
#import <UIKit/UIKit.h>

typedef enum{
    CMPopTipTargetMainCommentButton,
    CMPopTipTargetMainCameraSwitch,
    CMPopTipTargetMainSettingButton,
    CMPopTipTargetMainProgressSummary,
    CMPopTipTargetMainVideoCamera
} CMPopTipTarget;

@interface CMPopTipViewManager : NSObject<CMPopTipViewDelegate>{
    NSMutableDictionary *tips_;
    CMPopTipView *currentlyShownView_;
}
- (void)markAsArchived:(CMPopTipTarget)target;
- (void) showTipsWithTarget:(CMPopTipTarget) target message:(NSString *)message atView:(id)view inView:(UIView *)inView animated:(BOOL)animated;
+ (CMPopTipViewManager *)sharedInstance;
@end
