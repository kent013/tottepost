//
//  main.m
//  tottepost
//
//  Created by ISHITOYA Kentaro on 11/12/11.
//  Copyright (c) 2011 cocotomo. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AppDelegate.h"
#import "UncaughtExceptionHandler.h"
void uncaughtExceptionHandler(NSException *exception);
void uncaughtExceptionHandler(NSException *exception) {
    NSLog(@"CRASH: %@", exception);
    NSLog(@"Stack Trace: %@", [exception callStackSymbols]);
    // Internal error reporting
}
int main(int argc, char *argv[])
{
    @autoreleasepool {
        NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
        //InstallUncaughtExceptionHandler();
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
