//
//  FBRequest+UploadProgress.m
//  tottepost
//
//  Created by ISHITOYA Kentaro on 11/12/13.
//  Copyright (c) 2011 cocotomo. All rights reserved.
//

#import "FBRequest+UploadProgress.h"

@implementation FBRequest(UploadProgress)
/*!
 * delegate for upload progress
 */
- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
    id<FBRequestWithUploadProgressDelegate> d = (id<FBRequestWithUploadProgressDelegate>)_delegate;
    if ([d respondsToSelector:
         @selector(request:didSendBodyData:totalBytesWritten:totalBytesExpectedToWrite:)]) {
        [d request:self didSendBodyData:bytesWritten totalBytesWritten:totalBytesWritten totalBytesExpectedToWrite:totalBytesExpectedToWrite];
    }
}
@end
