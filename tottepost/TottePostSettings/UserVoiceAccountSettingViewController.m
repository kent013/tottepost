//
//  UserVoiceAccountSettingView.m
//  tottepost
//
//  Created by Kentaro ISHITOYA on 12/03/02.
//  Copyright (c) 2012 cocotomo. All rights reserved.
//

#import "UserVoiceAccountSettingViewController.h"
#import "TottePostSettings.h"
#import "TTLang.h"

#define UVA_SECTION_MAILADDR 0
#define UVA_SECTION_USERNAME 1

//-----------------------------------------------------------------------------
//Private Implementations
//-----------------------------------------------------------------------------
@interface UserVoiceAccountSettingViewController(PrivateImplementation)
- (void) setupInitialState;
- (void) handleDoneButtonTapped:(UIBarButtonItem *)sender;
- (void) done;
@end

@implementation UserVoiceAccountSettingViewController(PrivateImplementation)
/*!
 * initialize
 */
-(void)setupInitialState{
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc ] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(handleDoneButtonTapped:)];
    
    [self.navigationItem setTitle:[TTLang lstr:@"UserVoice_Navigation_Title"]];
    [self.navigationItem setRightBarButtonItem:doneButton animated:YES];
}

/*!
 * handle barbutton tapped
 */
- (void)handleDoneButtonTapped:(UIBarButtonItem *)sender{
    [self done];
}

/*!
 * done
 */
- (void)done{
    isDone_ = YES;
    [self.delegate accountSettingViewController:self didPresentMailAddress:mailAddressTextField_.text andUsername:usernameTextField_.text];
    [self.navigationController popViewControllerAnimated:YES];
}

/*!
 * should return
 */
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if(textField == mailAddressTextField_){
        [self done];
    }
    return YES;
}
@end

//-----------------------------------------------------------------------------
//Public Implementations
//-----------------------------------------------------------------------------
@implementation UserVoiceAccountSettingViewController
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
    return 2;
}

/*!
 * get row number
 */
- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

/*!
 * title for section
 */
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    switch (section) {
        case UVA_SECTION_MAILADDR: return [TTLang lstr:@"UserVoice_Section_MailAddress"];
        case UVA_SECTION_USERNAME: return [TTLang lstr:@"UserVoice_Section_Username"];
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
    UITextField *textField = [[UITextField alloc] init];
    textField.frame = CGRectInset(cell.frame, 20, 12);
    textField.borderStyle = UITextBorderStyleNone;
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    textField.returnKeyType = UIReturnKeyDone;
    textField.textAlignment = UITextAlignmentLeft;
    textField.delegate = self;
    textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    textField.autocorrectionType = UITextAutocorrectionTypeNo;
    
    TottePostSettings *settings = [TottePostSettings getInstance];
    switch (indexPath.section) {
        case UVA_SECTION_MAILADDR : 
            textField.placeholder = [TTLang lstr:@"UserVoice_Section_MailAddress_Placeholder"];
            mailAddressTextField_ = textField;
            textField.text = settings.emailAddress;
            break;
        case UVA_SECTION_USERNAME : 
            textField.placeholder = [TTLang lstr:@"UserVoice_Section_Username_Placeholder"];
            usernameTextField_ = textField;
            textField.text = settings.username;
            break;
    }
    [cell addSubview:textField];
    return cell;
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

/*!
 * register first responder
 */
- (void)viewWillAppear:(BOOL)animated {
    [usernameTextField_ becomeFirstResponder];
    isDone_ = NO;
}

/*!
 * remove first responder
 */
- (void)viewWillDisappear:(BOOL)animated {
    if(isDone_ == NO){
        [self.delegate didCancelAccountSettingViewController:self];
    }
    [usernameTextField_ resignFirstResponder];
}
@end
