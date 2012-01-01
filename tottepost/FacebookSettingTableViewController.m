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

#define FSV_BUTTON_TYPE 102
//-----------------------------------------------------------------------------
//Private Implementations
//-----------------------------------------------------------------------------
@interface FacebookSettingTableViewController(PrivateImplementation)
- (void) setupInitialState;
@end

@implementation FacebookSettingTableViewController(PrivateImplementation)
/*!
 * initialize
 */
-(void)setupInitialState{

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
    self = [super initWithType:PhotoSubmitterTypeFacebook];
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
    [self.submitter updateAlbumListWithDelegate:self];
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
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case FSV_SECTION_ALBUMS: return [PhotoSubmitterManager submitterForType:PhotoSubmitterTypeFacebook].albumList.count;
    }
    return [super tableView:tableView numberOfRowsInSection:section];
}

/*!
 * title for section
 */
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    switch (section) {
        case FSV_SECTION_ALBUMS : return [TTLang lstr:@"Detail_Section_Album"]; break;
    }
    return [super tableView:tableView titleForHeaderInSection:section];
}

/*!
 * footer for section
 */
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section{
    switch (section){
        case FSV_SECTION_ALBUMS: return [TTLang lstr:@"Facebook_Detail_Section_Album_Footer"];
    }
    return [super tableView:tableView titleForFooterInSection:section];;
}

/*!
 * create cell
 */
-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    if(indexPath.section == FSV_SECTION_ALBUMS){
        PhotoSubmitterAlbumEntity *album = [self.submitter.albumList objectAtIndex:indexPath.row];
        cell.textLabel.text = [NSString stringWithFormat:@"%@ (privacy:%@)", album.name, album.privacy];
        if([album.albumId isEqualToString: self.submitter.targetAlbum.albumId]){
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
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
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