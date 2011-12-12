//
//  FacebookSettingViewController.h
//  tottepost
//
//  Created by ISHITOYA Kentaro on 11/12/12.
//  Copyright (c) 2011 cocotomo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBConnect.h"

@interface FacebookSettingViewController : UIViewController<FBSessionDelegate>{
    __strong Facebook *facebook_;
}

@property (nonatomic, readonly) Facebook* facebook;
@end
