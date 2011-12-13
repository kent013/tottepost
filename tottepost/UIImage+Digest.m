//
//  UIImage+Digest.m
//  iSticky
//
//  Created by ISHITOYA Kentaro on 10/08/26.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "UIImage+Digest.h"
#import "NSData+Digest.h"
#import "CommonCrypto/CommonDigest.h"

@implementation UIImage (Digest)

//MD5ダイジェストを計算する
- (NSString *)MD5DigestString
{
    NSData* pngData = [[NSData alloc] initWithData:UIImagePNGRepresentation(self)];
    return [pngData MD5DigestString];
}

@end