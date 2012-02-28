//
//  TwitterPhotoSubmitterSettingTableViewController.m
//  tottepost
//
//  Created by Kentaro ISHITOYA on 12/02/13.
//  Copyright (c) 2012 cocotomo All rights reserved.
//

#import "TwitterPhotoSubmitterSettingTableViewController.h"
#import "TwitterPhotoSubmitter.h"
#import "TTLang.h"

#define TSV_SECTION_COUNT 2
#define TSV_SECTION_ACCOUNTS 1
#define TSV_ROW

//-----------------------------------------------------------------------------
//Private Implementations
//-----------------------------------------------------------------------------
@interface TwitterPhotoSubmitterSettingTableViewController(PrivateImplementation)
- (void) setupInitialState;
- (void) didLogoutButtonTapped:(id)sender;
- (TwitterPhotoSubmitter *)twitterSubmitter;
@end

@implementation TwitterPhotoSubmitterSettingTableViewController(PrivateImplementation)
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

/*!
 * get submitter as twitter submitter
 */
- (TwitterPhotoSubmitter *)twitterSubmitter{
    return (TwitterPhotoSubmitter *)self.submitter;
}
@end

//-----------------------------------------------------------------------------
//Public Implementations
//-----------------------------------------------------------------------------
@implementation TwitterPhotoSubmitterSettingTableViewController

#pragma mark -
#pragma mark tableview methods
/*! 
 * get section number
 */
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return TSV_SECTION_COUNT;
}

/*!
 * get row number
 */
- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case FSV_SECTION_ACCOUNT: return 2;
        case TSV_SECTION_ACCOUNTS: return self.twitterSubmitter.accounts.count;
    }
    return 0;
}

/*!
 * title for section
 */
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    switch (section) {
        case FSV_SECTION_ACCOUNT: return [self.submitter.name stringByAppendingString:[TTLang lstr:@"Detail_Section_Account"]] ; break;
        case TSV_SECTION_ACCOUNTS: return [self.submitter.name stringByAppendingString:[TTLang lstr:@"Detail_Section_Twitter_Accounts"]] ; break;
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
    }else if(indexPath.section == TSV_SECTION_ACCOUNTS){
        ACAccount *account = 
          [self.twitterSubmitter.accounts objectAtIndex:indexPath.row];
        cell.textLabel.text = account.username;
        if([account.username isEqualToString:self.twitterSubmitter.selectedAccountUsername]){
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }else{
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    return cell;
}


/*!
 * will select row at path
 */
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == TSV_SECTION_ACCOUNTS){
        ACAccount *account = 
        [self.twitterSubmitter.accounts objectAtIndex:indexPath.row];
        if([account.username isEqualToString:self.twitterSubmitter.selectedAccountUsername]){
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }else{
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
}

/*!
 * on row selected
 */
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == TSV_SECTION_ACCOUNTS){
        ACAccount *account = 
        [self.twitterSubmitter.accounts objectAtIndex:indexPath.row];
        if([account.username isEqualToString:self.twitterSubmitter.selectedAccountUsername] == NO){
            self.twitterSubmitter.selectedAccountUsername = account.username;
            [self.tableView reloadData];
            [self.twitterSubmitter login];
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated: YES];
}

#pragma mark -
#pragma mark UIView delegate
/*!
 * albums
 */
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.submitter updateUsernameWithDelegate:self];
}
@end
