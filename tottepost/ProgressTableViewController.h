//
//  ProgressTableViewController.h
//  tottepost
//
//  Created by ISHITOYA Kentaro on 11/12/14.
//  Copyright (c) 2011 cocotomo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UploadProgressEntity.h"
#import "ProgressTableViewCell.h"

@interface ProgressTableViewController : UITableViewController{
    __strong NSMutableArray *progresses_;
    __strong NSMutableDictionary *cells_;
}

@property (nonatomic, assign) CGSize progressSize;

- (id) initWithFrame:(CGRect)frame andProgressSize:(CGSize)size;
- (void) updateWithFrame:(CGRect)frame;
- (void) update;
- (void) addProgressWithType:(PhotoSubmitterType)type forHash:(NSString *)hash;
- (void) updateProgressWithType:(PhotoSubmitterType)type forHash: (NSString *)hash progress:(CGFloat)progress;
- (void) removeProgressWithType:(PhotoSubmitterType)type forHash: (NSString *)hash message:(NSString *)message delay:(int)delay;
@end
