//
//  ProgressTableViewController.h
//  tottepost
//
//  Created by ISHITOYA Kentaro on 11/12/14.
//  Copyright (c) 2011 cocotomo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProgressTableViewController : UITableViewController{
    __strong NSMutableArray *progresses_;
    __strong NSMutableDictionary *progressBars_;
    __strong NSMutableDictionary *cells_;
}

- (id) initWithFrame:(CGRect)frame;
- (void) updateWithFrame:(CGRect)frame;
- (void) update;
- (void) addProgress: (NSString *)hash;
- (void) updateProgress: (NSString *)hash progress:(CGFloat)progress;
- (void) removeProgress: (NSString *)hash;
- (void) removeProgress: (NSString *)hash message:(NSString *)message;
@end
