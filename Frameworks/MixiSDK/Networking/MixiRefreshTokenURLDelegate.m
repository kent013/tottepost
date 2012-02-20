//
//  MixiRefreshTokenURLDelegate.m
//
//  Created by Platform Service Department on 11/08/25.
//  Copyright 2011 mixi Inc. All rights reserved.
//

#import "MixiRefreshTokenURLDelegate.h"
#import "Mixi.h"
#import "MixiAuthorizer.h"
#import "MixiDelegate.h"

@implementation MixiRefreshTokenURLDelegate

- (void)successWithJson:(id)json {
    Mixi *mixi = [Mixi sharedMixi];
    [mixi.authorizer setPropertiesFromDictionary:json];
    [mixi.authorizer store];
}

@end
