//
//  LiteAlbumPhotoSubmitterSettingTableViewController.m
//  tottepost
//
//  Created by Kentaro ISHITOYA on 12/03/19.
//  Copyright (c) 2012 cocotomo. All rights reserved.
//

#import "LiteAlbumPhotoSubmitterSettingTableViewController.h"
#import "MAConfirmButton.h"

#define FSV_SECTION_ALBUMS 1

//-----------------------------------------------------------------------------
//Private Implementations
//-----------------------------------------------------------------------------
@interface LiteAlbumPhotoSubmitterSettingTableViewController(PrivateImplementatio)
@end

@implementation LiteAlbumPhotoSubmitterSettingTableViewController(PrivateImplementation)
@end

//-----------------------------------------------------------------------------
//Public Implementations
//----------------------------------------------------------------------------
@implementation LiteAlbumPhotoSubmitterSettingTableViewController
/*!
 * create cell
 */
-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    if(indexPath.section == FSV_SECTION_ALBUMS && self.submitter.isAlbumSupported){
        if(self.submitter.albumList.count == indexPath.row){
            MAConfirmButton *disabledButton = [MAConfirmButton buttonWithDisabledTitle:@"PRO"];
            cell.accessoryView = disabledButton;
            cell.textLabel.textColor = [UIColor grayColor];
        }
    }
    return cell;
}


/*!
 * on row selected
 */
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == FSV_SECTION_ALBUMS && self.submitter.isAlbumSupported && 
       indexPath.row == self.submitter.albumList.count){
        [tableView deselectRowAtIndexPath:indexPath animated: YES];
    }else{
        [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    }
}
@end
