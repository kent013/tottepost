//
//  AboutSettingViewController.h
//  tottepost
//
//  Created by Kentaro ISHITOYA on 12/01/27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AAMFeedbackViewController.h"

@interface AboutSettingViewController : UIViewController{
    __strong UITextView *textView_;
    __strong UIButton *feedbackButton_;
    __strong AAMFeedbackViewController *feetbackViewController_;
}
@end
