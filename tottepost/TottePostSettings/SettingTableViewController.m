//
//  SettingViewController.m
//  tottepost
//
//  Created by ISHITOYA Kentaro on 11/12/11.
//  Copyright (c) 2011 cocotomo. All rights reserved.
//

#import "SettingTableViewController.h"
#import "TottePostSettings.h"
#import "TTLang.h"

#define SV_SECTION_GENERAL  0
#define SV_SECTION_ACCOUNTS 1

#define SV_GENERAL_COUNT 3
#define SV_GENERAL_COMMENT 0
#define SV_GENERAL_GPS 1
#define SV_GENERAL_ABOUT 2

#define SV_ACCOUNTS_COUNT 10
#define SV_ACCOUNTS_FACEBOOK 0
#define SV_ACCOUNTS_TWITTER 1
#define SV_ACCOUNTS_FLICKR 2
#define SV_ACCOUNTS_DROPBOX 3
#define SV_ACCOUNTS_EVERNOTE 4
#define SV_ACCOUNTS_PICASA 5
#define SV_ACCOUNTS_MIXI 6
#define SV_ACCOUNTS_FOTOLIFE 7
#define SV_ACCOUNTS_MINUS 8
#define SV_ACCOUNTS_FILE 9

//-----------------------------------------------------------------------------
//Private Implementations
//-----------------------------------------------------------------------------
@interface SettingTableViewController(PrivateImplementation)
- (void) setupInitialState;
- (void) addAlbumSettingTableViewControllerWithType:(PhotoSubmitterType) type;
- (PhotoSubmitterSettingTableViewController *)settingTableViewControllerForType:(PhotoSubmitterType) type;
- (void) settingDone:(id)sender;
- (UITableViewCell *) createGeneralSettingCell:(int)tag;
- (UITableViewCell *) createSocialAppButtonWithTag:(int)tag;
- (void) didSocialAppSwitchChanged:(id)sender;
- (void) didGeneralSwitchChanged:(id)sender;
- (PhotoSubmitterType) indexToSubmitterType:(int) index;
- (int) submitterTypeToIndex:(PhotoSubmitterType) type;
- (UISwitch *)createSwitchWithTag:(int)tag on:(BOOL)on;
- (void) sortSocialAppCell;
- (void) updateSupportTypeIndex;
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
    settingControllers_ = [[NSMutableDictionary alloc] init];
    
    for(int i = 0; i < PhotoSubmitterCount; i++){
        if(i == PhotoSubmitterTypeFile || i == PhotoSubmitterTypeTwitter){
            continue;
        }
        [self addAlbumSettingTableViewControllerWithType:i];
    }
    [settingControllers_ 
     setObject:[[TwitterPhotoSubmitterSettingTableViewController alloc] initWithType:PhotoSubmitterTypeTwitter]
     forKey:[NSNumber numberWithInt:PhotoSubmitterTypeTwitter]];

    aboutSettingViewController_ = [[AboutSettingViewController alloc] init];
    aboutSettingViewController_.delegate = self;
    
    if([TottePostSettings getInstance].supportedTypeIndexes.count != SV_ACCOUNTS_COUNT){
        [TottePostSettings getInstance].supportedTypeIndexes =
        [PhotoSubmitterManager sharedInstance].supportedTypes;
    }
    accountTypeIndexes_ = [NSMutableArray arrayWithArray:[TottePostSettings getInstance].supportedTypeIndexes];
    [[PhotoSubmitterManager sharedInstance] setAuthenticationDelegate:self];
}

/*!
 * add Album setting table view controller
 */
- (void)addAlbumSettingTableViewControllerWithType:(PhotoSubmitterType)type{
    [settingControllers_ 
     setObject:[[AlbumPhotoSubmitterSettingTableViewController alloc] initWithType:type]
     forKey:[NSNumber numberWithInt:type]];
}

/*!
 * get setting table view fo type
 */
- (PhotoSubmitterSettingTableViewController *)settingTableViewControllerForType:(PhotoSubmitterType)type{
    return [settingControllers_ objectForKey:[NSNumber numberWithInt:type]];
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
        case SV_SECTION_ACCOUNTS: return SV_ACCOUNTS_COUNT;
    }
    return 0;
}

/*!
 * title for section
 */
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    switch (section) {
        case SV_SECTION_GENERAL : return [TTLang lstr:@"Settings_Section_General"]; break;
        case SV_SECTION_ACCOUNTS: return [TTLang lstr:@"Settings_Section_Accounts"]; break;
        case SV_GENERAL_ABOUT   : return [TTLang lstr:@"Settings_Section_About"]; break;
    }
    return nil;
}

/*!
 * footer for section
 */
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section{
    switch (section) {
        case SV_SECTION_GENERAL : break;
        case SV_SECTION_ACCOUNTS: return [TTLang lstr:@"Settings_Section_Accounts_Footer"]; break;
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
        case SV_GENERAL_ABOUT:
            cell.textLabel.text = [TTLang lstr:@"Settings_Row_About"];
            break;
        case SV_GENERAL_COMMENT:
            cell.textLabel.text = [TTLang lstr:@"Settings_Row_Comment"];
            s = [self createSwitchWithTag:tag on:settings.commentPostEnabled];
            [s addTarget:self action:@selector(didGeneralSwitchChanged:) forControlEvents:UIControlEventValueChanged];
            cell.accessoryView = s;
            break;
        case SV_GENERAL_GPS:
            cell.textLabel.text = [TTLang lstr:@"Settings_Row_GPSTagging"];
            UISwitch *s = [self createSwitchWithTag:tag on:settings.gpsEnabled];
            [s addTarget:self action:@selector(didGeneralSwitchChanged:) forControlEvents:UIControlEventValueChanged];
            cell.accessoryView = s;
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
    cell.textLabel.text = submitter.displayName;
    
    UISwitch *s = [self createSwitchWithTag:tag on:NO];
    [s addTarget:self action:@selector(didSocialAppSwitchChanged:) forControlEvents:UIControlEventValueChanged];
    cell.accessoryView = s;
    [switches_ setObject:s forKey:[NSNumber numberWithInt:tag]];
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
    if(indexPath.section == SV_SECTION_GENERAL){
        switch (indexPath.row) {
            case SV_GENERAL_ABOUT: 
                [self.navigationController pushViewController:aboutSettingViewController_ animated:YES];
                break;
        }        
    }else if(indexPath.section == SV_SECTION_ACCOUNTS){
        PhotoSubmitterType type = (PhotoSubmitterType)[self indexToSubmitterType:indexPath.row];
        id<PhotoSubmitterProtocol> submitter = [PhotoSubmitterManager submitterForType:type];
        if(submitter.isEnabled){
            [self.navigationController pushViewController:[self settingTableViewControllerForType:type] animated:YES];
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated: YES];
}

/*!
 * sort social app cell by switch state
 */
- (void) sortSocialAppCell{
    NSArray* suportTypes = [PhotoSubmitterManager sharedInstance].supportedTypes;
    NSMutableArray* newSupportTypes = [[NSMutableArray alloc] init];

    NSMutableArray* onTypes = [[NSMutableArray alloc] init];
    NSMutableArray* offTypes = [[NSMutableArray alloc] init];
    for (int i = 0;i < accountTypeIndexes_.count;i++) {
        PhotoSubmitterType type = (PhotoSubmitterType)[[accountTypeIndexes_ objectAtIndex:i] intValue];
        id<PhotoSubmitterProtocol> submitter = [[PhotoSubmitterManager sharedInstance] submitterForType:type];
        if([submitter isLogined]){
            [onTypes addObject:[NSNumber numberWithInt:(int)[self indexToSubmitterType:i]]];
        }else{
            [offTypes addObject:[NSNumber numberWithInt:(int)[self indexToSubmitterType:i]]];
        }
    }
    for(NSNumber* i in onTypes){
        [newSupportTypes addObject:i];
    }
    for(NSNumber* i in offTypes){
        [newSupportTypes addObject:i];
    }
         
    NSMutableDictionary* newSwitches = [[NSMutableDictionary alloc] init];
    int i = 0;
    for (id key in switches_) {
        NSNumber* newKey = [NSNumber numberWithInt:[newSupportTypes indexOfObject:[suportTypes objectAtIndex:i]]];
        [newSwitches setObject:[switches_ objectForKey:key] forKey:newKey];
         i++;
    }
    switches_ = newSwitches;
    
    accountTypeIndexes_ = (NSMutableArray*)newSupportTypes;
    [self updateSupportTypeIndex];
    [self.tableView reloadData];
}

/*!
 * upldate support type index
 */
- (void) updateSupportTypeIndex{
    [TottePostSettings getInstance].supportedTypeIndexes = accountTypeIndexes_;
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
            [PhotoSubmitterManager sharedInstance].enableGeoTagging = s.on;
            break;
    }
}

/*!
 * create switch with tag
 */
- (UISwitch *)createSwitchWithTag:(int)tag on:(BOOL)on{
    UISwitch *s = [[UISwitch alloc] initWithFrame:CGRectZero];
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
    return (PhotoSubmitterType)[[accountTypeIndexes_ objectAtIndex:index] intValue];
}

/*!
 * convert PhotoSubmitterType to index
 */
- (int)submitterTypeToIndex:(PhotoSubmitterType)type{
    return [accountTypeIndexes_ indexOfObject:[NSNumber numberWithInt:type]]; 
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

/*!
 * update social app switches
 */
- (void)updateSocialAppSwitches{
    for(NSNumber *num in accountTypeIndexes_){
        PhotoSubmitterType type = [num intValue];
        int index = [self submitterTypeToIndex:type];
        UISwitch *s = [switches_ objectForKey:[NSNumber numberWithInt:index]];
        id<PhotoSubmitterProtocol> submitter = [PhotoSubmitterManager submitterForType:type];
        BOOL isLogined = submitter.isLogined;
        if(isLogined == NO){
            [submitter disable];
        }
        [s setOn:isLogined animated:YES];
    }
}

#pragma mark -
#pragma mark PhotoSubmitterAuthDelegate delegate methods
/*!
 * photo submitter did login
 */
- (void)photoSubmitter:(id<PhotoSubmitterProtocol>)photoSubmitter didLogin:(PhotoSubmitterType)type{
    int index = [self submitterTypeToIndex:type];
    UISwitch *s = [switches_ objectForKey:[NSNumber numberWithInt:index]];
    [s setOn:YES animated:YES];
    [self sortSocialAppCell];
}

/*!
 * photo submitter did logout
 */
- (void)photoSubmitter:(id<PhotoSubmitterProtocol>)photoSubmitter didLogout:(PhotoSubmitterType)type{
    int index = [self submitterTypeToIndex:type];
    UISwitch *s = [switches_ objectForKey:[NSNumber numberWithInt:index]];
    [s setOn:NO animated:YES];    
    [self sortSocialAppCell];
}

/*!
 * photo submitter start authorization
 */
- (void)photoSubmitter:(id<PhotoSubmitterProtocol>)photoSubmitter willBeginAuthorization:(PhotoSubmitterType)type{
}

/*!
 * photo submitter authorization finished
 */
- (void)photoSubmitter:(id<PhotoSubmitterProtocol>)photoSubmitter didAuthorizationFinished:(PhotoSubmitterType)type{
}

#pragma mark -
#pragma mark UIViewController methods
- (void)viewDidAppear:(BOOL)animated{
    [[PhotoSubmitterManager sharedInstance] refreshCredentials];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(settingDone:)];
    [self.navigationItem setRightBarButtonItem:doneButton animated:YES];
    [self setTitle:[TTLang lstr:@"Settings_Title"]];
    
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:SV_GENERAL_COMMENT inSection:SV_SECTION_GENERAL], nil] withRowAnimation:NO];
}

#pragma mark -
#pragma mark AboutSettingViewController delegate
- (void)didFeedbackButtonPressed{
    [self.parentViewController dismissModalViewControllerAnimated:YES];
    [self.delegate didFeedbackButtonPressed];
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
