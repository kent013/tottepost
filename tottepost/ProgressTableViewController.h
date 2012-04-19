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
- (void) addProgressWithAccount:(PhotoSubmitterAccount *)account forHash:(NSString *)hash;
- (void) updateProgressWithAccount:(PhotoSubmitterAccount *)account forHash: (NSString *)hash progress:(CGFloat)progress;
- (void) removeProgressWithAccount:(PhotoSubmitterAccount *)account forHash: (NSString *)hash message:(NSString *)message delay:(int)delay;
@end
