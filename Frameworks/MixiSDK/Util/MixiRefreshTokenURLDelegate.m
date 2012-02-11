//
//  MixiRefreshTokenURLDelegate.m
//
//  Created by Platform Service Department on 11/08/25.
//  Copyright 2011 mixi Inc. All rights reserved.
//

#import "MixiRefreshTokenURLDelegate.h"
#import "Mixi.h"
#import "MixiDelegate.h"

@implementation MixiRefreshTokenURLDelegate

- (void)successWithJson:(NSDictionary*)json {
    Mixi *mixi = [Mixi sharedMixi];
    [mixi setPropertiesFromDictionary:json];
    [mixi store];
}

@end
