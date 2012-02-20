//
//  MixiConfig.m
//
//  Created by Platform Service Department on 11/06/29.
//  Copyright 2011 mixi Inc. All rights reserved.
//

#import <CommonCrypto/CommonHMAC.h>
#import "MixiConfig.h"
#import "MixiConstants.h"
#import "MixiUtils.h"

#define kMixiConfigVersion @"1.0";

@implementation MixiConfig

@synthesize clientId=clientId_, 
    secret=secret_,
    redirectUrl=redirectUrl_,
    selectorType=selectorType_, 
    version=version_,
    pbkey=pbkey_,
    urlScheme=urlScheme_;

#pragma mark - Initialize

+ (id)configWithType:(MixiApiType)type {
    return [self configWithType:type clientId:nil secret:nil redirectUrl:nil];
}

+ (id)configWithType:(MixiApiType)type clientId:(NSString*)cid secret:(NSString*)secret {
    return [self configWithType:type clientId:cid secret:secret redirectUrl:nil];
}

+ (id)configWithType:(MixiApiType)type clientId:(NSString*)cid secret:(NSString*)secret redirectUrl:(NSString *)redirectUrl {
    return [[[self alloc] initWithType:type clientId:cid secret:secret redirectUrl:redirectUrl] autorelease];
}

+ (id)configWithType:(MixiApiType)type clientId:(NSString*)cid secret:(NSString*)secret appId:(NSString*)appId {
    NSLog(@"appId is ignored. Please use configWithType:clientId:secret: method instead.");
    return [[[self alloc] initWithType:type clientId:cid secret:secret] autorelease];
}

- (id)init {
    return [self initWithType:kMixiApiTypeSelectorGraphApi];
}

- (id)initWithType:(MixiApiType)type {
    return [self initWithType:type clientId:nil secret:nil redirectUrl:nil];
}

- (id)initWithType:(MixiApiType)type clientId:(NSString*)cid secret:(NSString*)secret {
    return [self initWithType:type clientId:cid secret:secret redirectUrl:nil];
}

- (id)initWithType:(MixiApiType)type clientId:(NSString*)cid secret:(NSString*)secret redirectUrl:(NSString*)redirectUrl {
    if ((self = [super init])) {
        self.selectorType = type;
        self.clientId = cid;
        self.secret = secret;
        self.redirectUrl = redirectUrl;
        if (!redirectUrl) self.redirectUrl = kMixiDefaultRedirectUrl;
        self.version = kMixiConfigVersion;
        self.urlScheme = MixiUtilFirstBundleURLScheme();
    }
    
    return self;
}

- (id)initWithType:(MixiApiType)type clientId:(NSString*)cid secret:(NSString*)secret appId:(NSString*)appId {
    NSLog(@"appId is ignored. Please use initWithType:clientId:secret: method instead.");
    return [self initWithType:type clientId:cid secret:secret redirectUrl:nil];
}

#pragma mark -

- (BOOL)isReady {
    return self.clientId != nil && self.secret != nil;
}

- (NSString*)description {
    return [NSString stringWithFormat:@"{clientId:%@, secret:%@, redirectUrl:%@, selectorType:%d, version:%@}", 
            self.clientId, self.secret, self.redirectUrl, self.selectorType, self.version];
}

#pragma mark - Getter

- (NSString*)pbkey {
    if (pbkey_ == nil) {
        NSMutableString *value = [NSMutableString string];
        const char *key  = [self.secret cStringUsingEncoding:NSASCIIStringEncoding];
        const char *data = [self.clientId cStringUsingEncoding:NSASCIIStringEncoding];
        unsigned char digest[CC_SHA1_DIGEST_LENGTH];
        CCHmac(kCCHmacAlgSHA1, key, strlen(key), data, strlen(data), digest);
        for (int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++) {
            [value appendFormat:@"%02x", digest[i]];
        }
        pbkey_ = [value retain];
    }
    return pbkey_;
}

#pragma mark - 

- (void)dealloc {
    self.clientId = nil;
    self.secret = nil;
    self.redirectUrl = nil;
    self.version = nil;
    if (pbkey_ != nil) {
        [pbkey_ release];
        pbkey_ = nil;
    }
    self.urlScheme = nil;
    [super dealloc];
}

@end
