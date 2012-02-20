//
//  MixiWebViewController.m
//
//  Created by Platform Service Department on 11/08/22.
//  Copyright 2011 mixi Inc. All rights reserved.
//

#import "MixiWebViewController.h"
#import "MixiOrientationDelegate.h"


@implementation MixiWebViewController

@synthesize url=url_, html=html_, delegate=delegate_, orientationDelegate=orietationDelegate_, toolbarTitle=toolbarTitle_, toolbarColor=toolbarColor_;

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

- (id)initWithHTML:(NSString*)html delegate:(id<UIWebViewDelegate>)delegate {
    self = [super initWithNibName:@"MixiWebViewController" bundle:nil];
    if (self) {
        self.html = html;
        self.delegate = delegate;
    }
    return self;
}

- (void)dealloc
{
    self.url = nil;
    self.html = nil;
    self.delegate = nil;
    self.toolbarColor = nil;
    self.toolbarTitle = nil;
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - Getter/Setter

- (void)setToolbarTitle:(NSString *)toolbarTitle {
    [toolbarTitle_ release];
    toolbarTitle_ = [toolbarTitle copy];
    if (titleLabel_) titleLabel_.text = toolbarTitle_;
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
    else if (self.html) {
//        [webView_ loadHTMLString:self.html baseURL:[NSURL URLWithString:@"http://mixi.jp"]];
        [webView_ loadHTMLString:self.html baseURL:[NSURL URLWithString:@"/"]];
    }
    if (self.toolbarTitle) {
        titleLabel_.text = self.toolbarTitle;
    }
    if (self.toolbarColor) {
        toolbar_.tintColor = self.toolbarColor;
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
