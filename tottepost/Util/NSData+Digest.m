//
//  NSData+Digest.m
//  iSticky
//
//  Created by ISHITOYA Kentaro on 10/08/26.
//  Copyright 2010 cocotomo. All rights reserved.
//

#import "NSData+Digest.h"
#import "CommonCrypto/CommonDigest.h"

@implementation NSData (Digest)

//calcurate MD5 digest
- (NSString *)MD5DigestString
{
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    
    CC_MD5([self bytes], [self length], digest);
    
    char md5cstring[CC_MD5_DIGEST_LENGTH*2];
    
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        sprintf(md5cstring+i*2, "%02x", digest[i]);
    }
    
    return [NSString stringWithCString:md5cstring encoding:NSASCIIStringEncoding];
}

@end