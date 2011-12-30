//
//  SettingViewController.m
//  tottepost
//
//  Created by ISHITOYA Kentaro on 11/12/11.
//  Copyright (c) 2011 cocotomo. All rights reserved.
//

#import "SettingTableViewController.h"
#import "TottePostSettings.h"

#define SV_SECTION_GENERAL  0
#define SV_SECTION_ACCOUNTS 1

#define SV_GENERAL_COMMENT 0
#define SV_GENERAL_GPS 1

#define SV_ACCOUNTS_FACEBOOK 0
#define SV_ACCOUNTS_TWITTER 1
#define SV_ACCOUNTS_FLICKR 2
#define SV_ACCOUNTS_DROPBOX 3
#define SV_ACCOUNTS_FILE 4

//-----------------------------------------------------------------------------
//Private Implementations
//-----------------------------------------------------------------------------
@interface SettingTableViewController(PrivateImplementation)
- (void) setupInitialState;
- (void) settingDone:(id)sender;
- (UITableViewCell *) createGeneralSettingCell:(int)tag;
- (UITableViewCell *) createSocialAppButtonWithTag:(int)tag;
- (void) didSocialAppSwitchChanged:(id)sender;
- (void) didGeneralSwitchChanged:(id)sender;
- (PhotoSubmitterType) indexToSubmitterType:(int) index;
- (int) submitterTypeToIndex:(PhotoSubmitterType) type;
- (UISwitch *)createSwitchWithTag:(int)tag on:(BOOL)on;
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
    facebookSettingViewController_ = [[FacebookSettingTableViewController alloc] init];
    twitterSettingViewController_ = [[TwitterSettingTableViewController alloc] init];
    flickrSettingViewController_ = [[FlickrSettingTableViewController alloc] init];
    dropboxSettingViewController_ = [[DropboxSettingTableViewController alloc] init];
    
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
        case SV_SECTION_GENERAL: return 2;
        case SV_SECTION_ACCOUNTS: return 5;
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
 * footer for section
 */
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section{
    switch (section) {
        case SV_SECTION_GENERAL : break;
        case SV_SECTION_ACCOUNTS: return @"Tap account name to enter details."; break;
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
        cell = [self createGeneralSettingCell:indexPath.row];
    }else if(indexPath.section == SV_SECTION_ACCOUNTS){
        cell = [self createSocialAppButtonWithTag:indexPath.row];
    }
    return cell;
}

/*!
 * create general setting cell
 */
- (UITableViewCell *)createGeneralSettingCell:(int)tag{
    TottePostSettings *settings = [TottePostSettings getInstance];
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    UISwitch *s = nil;
    switch (tag) {
        case SV_GENERAL_COMMENT:
            cell.textLabel.text = @"Comment";
            s = [self createSwitchWithTag:tag on:settings.commentPostEnabled];
            [s addTarget:self action:@selector(didGeneralSwitchChanged:) forControlEvents:UIControlEventValueChanged];
            [cell.contentView addSubview:s];
            break;
        case SV_GENERAL_GPS:
            cell.textLabel.text = @"GPS tagging";
            UISwitch *s = [self createSwitchWithTag:tag on:settings.gpsEnabled];
            [s addTarget:self action:@selector(didGeneralSwitchChanged:) forControlEvents:UIControlEventValueChanged];
            [cell.contentView addSubview:s];
            break;
    }
    return cell;
}

/*!
 * create social app button
 */
-(UITableViewCell *) createSocialAppButtonWithTag:(int)tag{
    PhotoSubmitterType type = [self indexToSubmitterType:tag];
    id<PhotoSubmitterProtocol> submitter = [PhotoSubmitterManager submitterForType:type];
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    cell.imageView.image = submitter.icon;
    cell.textLabel.text = submitter.name;
    
    UISwitch *s = [self createSwitchWithTag:tag on:NO];
    [s addTarget:self action:@selector(didSocialAppSwitchChanged:) forControlEvents:UIControlEventValueChanged];
    [cell.contentView addSubview:s];
    [switches_ setObject:s forKey:[NSNumber numberWithInt:tag]];
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
            case SV_ACCOUNTS_FACEBOOK: 
                if([PhotoSubmitterManager submitterForType:PhotoSubmitterTypeFacebook].isEnabled){
                    [self.navigationController pushViewController:facebookSettingViewController_ animated:YES]; 
                }
                break;
            case SV_ACCOUNTS_TWITTER: 
                if([PhotoSubmitterManager submitterForType:PhotoSubmitterTypeTwitter].isEnabled){
                    [self.navigationController pushViewController:twitterSettingViewController_ animated:YES]; 
                }
                break;
            case SV_ACCOUNTS_FLICKR: 
                if([PhotoSubmitterManager submitterForType:PhotoSubmitterTypeFlickr].isEnabled){
                    [self.navigationController pushViewController:flickrSettingViewController_ animated:YES]; 
                }
                break;
            case SV_ACCOUNTS_DROPBOX: 
                if([PhotoSubmitterManager submitterForType:PhotoSubmitterTypeDropbox].isEnabled){
                    [self.navigationController pushViewController:dropboxSettingViewController_ animated:YES]; 
                }
                break;
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
    [self.delegate didDismissSettingTableViewController];
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

/*!
 * if social app switch changed
 */
- (void)didGeneralSwitchChanged:(id)sender{
    TottePostSettings *settings = [TottePostSettings getInstance];
    UISwitch *s = (UISwitch *)sender;
    switch(s.tag){
        case SV_GENERAL_COMMENT: 
            settings.commentPostEnabled = s.on; 
            break;
        case SV_GENERAL_GPS:
            settings.gpsEnabled = s.on;
            [PhotoSubmitterManager getInstance].enableGeoTagging = s.on;
            break;
    }
}

/*!
 * create switch with tag
 */
- (UISwitch *)createSwitchWithTag:(int)tag on:(BOOL)on{
    UISwitch *s = [[UISwitch alloc] initWithFrame:CGRectMake(self.tableView.frame.size.width - 150, 8, 100, 30)];
    s.tag = tag;
    s.on = on;
    return s;
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
@synthesize delegate;
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
