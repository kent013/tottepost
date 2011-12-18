//
//  ProgressTableViewController.m
//  tottepost
//
//  Created by ISHITOYA Kentaro on 11/12/14.
//  Copyright (c) 2011 cocotomo. All rights reserved.
//

#import "ProgressTableViewController.h"

#define TOTTEPOST_PROGRESS_REMOVE_DELAY 5

//-----------------------------------------------------------------------------
//Private Implementations
//-----------------------------------------------------------------------------
@interface ProgressTableViewController(PrivateImplementation)
- (void) setupInitialState:(CGRect)frame;
- (void) removeProgressCell:(UploadProgressEntity *)entity;
- (void) showText:(UploadProgressEntity *)entity text:(NSString *)text;
- (UploadProgressEntity *) progressForType:(PhotoSubmitterType)type andHash:(NSString *)hash;
- (int) indexForProgress:(UploadProgressEntity *)e;
@end

#pragma mark -
#pragma mark Private Implementations
@implementation ProgressTableViewController(PrivateImplementation)
/*!
 * setup initial state
 */
- (void)setupInitialState:(CGRect)frame{
    [self.tableView setFrame:frame];
    self.tableView.delegate = self;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.userInteractionEnabled = NO;
    
    progresses_ = [[NSMutableArray alloc] init];
    cells_ = [[NSMutableDictionary alloc] init];
}

#pragma mark -
#pragma mark tableview methods
/*! 
 * get section number
 */
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

/*!
 * get row number
 */
- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section
{
    return progresses_.count;
}

/*!
 * create cell
 */
-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    UploadProgressEntity *e = [progresses_ objectAtIndex:indexPath.row];
    UITableViewCell *cell = [cells_ objectForKey:e.progressHash];
    if(cell){
        return cell;
    }
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    UIProgressView *p = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
    p.frame = CGRectMake(10, 10, 100, 10);
    p.backgroundColor = [UIColor clearColor];
    p.progressTintColor = [UIColor colorWithRed:0 green:0 blue:0.8 alpha:0.5];
    p.trackTintColor = [UIColor colorWithWhite:0.5 alpha:0.5];
    e.progressBar = p;
    [cell.contentView addSubview:p];
    [cells_ setObject:cell forKey:e.progressHash];
    return cell;
}

/*!
 * set color
 */
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    cell.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.5];
}

/*!
 * on row selected
 */
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated: YES];
}


#pragma mark -
#pragma mark ui parts delegates
/*!
 * remove progress cell
 */
- (void)removeProgressCell:(UploadProgressEntity *)entity{
    int index = [self indexForProgress:entity];
    [progresses_ removeObjectAtIndex:index];
    [cells_ removeObjectForKey:entity.progressHash];
    NSIndexPath *path = [NSIndexPath indexPathForRow:index inSection:0];
    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:path] withRowAnimation:UITableViewRowAnimationTop];
    NSLog(@"remove");
}

#pragma mark -
#pragma mark util methods
/*!
 * show text
 */
- (void) showText:(UploadProgressEntity *)entity text:(NSString *)text{
    [entity.progressBar removeFromSuperview];
    UITableViewCell *cell = [cells_ objectForKey:entity.progressHash];
    cell.textLabel.text = text;
    cell.textLabel.textColor = [UIColor blackColor];
    cell.textLabel.font = [UIFont fontWithName:@"AmericanTypewriter-Bold" size:10.0];
    int index = [self indexForProgress:entity];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
}

/*!
 * get progress entity
 */
- (UploadProgressEntity *)progressForType:(PhotoSubmitterType)type andHash:(NSString *)hash{
    for(UploadProgressEntity *e in progresses_){
        if(e.type == type && [e.photoHash isEqualToString:hash]){
            return e;
        }
    }
    return nil;
}

/*!
 * get index entity
 */
- (int)indexForProgress:(UploadProgressEntity *)e{
    int index = 0;
    for(UploadProgressEntity *ep in progresses_){
        if(ep.type == e.type && [ep.photoHash isEqualToString:e.photoHash]){
            return index;
        }
        index++;
    }
    return index;
}
@end

//-----------------------------------------------------------------------------
//Public Implementations
#pragma mark -
#pragma mark Public Implementations
//-----------------------------------------------------------------------------
@implementation ProgressTableViewController
/*!
 * initialize with frame
 */
- (id) initWithFrame:(CGRect)frame{
    self = [super initWithStyle:UITableViewStylePlain];
    if(self){
        [self setupInitialState:frame];
    }
    return self;
}

/*!
 * update
 */
-(void)update{
    [self updateWithFrame:self.tableView.frame];
}

/*!
 * update frame
 */
-(void)updateWithFrame:(CGRect)frame{
    [self.tableView setFrame:frame];
}

#pragma mark -
#pragma mark progress methods
/*!
 * add progress
 */
- (void)addProgressWithType:(PhotoSubmitterType)type forHash:(NSString *)hash{
    UploadProgressEntity *entity = [[UploadProgressEntity alloc] initWithSubmitterType:type photoHash:hash];
    [progresses_ addObject:entity];
    [self.tableView reloadData];
}

/*!
 * update progress
 */
- (void)updateProgressWithType:(PhotoSubmitterType)type forHash:(NSString *)hash progress:(CGFloat)progress{
    UploadProgressEntity *entity = [self progressForType:type andHash:hash];
    entity.progress = progress;
}

/*!
 * remove progress
 */
- (void)removeProgressWithType:(PhotoSubmitterType)type forHash:(NSString *)hash{
    UploadProgressEntity *entity = [self progressForType:type andHash:hash];
    [self showText:entity text:@"Upload completed"];
    [self performSelector:@selector(removeProgressCell:) withObject:entity afterDelay:TOTTEPOST_PROGRESS_REMOVE_DELAY];
}

/*! 
 * remove progress with message
 */
- (void)removeProgressWithType:(PhotoSubmitterType)type forHash:(NSString *)hash message:(NSString *)message{
    UploadProgressEntity *entity = [self progressForType:type andHash:hash];
    [self showText:entity text:message];
    [self performSelector:@selector(removeProgressCell:) withObject:entity afterDelay:TOTTEPOST_PROGRESS_REMOVE_DELAY];
}

#pragma mark -
#pragma mark UIViewController methods
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}
@end

