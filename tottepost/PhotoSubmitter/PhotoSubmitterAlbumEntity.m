//
//  PhotoSubmitterAlbumEntity.m
//  tottepost
//
//  Created by ISHITOYA Kentaro on 11/12/22.
//  Copyright (c) 2011 cocotomo. All rights reserved.
//

#import "PhotoSubmitterAlbumEntity.h"


//-----------------------------------------------------------------------------
//Private Implementations
//-----------------------------------------------------------------------------
@interface PhotoSubmitterAlbumEntity(PrivateImplementation)
@end

@implementation PhotoSubmitterAlbumEntity(PrivateImplementation)
@end

//-----------------------------------------------------------------------------
//Public Implementations
//-----------------------------------------------------------------------------
@implementation PhotoSubmitterAlbumEntity
@synthesize albumId;
@synthesize name;
@synthesize privacy;

/*!
 * initializer
 */
- (id)initWithId:(NSString*)inAlbumId name:(NSString *)inName privacy:(NSString *)inPrivacy{
    self = [super init];
    if(self){
        self.albumId = inAlbumId;
        self.name = inName;
        self.privacy = inPrivacy;
    }
    return self;
}

/*!
 * encode
 */
- (void)encodeWithCoder:(NSCoder*)coder {
    [coder encodeObject:self.albumId forKey:@"albumId"];
    [coder encodeObject:self.name forKey:@"name"];
    [coder encodeObject:self.privacy forKey:@"privacy"];
}

/*!
 * init with coder
 */
- (id)initWithCoder:(NSCoder*)coder {
    self = [super init];
    if (self) {
        self.albumId = [coder decodeObjectForKey:@"albumId"]; 
        self.name = [coder decodeObjectForKey:@"name"];
        self.privacy = [coder decodeObjectForKey:@"privacy"];
    }
    return self;
}
@end
