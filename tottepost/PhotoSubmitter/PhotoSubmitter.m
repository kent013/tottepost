//
//  PhotoSubmitter.m
//  tottepost
//
//  Created by ISHITOYA Kentaro on 11/12/13.
//  Copyright (c) 2011 cocotomo. All rights reserved.
//

#import "PhotoSubmitter.h"
/*!
 * singleton instance
 */
static PhotoSubmitter* TottePostPhotoSubmitter;

//-----------------------------------------------------------------------------
//Private Implementations
//-----------------------------------------------------------------------------
@interface PhotoSubmitter(PrivateImplementation)
- (void) setupInitialState;
@end

@implementation PhotoSubmitter(PrivateImplementation)
-(void)setupInitialState{
    submitters_ = [[NSMutableDictionary alloc] init];
    [self loadSubmitters];
}
@end

//-----------------------------------------------------------------------------
//Public Implementations
//-----------------------------------------------------------------------------

@implementation PhotoSubmitter
/*!
 * initializer
 */
- (id)init{
    self = [super init];
    if(self){
        [self setupInitialState];
    }
    return self;
}

/*!
 * get submitter
 */
- (id<PhotoSubmitterProtocol>)submitterWithType:(PhotoSubmitterType)type{
    id <PhotoSubmitterProtocol> submitter = [submitters_ objectForKey:[NSNumber numberWithInt:type]];
    if(submitter){
        return submitter;
    }
    switch (type) {
        case PhotoSubmitterTypeFacebook:
            submitter = [[FacebookPhotoSubmitter alloc] init];
            break;
        case PhotoSubmitterTypeTwitter:
            break;
        case PhotoSubmitterTypeFlickr:
            submitter = [[FlickrPhotoSubmitter alloc] init];
            break;
        default:
            break;
    }
    [submitters_ setObject:submitter forKey:[NSNumber numberWithInt:type]];
    return submitter;
}

/*!
 * submit photo to social app
 */
- (void)submitPhoto:(UIImage *)photo{
    [self submitPhoto:photo comment:nil];
}

/*!
 * submit photo with comment to social app
 */
- (void)submitPhoto:(UIImage *)photo comment:(NSString *)comment{
    for(NSNumber *key in submitters_){
        id<PhotoSubmitterProtocol> submitter = [submitters_ objectForKey:key];
        if([submitter isLogined]){
            [submitter submitPhoto:photo];
        }
    }
}

/*!
 * set authentication delegate to submitters
 */
- (void)setAuthenticationDelegate:(id<PhotoSubmitterAuthenticationDelegate>)delegate{
    for(NSNumber *key in submitters_){
        id<PhotoSubmitterProtocol> submitter = [submitters_ objectForKey:key];
        submitter.authDelegate = delegate;
    }
}

/*!
 * set photo delegate to submitters
 */
- (void)setPhotoDelegate:(id<PhotoSubmitterPhotoDelegate>)delegate{
    for(NSNumber *key in submitters_){
        id<PhotoSubmitterProtocol> submitter = [submitters_ objectForKey:key];
        submitter.photoDelegate = delegate;
    }
}

/*!
 * load selected submitters
 */
- (void)loadSubmitters{
    if([FacebookPhotoSubmitter isEnabled]){
        [self submitterWithType:PhotoSubmitterTypeFacebook];
    }
}

/*!
 * on url loaded
 */
- (BOOL)didOpenURL:(NSURL *)url{
    for(NSNumber *key in submitters_){
        id<PhotoSubmitterProtocol> submitter = [submitters_ objectForKey:key];
        if([submitter isProcessableURL:url]){
            return [submitter didOpenURL:url];
        }
    }
    return NO; 
}

#pragma mark -
#pragma mark static methods
/*!
 * singleton method
 */
+ (PhotoSubmitter *)getInstance{
    if(TottePostPhotoSubmitter == nil){
        TottePostPhotoSubmitter = [[PhotoSubmitter alloc]init];
    }
    return TottePostPhotoSubmitter;
}
/*!
 * get facebook photo submitter
 */
+ (FacebookPhotoSubmitter *)facebookPhotoSubmitter{
    return (FacebookPhotoSubmitter *)[[PhotoSubmitter getInstance] submitterWithType:PhotoSubmitterTypeFacebook];
}
/*!
 * get facebook photo submitter
 */
+ (FlickrPhotoSubmitter *)flickrPhotoSubmitter{
    return (FlickrPhotoSubmitter *)[[PhotoSubmitter getInstance] submitterWithType:PhotoSubmitterTypeFlickr];
}
@end
