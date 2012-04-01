//
//  CMPopTipViewManager.m
//  tottepost
//
//  Created by Kentaro ISHITOYA on 12/04/01.
//  Copyright (c) 2012 cocotomo. All rights reserved.
//

#import "CMPopTipView.h"
#import "CMPopTipViewManager.h"
#import "TottepostSettings.h"
#import "TTLang.h"

static CMPopTipViewManager *TottepostCMPopTipViewManagerInstance_;

//-----------------------------------------------------------------------------
//Private Implementations
//-----------------------------------------------------------------------------
@interface CMPopTipViewManager(PrivateImplementation)
- (void)setupInitialState;
- (BOOL)isAlreadyArchived:(CMPopTipTarget) target;
- (NSString *)keyFromTarget:(CMPopTipTarget)target;
- (void)dismissView:(CMPopTipView *)view;
@end

@implementation CMPopTipViewManager(PrivateImplementation)
/*!
 * initialize
 */
- (void)setupInitialState{
    tips_ = [[NSMutableDictionary alloc] init];
}

/*!
 * check is already archived
 */
- (BOOL)isAlreadyArchived:(CMPopTipTarget)target{
    NSString *key = [self keyFromTarget:target];
    NSNumber *value = [[TottepostSettings sharedInstance].tooltipHistory objectForKey:key];
    if(value == nil){
        return NO;
    }
    return [value boolValue];
}

/*!
 * string from target
 */
- (NSString *)keyFromTarget:(CMPopTipTarget)target{
    return [NSString stringWithFormat:@"%d", target];
}

/*!
 * dismiss view
 */
- (void)dismissView:(CMPopTipView *)view{
    if(currentlyShownView_ == nil || view != currentlyShownView_){
        return;
    }
    [view dismissAnimated:YES];
    NSString *key = [self keyFromTarget:view.tag];
    [tips_ removeObjectForKey:key];
}
@end

//-----------------------------------------------------------------------------
//Public Implementations
//----------------------------------------------------------------------------
@implementation CMPopTipViewManager
/*!
 * initialize
 */
- (id)init{
    self = [super init];
    if(self){
        [self setupInitialState];
    }
    return self;
}


/*!
 * mark as archived
 */
- (void)markAsArchived:(CMPopTipTarget)target{
    NSString *key = [self keyFromTarget:target];
    NSMutableDictionary *history = [NSMutableDictionary dictionaryWithDictionary:[TottepostSettings sharedInstance].tooltipHistory];
    [history setObject:[NSNumber numberWithBool:YES] forKey:key];
    [TottepostSettings sharedInstance].tooltipHistory = history;
    
    if(currentlyShownView_.tag == target){
        [self dismissView:currentlyShownView_];
    }
}

/*!
 * show tips
 */
- (void) showTipsWithTarget:(CMPopTipTarget) target message:(NSString *)message atView:(id)view inView:(UIView *)inView animated:(BOOL)animated{
    if([TottepostSettings sharedInstance].useTooltip == NO){
        return;
    }
    if([self isAlreadyArchived:target]){
        return;
    }
    if(tips_.count != 0){
        return;
    }
    
    message = [NSString stringWithFormat:@"%@(%@)", message, [TTLang localized:@"Tooltip_Dismiss"]];
    CMPopTipView *tipview = [[CMPopTipView alloc] initWithMessage:message];
    tipview.delegate = self;
    tipview.tag = target;  
    tipview.backgroundColor = [UIColor colorWithRed:0.220 green:0.357 blue:0.608 alpha:0.5];
    tipview.textColor = [UIColor colorWithWhite:1.0 alpha:0.9];
    
    if(inView == nil){
        [tipview presentPointingAtBarButtonItem:view animated:YES];
    }else{
        [tipview presentPointingAtView:view inView:inView animated:animated];
    }
    
    NSString *key = [self keyFromTarget:target];
    [tips_ setObject:tipview forKey:key];
    
    currentlyShownView_ = tipview;
    [self performSelector:@selector(dismissView:) withObject:tipview afterDelay:30.0];
}

/*!
 * dissmissed
 */
- (void)popTipViewWasDismissedByUser:(CMPopTipView *)popTipView{
    currentlyShownView_ = nil;
    NSString *key = [self keyFromTarget:popTipView.tag];
    [self markAsArchived:popTipView.tag];
    [tips_ removeObjectForKey:key];
}

/*!
 * get singleton instance
 */
+ (CMPopTipViewManager *)sharedInstance{
    if(TottepostCMPopTipViewManagerInstance_ == nil){
        TottepostCMPopTipViewManagerInstance_ = [[CMPopTipViewManager alloc] init];
    }
    return TottepostCMPopTipViewManagerInstance_;
}
@end
