//
//  PhotoSubmitterAlbumEntity.h
//  tottepost
//
//  Created by ISHITOYA Kentaro on 11/12/22.
//  Copyright (c) 2011 cocotomo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PhotoSubmitterAlbumEntity : NSObject<NSCoding>
@property (strong, nonatomic) NSString *albumId;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *privacy;

- (id)initWithId:(NSString*)albumId name:(NSString *)name privacy:(NSString *)privacy;
@end
