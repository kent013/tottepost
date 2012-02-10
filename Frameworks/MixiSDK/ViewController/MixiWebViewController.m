//
//  MixiWebViewController.m
//
//  Created by Platform Service Department on 11/08/22.
//  Copyright 2011 mixi Inc. All rights reserved.
//

#import "MixiWebViewController.h"
#import "MixiOrientationDelegate.h"


@implementation MixiWebViewController

@synthesize url=url_, delegate=delegate_, orientationDelegate=orietationDelegate_;

- (id)initWithURL:(NSURL*)url {
    return [self initWithURL:url delegate:nil];
}

- (id)initWithURL:(NSURL*)url delegate:(id<UIWebViewDelegate>)delegate {
    self = [super initWithNibName:@"MixiWebViewController" bundle:nil];
    if (self) {
        self.url = url;
        self.delegate = delegate;
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
    self.url = nil;
    self.delegate = nil;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController.view setFrame:[[UIScreen mainScreen] bounds]];
    [self.navigationController.view setBounds:[[UIScreen mainScreen] bounds]];
    if (self.delegate) {
        webView_.delegate = self.delegate;
    }
    if (self.url) {
        [webView_ loadRequest:[NSURLRequest requestWithURL:self.url]];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (self.orientationDelegate) {
        return [self.orientationDelegate shouldAutorotateToInterfaceOrientation:interfaceOrientation];
    }
    else {
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    }
}

#pragma mark - Actions

- (IBAction)close:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

@end
