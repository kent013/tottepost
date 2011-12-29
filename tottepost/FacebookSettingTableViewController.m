//
//  FacebookSettingViewController.m
//  tottepost
//
//  Created by ISHITOYA Kentaro on 11/12/12.
//  Copyright (c) 2011 cocotomo. All rights reserved.
//

#import "FacebookSettingTableViewController.h"
#import "PhotoSubmitterManager.h"
#import "PhotoSubmitterAlbumEntity.h"
#import "RegexKitLite.h"
#import "TTLang.h"

#define FSV_SECTION_ACCOUNT 0
#define FSV_SECTION_ALBUMS 1
#define FSV_ROW_ACCOUNT_NAME 0
#define FSV_ROW_ACCOUNT_LOGOUT 1
#define TOTTEPOST_DEFAULT_ALBUM_NAME @"tottepost"

#define FSV_BUTTON_TYPE 102
//-----------------------------------------------------------------------------
//Private Implementations
//-----------------------------------------------------------------------------
@interface FacebookSettingTableViewController(PrivateImplementation)
- (void) setupInitialState;
- (void) didLogoutButtonTapped:(id)sender;
@end

@implementation FacebookSettingTableViewController(PrivateImplementation)
/*!
 * initialize
 */
-(void)setupInitialState{

}

/*!
 * did logout button tapped
 */
- (void)didLogoutButtonTapped:(id)sender{
    [[PhotoSubmitterManager submitterForType:PhotoSubmitterTypeFacebook] logout];
    [self.navigationController popViewControllerAnimated:YES];
}
@end

//-----------------------------------------------------------------------------
//Public Implementations
//-----------------------------------------------------------------------------
@implementation FacebookSettingTableViewController
/*!
 * initialize
 */
- (id)init{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if(self){
        [self setupInitialState];
    }
    return self;
}

/*!
 * albums
 */
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    id<PhotoSubmitterProtocol> submitter = [PhotoSubmitterManager submitterForType:PhotoSubmitterTypeFacebook];
    [submitter updateAlbumListWithDelegate:self];
}

#pragma mark -
#pragma mark tableview methods
/*! 
 * get section number
 */
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

/*!
 * get row number
 */
- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case FSV_SECTION_ACCOUNT: return 2;
        case FSV_SECTION_ALBUMS: return [PhotoSubmitterManager submitterForType:PhotoSubmitterTypeFacebook].albumList.count;
    }
    return 0;
}

/*!
 * title for section
 */
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    id<PhotoSubmitterProtocol> submitter = [PhotoSubmitterManager submitterForType:PhotoSubmitterTypeFacebook];
    switch (section) {
        case FSV_SECTION_ACCOUNT: return [submitter.name stringByAppendingString:[TTLang lstr:@"Detail_Section_Account"]] ; break;
        case FSV_SECTION_ALBUMS : return [TTLang lstr:@"Detail_Section_Album"]; break;
    }
    return nil;
}

/*!
 * footer for section
 */
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section{
    switch (section){
        case FSV_SECTION_ALBUMS: return [TTLang lstr:@"Facebook_Detail_Section_Album_Footer"];
    }
    return nil;
}

/*!
 * create cell
 */
-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    id<PhotoSubmitterProtocol> submitter = [PhotoSubmitterManager submitterForType:PhotoSubmitterTypeFacebook];
    if(indexPath.section == FSV_SECTION_ACCOUNT){
        if(indexPath.row == FSV_ROW_ACCOUNT_NAME){
            cell.textLabel.text = [TTLang lstr:@"Detail_Row_AccountName"];
            UILabel *label = [[UILabel alloc] init];
            label.text = submitter.username;
            label.font = [UIFont systemFontOfSize:15.0];
            [label sizeToFit];
            label.backgroundColor = [UIColor clearColor];
            CGRect frame = label.frame;
            frame.origin.x = self.tableView.frame.size.width - frame.size.width - 70;
            frame.origin.y = 10;
            label.frame = frame;
            [cell.contentView addSubview:label];
        }else if(indexPath.row == FSV_ROW_ACCOUNT_LOGOUT){
            cell.textLabel.text = [TTLang lstr:@"Detail_Row_Logout"];
            UIButton *button = [UIButton buttonWithType:FSV_BUTTON_TYPE];
            button.frame = CGRectMake(self.tableView.frame.size.width - 130, 8, button.frame.size.width, button.frame.size.height);
            [button setTitle:[TTLang lstr:@"Detail_Row_LogoutButtonTitle"] forState:UIControlStateNormal];
            [button addTarget:self action:@selector(didLogoutButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:button];
        }
    }else if(indexPath.section == FSV_SECTION_ALBUMS){
        PhotoSubmitterAlbumEntity *album = [submitter.albumList objectAtIndex:indexPath.row];
        cell.textLabel.text = [NSString stringWithFormat:@"%@ (privacy:%@)", album.name, album.privacy];
        if([album.albumId isEqualToString: submitter.targetAlbum.albumId]){
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }
    return cell;
}


/*!
 * on row selected
 */
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == FSV_SECTION_ALBUMS){
        id<PhotoSubmitterProtocol> submitter = [PhotoSubmitterManager submitterForType:PhotoSubmitterTypeFacebook];
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        if(selectedAlbumIndex_ != indexPath.row){
            cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:selectedAlbumIndex_ inSection:FSV_SECTION_ALBUMS]];
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        submitter.targetAlbum = [submitter.albumList objectAtIndex:indexPath.row];
        selectedAlbumIndex_ = indexPath.row;
    }
    [tableView deselectRowAtIndexPath:indexPath animated: YES];
}

#pragma mark -
#pragma mark PhotoSubmitterAlbumDelegate methods
- (void)photoSubmitter:(id<PhotoSubmitterProtocol>)photoSubmitter didAlbumUpdated:(NSMutableArray *)albums{
    if(photoSubmitter.targetAlbum == nil){
        for(PhotoSubmitterAlbumEntity *album in albums){
            if([album.name isMatchedByRegex:TOTTEPOST_DEFAULT_ALBUM_NAME options:RKLCaseless inRange:NSMakeRange(0, album.name.length) error:nil]){
                photoSubmitter.targetAlbum = album;
                break;
            }
        }
    }
    [self.tableView reloadData];
}
@end