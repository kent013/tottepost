//
//  TottepostSettingTableViewController.m
//  tottepost
//
//  Created by Kentaro ISHITOYA on 12/03/06.
//  Copyright (c) 2012 cocotomo. All rights reserved.
//

#import "TottepostSettingTableViewController.h"
#import "TTLang.h"
#import "PhotoSubmitterSettings.h"
#import "PhotoSubmitterSettingTableViewProtocol.h"

#define SV_SECTION_GENERAL  0
#define SV_GENERAL_ABOUT 2
static NSString *kTwitterPhotoSubmitterType = @"TwitterPhotoSubmitter";

//-----------------------------------------------------------------------------
//Private Implementations
//-----------------------------------------------------------------------------
@interface TottepostSettingTableViewController(PrivateImplementation)
@end

#pragma mark -
#pragma mark Private Implementations
@implementation TottepostSettingTableViewController(PrivateImplementation)
#pragma mark -
#pragma mark tableview methods
/*!
 * get row number
 */
- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case SV_SECTION_GENERAL: return SV_GENERAL_COUNT + 1;
        default:return [super tableView:table numberOfRowsInSection:section];
    }
    return 0;
}

/*!
 * title for section
 */
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    switch (section) {
        case SV_GENERAL_ABOUT : return [TTLang lstr:@"Settings_Section_About"]; break;
        default: return [super tableView:tableView titleForHeaderInSection:section];
    }
    return nil;
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
    }else{
        [super tableView:tableView didSelectRowAtIndexPath:indexPath];
        return;
    }
    [tableView deselectRowAtIndexPath:indexPath animated: YES];
}
@end

//-----------------------------------------------------------------------------
//Public Implementations
#pragma mark -
#pragma mark Public Implementations
//-----------------------------------------------------------------------------
@implementation TottepostSettingTableViewController
@synthesize delegate;
/*!
 * initialize with frame
 */
- (id) init{
    self = [super init];
    if(self){
        aboutSettingViewController_ = [[AboutSettingViewController alloc] init];
        aboutSettingViewController_.delegate = self;
    }
    return self;
}

/*!
 * create general setting cell
 */
- (UITableViewCell *)createGeneralSettingCell:(int)tag{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    switch (tag) {
        case SV_GENERAL_ABOUT:
            cell.textLabel.text = [TTLang lstr:@"Settings_Row_About"];
            break;
        default: return [super createGeneralSettingCell:tag];
    }
    return cell;
}


#pragma mark -
#pragma mark AboutSettingViewController delegate
- (void)didUserVoiceFeedbackButtonPressed{
    [self.parentViewController dismissModalViewControllerAnimated:YES];
    [(id<TottepostSettingTableViewControllerDelegate>)self.delegate didUserVoiceFeedbackButtonPressed];
}

- (void)didMailFeedbackButtonPressed{
    [self.parentViewController dismissModalViewControllerAnimated:YES];
    [(id<TottepostSettingTableViewControllerDelegate>)self.delegate didMailFeedbackButtonPressed];
}

@end
