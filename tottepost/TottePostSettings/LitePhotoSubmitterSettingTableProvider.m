//
//  LiteAlbumPhotoSubmitterSettingTableViewController.m
//  tottepost
//
//  Created by Kentaro ISHITOYA on 12/03/19.
//  Copyright (c) 2012 cocotomo. All rights reserved.
//

#import "LitePhotoSubmitterSettingTableProvider.h"
#import "MAConfirmButton.h"
#import "TTLang.h"
#import "PSLang.h"

#define FSV_SECTION_ALBUMS 1

//-----------------------------------------------------------------------------
//Private Implementations
//-----------------------------------------------------------------------------
@interface LitePhotoSubmitterSettingTableProvider(PrivateImplementatio)
- (void) handleProButtonTapped:(id)sender;
@end

@implementation LitePhotoSubmitterSettingTableProvider(PrivateImplementation)
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
@implementation LitePhotoSubmitterSettingTableProvider
/*!
 * sections
 */
- (NSInteger)settingViewController:(PhotoSubmitterServiceSettingTableViewController *)settingViewController numberOfSectionsInTableView:(UITableView *)tableView{
    return -1;
}

/*!
 * rows
 */
- (NSInteger)settingViewController:(PhotoSubmitterServiceSettingTableViewController *)settingViewController tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section{
    return -1;
}


/*!
 * header
 */
- (NSString *)settingViewController:(PhotoSubmitterServiceSettingTableViewController *)settingViewController tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return nil;
}

/*!
 * footer
 */
- (NSString *)settingViewController:(PhotoSubmitterServiceSettingTableViewController *)settingViewController tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section{
    return nil;
}

/*!
 * request for cell
 */
- (UITableViewCell *)settingViewController:(PhotoSubmitterServiceSettingTableViewController *)settingViewController tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if([settingViewController isKindOfClass:[AlbumPhotoSubmitterSettingTableViewController class]]){
        if(indexPath.section == FSV_SECTION_ALBUMS && 
           settingViewController.submitter.isAlbumSupported){
            if(settingViewController.submitter.albumList.count == indexPath.row){
                UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
                cell.textLabel.text = [PSLang localized:@"Album_Detail_Section_Create_Album_Title"];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                MAConfirmButton *proButton = [MAConfirmButton buttonWithTitle:@"PRO" confirm:[TTLang localized:@"AppStore_Open"]];
                [proButton addTarget:self action:@selector(handleProButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
                cell.accessoryView = proButton;
                cell.textLabel.textColor = [UIColor grayColor];
                return cell;
            }
        }
    }
    if(indexPath.section == SV_SECTION_ACCOUNT &&
             indexPath.row == SV_ROW_ACCOUNT_ADD){
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
        cell.textLabel.text = [PSLang localized:@"Detail_Row_AddAccount"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        MAConfirmButton *proButton = [MAConfirmButton buttonWithTitle:@"PRO" confirm:[TTLang localized:@"AppStore_Open"]];
        [proButton addTarget:self action:@selector(handleProButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        cell.accessoryView = proButton;
        cell.textLabel.textColor = [UIColor grayColor];
        return cell;
    }
    return nil;
}

/*!
 * cell selected
 */
- (BOOL)settingViewController:(PhotoSubmitterServiceSettingTableViewController *)settingViewController tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if([settingViewController isKindOfClass:[AlbumPhotoSubmitterSettingTableViewController class]]){
        if(indexPath.section == FSV_SECTION_ALBUMS && 
           settingViewController.submitter.isAlbumSupported && 
           indexPath.row == settingViewController.submitter.albumList.count){
            [tableView deselectRowAtIndexPath:indexPath animated: YES];
            return YES;
            
        }
    }
    if(indexPath.section == SV_SECTION_ACCOUNT &&
             indexPath.row == SV_ROW_ACCOUNT_ADD){
        [tableView deselectRowAtIndexPath:indexPath animated: YES];
        return YES;
    }
    return NO;
}
@end
