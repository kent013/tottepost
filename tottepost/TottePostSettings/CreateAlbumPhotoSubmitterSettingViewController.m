//
//  CreateAlbumSubmitterSettingViewController.m
//  tottepost
//
//  Created by Kentaro ISHITOYA on 12/02/13.
//  Copyright (c) 2012 cocotomo. All rights reserved.
//

#import "CreateAlbumPhotoSubmitterSettingViewController.h"
#import "PhotoSubmitterSettingTableViewController.h"
#import "PhotoSubmitterManager.h"
#import "TTLang.h"

#define CSV_SECTION_CREATE_ALBUM 0
#define CSV_ROW_FIELD 0

//-----------------------------------------------------------------------------
//Private Implementations
//-----------------------------------------------------------------------------
@interface CreateAlbumPhotoSubmitterSettingViewController(PrivateImplementation)
- (void) setupInitialState;
- (void) handleCreateButtonTapped:(UIButton *)sender;
- (void) createAlbum:(NSString *)title;
@end

@implementation CreateAlbumPhotoSubmitterSettingViewController(PrivateImplementation)
/*!
 * on touch up inside
 */
- (void)handleCreateButtonTapped:(UIBarButtonItem *)sender{
    NSString *title = titleField_.text;
    [self createAlbum:title];
}

/*!
 * initialize
 */
-(void)setupInitialState{
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc ] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(handleCreateButtonTapped:)];
    
    [self.navigationItem setTitle:[TTLang lstr:@"Create_Album_Navigation_Title"]];
    [self.navigationItem setRightBarButtonItem:doneButton animated:YES];
}

/*!
 * UITextFieldDelegate
 */
-(BOOL)textFieldShouldReturn:(UITextField*)textField{
    return YES;
}

/*!
 * create album
 */
-(void)createAlbum:(NSString *)title{
    if(title == nil || [title isEqualToString: @""]){
        UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle:
         [TTLang lstr:@"Create_Album_Alert_Creation_Empty_Title"] 
                                   message:
         [TTLang lstr:@"Create_Album_Alert_Creation_Empty_Message"]
                                  delegate:self 
                         cancelButtonTitle:
         [TTLang lstr:@"Create_Album_Alert_Creation_Empty_Button_Title"]
                         otherButtonTitles:nil];
        [alert show];
        return;
    }
    [self.submitter createAlbum:title withDelegate:self];
}
@end

//-----------------------------------------------------------------------------
//Public Implementations
//-----------------------------------------------------------------------------
@implementation CreateAlbumPhotoSubmitterSettingViewController
#pragma mark -
#pragma mark tableview methods
/*! 
 * get section number
 */
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
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
        case CSV_SECTION_CREATE_ALBUM: return [TTLang lstr:@"Create_Album_Section_Title"];
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
    if(indexPath.row == CSV_ROW_FIELD){
        titleField_ = [[UITextField alloc] init];
        titleField_.frame = CGRectInset(cell.frame, 20, 12);
        titleField_.borderStyle = UITextBorderStyleNone;
        titleField_.placeholder = [TTLang lstr:@"Create_Album_Placeholder"];
        titleField_.clearButtonMode = UITextFieldViewModeWhileEditing;
        titleField_.spellCheckingType = UITextSpellCheckingTypeNo;
        titleField_.autocapitalizationType = UITextAutocapitalizationTypeNone;
        titleField_.autocorrectionType = UITextAutocorrectionTypeNo;
        titleField_.returnKeyType = UIReturnKeyDone;
        titleField_.textAlignment = UITextAlignmentLeft;
        titleField_.delegate = self;
        [cell addSubview:titleField_];
    }
    return cell;
}

/*!
 * on row selected
 */
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated: YES];
}

#pragma mark - PhotoSubmitterAlbumDelegate
/*!
 * on album created
 */
- (void)photoSubmitter:(id<PhotoSubmitterProtocol>)photoSubmitter didAlbumCreated:(PhotoSubmitterAlbumEntity *)album suceeded:(BOOL)suceeded withError:(NSError *)error{
    if(suceeded){
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle:
         [TTLang lstr:@"Create_Album_Alert_Creation_Failed_Title"] 
                                   message: error.localizedDescription
                                  delegate:self 
                         cancelButtonTitle:
         [TTLang lstr:@"Create_Album_Alert_Creation_Failed_Button_Title"]
                         otherButtonTitles:nil];
        [alert show];
        return;
    }
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

/*!
 * register first responder
 */
- (void)viewWillAppear:(BOOL)animated {
    [titleField_ becomeFirstResponder];
    titleField_.text = @"";
}

/*!
 * remove first responder
 */
- (void)viewWillDisappear:(BOOL)animated {
    [titleField_ resignFirstResponder];
}
@end