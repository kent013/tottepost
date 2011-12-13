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
- (void) removeProgressCell:(NSString *)hash;
- (void) showText:(NSString *)hash text:(NSString *)text;
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
    progressBars_ = [[NSMutableDictionary alloc] init];
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
    NSString *hash = [progresses_ objectAtIndex:indexPath.row];
    UITableViewCell *cell = [cells_ objectForKey:hash];
    if(cell){
        return cell;
    }
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    cell.backgroundColor = [UIColor clearColor];
    UIProgressView *p = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
    p.frame = CGRectMake(10, 10, 60, 10);
    [progressBars_ setObject:p forKey:hash];
    [cell.contentView addSubview:p];
    [cells_ setObject:cell forKey:hash];
    return cell;
}

/*!
 * on row selected
 */
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated: YES];
}

/*!
 * remove progress cell
 */
- (void)removeProgressCell:(NSString *)hash{
    int index = [progresses_ indexOfObject:hash];
    [progresses_ removeObjectAtIndex:index];
    [progressBars_ removeObjectForKey:hash];
    [cells_ removeObjectForKey:hash];
    NSIndexPath *path = [NSIndexPath indexPathForRow:index inSection:0];
    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:path] withRowAnimation:UITableViewRowAnimationTop];
    NSLog(@"remove");
}

/*!
 * show text
 */
- (void) showText:(NSString *)hash text:(NSString *)text{
    int index = [progresses_ indexOfObject:hash];
    UIProgressView *p = [progressBars_ objectForKey:hash];
    [p removeFromSuperview];
    UITableViewCell *cell = [cells_ objectForKey:hash];
    cell.textLabel.text = text;
    cell.textLabel.textColor = [UIColor blackColor];
    cell.textLabel.font = [UIFont fontWithName:@"AmericanTypewriter-Bold" size:10.0];
    NSLog(@"show %@", text);
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark -
#pragma mark ui parts delegates
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
- (void)addProgress:(NSString *)hash{
    [progresses_ addObject:hash];
    [self.tableView reloadData];
}

/*!
 * update progress
 */
- (void)updateProgress:(NSString *)hash progress:(CGFloat)progress{
    UIProgressView *p = (UIProgressView *)[progressBars_ objectForKey:hash];
    p.progress = progress;
}

/*!
 * remove progress
 */
- (void)removeProgress:(NSString *)hash{
    [self showText:hash text:@"Upload completed"];
    [self performSelector:@selector(removeProgressCell:) withObject:hash afterDelay:5];
}

/*! 
 * remove progress with message
 */
- (void)removeProgress:(NSString *)hash message:(NSString *)message{
    [self showText:hash text:message];
    [self performSelector:@selector(removeProgressCell:) withObject:hash afterDelay:5];
}

#pragma mark -
#pragma mark UIViewController methods
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}
@end

