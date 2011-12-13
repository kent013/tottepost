//
//  FBRequest+UploadProgress.h
//  tottepost
//
//  Created by ISHITOYA Kentaro on 11/12/13.
//  Copyright (c) 2011 cocotomo. All rights reserved.
//

#import "FBRequest.h"

@protocol FBRequestWithUploadProgressDelegate;

@interface FBRequest(UploadProgress)
@end

@protocol FBRequestWithUploadProgressDelegate <FBRequestDelegate>
@optional
/**
 * Called as the body (message data) of a request
 * is transmitted (as during an http POST). It provides the number of bytes
 * written for the latest write, the total number of bytes written and the
 * total number of bytes the connection expects to write (for HTTP this is
 * based on the content length). The total number of expected bytes may change
 * if the request needs to be retransmitted (underlying connection lost, authentication
 * challenge from the server, etc.).
 * See https://github.com/johnmph/facebook-ios-sdk for more information.
 *
 * @param bytesWritten number of bytes written
 * @param totalBytesWritten total number of bytes written for this connection
 * @param totalBytesExpectedToWrite the number of bytes the connection expects to write (can change due to retransmission of body content)
 */
- (void)request:(FBRequest *)request didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite;
@end