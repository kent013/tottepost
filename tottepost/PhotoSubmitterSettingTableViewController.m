//
//  PhotoSubmitterSettingTableViewController.m
//  tottepost
//
//  Created by Kentaro ISHITOYA on 12/01/02.
//  Copyright (c) 2012 cocotomo All rights reserved.
//

#import "PhotoSubmitterSettingTableViewController.h"
#import "TTLang.h"

//-----------------------------------------------------------------------------
//Private Implementations
//-----------------------------------------------------------------------------
@interface PhotoSubmitterSettingTableViewController(PrivateImplementation)
- (void) setupInitialState;
- (void) didLogoutButtonTapped:(id)sender;
@end

@implementation PhotoSubmitterSettingTableViewController(PrivateImplementation)
/*!
 * initialize
 */
-(void)setupInitialState{
}

/*!
 * did logout button tapped
 */
- (void)didLogoutButtonTapped:(id)sender{
    [self.submitter logout];
    [self.navigationController popViewControllerAnimated:YES];
}
@end

//-----------------------------------------------------------------------------
//Public Implementations
//-----------------------------------------------------------------------------
@implementation PhotoSubmitterSettingTableViewController
/*!
 * initialize
 */
- (id)initWithType:(PhotoSubmitterType)type{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if(self){
        type_ = type;
        [self setupInitialState];
    }
    return self;
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
    }
    return 0;
}

/*!
 * title for section
 */
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    switch (section) {
        case FSV_SECTION_ACCOUNT: return [self.submitter.name stringByAppendingString:[TTLang lstr:@"Detail_Section_Account"]] ; break;
    }
    return nil;
}

/*!
 * footer for section
 */
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section{
    return nil;    
}

/*!
 * create cell
 */
-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    if(indexPath.section == FSV_SECTION_ACCOUNT){
        if(indexPath.row == FSV_ROW_ACCOUNT_NAME){
            cell.textLabel.text = [TTLang lstr:@"Detail_Row_AccountName"];
            UILabel *label = [[UILabel alloc] init];
            label.text = self.submitter.username;
            label.font = [UIFont systemFontOfSize:15.0];
            [label sizeToFit];
            label.backgroundColor = [UIColor clearColor];
            cell.accessoryView = label;
        }else if(indexPath.row == FSV_ROW_ACCOUNT_LOGOUT){
            cell.textLabel.text = [TTLang lstr:@"Detail_Row_Logout"];
            UIButton *button = [UIButton buttonWithType:FSV_BUTTON_TYPE];
            [button setTitle:[TTLang lstr:@"Detail_Row_LogoutButtonTitle"] forState:UIControlStateNormal];
            [button addTarget:self action:@selector(didLogoutButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
            cell.accessoryView = button;
        }
        
    }
    return cell;
}


/*!
 * on row selected
 */
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated: YES];
}

#pragma mark -
#pragma mark PhotoSubmitterSettingTableViewProtocol methods
/*!
 * submitter
 */
- (id<PhotoSubmitterProtocol>)submitter{
    return [PhotoSubmitterManager submitterForType:self.type];
}

/*!
 * type
 */
- (PhotoSubmitterType)type{
    return type_;
}

#pragma mark -
#pragma mark UIView delegate
/*!
 * auto rotation
 */
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        if(interfaceOrientation == UIInterfaceOrientationPortrait ||
           interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown){
            return YES;
        }
        return NO;
    }
    return YES;
}

/*!
 * albums
 */
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.submitter updateUsernameWithDelegate:self];
}

#pragma mark -
#pragma mark PhotoSubmitterAlbumDelegate methods
/*!
 * album
 */
- (void)photoSubmitter:(id<PhotoSubmitterProtocol>)photoSubmitter didAlbumUpdated:(NSMutableArray *)albums{
    //Do nothing
}

/*!
 * username
 */
- (void) photoSubmitter:(id<PhotoSubmitterProtocol>)photoSubmitter didUsernameUpdated:(NSString *)username{
    [self.tableView reloadData];
}
@end
