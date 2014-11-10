//
//  ProgressSummaryView.h
//  tottepost
//
//  Created by ISHITOYA Kentaro on 11/12/21.
//  Copyright (c) 2011 cocotomo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ENGPhotoSubmitterProtocol.h"
#import "ENGPhotoSubmitterManager.h"

@interface ProgressSummaryView : UIView<ENGPhotoSubmitterPhotoDelegate,ENGPhotoSubmitterManagerDelegate,UIAlertViewDelegate>{
    __strong UILabel *textLabel_;
    __strong UIImageView *imageView;
    __strong UIImage *cancelImage;
    __strong UIImage *retryImage;
    int operationCount_;
    int enabledAppCount_;
    BOOL isVisible_;
}

-(void) updateWithFrame:(CGRect)frame;
@end
