//
//  AboutSettingViewController.m
//  tottepost
//
//  Created by Kentaro ISHITOYA on 12/01/27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "AboutSettingViewController.h"
#import "TTLang.h"

//-----------------------------------------------------------------------------
//Private Implementations
//-----------------------------------------------------------------------------
@interface AboutSettingViewController(PrivateImplementation)
- (void) setupInitialState;
- (void) handleFeedbackButtonTapped:(UIButton *)sender;
@end

@implementation AboutSettingViewController(PrivateImplementation)
/*!
 * initialize
 */
-(void)setupInitialState{
    self.view.backgroundColor = [UIColor lightGrayColor];
    textView_ = [[UITextView alloc] initWithFrame:CGRectMake(10, 10, self.view.frame.size.width - 20, 200)];
    textView_.text = [TTLang lstr:@"AboutText"];
    textView_.backgroundColor = [UIColor clearColor];
    textView_.userInteractionEnabled = NO;
    feedbackButton_ = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [feedbackButton_ setTitle: [TTLang lstr:@"AAMFeedbackTitle"] forState:UIControlStateNormal];
    [feedbackButton_ addTarget:self action:@selector(handleFeedbackButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    feedbackButton_.frame = CGRectMake((self.view.frame.size.width - 150) / 2, textView_.frame.origin.y + textView_.frame.size.height + 20, 150, 30);
    feetbackViewController_ = [[AAMFeedbackViewController alloc] init];
    feetbackViewController_.toRecipients = [NSArray arrayWithObject:@"kentaro.ishitoya@gmail.com"];
    feetbackViewController_.bccRecipients = [NSArray arrayWithObject:@"ken45000@gmail.com"];
    [self.view addSubview:textView_];
    [self.view addSubview:feedbackButton_];
}

/*!
 * handle feedback button tapped
 */
- (void)handleFeedbackButtonTapped:(UIButton *)sender{
    [self.navigationController pushViewController:feetbackViewController_ animated:YES];
}
@end

//-----------------------------------------------------------------------------
//Public Implementations
//-----------------------------------------------------------------------------
@implementation AboutSettingViewController
/*!
 * initialize
 */
- (id)init{
    self = [super init];
    if(self){
        [self setupInitialState];
    }
    return self;
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
