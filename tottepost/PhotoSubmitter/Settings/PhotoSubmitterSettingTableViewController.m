//
//  SettingViewController.m
//  tottepost
//
//  Created by ISHITOYA Kentaro on 11/12/11.
//  Copyright (c) 2011 cocotomo. All rights reserved.
//

#import "PhotoSubmitterSettingTableViewController.h"
#import "PhotoSubmitterSettingTableViewProtocol.h"
#import "PhotoSubmitterServiceSettingTableViewController.h"
#import "PhotoSubmitterSettings.h"
#import "PSLang.h"
#import "PhotoSubmitterSwitch.h"

//-----------------------------------------------------------------------------
//Private Implementations
//-----------------------------------------------------------------------------
@interface PhotoSubmitterSettingTableViewController(PrivateImplementation)
- (void) setupInitialState;
- (PhotoSubmitterServiceSettingTableViewController *)settingTableViewControllerForType:(NSString *) type;
- (void) settingDone:(id)sender;
- (UITableViewCell *) createSocialAppButtonWithTag:(int)tag;
- (void) didSocialAppSwitchChanged:(id)sender;
- (void) didGeneralSwitchChanged:(id)sender;
- (NSString *) indexToSubmitterType:(int) index;
- (int) submitterTypeToIndex:(NSString *) type;
- (UISwitch *)createSwitchWithTag:(int)tag on:(BOOL)on;
- (void) sortSocialAppCell;
- (void) updateSubmitterEnabledDates;
@end

#pragma mark -
#pragma mark Private Implementations
@implementation PhotoSubmitterSettingTableViewController(PrivateImplementation)
/*!
 * setup initial state
 */
- (void)setupInitialState{
    self.tableView.delegate = self;
    switches_ = [[NSMutableArray alloc] init];
    settingControllers_ = [[NSMutableDictionary alloc] init];
    
    for(NSString *type in [PhotoSubmitterManager registeredPhotoSubmitters]){
        id<PhotoSubmitterProtocol> submitter = [PhotoSubmitterManager submitterForType:type];
        PhotoSubmitterServiceSettingTableViewController *settingView = 
          submitter.settingView;
        if(settingView != nil){
            [settingControllers_ setObject:settingView forKey:type];
        }
    }
    
    [[PhotoSubmitterManager sharedInstance] setAuthenticationDelegate:self];
    
    NSDictionary *submitterEnabledDates = [PhotoSubmitterSettings getInstance].submitterEnabledDates;
    NSArray *keys = [submitterEnabledDates allKeys];
    if(submitterEnabledDates == nil || 
       [PhotoSubmitterManager registeredPhotoSubmitterCount] != submitterEnabledDates.count){
        keys = [PhotoSubmitterManager registeredPhotoSubmitters];
    }
    int i = 0;
    for(NSString *type in keys){
        PhotoSubmitterSwitch *s = [[PhotoSubmitterSwitch alloc] init];
        s.submitterType = type;
        s.index = i;
        s.onEnabled = [submitterEnabledDates objectForKey:type];
        [s addTarget:self action:@selector(didSocialAppSwitchChanged:) forControlEvents:UIControlEventValueChanged];
        [switches_ addObject:s];
        i++;
    }
    [self sortSocialAppCell];
}

/*!
 * get setting table view fo type
 */
- (PhotoSubmitterServiceSettingTableViewController *)settingTableViewControllerForType:(NSString *)type{
    return [settingControllers_ objectForKey:type];
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
        case SV_SECTION_GENERAL: return SV_GENERAL_COUNT;
        case SV_SECTION_ACCOUNTS: return [PhotoSubmitterManager registeredPhotoSubmitterCount];
    }
    return 0;
}

/*!
 * title for section
 */
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    switch (section) {
        case SV_SECTION_GENERAL : return [PSLang localized:@"Settings_Section_General"]; break;
        case SV_SECTION_ACCOUNTS: return [PSLang localized:@"Settings_Section_Accounts"]; break;
    }
    return nil;
}

/*!
 * footer for section
 */
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section{
    switch (section) {
        case SV_SECTION_GENERAL : break;
        case SV_SECTION_ACCOUNTS: return [PSLang localized:@"Settings_Section_Accounts_Footer"]; break;
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
 * create social app button
 */
-(UITableViewCell *) createSocialAppButtonWithTag:(int)tag{
    NSString *type = [self indexToSubmitterType:tag];
    id<PhotoSubmitterProtocol> submitter = [PhotoSubmitterManager submitterForType:type];
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    cell.imageView.image = submitter.icon;
    cell.textLabel.text = submitter.displayName;
    PhotoSubmitterSwitch *s = [switches_ objectAtIndex:tag];
    cell.accessoryView = s;
    if([submitter isLogined]){
        [s setOn:YES animated:NO];
    }else{
        [s setOn:NO animated:NO];
    }
    return cell;
}
     
/*!
 * on row selected
 */
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == SV_SECTION_ACCOUNTS){
        NSString * type = (NSString *)[self indexToSubmitterType:indexPath.row];
        id<PhotoSubmitterProtocol> submitter = [PhotoSubmitterManager submitterForType:type];
        if(submitter.isEnabled){
            PhotoSubmitterServiceSettingTableViewController *vc = [self settingTableViewControllerForType:type];
            if(vc != nil){
                [self.navigationController pushViewController:vc animated:YES];
            }
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated: YES];
}

/*!
 * sort social app cell by switch state
 */
- (void) sortSocialAppCell{
    [switches_ sortUsingComparator:^(PhotoSubmitterSwitch *a, PhotoSubmitterSwitch *b){
        return [b.onEnabled compare:a.onEnabled];
    }];
    
    for(int index = 0; index < switches_.count; index++){
        PhotoSubmitterSwitch *s = [switches_ objectAtIndex:index];
        s.index = index;
    }
    
    [self updateSubmitterEnabledDates];
    [self.tableView reloadData];
}

/*!
 * upldate support type index
 */
- (void) updateSubmitterEnabledDates{
    NSMutableDictionary *enabledDates = [[NSMutableDictionary alloc] init];
    for(PhotoSubmitterSwitch *s in switches_){
        if(s.onEnabled == nil){
            s.onEnabled = [NSDate distantPast];
        }
        [enabledDates setObject:s.onEnabled forKey:s.submitterType];
    }
    [PhotoSubmitterSettings getInstance].submitterEnabledDates = enabledDates;
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
    PhotoSubmitterSwitch *s = (PhotoSubmitterSwitch *)sender;
    NSString *type = [self indexToSubmitterType:s.index];
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
    PhotoSubmitterSettings *settings = [PhotoSubmitterSettings getInstance];
    UISwitch *s = (UISwitch *)sender;
    switch(s.tag){
        case SV_GENERAL_COMMENT: 
            settings.commentPostEnabled = s.on; 
            break;
        case SV_GENERAL_GPS:
            settings.gpsEnabled = s.on;
            [PhotoSubmitterManager sharedInstance].enableGeoTagging = s.on;
            break;
    }
}

/*!
 * create switch with tag
 */
- (UISwitch *)createSwitchWithTag:(int)tag on:(BOOL)on{
    PhotoSubmitterSwitch *s = [[PhotoSubmitterSwitch alloc] initWithFrame:CGRectZero];
    s.on = on;
    s.tag = tag;
    return s;
}

#pragma mark -
#pragma mark conversion methods
/*!
 * convert index to NSString *
 */
- (NSString *)indexToSubmitterType:(int)index{
    for(PhotoSubmitterSwitch *s in switches_){
        if(s.index == index){
            return s.submitterType;
        }
    }    
    return nil;
}

/*!
 * convert NSString * to index
 */
- (int)submitterTypeToIndex:(NSString *)type{
    for(PhotoSubmitterSwitch *s in switches_){
        if([s.submitterType isEqualToString:type]){
            return s.index;
        }
    }
    return SWITCH_NOTFOUND;
}
@end

//-----------------------------------------------------------------------------
//Public Implementations
#pragma mark -
#pragma mark Public Implementations
//-----------------------------------------------------------------------------
@implementation PhotoSubmitterSettingTableViewController
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

/*!
 * update social app switches
 */
- (void)updateSocialAppSwitches{
    for(int i = 0; i < switches_.count; i++){
        PhotoSubmitterSwitch *s = [switches_ objectAtIndex:i];
        id<PhotoSubmitterProtocol> submitter = [PhotoSubmitterManager submitterForType:s.submitterType];
        BOOL isLogined = submitter.isLogined;
        if(isLogined == NO){
            [submitter disable];
        }
        [s setOn:isLogined animated:YES];
    }
}


/*!
 * create general setting cell
 */
- (UITableViewCell *)createGeneralSettingCell:(int)tag{
    PhotoSubmitterSettings *settings = [PhotoSubmitterSettings getInstance];
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    UISwitch *s = nil;
    switch (tag) {
        case SV_GENERAL_COMMENT:
            cell.textLabel.text = [PSLang localized:@"Settings_Row_Comment"];
            s = [self createSwitchWithTag:tag on:settings.commentPostEnabled];
            [s addTarget:self action:@selector(didGeneralSwitchChanged:) forControlEvents:UIControlEventValueChanged];
            cell.accessoryView = s;
            break;
        case SV_GENERAL_GPS:
            cell.textLabel.text = [PSLang localized:@"Settings_Row_GPSTagging"];
            UISwitch *s = [self createSwitchWithTag:tag on:settings.gpsEnabled];
            [s addTarget:self action:@selector(didGeneralSwitchChanged:) forControlEvents:UIControlEventValueChanged];
            cell.accessoryView = s;
            break;
    }
    return cell;
}

#pragma mark -
#pragma mark PhotoSubmitterAuthDelegate delegate methods
/*!
 * photo submitter did login
 */
- (void)photoSubmitter:(id<PhotoSubmitterProtocol>)photoSubmitter didLogin:(NSString *)type{
    int index = [self submitterTypeToIndex:type];
    UISwitch *s = [switches_ objectAtIndex:index];
    [s setOn:YES animated:YES];
    [self sortSocialAppCell];
}

/*!
 * photo submitter did logout
 */
- (void)photoSubmitter:(id<PhotoSubmitterProtocol>)photoSubmitter didLogout:(NSString *)type{
    int index = [self submitterTypeToIndex:type];
    UISwitch *s = [switches_ objectAtIndex:index];
    [s setOn:NO animated:YES];    
    [self sortSocialAppCell];
}

/*!
 * photo submitter start authorization
 */
- (void)photoSubmitter:(id<PhotoSubmitterProtocol>)photoSubmitter willBeginAuthorization:(NSString *)type{
}

/*!
 * photo submitter authorization finished
 */
- (void)photoSubmitter:(id<PhotoSubmitterProtocol>)photoSubmitter didAuthorizationFinished:(NSString *)type{
}

#pragma mark -
#pragma mark UIViewController methods
- (void)viewDidAppear:(BOOL)animated{
    [[PhotoSubmitterManager sharedInstance] refreshCredentials];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(settingDone:)];
    [self.navigationItem setRightBarButtonItem:doneButton animated:YES];
    [self setTitle:[PSLang localized:@"Settings_Title"]];
    
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:SV_GENERAL_COMMENT inSection:SV_SECTION_GENERAL], nil] withRowAnimation:NO];
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
@end
