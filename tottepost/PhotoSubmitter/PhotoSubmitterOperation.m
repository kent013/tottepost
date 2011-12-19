//
//  PhotoSubmitterOperation.m
//  tottepost
//
//  Created by ISHITOYA Kentaro on 11/12/19.
//  Copyright (c) 2011 cocotomo. All rights reserved.
//

#import "PhotoSubmitterOperation.h"
//-----------------------------------------------------------------------------
//Private Implementations
//-----------------------------------------------------------------------------
@interface PhotoSubmitterOperation(PrivateImplementation)
@end

@implementation PhotoSubmitterOperation(PrivateImplementation)
@end

//-----------------------------------------------------------------------------
//Public Implementations
//----------------------------------------------------------------------------
@implementation PhotoSubmitterOperation
@synthesize submitter;
@synthesize photo;
@synthesize comment;
/*!
 * initialize with data
 */
- (id)initWithSubmitter:(id<PhotoSubmitterProtocol>)inSubmitter 
                  photo:(UIImage *)inPhoto comment:(NSString *)inComment{
    self = [super init];
    if(self){
        self.submitter = inSubmitter;
        self.photo = inPhoto;
        self.comment = inComment;
    }
    return self;
}

/*!
 * operation main
 */
- (void)main{
    [self.submitter submitPhoto:self.photo comment:self.comment];
}
@end
