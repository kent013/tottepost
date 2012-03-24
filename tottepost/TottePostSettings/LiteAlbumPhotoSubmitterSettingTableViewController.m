//
//  LiteAlbumPhotoSubmitterSettingTableViewController.m
//  tottepost
//
//  Created by Kentaro ISHITOYA on 12/03/19.
//  Copyright (c) 2012 cocotomo. All rights reserved.
//

#import "LiteAlbumPhotoSubmitterSettingTableViewController.h"
#import "MAConfirmButton.h"
#import "TTLang.h"

#define FSV_SECTION_ALBUMS 1

//-----------------------------------------------------------------------------
//Private Implementations
//-----------------------------------------------------------------------------
@interface LiteAlbumPhotoSubmitterSettingTableViewController(PrivateImplementatio)
- (void) handleProButtonTapped:(id)sender;
@end

@implementation LiteAlbumPhotoSubmitterSettingTableViewController(PrivateImplementation)
/*!
 * open app store
 */
- (void) handleProButtonTapped:(id)sender{
    NSString *stringURL = [TTLang localized:@"AppStore_Url_Pro"];
    NSURL *url = [NSURL URLWithString:stringURL];
    [[UIApplication sharedApplication] openURL:url]; 
}
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
            MAConfirmButton *proButton = [MAConfirmButton buttonWithTitle:@"PRO" confirm:[TTLang localized:@"AppStore_Open"]];
            [proButton addTarget:self action:@selector(handleProButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
            cell.accessoryView = proButton;
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
