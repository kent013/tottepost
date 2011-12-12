//
//  SettingViewController.m
//  tottepost
//
//  Created by ISHITOYA Kentaro on 11/12/11.
//  Copyright (c) 2011 cocotomo. All rights reserved.
//

#import "SettingViewController.h"

#define SV_SECTION_GENERAL  0
#define SV_SECTION_ACCOUNTS 1
//-----------------------------------------------------------------------------
//Private Implementations
//-----------------------------------------------------------------------------
@interface SettingViewController(PrivateImplementation)
- (void) setupInitialState;
- (void) settingDone:(id)sender;
- (UITableViewCell *) createSocialAppButtonWithTitle:(NSString *)title imageName:(NSString *)imageName;
@end

@implementation SettingViewController(PrivateImplementation)
- (void)setupInitialState{
    self.tableView.delegate = self;
    //self.view = [[UIView alloc] initWithFrame:aFrame];
}
- (void)settingDone:(id)sender{
    [self.parentViewController dismissModalViewControllerAnimated:YES];
}
//テーブルに表示するセクションの数
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

//セクションに表示する列の数
- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

//ヘッダの取得
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
        if(indexPath.row == 0){
            cell = [self createSocialAppButtonWithTitle: @"Facebook" imageName:@"facebook_32.png"];
        }else if(indexPath.row == 1){
            cell = [self createSocialAppButtonWithTitle: @"Twitter" imageName:@"twitter_32.png"];
        }else if(indexPath.row == 2){
            cell = [self createSocialAppButtonWithTitle: @"Flickr" imageName:@"flickr_32.png"];
        }
    }
    return cell;
}

/*!
 * create social app button
 */
-(UITableViewCell *) createSocialAppButtonWithTitle:(NSString *)title imageName:(NSString *)imageName{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    cell.imageView.image = [UIImage imageNamed:imageName];
    cell.textLabel.text = title;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    NSLog(@"%f", self.tableView.frame.size.width);
    UISwitch *s = [[UISwitch alloc] initWithFrame:CGRectMake(self.tableView.frame.size.width - 180, 8, 100, 30)];
    [cell.contentView addSubview:s];
    return cell;
}

/*!
 * on row selected
 */
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated: YES];
}
@end

//-----------------------------------------------------------------------------
//Public Implementations
//-----------------------------------------------------------------------------
@implementation SettingViewController
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
#pragma mark UIViewController methods
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidAppear:(BOOL)animated{
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(settingDone:)];
    [self.navigationItem setRightBarButtonItem:doneButton animated:YES];
    [self setTitle:@"Settings"];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
