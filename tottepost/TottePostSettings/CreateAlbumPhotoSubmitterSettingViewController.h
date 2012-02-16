//
//  CreateAlbumPhotoSubmitterSettingViewController.h
//  tottepost
//
//  Created by Kentaro ISHITOYA on 12/02/13.
//  Copyright (c) 2012 cocotomo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoSubmitterSettingTableViewController.h"

@interface CreateAlbumPhotoSubmitterSettingViewController : PhotoSubmitterSettingTableViewController<UITextFieldDelegate, PhotoSubmitterAlbumDelegate>{
    UITextField *titleField_;
}
@end
