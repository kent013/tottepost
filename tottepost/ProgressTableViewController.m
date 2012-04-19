//
//  ProgressTableViewController.m
//  tottepost
//
//  Created by ISHITOYA Kentaro on 11/12/14.
//  Copyright (c) 2011 cocotomo. All rights reserved.
//

#import "ProgressTableViewController.h"

//-----------------------------------------------------------------------------
//Private Implementations
//-----------------------------------------------------------------------------
@interface ProgressTableViewController(PrivateImplementation)
- (void) setupInitialState:(CGRect)frame;
- (void) removeProgressCell:(UploadProgressEntity *)entity;
- (void) showText:(UploadProgressEntity *)entity text:(NSString *)text;
- (UploadProgressEntity *) progressForAccount:(PhotoSubmitterAccount *)account andHash:(NSString *)hash;
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
    [self.view setAutoresizingMask:UIViewAutoresizingNone];
    self.tableView.delegate = self;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
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
 * get height
 */
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return self.progressSize.height;
}

/*!
 * create cell
 */
-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    UploadProgressEntity *e = [progresses_ objectAtIndex:indexPath.row];
    ProgressTableViewCell *cell = [cells_ objectForKey:e.progressHash];
    if(cell){
        return cell;
    }
    cell = [[ProgressTableViewCell alloc] initWithSubmitter:e.submitter andSize:self.progressSize];
    [cells_ setObject:cell forKey:e.progressHash];
    return cell;
}

/*!
 * set color
 */
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    cell.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.2];
    cell.textLabel.backgroundColor = [UIColor clearColor];
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
    if(progresses_.count <= index){
        return;
    }
    [progresses_ removeObjectAtIndex:index];
    [cells_ removeObjectForKey:entity.progressHash];
    NSIndexPath *path = [NSIndexPath indexPathForRow:index inSection:0];
    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:path] withRowAnimation:UITableViewRowAnimationTop];
}

#pragma mark -
#pragma mark util methods
/*!
 * show text
 */
- (void) showText:(UploadProgressEntity *)entity text:(NSString *)text{
    ProgressTableViewCell *cell = [cells_ objectForKey:entity.progressHash];
    [cell showText:text];
    int index = [self indexForProgress:entity];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
}

/*!
 * get progress entity
 */
- (UploadProgressEntity *)progressForAccount:(PhotoSubmitterAccount *)account andHash:(NSString *)hash{
    for(UploadProgressEntity *e in progresses_){
        if([e.account.accountHash isEqualToString:account.accountHash] && 
           [e.contentHash isEqualToString:hash]){
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
        if([ep.account.accountHash isEqualToString:e.account.accountHash] &&
           [ep.contentHash isEqualToString:e.contentHash]){
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
@synthesize progressSize;
/*!
 * initialize with frame
 */
- (id) initWithFrame:(CGRect)frame andProgressSize:(CGSize)size{
    self = [super init];
    if(self){
        self.progressSize = size;
        [self setupInitialState:frame];
    }
    return self;
}

/*!
 * update
 */
-(void)update{
    [self updateWithFrame:self.view.frame];
}   

/*!
 * update frame
 */
-(void)updateWithFrame:(CGRect)frame{
    [self.view setFrame:frame];
}

#pragma mark -
#pragma mark progress methods
/*!
 * add progress
 */
- (void)addProgressWithAccount:(PhotoSubmitterAccount *)account forHash:(NSString *)hash{
    UploadProgressEntity *entity = [[UploadProgressEntity alloc] initWithAccount:account contentHash:hash];
    if(entity == nil){
        return;
    }
    [progresses_ addObject:entity];
    [self.tableView reloadData];
}

/*!
 * update progress
 */
- (void)updateProgressWithAccount:(PhotoSubmitterAccount *)account forHash:(NSString *)hash progress:(CGFloat)progress{
    UploadProgressEntity *entity = [self progressForAccount:account andHash:hash];
    if(entity == nil){
        return;
    }
    entity.progress = progress;
    
    ProgressTableViewCell *cell = [cells_ objectForKey:entity.progressHash];
    cell.progressView.progress = progress;
    [cell.progressView performSelectorOnMainThread:@selector(setNeedsDisplay) withObject:nil waitUntilDone:NO];
}

/*! 
 * remove progress with message
 */
- (void)removeProgressWithAccount:(PhotoSubmitterAccount *)account forHash:(NSString *)hash message:(NSString *)message delay:(int)delay{
    UploadProgressEntity *entity = [self progressForAccount:account andHash:hash];
    if(entity == nil){
        return;
    }
    [self showText:entity text:message];
    [self performSelector:@selector(removeProgressCell:) withObject:entity afterDelay:delay];
}
@end

