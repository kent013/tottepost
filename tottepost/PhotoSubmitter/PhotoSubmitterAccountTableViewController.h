//
//  PhotoSubmitterAccountView.h
//  tottepost
//
//  Created by Kentaro ISHITOYA on 12/02/18.
//  Copyright (c) 2012 cocotomo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoSubmitterProtocol.h"

@interface PhotoSubmitterAccountTableViewController : UITableViewController<UITextFieldDelegate>{
    __strong UITextField *usernameTextField_;
    __strong UITextField *passwordTextField_;
}

@property (nonatomic, assign) id<PhotoSubmitterPasswordAuthViewDelegate> delegate;
@end
