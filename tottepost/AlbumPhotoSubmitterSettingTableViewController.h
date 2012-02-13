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
#import "SimplePhotoSubmitterSettingTableViewController.h"
#import "CreateAlbumPhotoSubmitterSettingViewController.h"

@interface AlbumPhotoSubmitterSettingTableViewController : SimplePhotoSubmitterSettingTableViewController{
    int selectedAlbumIndex_;
    CreateAlbumPhotoSubmitterSettingViewController *createAlbumViewController_;
}
@end
