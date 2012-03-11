//
//  AboutSettingViewController.m
//  tottepost
//
//  Created by Kentaro ISHITOYA on 12/01/27.
//  Copyright (c) 2012 cocotomo. All rights reserved.
//

#import "AboutSettingViewController.h"
#import "Appirater.h"
#import "TTLang.h"

#define ASV_BUTTON_TYPE 102

#define ASV_SECTION_FEEDBACK 0
#define ASV_SECTION_ABOUT 1

#define ASV_ROW_FEEDBACK_USERVOICE 0
#define ASV_ROW_FEEDBACK_MAIL 1
#define ASV_ROW_FEEDBACK_RATE 2

//-----------------------------------------------------------------------------
//Private Implementations
//-----------------------------------------------------------------------------
@interface AboutSettingViewController(PrivateImplementation)
- (void) setupInitialState;
- (void) handleMailFeedbackButtonTapped:(UIButton *)sender;
- (void) handleUserVoiceFeedbackButtonTapped:(UIButton *)sender;
- (void) handleRateFeedbackButtonTapped:(UIButton *)sender;
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
    [self.delegate didUserVoiceFeedbackButtonPressed];
}

/*!
 * handle mail feedback button tapped
 */
- (void)handleMailFeedbackButtonTapped:(UIButton *)sender{
    [self.delegate didMailFeedbackButtonPressed];    
}

/*!
 * handle rate feedback button tapped
 */
- (void)handleRateFeedbackButtonTapped:(UIButton *)sender{
    [Appirater rateApp];
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
    return 2;
}

/*!
 * get row number
 */
- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section
{
    if(section == ASV_SECTION_FEEDBACK){
        return 3;
    }
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
        case ASV_SECTION_ABOUT: return [TTLang localized:@"About_Section_About"];
        case ASV_SECTION_FEEDBACK: return [TTLang localized:@"About_Section_Feedback"];
    }
    return nil;
}

/*!
 * footer for section
 */
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section{
    if(section == ASV_SECTION_FEEDBACK){
        return [TTLang localized:@"About_Section_Feedback_Footer"];
    }
    return nil;
}

/*!
 * create cell
 */
-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    
    switch(indexPath.section){
        case ASV_SECTION_ABOUT:{
            UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(10, 10, self.view.frame.size.width - 20, 220)];
            textView.text = [TTLang localized:@"AboutText"];
            textView.backgroundColor = [UIColor clearColor];
            textView.dataDetectorTypes = UIDataDetectorTypeLink;
            textView.editable = NO;
            [cell addSubview:textView];
            break;
        }
        case ASV_SECTION_FEEDBACK:{
            switch (indexPath.row) {
                case ASV_ROW_FEEDBACK_MAIL:{
                    UIButton *feedbackButton = [UIButton buttonWithType:ASV_BUTTON_TYPE];
                    [feedbackButton setTitle: [TTLang localized:@"About_Feedback_Mail_Button"] forState:UIControlStateNormal];
                    [feedbackButton addTarget:self action:@selector(handleMailFeedbackButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
                    cell.accessoryView = feedbackButton;
                    cell.textLabel.text = [TTLang localized:@"About_Feedback_Mail_Title"];
                    break;
                }
                case ASV_ROW_FEEDBACK_USERVOICE:{
                    UIButton *feedbackButton = [UIButton buttonWithType:ASV_BUTTON_TYPE];
                    [feedbackButton setTitle: [TTLang localized:@"About_Feedback_UserVoice_Button"] forState:UIControlStateNormal];
                    [feedbackButton addTarget:self action:@selector(handleUserVoiceFeedbackButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
                    cell.accessoryView = feedbackButton;
                    cell.textLabel.text = [TTLang localized:@"About_Feedback_UserVoice_Title"];
                    break;
                }
                case ASV_ROW_FEEDBACK_RATE:{
                    UIButton *rateButton = [UIButton buttonWithType:ASV_BUTTON_TYPE];
                    [rateButton setTitle: [TTLang localized:@"About_Feedback_Rate_Button"] forState:UIControlStateNormal];
                    [rateButton addTarget:self action:@selector(handleRateFeedbackButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
                    cell.accessoryView = rateButton;
                    cell.textLabel.text = [TTLang localized:@"About_Feedback_Rate_Title"];
                    break;
                }
            }
        }
    }
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
    if(interfaceOrientation == UIInterfaceOrientationPortrait ||
       interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown){
        return YES;
    }
    return NO;
}
@end
