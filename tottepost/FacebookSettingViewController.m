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
- (void) didLoginButtonTapped:(id)sender;
@end

@implementation FacebookSettingViewController(PrivateImplementation)
-(void)setupInitialState{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.titleLabel.text = @"Login to facebook";
    button.frame = CGRectMake(10, 10, 200, 30);
    [button addTarget:self action:@selector(didLoginButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (void)didLoginButtonTapped:(id)sender{
    facebook_ = [[Facebook alloc] initWithAppId:@"206421902773102" andDelegate:self];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"FBAccessTokenKey"] 
        && [defaults objectForKey:@"FBExpirationDateKey"]) {
        facebook_.accessToken = [defaults objectForKey:@"FBAccessTokenKey"];
        facebook_.expirationDate = [defaults objectForKey:@"FBExpirationDateKey"];
    }
    if (![facebook_ isSessionValid]) {
        [facebook_ authorize:nil];
    }    
}
@end

//-----------------------------------------------------------------------------
//Public Implementations
//-----------------------------------------------------------------------------
@implementation FacebookSettingViewController
- (Facebook *)facebook{
    return facebook_;
}

- (void)fbDidLogin {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[facebook_ accessToken] forKey:@"FBAccessTokenKey"];
    [defaults setObject:[facebook_ expirationDate] forKey:@"FBExpirationDateKey"];
    [defaults synchronize];
    
}

- (id)init{
    self = [super init];
    if(self){
        [self setupInitialState];
    }
    return self;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
