//
//  MixiDownloadWebViewController.m
//  iosSDK
//
//  Created by Platform Service Department on 12/01/19.
//  Copyright (c) 2012 mixi Inc. All rights reserved.
//

#import "MixiDownloadWebViewController.h"
#import "MixiDownloadWebViewDelegate.h"

@implementation MixiDownloadWebViewController

- (void)loadView
{
    // Implement loadView to create a view hierarchy programmatically, without using a nib.
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)addCloseTaget:(id)target action:(SEL)action {
    downloadDelegate_ = [[MixiDownloadWebViewDelegate alloc] initWithCloseTarget:target action:action];
}

- (void)dealloc {
    [downloadDelegate_ release];
    [super dealloc];
}

@end
