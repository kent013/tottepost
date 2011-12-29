//
//  DropboxSettingTableViewController.m
//  tottepost
//
//  Created by ISHITOYA Kentaro on 11/12/22.
//  Copyright (c) 2011 cocotomo. All rights reserved.
//

#import "DropboxSettingTableViewController.h"
#import "PhotoSubmitterManager.h"
#import "TTLang.h"
#define FSV_SECTION_ACCOUNT 0
#define FSV_ROW_ACCOUNT_NAME 0
#define FSV_ROW_ACCOUNT_LOGOUT 1

#define FSV_BUTTON_TYPE 102
//-----------------------------------------------------------------------------
//Private Implementations
//-----------------------------------------------------------------------------
@interface DropboxSettingTableViewController(PrivateImplementation)
- (void) setupInitialState;
- (void) didLogoutButtonTapped:(id)sender;
@end

@implementation DropboxSettingTableViewController(PrivateImplementation)
/*!
 * initialize
 */
-(void)setupInitialState{
    
}

/*!
 * did logout button tapped
 */
- (void)didLogoutButtonTapped:(id)sender{
    [[PhotoSubmitterManager submitterForType:PhotoSubmitterTypeDropbox] logout];
    [self.navigationController popViewControllerAnimated:YES];
}
@end

//-----------------------------------------------------------------------------
//Public Implementations
//-----------------------------------------------------------------------------
@implementation DropboxSettingTableViewController
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
    id<PhotoSubmitterProtocol> submitter = [PhotoSubmitterManager submitterForType:PhotoSubmitterTypeFacebook];
    switch (section) {
        case FSV_SECTION_ACCOUNT: return [submitter.name stringByAppendingString:[TTLang lstr:@"Detail_Section_Account"]] ; break;
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
    id<PhotoSubmitterProtocol> submitter = [PhotoSubmitterManager submitterForType:PhotoSubmitterTypeDropbox];
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
        
    }
    return cell;
}


/*!
 * on row selected
 */
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated: YES];
}
@end
