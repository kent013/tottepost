//
//  AboutSettingViewController.m
//  tottepost
//
//  Created by Kentaro ISHITOYA on 12/01/27.
//  Copyright (c) 2012 cocotomo. All rights reserved.
//

#import "AboutSettingViewController.h"
#import "TottePostSettings.h"
#import "UserVoiceAccountSettingViewController.h"
#import "TTLang.h"

#define ASV_BUTTON_TYPE 102

#define ASV_SECTION_ABOUT 0
#define ASV_SECTION_FEEDBACK_USERVOICE 1
//#define ASV_SECTION_USERVOICE 2
#define ASV_SECTION_FEEDBACK_MAIL 2

#define ASV_ROW_USERVOICE_MAIL 0
#define ASV_ROW_USERVOICE_USERNAME 1
#define ASV_ROW_USERVOICE_BUTTON 2

//-----------------------------------------------------------------------------
//Private Implementations
//-----------------------------------------------------------------------------
@interface AboutSettingViewController(PrivateImplementation)
- (void) setupInitialState;
- (void) handleMailFeedbackButtonTapped:(UIButton *)sender;
- (void) handleUserVoiceFeedbackButtonTapped:(UIButton *)sender;
- (void) handleUserVoiceSettingButtonTapped:(UIButton *)sender;
@end

@implementation AboutSettingViewController(PrivateImplementation)
/*!
 * initialize
 */
-(void)setupInitialState{
}

/*!
 * handle feedback button tapped
 */
- (void)handleUserVoiceFeedbackButtonTapped:(UIButton *)sender{
    /*NSString *email = [[TottePostSettings getInstance] username];
    if(email == nil){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[TTLang lstr:@"Alert_Error"] message:[TTLang lstr:@"Alert_NoEmailForUserVoiceProvided"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }*/
    [self.delegate didUserVoiceFeedbackButtonPressed];
}

/*!
 * handle mail feedback button tapped
 */
- (void)handleMailFeedbackButtonTapped:(UIButton *)sender{
    [self.delegate didMailFeedbackButtonPressed];    
}

/*!
 * handle uservoice setting button tapped
 */
- (void)handleUserVoiceSettingButtonTapped:(UIButton *)sender{
    UserVoiceAccountSettingViewController *uvc = [[UserVoiceAccountSettingViewController alloc] init];
    uvc.delegate = self;
    [self.navigationController pushViewController:uvc animated:YES];
}
@end

//-----------------------------------------------------------------------------
//Public Implementations
//-----------------------------------------------------------------------------
@implementation AboutSettingViewController
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

#pragma mark - tableview methods
/*! 
 * get section number
 */
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

/*!
 * get row number
 */
- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section
{
    /*if(section == ASV_SECTION_USERVOICE){
        return 3;
    }*/
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == ASV_SECTION_ABOUT && indexPath.row == 0){
        return 230;
    }
    return 50;
}

/*!
 * title for section
 */
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    switch (section) {
        case ASV_SECTION_ABOUT: return [TTLang lstr:@"About_Section_About"];
        //case ASV_SECTION_USERVOICE: return [TTLang lstr:@"About_Section_UserVoice"];
        case ASV_SECTION_FEEDBACK_MAIL: return [TTLang lstr:@"About_Section_Feedback_Mail"];
        case ASV_SECTION_FEEDBACK_USERVOICE: return [TTLang lstr:@"About_Section_Feedback_UserVoice"];
    }
    return nil;
}

/*!
 * create cell
 */
-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    
    //TottePostSettings *settings = [TottePostSettings getInstance];
    switch(indexPath.section){
        case ASV_SECTION_ABOUT:{
            UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(10, 10, self.view.frame.size.width - 20, 220)];
            textView.text = [TTLang lstr:@"AboutText"];
            textView.backgroundColor = [UIColor clearColor];
            textView.dataDetectorTypes = UIDataDetectorTypeLink;
            textView.editable = NO;
            [cell addSubview:textView];
            break;
        }
        /*case ASV_SECTION_USERVOICE:{
            switch (indexPath.row) {
                case ASV_ROW_USERVOICE_MAIL:{
                    NSString *email = settings.emailAddress;
                    if(email == nil){
                        email = [TTLang lstr:@"About_Row_UserVoice_Mail_Default"];
                    }
                    UILabel *label = [[UILabel alloc] init];
                    label.text = email;
                    label.font = [UIFont systemFontOfSize:15.0];
                    [label sizeToFit];
                    label.backgroundColor = [UIColor clearColor];
                    cell.accessoryView = label;
                    cell.textLabel.text = [TTLang lstr:@"About_Row_UserVoice_Mail_Title"];
                    break;
                }
                case ASV_ROW_USERVOICE_USERNAME:{
                    NSString *username = settings.username;
                    if(username == nil){
                        username = [TTLang lstr:@"About_Row_UserVoice_Username_Default"];
                    }
                    UILabel *label = [[UILabel alloc] init];
                    label.text = username;
                    label.font = [UIFont systemFontOfSize:15.0];
                    [label sizeToFit];
                    label.backgroundColor = [UIColor clearColor];
                    cell.accessoryView = label;
                    cell.textLabel.text = [TTLang lstr:@"About_Row_UserVoice_Username_Title"];
                    break;
                }
                case ASV_ROW_USERVOICE_BUTTON:{
                    UIButton *settingButton = [UIButton buttonWithType:ASV_BUTTON_TYPE];
                    [settingButton setTitle: [TTLang lstr:@"About_Row_UserVoice_Button"] forState:UIControlStateNormal];
                    [settingButton addTarget:self action:@selector(handleUserVoiceSettingButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
                    cell.accessoryView = settingButton;
                    cell.textLabel.text = [TTLang lstr:@"About_Row_UserVoice_Button_Title"];
                    break;
                }
            }
            break;
        }*/
        case ASV_SECTION_FEEDBACK_MAIL:{
            UIButton *feedbackButton = [UIButton buttonWithType:ASV_BUTTON_TYPE];
            [feedbackButton setTitle: [TTLang lstr:@"About_Feedback_Mail_Button"] forState:UIControlStateNormal];
            [feedbackButton addTarget:self action:@selector(handleMailFeedbackButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
            cell.accessoryView = feedbackButton;
            cell.textLabel.text = [TTLang lstr:@"About_Feedback_Mail_Title"];
            break;
        }
        case ASV_SECTION_FEEDBACK_USERVOICE:{
            UIButton *feedbackButton = [UIButton buttonWithType:ASV_BUTTON_TYPE];
            [feedbackButton setTitle: [TTLang lstr:@"About_Feedback_UserVoice_Button"] forState:UIControlStateNormal];
            [feedbackButton addTarget:self action:@selector(handleUserVoiceFeedbackButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
            cell.accessoryView = feedbackButton;
            cell.textLabel.text = [TTLang lstr:@"About_Feedback_UserVoice_Title"];
            break;
        }
    }
    return cell;
}

/*!
 * footer for section
 */
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section{
    return nil;    
}

/*!
 * on row selected
 */
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated: YES];
}

#pragma mark - UIView delegate
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

#pragma mark - UserVoiceAccountSettingViewControllerDelegate
/*!
 * account setting view done
 */
- (void)accountSettingViewController:(UserVoiceAccountSettingViewController *)accountSettingViewController didPresentMailAddress:(NSString *)mailAddress andUsername:(NSString *)username{
    TottePostSettings *settings = [TottePostSettings getInstance];
    if(mailAddress != nil){
        settings.emailAddress = mailAddress;
    }
    settings.username = username;
    [self.tableView reloadData];
}

/*!
 * account setting view is canceled
 */
- (void)didCancelAccountSettingViewController:(UserVoiceAccountSettingViewController *)accountSettingViewController{
}
@end
