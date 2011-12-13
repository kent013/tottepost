//
//  SettingViewController.m
//  tottepost
//
//  Created by ISHITOYA Kentaro on 11/12/11.
//  Copyright (c) 2011 cocotomo. All rights reserved.
//

#import "SettingTableViewController.h"

#define SV_SECTION_GENERAL  0
#define SV_SECTION_ACCOUNTS 1

#define SV_ACCOUNTS_FACEBOOK 0
#define SV_ACCOUNTS_TWITTER 1
#define SV_ACCOUNTS_FLICKER 2

//-----------------------------------------------------------------------------
//Private Implementations
//-----------------------------------------------------------------------------
@interface SettingTableViewController(PrivateImplementation)
- (void) setupInitialState;
- (void) settingDone:(id)sender;
- (UITableViewCell *) createSocialAppButtonWithTitle:(NSString *)title imageName:(NSString *)imageName tag:(int)tag;
- (void) didSocialAppSwitchChanged:(id)sender;
@end

#pragma mark -
#pragma mark Private Implementations
@implementation SettingTableViewController(PrivateImplementation)
/*!
 * setup initial state
 */
- (void)setupInitialState{
    self.tableView.delegate = self;
    switches_ = [[NSMutableDictionary alloc] init];
    facebookSettingViewController_ = [[FacebookSettingViewController alloc] init];
    
    [PhotoSubmitter facebookPhotoSubmitter].delegate = self;
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
        case SV_SECTION_GENERAL: return 1;
        case SV_SECTION_ACCOUNTS: return 3;
    }
    return 0;
}

/*!
 * title for section
 */
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    switch (section) {
        case SV_SECTION_GENERAL : return @"General"; break;
        case SV_SECTION_ACCOUNTS: return @"Accounts"; break;
    }
    return nil;
}

/*!
 * create cell
 */
-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    UITableViewCell *cell;
    if(indexPath.section == SV_SECTION_GENERAL){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
        cell.textLabel.text = @"moge";
    }else if(indexPath.section == SV_SECTION_ACCOUNTS){
        if(indexPath.row == SV_ACCOUNTS_FACEBOOK){
            cell = [self createSocialAppButtonWithTitle: @"Facebook" imageName:@"facebook_32.png" tag:SV_ACCOUNTS_FACEBOOK];
        }else if(indexPath.row == SV_ACCOUNTS_TWITTER){
            cell = [self createSocialAppButtonWithTitle: @"Twitter" imageName:@"twitter_32.png" tag:SV_ACCOUNTS_TWITTER];
        }else if(indexPath.row == SV_ACCOUNTS_FLICKER){
            cell = [self createSocialAppButtonWithTitle: @"Flickr" imageName:@"flickr_32.png" tag:SV_ACCOUNTS_FLICKER];
        }
    }
    return cell;
}

/*!
 * create social app button
 */
-(UITableViewCell *) createSocialAppButtonWithTitle:(NSString *)title imageName:(NSString *)imageName tag:(int)tag{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    cell.imageView.image = [UIImage imageNamed:imageName];
    cell.textLabel.text = title;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    UISwitch *s = [[UISwitch alloc] initWithFrame:CGRectMake(self.tableView.frame.size.width - 180, 8, 100, 30)];
    [s addTarget:self action:@selector(didSocialAppSwitchChanged:) forControlEvents:UIControlEventValueChanged];
    [cell.contentView addSubview:s];
    [switches_ setObject:s forKey:[NSNumber numberWithInt:tag]];
    
    switch (tag) {
        case SV_ACCOUNTS_FACEBOOK:
            if ([[PhotoSubmitter facebookPhotoSubmitter] isLogined]){
                [s setOn:YES animated:YES];
            }else{
                [s setOn:NO animated:YES];
            }
            break;
    }
    return cell;
}
     
/*!
 * on row selected
 */
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == SV_SECTION_ACCOUNTS){
        switch (indexPath.row) {
            case SV_ACCOUNTS_FACEBOOK: [self.navigationController pushViewController:facebookSettingViewController_ animated:YES]; break;
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated: YES];
}

#pragma mark -
#pragma mark ui parts delegates
/*!
 * done button tapped
 */
- (void)settingDone:(id)sender{
    [self.parentViewController dismissModalViewControllerAnimated:YES];
}

/*!
 * if social app switch changed
 */
- (void)didSocialAppSwitchChanged:(id)sender{
    UISwitch *s = (UISwitch *)sender;
    switch (s.tag) {
        case SV_ACCOUNTS_FACEBOOK:
            if(s.on){
                [[PhotoSubmitter facebookPhotoSubmitter] login];
            }else{
                [[PhotoSubmitter facebookPhotoSubmitter] logout];
            }
            break;
    } 
}
@end

//-----------------------------------------------------------------------------
//Public Implementations
#pragma mark -
#pragma mark Public Implementations
//-----------------------------------------------------------------------------
@implementation SettingTableViewController
/*!
 * initialize with frame
 */
- (id) init{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if(self){
        [self setupInitialState];
    }
    return self;
}

#pragma mark -
#pragma mark FacebookSettingViewController delegate methods
/*!
 * facebook did login
 */
- (void)facebookPhotoSubmitterDidLogin{
    UISwitch *s = [switches_ objectForKey:[NSNumber numberWithInt:SV_ACCOUNTS_FACEBOOK]];
    [s setOn:YES animated:YES];
}

/*!
 * facebook did logout
 */
- (void)facebookPhotoSubmitterDidLogout{
    UISwitch *s = [switches_ objectForKey:[NSNumber numberWithInt:SV_ACCOUNTS_FACEBOOK]];
    [s setOn:NO animated:YES];    
}

#pragma mark -
#pragma mark UIViewController methods
- (void)viewDidAppear:(BOOL)animated{
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(settingDone:)];
    [self.navigationItem setRightBarButtonItem:doneButton animated:YES];
    [self setTitle:@"Settings"];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
