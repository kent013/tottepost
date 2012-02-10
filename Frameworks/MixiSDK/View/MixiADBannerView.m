//
//  MixiADBannerView.m
//
//  Created by Platform Service Department on 11/08/29.
//  Copyright 2011 mixi Inc. All rights reserved.
//

#import "MixiADBannerView.h"
#import "MixiImageButtonView.h"

#define kMixiLogoImageTag 1000
#define kMixiListImageTag 1001
#define kMixiSearchImageTag 1002
#define kMixiADViewTag 9837

/** \cond PRIVATE */
@interface MixiADBannerView (Private)
- (void)rearrange;
- (void)setup;
- (void)startReporting;
- (void)observeRotating;
- (void)addButtonViewWithImageName:(NSString*)name tag:(int)tag frame:(CGRect)frame linkURL:(NSString*)url;
- (void)linkTo:(NSString*)url;
@end
/** \endcond */


@implementation MixiADBannerView

@synthesize currentContentSizeIdentifier=currentContentSizeIdentifier_,
    useOrientation=useOrientation_,
    mapReporter=mapReporter_;

#pragma mark - Singlelton

static MixiADBannerView *sharedView;

+ (MixiADBannerView*)sharedView {
	@synchronized(self) {
		if (sharedView == nil) {
			sharedView = [[self alloc] init];
            sharedView.tag = kMixiADViewTag;
		}
	}
	return sharedView;
}

#pragma mark - init

- (id)init {
    return [self initWithFrame:CGRectZero];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
        [self startReporting];
        [self observeRotating];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];
    if (self) {
        [self setup];
        [self startReporting];
        [self observeRotating];
    }
    return self;
}

- (void)dealloc
{
    [self.mapReporter release];
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
	[[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:UIDeviceOrientationDidChangeNotification 
                                                  object:nil];
    [super dealloc];
}

- (void)setup {
    [self addButtonViewWithImageName:@"mixi_map_logo.png" 
                                 tag:kMixiLogoImageTag 
                               frame:CGRectMake(5, 5, 36, 16) 
                             linkURL:@"http://mixi.jp/home.pl"];
    [self addButtonViewWithImageName:@"mixi_map_search.png" 
                                 tag:kMixiSearchImageTag 
                               frame:CGRectMake(self.frame.size.width-49, 0, 49, 24) 
                             linkURL:@"http://mixi.jp/search_appli.pl"];
    [self addButtonViewWithImageName:@"mixi_map_list.png" 
                                 tag:kMixiListImageTag 
                               frame:CGRectMake(self.frame.size.width-49-49, 0, 49, 24) 
                             linkURL:@"http://mixi.jp/recent_appli.pl?type=touch"];

    self.currentContentSizeIdentifier = kMixiADBannerContentSizeIdentifierPortrait;
    self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"mixi_map_bg.png"]];
    self.useOrientation = NO;
}

- (void)startReporting {
    self.mapReporter = [MixiReporter mapReporter];
    [self.mapReporter setRetryNever];
    [self.mapReporter ping];
}

- (void)observeRotating {
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didRotate:)
                                                 name:UIDeviceOrientationDidChangeNotification	
                                               object:nil];
}

- (void) didRotate:(NSNotification *)notification {
    if (self.useOrientation) self.orientation = [[notification object] orientation];
}

#pragma mark - Display

- (void)addOnTop {
    UIView *view = ((UIWindow*)[[UIApplication sharedApplication].windows objectAtIndex:0]).rootViewController.view;
    if (![view viewWithTag:kMixiADViewTag]) {
        [self arrangeOn:view];
        [self addOn:view];
    }
}

- (void)addOn:(UIView*)view {
    self.orientation = [[UIDevice currentDevice] orientation];
    [view addSubview:self];        
}

- (void)arrange {
    UIView *view = [self superview];
    [self arrangeOn:view];
}

- (void)arrangeOn:(UIView*)view {
    CGRect frame = view.frame;
    if (frame.origin.y != 25) {
        frame.origin.y = 25;
        frame.size.height -= 25;
        view.frame = frame;
    }
}

#pragma mark - Setter/Getter

- (void)setCurrentContentSizeIdentifier:(int)sizeIdentifier {
    CGRect frame = self.frame;
    frame.origin.x = 0;
    frame.origin.y = 0;
    frame.size.height = 25;
    frame.size.width = sizeIdentifier == kMixiADBannerContentSizeIdentifierPortrait ? 320 : 480;
    self.frame = frame;
    [self rearrange];
}

- (void)setOrientation:(int)orientation {
    if (orientation == UIInterfaceOrientationLandscapeLeft ||
        orientation == UIInterfaceOrientationLandscapeRight) {
        self.currentContentSizeIdentifier = kMixiADBannerContentSizeIdentifierLandscape;
    }
    else {
        self.currentContentSizeIdentifier = kMixiADBannerContentSizeIdentifierPortrait;        
    }
}

- (int)orientation {
    if (self.currentContentSizeIdentifier == kMixiADBannerContentSizeIdentifierLandscape) {
        return UIInterfaceOrientationLandscapeLeft;
    }
    else {
        return UIInterfaceOrientationPortrait;
    }
}

#pragma mark - Private

- (void)rearrange {
    UIView *searchImage = [self viewWithTag:kMixiSearchImageTag];
    CGRect frame = searchImage.frame;
    frame.origin.x = self.frame.size.width - 49;
    searchImage.frame = frame;
    
    UIView *listImage = [self viewWithTag:kMixiListImageTag];
    frame = listImage.frame;
    frame.origin.x = self.frame.size.width - 49 - 49;
    listImage.frame = frame;
}

- (void)addButtonViewWithImageName:(NSString*)name tag:(int)tag frame:(CGRect)frame linkURL:(NSString*)url {
    MixiImageButtonView *imageButton = [[MixiImageButtonView alloc] initWithImage:[UIImage imageNamed:name]];
    imageButton.tag = tag;
    imageButton.frame = frame;
    [imageButton addTarget:self action:@selector(linkTo:) withObject:url];
    [self addSubview:imageButton];
    [imageButton release];
}

- (void)linkTo:(NSString*)url {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

@end
