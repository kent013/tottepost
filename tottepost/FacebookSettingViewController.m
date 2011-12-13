//
//  FacebookSettingViewController.m
//  tottepost
//
//  Created by ISHITOYA Kentaro on 11/12/12.
//  Copyright (c) 2011 cocotomo. All rights reserved.
//

#import "FacebookSettingViewController.h"
//-----------------------------------------------------------------------------
//Private Implementations
//-----------------------------------------------------------------------------
@interface FacebookSettingViewController(PrivateImplementation)
- (void) setupInitialState;
@end

@implementation FacebookSettingViewController(PrivateImplementation)
-(void)setupInitialState{
}
@end

//-----------------------------------------------------------------------------
//Public Implementations
//-----------------------------------------------------------------------------
@implementation FacebookSettingViewController
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
