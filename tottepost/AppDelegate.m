//
//  AppDelegate.m
//  tottepost
//
//  Created by ISHITOYA Kentaro on 11/12/11.
//  Copyright (c) 2011 cocotomo. All rights reserved.
//

#import "AppDelegate.h"
#import "PhotoSubmitterManager.h"

@implementation AppDelegate
@synthesize window = _window;
@synthesize mainViewController = _mainViewController;
@synthesize backgroundTaskIdentifer;

/*!
 * when the application lunched, initialize camera view immediately
 */
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    application.statusBarHidden = NO;
    CGRect frame = [UIScreen mainScreen].bounds;
    self.window = [[UIWindow alloc] initWithFrame:frame];
    self.window.backgroundColor = [UIColor whiteColor];
    
    self.mainViewController = [[MainViewController alloc] initWithFrame:frame];
    self.window.rootViewController = self.mainViewController;
    [self.window makeKeyAndVisible];
    [self.mainViewController createCameraController];
    return YES;
}

/*!
 * OAuth delegate
 */
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [[PhotoSubmitterManager getInstance] didOpenURL:url];
}

/*!
 * When the application going to background
 */
- (void)applicationWillResignActive:(UIApplication *)application
{
    UIApplication* app = [UIApplication sharedApplication];
    
    self.mainViewController.isRecoveredFromSuspend = YES;    
    NSAssert(backgroundTaskIdentifer == UIBackgroundTaskInvalid, nil);
    
    backgroundTaskIdentifer = [app beginBackgroundTaskWithExpirationHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (backgroundTaskIdentifer != UIBackgroundTaskInvalid) {
                [app endBackgroundTask:backgroundTaskIdentifer];
                backgroundTaskIdentifer = UIBackgroundTaskInvalid;
            }
        });
    }];    
}

/*!
 * When the application came back to foreground
 */
- (void)applicationDidBecomeActive:(UIApplication *)application
{
    UIApplication* app = [UIApplication sharedApplication];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (backgroundTaskIdentifer != UIBackgroundTaskInvalid) {
            [app endBackgroundTask:backgroundTaskIdentifer];
            backgroundTaskIdentifer = UIBackgroundTaskInvalid;
        }
    });
}
@end
