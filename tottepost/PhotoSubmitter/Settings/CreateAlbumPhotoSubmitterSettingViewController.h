//
//  CreateAlbumPhotoSubmitterSettingViewController.h
//  tottepost
//
//  Created by Kentaro ISHITOYA on 12/02/13.
//  Copyright (c) 2012 cocotomo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoSubmitterServiceSettingTableViewController.h"

@interface CreateAlbumPhotoSubmitterSettingViewController : PhotoSubmitterServiceSettingTableViewController<UITextFieldDelegate, PhotoSubmitterAlbumDelegate>{
    UITextField *titleField_;
}
@end
