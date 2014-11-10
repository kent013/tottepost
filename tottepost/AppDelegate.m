//
//  AppDelegate.m
//  tottepost
//
//  Created by ISHITOYA Kentaro on 11/12/11.
//  Copyright (c) 2011 cocotomo. All rights reserved.
//

#import "ENGPhotoSubmitterManager.h"
#import "AppDelegate.h"
#import "Appirater.h"

@implementation AppDelegate
@synthesize window = _window;
@synthesize mainViewController = _mainViewController;
@synthesize backgroundTaskIdentifer;
@synthesize applicationBecomeActiveAfterOpenURL;

/*!
 * when the application lunched, initialize camera view immediately
 */
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    application.statusBarHidden = NO;
    CGRect frame = [UIScreen mainScreen].bounds;
    self.window = [[UIWindow alloc] initWithFrame:frame];
    self.window.backgroundColor = [UIColor clearColor];
    
    self.mainViewController = [[MainViewController alloc] initWithFrame:frame];
    self.window.rootViewController = self.mainViewController;
    [self.window makeKeyAndVisible];
    
    [[ENGPhotoSubmitterManager sharedInstance] wakeup];
    [Appirater appLaunched:YES];
    return YES;
}

/*!
 * OAuth delegate
 */
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    applicationBecomeActiveAfterOpenURL = YES;
    return [[ENGPhotoSubmitterManager sharedInstance] didOpenURL:url];
}

/*!
 * When the application going to background
 */
- (void)applicationWillResignActive:(UIApplication *)application
{
    [self.mainViewController applicationWillResignActivate];
    UIApplication* app = [UIApplication sharedApplication];
    [self.mainViewController determinRefreshCameraNeeded];
    NSAssert(backgroundTaskIdentifer == UIBackgroundTaskInvalid, nil);
    
    backgroundTaskIdentifer = [app beginBackgroundTaskWithExpirationHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [[ENGPhotoSubmitterManager sharedInstance] suspend];
            if (backgroundTaskIdentifer != UIBackgroundTaskInvalid) {
                [app endBackgroundTask:backgroundTaskIdentifer];
                backgroundTaskIdentifer = UIBackgroundTaskInvalid;
            }
        });
    }];
    
    // Start the long-running task and return immediately.    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        while([[ENGPhotoSubmitterManager sharedInstance] isUploading] &&
              backgroundTaskIdentifer != UIBackgroundTaskInvalid){
            //NSLog(@"continue: %d, %d", [[PhotoSubmitterManager sharedInstance] isUploading], backgroundTaskIdentifer);
            [NSThread sleepForTimeInterval:1];
        }
        //NSLog(@"finished: %d, %d", [[PhotoSubmitterManager sharedInstance] isUploading], backgroundTaskIdentifer);
        [app endBackgroundTask:backgroundTaskIdentifer];
        backgroundTaskIdentifer = UIBackgroundTaskInvalid;
    });
}

/*!
 * When the application came back to foreground
 */
- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [[ENGPhotoSubmitterManager sharedInstance] refreshCredentials];
    UIApplication* app = [UIApplication sharedApplication];
    if(applicationBecomeActiveAfterOpenURL == NO){
        [self.mainViewController applicationDidBecomeActive];
        [[ENGPhotoSubmitterManager sharedInstance] wakeup];
    }
    applicationBecomeActiveAfterOpenURL = NO;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (backgroundTaskIdentifer != UIBackgroundTaskInvalid) {
            [app endBackgroundTask:backgroundTaskIdentifer];
            backgroundTaskIdentifer = UIBackgroundTaskInvalid;
        }
    });
}

/*!
 * When the application terminate
 */
- (void)applicationWillTerminate:(UIApplication *)application{
    NSLog(@"term");
    [[ENGPhotoSubmitterManager sharedInstance] suspend];
}

/*!
 * app will enter foreground
 */
- (void)applicationWillEnterForeground:(UIApplication *)application{
    [Appirater appEnteredForeground:YES];
}
@end
