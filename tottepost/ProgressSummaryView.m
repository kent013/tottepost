//
//  ProgressSummaryView.m
//  tottepost
//
//  Created by ISHITOYA Kentaro on 11/12/21.
//  Copyright (c) 2011 cocotomo. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "ProgressSummaryView.h"
#import "PhotoSubmitterManager.h"
#import "TTLang.h"
#import "FBNetworkReachability.h"

static NSString *kFilePhotoSubmitterType = @"FilePhotoSubmitter";

#define PSV_RETRY_INTERVAL 2
#define PSV_ALERT_RESTART 1
#define PSV_ALERT_ABORT 2

//-----------------------------------------------------------------------------
//Private Implementations
//-----------------------------------------------------------------------------
@interface ProgressSummaryView(PrivateImplementation)
- (void)setupInitialState: (CGRect)frame;
- (void)updateLabel;
- (void)handleTapGesture: (UITapGestureRecognizer *)sender;
@end

@implementation ProgressSummaryView(PrivateImplementation)
/*!
 * setup initial state
 */
- (void)setupInitialState:(CGRect)frame{
    self.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.2];
    [self.layer setCornerRadius:5.0];
    [self setClipsToBounds:YES];
    
    [self.layer setBorderColor:[[UIColor colorWithWhite:0.8 alpha:0.4] CGColor]];
    [self.layer setBorderWidth:1.0];
    
    textLabel_ = [[UILabel alloc] initWithFrame:CGRectZero];
    textLabel_.textColor = [UIColor blackColor];
    textLabel_.font = [UIFont systemFontOfSize:10.0];
    textLabel_.backgroundColor = [UIColor clearColor];
    textLabel_.textAlignment = UITextAlignmentCenter;
    [self addSubview:textLabel_];

    cancelImage = [UIImage imageNamed:@"cancel.png"];
    retryImage = [UIImage imageNamed:@"retry.png"];
    imageView = [[UIImageView alloc] initWithImage:cancelImage];
    [self addSubview:imageView];
    
    self.alpha = 0.0f;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    [self addGestureRecognizer:tapGesture];
    [[PhotoSubmitterManager sharedInstance] addDelegate:self];
}

/*!
 * update Label
 */
- (void)updateLabel{        
    if([PhotoSubmitterManager sharedInstance].isError &&
       [PhotoSubmitterManager sharedInstance].errorOperationCount == operationCount_){
        imageView.image = retryImage;
    }else{
        imageView.image = cancelImage;
    }
    if(operationCount_ == 0){
        textLabel_.text = [NSString stringWithFormat:[TTLang localized:@"Progress_Finished"], operationCount_];
    }else{
        textLabel_.text = [NSString stringWithFormat:[TTLang localized:@"Progress_Uploading"], operationCount_];
    }
    [textLabel_ sizeToFit];
    [self updateWithFrame:self.frame];
}

/*!
 * handle tap gesture
 */
- (void)handleTapGesture:(UITapGestureRecognizer *)sender{
    [[PhotoSubmitterManager sharedInstance] pause];
    UIAlertView *alert = nil;
    
    if([PhotoSubmitterManager sharedInstance].isError &&
       [PhotoSubmitterManager sharedInstance].errorOperationCount == operationCount_){
        alert = [[UIAlertView alloc] initWithTitle:[TTLang localized:@"Restart_Alert_Message"]
                                           message:[TTLang localized:@"Restart_Alert_Message"]
                                          delegate:self 
                                 cancelButtonTitle:[TTLang localized:@"Restart_Alert_Cancel"]
                                 otherButtonTitles:[TTLang localized:@"Restart_Alert_OK"], nil];
        alert.tag = PSV_ALERT_RESTART;
    }else{
        alert = [[UIAlertView alloc] initWithTitle:[TTLang localized:@"Abort_Alert_Title"]
                                           message:[TTLang localized:@"Abort_Alert_Message"]
                                          delegate:self 
                                 cancelButtonTitle:[TTLang localized:@"Abort_Alert_Cancel"]
                                 otherButtonTitles:[TTLang localized:@"Abort_Alert_OK"], nil];
        alert.tag = PSV_ALERT_ABORT;
    }
    [alert show];
}
@end

//-----------------------------------------------------------------------------
//Public Implementations
//----------------------------------------------------------------------------
@implementation ProgressSummaryView
/*!
 * initialize
 */
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupInitialState:frame];
    }
    return self;
}

/*!
 * update with frame
 */
- (void)updateWithFrame:(CGRect)inFrame{
    self.frame = inFrame;
    imageView.frame = CGRectMake(5, 5, inFrame.size.height - 10, inFrame.size.height - 10);
    CGRect labelFrame = CGRectMake(imageView.frame.size.width, 0, inFrame.size.width - imageView.frame.size.width, inFrame.size.height);
    textLabel_.frame = labelFrame;    
}

/*!
 * show view
 */
- (void) show{
    self.alpha = 0.0;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:1.0f];
    self.alpha = 1.0f;
    [UIView commitAnimations];  
    isVisible_ = YES;
}

/*!
 * hide view
 */
- (void) hide{
    self.alpha = 1.0f;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:1.0f];
    self.alpha = 0.0f;
    [UIView commitAnimations];   
    isVisible_ = NO;
}

/*!
 * PhotoSubmitterPhotoDelegate will start upload
 */
- (void)photoSubmitter:(id<PhotoSubmitterProtocol>)photoSubmitter willStartUpload:(NSString *)imageHash{
    dispatch_async(dispatch_get_main_queue(), ^{
        operationCount_ = [PhotoSubmitterManager sharedInstance].uploadOperationCount;
        enabledAppCount_ = [PhotoSubmitterManager sharedInstance].enabledSubmitterCount;
        [self updateLabel];
        if(operationCount_ != 0 && isVisible_ == NO){
            [self show];
        }
    });
}

/*!
 * PhotoSubmitterPhotoDelegate did submitted
 */
- (void)photoSubmitter:(id<PhotoSubmitterProtocol>)photoSubmitter didSubmitted:(NSString *)imageHash suceeded:(BOOL)suceeded message:(NSString *)message{    
    dispatch_async(dispatch_get_main_queue(), ^{
        if([photoSubmitter.type isEqualToString:kFilePhotoSubmitterType]){
            return;
        }
        if(suceeded){
            operationCount_--;
            enabledAppCount_ = [PhotoSubmitterManager sharedInstance].enabledSubmitterCount;
            if(operationCount_ <= 0 && isVisible_){
                [self hide];
            }
            [self updateLabel];
        }
    });
}

/*!
 * PhotoSubmitterPhotoDelegate did progress changed
 */
- (void)photoSubmitter:(id<PhotoSubmitterProtocol>)photoSubmitter didProgressChanged:(NSString *)imageHash progress:(CGFloat)progress{
    //do nothing
}

/*!
 * PhotoSubmitterPhotoDelegate did cancel
 */
- (void)photoSubmitter:(id<PhotoSubmitterProtocol>)photoSubmitter didCanceled:(NSString *)imageHash{
    //do nothing
}

#pragma mark -
#pragma mark UIAlertView delegate methods

-(void)alertView:(UIAlertView*)alertView
clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (alertView.tag) {
        case PSV_ALERT_ABORT:{
            switch (buttonIndex) {
                case 0:{
                    if([FBNetworkReachability sharedInstance].connectionMode == FBNetworkReachableNon){
                        break;
                    }
                    [[PhotoSubmitterManager sharedInstance] performSelector:@selector(restart) withObject:nil afterDelay:PSV_RETRY_INTERVAL];
                    [self updateLabel];            
                    break;
                }
                case 1:{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[PhotoSubmitterManager sharedInstance] cancel];
                        [self updateLabel];
                    });
                    break;
                }
            }
        }
        case PSV_ALERT_RESTART:{
            switch (buttonIndex) {
                case 0:{      
                    break;
                }
                case 1:{
                    if([FBNetworkReachability sharedInstance].connectionMode == FBNetworkReachableNon){
                        break;
                    }
                    [[PhotoSubmitterManager sharedInstance] performSelector:@selector(restart) withObject:nil afterDelay:PSV_RETRY_INTERVAL];
                    [self updateLabel]; 
                    break;
                }
            }
        }
    }
}

#pragma mark -
#pragma mark PhotoSubmitterManager delegate methods

/*!
 * PhotoSubmitterManager delegate did operation added
 */
- (void)photoSubmitterManager:(PhotoSubmitterManager *)photoSubmitterManager didOperationAdded:(PhotoSubmitterOperation *)operation{
    dispatch_async(dispatch_get_main_queue(), ^{
        operationCount_ = [PhotoSubmitterManager sharedInstance].uploadOperationCount;
        [self updateLabel];
    });
}

/*!
 * PhotoSubmitterManager delegate did operation canceled
 */
- (void) didUploadCanceled{
    dispatch_async(dispatch_get_main_queue(), ^{
        operationCount_ = [PhotoSubmitterManager sharedInstance].uploadOperationCount;
        [self updateLabel];
        if(operationCount_ == 0 && isVisible_){
            [self hide];
        }
    });
}

@end
