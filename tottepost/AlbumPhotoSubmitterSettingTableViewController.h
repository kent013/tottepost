//
//  AlbumPhotoSubmitterSettingViewController.h
//  tottepost
//
//  Created by ISHITOYA Kentaro on 11/12/12.
//  Copyright (c) 2011 cocotomo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBConnect.h"
#import "PhotoSubmitterProtocol.h"
#import "PhotoSubmitterSettingTableViewController.h"

@interface AlbumPhotoSubmitterSettingTableViewController : PhotoSubmitterSettingTableViewController<PhotoSubmitterSettingTableViewProtocol, PhotoSubmitterDataDelegate>{
    int selectedAlbumIndex_;
}
@end
