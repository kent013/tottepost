//
//  TottepostSettingTableViewController.m
//  tottepost
//
//  Created by Kentaro ISHITOYA on 12/03/06.
//  Copyright (c) 2012 cocotomo. All rights reserved.
//

#import "TottepostSettingTableViewController.h"
#import "TTLang.h"
#import "ENGPhotoSubmitterSettings.h"
#import "ENGPhotoSubmitterSettingTableViewProtocol.h"
#import "MAConfirmButton.h"
#import "TottepostSettings.h"

#define SV_SECTION_GENERAL  0
#define SV_GENERAL_ROW_PHOTO_PRESET SV_GENERAL_COUNT
#define SV_GENERAL_ROW_VIDEO_PRESET SV_GENERAL_COUNT + 1
#define SV_GENERAL_ROW_SILENT_MODE SV_GENERAL_COUNT + 2
#define SV_GENERAL_ROW_SHUTTER_VOLUME SV_GENERAL_COUNT + 3
#define SV_GENERAL_ROW_TOOLTIP SV_GENERAL_COUNT + 4
#define SV_GENERAL_ROW_ABOUT SV_GENERAL_COUNT + 5
#define SV_GENERAL_COUNT_TOTTEPOST SV_GENERAL_COUNT + 6

static NSString *kTwitterPhotoSubmitterType = @"TwitterPhotoSubmitter";

//-----------------------------------------------------------------------------
//Private Implementations
//-----------------------------------------------------------------------------
@interface TottepostSettingTableViewController(PrivateImplementation)
- (void) handleProButtonTapped:(id)sender;
- (void) handleUseSlientModeSwitchChanged:(UISwitch *)sender;
- (void) handleShutterVolumeChanged:(UISlider *)sender;
- (void) handleUseTooltipSwitchChanged:(UISwitch *)sender;
@end

#pragma mark -
#pragma mark Private Implementations
@implementation TottepostSettingTableViewController(PrivateImplementation)
#pragma mark -
#pragma mark tableview methods
/*!
 * open app store
 */
- (void) handleProButtonTapped:(id)sender{
    NSString *stringURL = [TTLang localized:@"AppStore_Url_Pro"];
    NSURL *url = [NSURL URLWithString:stringURL];
    [[UIApplication sharedApplication] openURL:url]; 
}

/*!
 * on silent mode switch changed
 */
- (void) handleUseSlientModeSwitchChanged:(UISwitch *)sender{
    if(sender.on){
        UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle:
         [TTLang localized:@"Silent_Mode_Alert_Title"] 
                                   message:
         [TTLang localized:@"Silent_Mode_Alert_Message"]
                                  delegate:self 
                         cancelButtonTitle:
         [TTLang localized:@"Silent_Mode_Alert_Cancel_Button_Title"]
                         otherButtonTitles:nil];
        [alert show];
    }
    
    [TottepostSettings sharedInstance].useSilentMode = sender.on;
    UITableViewCell *cell = [self tableView:self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:SV_GENERAL_ROW_SHUTTER_VOLUME inSection:SV_SECTION_GENERAL]];
    UISlider *slider = (UISlider *)cell.accessoryView;
    if(slider && [slider isKindOfClass:[UISlider class]]){
        if([TottepostSettings sharedInstance].useSilentMode == NO){
            slider.enabled = NO;
            cell.textLabel.textColor = [UIColor grayColor];
        }else{
            slider.enabled = YES;
            cell.textLabel.textColor = [UIColor blackColor];
        }
    }
}

/*!
 * on shutter volume value changed
 */
- (void)handleShutterVolumeChanged:(UISlider *)sender{
    if(sender.value < 0.1){
        sender.value = 0.1;
    }
    [TottepostSettings sharedInstance].shutterSoundVolume = sender.value;
}

/*!
 * on tooltip switch changed
 */
- (void) handleUseTooltipSwitchChanged:(UISwitch *)sender{
    [TottepostSettings sharedInstance].useTooltip = sender.on;
}

#pragma mark - UITableViewDelegate
/*!
 * get row number
 */
- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case SV_SECTION_GENERAL: return SV_GENERAL_COUNT_TOTTEPOST;
        default:return [super tableView:table numberOfRowsInSection:section];
    }
    return 0;
}

/*!
 * title for section
 */
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if(section == SV_GENERAL_COUNT){
        return [TTLang localized:@"Settings_Section_About"];
    }else{
        return [super tableView:tableView titleForHeaderInSection:section];
    }
    return nil;
}

/*!
 * on row selected
 */
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == SV_SECTION_GENERAL){
        if(indexPath.row == SV_GENERAL_ROW_PHOTO_PRESET){
#ifndef LITE_VERSION
            presetSettingViewController_.type = AVFoundationPresetTypePhoto;
            presetSettingViewController_.title = [TTLang localized:@"Settings_Title_PhotoPreset"];
            [self.navigationController pushViewController:presetSettingViewController_ animated:YES];
#endif
        }else if(indexPath.row == SV_GENERAL_ROW_VIDEO_PRESET){
#ifndef LITE_VERSION
            presetSettingViewController_.type = AVFoundationPresetTypeVideo;
            presetSettingViewController_.title = [TTLang localized:@"Settings_Title_VideoPreset"];
            [self.navigationController pushViewController:presetSettingViewController_ animated:YES];
#endif
        }else if(indexPath.row == SV_GENERAL_ROW_SILENT_MODE){
        }else if(indexPath.row == SV_GENERAL_ROW_SHUTTER_VOLUME){
            
        }else if(indexPath.row == SV_GENERAL_ROW_ABOUT){
            [self.navigationController pushViewController:aboutSettingViewController_ animated:YES];
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
        presetSettingViewController_ = [[AVFoundationPresetTableViewController alloc] init];
    }
    return self;
}

/*!
 * create general setting cell
 */
- (UITableViewCell *)createGeneralSettingCell:(int)tag{
    NSString *identifier = [NSString stringWithFormat:@"general_%d", tag];
    UITableViewCell *cell = [cells_ objectForKey:identifier];
    if(cell){
        return cell;
    }
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
    
    if(tag == SV_GENERAL_ROW_PHOTO_PRESET){
        cell.textLabel.text = [TTLang localized:@"Settings_Row_PhotoPreset"];
        cell.imageView.image = [UIImage imageNamed:@"photoResolution.png"];
#ifdef LITE_VERSION
        MAConfirmButton *proButton = [MAConfirmButton buttonWithTitle:@"PRO" confirm:[TTLang localized:@"AppStore_Open"]];
        [proButton addTarget:self action:@selector(handleProButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        cell.accessoryView = proButton;
        cell.textLabel.textColor = [UIColor grayColor];
#else
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
#endif

    }else if(tag == SV_GENERAL_ROW_VIDEO_PRESET){
        cell.textLabel.text = [TTLang localized:@"Settings_Row_VideoPreset"];
        cell.imageView.image = [UIImage imageNamed:@"movieResolution.png"];
#ifdef LITE_VERSION
        MAConfirmButton *proButton = [MAConfirmButton buttonWithTitle:@"PRO" confirm:[TTLang localized:@"AppStore_Open"]];
        [proButton addTarget:self action:@selector(handleProButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        cell.accessoryView = proButton;
        cell.textLabel.textColor = [UIColor grayColor];
#else
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
#endif
    }else if(tag == SV_GENERAL_ROW_SILENT_MODE){
        cell.textLabel.text = [TTLang localized:@"Settings_Row_Silent"];
        cell.imageView.image = [UIImage imageNamed:@"silentMode.png"];
#ifdef LITE_VERSION
        MAConfirmButton *proButton = [MAConfirmButton buttonWithTitle:@"PRO" confirm:[TTLang localized:@"AppStore_Open"]];
        [proButton addTarget:self action:@selector(handleProButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        cell.accessoryView = proButton;
        cell.textLabel.textColor = [UIColor grayColor];
#else
        UISwitch *s = [[UISwitch alloc] init];
        s.on = [TottepostSettings sharedInstance].useSilentMode;
        s.tag = tag;
        [s addTarget:self action:@selector(handleUseSlientModeSwitchChanged:) forControlEvents:UIControlEventValueChanged];
        cell.accessoryView = s;
#endif
    }else if(tag == SV_GENERAL_ROW_SHUTTER_VOLUME){
        cell.textLabel.text = [TTLang localized:@"Settings_Row_Shutter_Volume"];
        cell.imageView.image = [UIImage imageNamed:@"blank.png"];
        UISlider *slider = [[UISlider alloc] init];
        [slider addTarget:self action:@selector(handleShutterVolumeChanged:) forControlEvents:UIControlEventValueChanged];
        slider.value = [TottepostSettings sharedInstance].shutterSoundVolume;
        if([TottepostSettings sharedInstance].useSilentMode == NO){
            slider.enabled = NO;
            cell.textLabel.textColor = [UIColor grayColor];
        }
        cell.accessoryView = slider;
    }else if(tag == SV_GENERAL_ROW_TOOLTIP){
        cell.textLabel.text = [TTLang localized:@"Settings_Row_Tooltip"];
        cell.imageView.image = [UIImage imageNamed:@"tooltip.png"];
        UISwitch *s = [[UISwitch alloc] init];
        s.on = [TottepostSettings sharedInstance].useTooltip;
        s.tag = tag;
        [s addTarget:self action:@selector(handleUseTooltipSwitchChanged:) forControlEvents:UIControlEventValueChanged];
        cell.accessoryView = s;
    }else if(tag == SV_GENERAL_ROW_ABOUT){
        cell.textLabel.text = [TTLang localized:@"Settings_Row_About"];
        cell.imageView.image = [UIImage imageNamed:@"feedback.png"];
    }else{
        return [super createGeneralSettingCell:tag];
    }
    
    [cells_ setObject:cell forKey:identifier];
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{

}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:YES forKey:@"alreadyOpenedSettings"];
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
