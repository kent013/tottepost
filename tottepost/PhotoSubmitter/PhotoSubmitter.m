//
//  PhotoSubmitter.m
//  tottepost
//
//  Created by ISHITOYA Kentaro on 11/12/17.
//  Copyright (c) 2011 cocotomo. All rights reserved.
//

#import "PhotoSubmitter.h"
#import "UIImage+Digest.h"

//-----------------------------------------------------------------------------
//Private Implementations
//-----------------------------------------------------------------------------
@interface PhotoSubmitter(PrivateImplementation)
@end

@implementation PhotoSubmitter(PrivateImplementation)
@end

//-----------------------------------------------------------------------------
//Public Implementations
//-----------------------------------------------------------------------------

@implementation PhotoSubmitter
/*!
 * initialize
 */
- (id)init{
    self = [super init];
    if(self){
        photos_ = [[NSMutableDictionary alloc] init];
        requests_ = [[NSMutableDictionary alloc] init];
    }
    return self;
}

/*!
 * add request
 */
- (void)addRequest:(NSObject *)request{
    [requests_ setObject:request forKey:[NSNumber numberWithInt:request.hash]];
}

/*!
 * remove request
 */
- (void)removeRequest:(NSObject *)request{
    [requests_ removeObjectForKey:[NSNumber numberWithInt:request.hash]];
}

/*!
 * set photo hash
 */
- (void)setPhotoHash:(NSString *)photoHash forRequest:(NSObject *)request{
    [photos_ setObject:photoHash forKey:[NSNumber numberWithInt:request.hash]];
}


/*!
 * remove photo hash
 */
- (void)removePhotoForRequest:(NSObject *)request{
    [photos_ removeObjectForKey:[NSNumber numberWithInt:request.hash]];
}

/*!
 * get photo hash
 */
- (NSString *)photoForRequest:(NSObject *)request{
    return [photos_ objectForKey:[NSNumber numberWithInt:request.hash]];
}
@end
