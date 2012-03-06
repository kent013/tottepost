//
//  PhotoSubmitterSettingTableViewController.m
//  tottepost
//
//  Created by ISHITOYA Kentaro on 12/01/02.
//  Copyright (c) 2012 cocotomo All rights reserved.
//

#import "PhotoSubmitterServiceSettingTableViewController.h"

//-----------------------------------------------------------------------------
//Private Implementations
//-----------------------------------------------------------------------------
@interface PhotoSubmitterServiceSettingTableViewController(PrivateImplementation)
- (void) setupInitialState;
@end

@implementation PhotoSubmitterServiceSettingTableViewController(PrivateImplementation)
/*!
 * initialize
 */
-(void)setupInitialState{
}
@end

//-----------------------------------------------------------------------------
//Public Implementations
//-----------------------------------------------------------------------------
@implementation PhotoSubmitterServiceSettingTableViewController
/*!
 * initialize
 */
- (id)initWithType:(NSString *)inType{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if(self){
        type_ = inType;
        [self setupInitialState];
    }
    return self;
}


#pragma mark -
#pragma mark PhotoSubmitterSettingTableViewProtocol methods
/*!
 * submitter
 */
- (id<PhotoSubmitterProtocol>)submitter{
    return [PhotoSubmitterManager submitterForType:self.type];
}

/*!
 * type
 */
- (NSString *)type{
    return type_;
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
