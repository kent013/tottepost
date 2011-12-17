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
#define SV_ACCOUNTS_FLICKR 2

//-----------------------------------------------------------------------------
//Private Implementations
//-----------------------------------------------------------------------------
@interface SettingTableViewController(PrivateImplementation)
- (void) setupInitialState;
- (void) settingDone:(id)sender;
- (UITableViewCell *) createSocialAppButtonWithTitle:(NSString *)title imageName:(NSString *)imageName tag:(int)tag;
- (void) didSocialAppSwitchChanged:(id)sender;
- (PhotoSubmitterType) indexToSubmitterType:(int) index;
- (int) submitterTypeToIndex:(PhotoSubmitterType) type;
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
    
    accountTypes_ = [PhotoSubmitterManager getInstance].supportedTypes;
    
    [[PhotoSubmitterManager getInstance] setAuthenticationDelegate:self];
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
        }else if(indexPath.row == SV_ACCOUNTS_FLICKR){
            cell = [self createSocialAppButtonWithTitle: @"Flickr" imageName:@"flickr_32.png" tag:SV_ACCOUNTS_FLICKR];
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
    s.tag = tag;
    [switches_ setObject:s forKey:[NSNumber numberWithInt:tag]];
    
    PhotoSubmitterType type = [self indexToSubmitterType:tag];
    id<PhotoSubmitterProtocol> submitter = [PhotoSubmitterManager submitterForType:type];
    if([submitter isLogined]){
        [s setOn:YES animated:YES];
    }else{
        [s setOn:NO animated:YES];
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
    PhotoSubmitterType type = [self indexToSubmitterType:s.tag];
    id<PhotoSubmitterProtocol> submitter = [PhotoSubmitterManager submitterForType:type];
    if(s.on){
        [submitter login];
    }else{
        [submitter disable];
    }
}

#pragma mark -
#pragma mark conversion methods
/*!
 * convert index to PhotoSubmitterType
 */
- (PhotoSubmitterType)indexToSubmitterType:(int)index{
    return (PhotoSubmitterType)[[accountTypes_ objectAtIndex:index] intValue];
}

/*!
 * convert PhotoSubmitterType to index
 */
- (int)submitterTypeToIndex:(PhotoSubmitterType)type{
    return [accountTypes_ indexOfObject:[NSNumber numberWithInt:type]]; 
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
 * photo submitter did login
 */
- (void)photoSubmitter:(id<PhotoSubmitterProtocol>)photoSubmitter didLogin:(PhotoSubmitterType)type{
    int index = [self submitterTypeToIndex:type];
    UISwitch *s = [switches_ objectForKey:[NSNumber numberWithInt:index]];
    [s setOn:YES animated:YES];
}

/*!
 * photo submitter did logout
 */
- (void)photoSubmitter:(id<PhotoSubmitterProtocol>)photoSubmitter didLogout:(PhotoSubmitterType)type{
    int index = [self submitterTypeToIndex:type];
    UISwitch *s = [switches_ objectForKey:[NSNumber numberWithInt:index]];
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
