//
//  AVFoundationPresetTableViewController.m
//  tottepost
//
//  Created by Kentaro ISHITOYA on 12/03/17.
//  Copyright (c) 2012 cocotomo. All rights reserved.
//

#import "AVFoundationPresetTableViewController.h"
#import "TTLang.h"
#import "TottepostSettings.h"

//-----------------------------------------------------------------------------
//Private Implementations
//-----------------------------------------------------------------------------
@interface AVFoundationPresetTableViewController(PrivateImplementation)
- (void) setupInitialState;
- (int) indexOfPreset:(AVFoundationPreset *)preset type:(AVFoundationPresetType)type;
@end

@implementation AVFoundationPresetTableViewController(PrivateImplementation)
/*!
 * initialize
 */
-(void)setupInitialState{
    self.type = AVFoundationPresetTypePhoto;
}

/*!
 * get index of preset
 */
- (int)indexOfPreset:(AVFoundationPreset *)preset type:(AVFoundationPresetType)type{
    NSArray *presets = nil;
    if(type == AVFoundationPresetTypePhoto){
        presets = [AVFoundationPreset availablePhotoPresets];
    }else{
        presets = [AVFoundationPreset availableVideoPresets];
    }
    int index = 0;
    for(AVFoundationPreset *p in presets){
        if([p.name isEqualToString:preset.name]){
            break;
        }
        index++;
    }
    return index;
}
@end

//-----------------------------------------------------------------------------
//Public Implementations
//-----------------------------------------------------------------------------
@implementation AVFoundationPresetTableViewController
@synthesize type = type_;
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

- (void)setType:(AVFoundationPresetType)type{
    type_ = type;
    AVFoundationPreset *preset;
    if(self.type == AVFoundationPresetTypePhoto){
        preset = [TottepostSettings sharedInstance].photoPreset;
    }else{
        preset = [TottepostSettings sharedInstance].videoPreset;
    }
    selectedIndex_ = [self indexOfPreset:preset type:type_];
    [self.tableView reloadData];
}

#pragma mark - tableview methods
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
    if(self.type == AVFoundationPresetTypePhoto){
        return [AVFoundationPreset availablePhotoPresets].count;
    }
    return [AVFoundationPreset availableVideoPresets].count;
}

/*!
 * create cell
 */
-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    
    AVFoundationPreset *preset;    
    if(self.type == AVFoundationPresetTypePhoto){
        preset = [[AVFoundationPreset availablePhotoPresets] objectAtIndex:indexPath.row];
    }else{
        preset = [[AVFoundationPreset availableVideoPresets] objectAtIndex:indexPath.row];
    }
    cell.textLabel.text = preset.desc;
    if(indexPath.row == selectedIndex_){
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    return cell;
}

/*!
 * on row selected
 */
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.type == AVFoundationPresetTypePhoto){
        [TottepostSettings sharedInstance].photoPreset = [[AVFoundationPreset availablePhotoPresets] objectAtIndex:indexPath.row];
    }else{
        [TottepostSettings sharedInstance].videoPreset = [[AVFoundationPreset availableVideoPresets] objectAtIndex:indexPath.row];
    }
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    if(selectedIndex_ != indexPath.row){
        cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:selectedIndex_ inSection:0]];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    selectedIndex_ = indexPath.row;
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

