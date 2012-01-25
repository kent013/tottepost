//
//  ProgressSummaryView.h
//  tottepost
//
//  Created by ISHITOYA Kentaro on 11/12/21.
//  Copyright (c) 2011 cocotomo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoSubmitterProtocol.h"
#import "PhotoSubmitterManager.h"

@interface ProgressSummaryView : UIView<PhotoSubmitterPhotoDelegate,PhotoSubmitterManagerDelegate>{
    __strong UILabel *textLabel_;
    int operationCount_;
    int enabledAppCount_;
    BOOL isVisible_;
}

-(void) updateWithFrame:(CGRect)frame;
@end
