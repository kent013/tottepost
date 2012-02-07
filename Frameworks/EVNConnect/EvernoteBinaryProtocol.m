//
//  EvernoteBinaryProtocol.m
//  tottepost
//
//  Created by Kentaro ISHITOYA on 12/02/07.
//  Copyright (c) 2012 Kentaro ISHITOYA. All rights reserved.
//

#import "EvernoteBinaryProtocol.h"
#import "EvernoteHTTPClient.h"

@implementation EvernoteBinaryProtocol
/*!
 * override to obtain method name
 */
- (void)writeMessageBeginWithName:(NSString *)name type:(int)messageType sequenceID:(int)sequenceID{
    [super writeMessageBeginWithName:name type:messageType sequenceID:sequenceID];
    if(TMessageType_CALL && sequenceID == 0){
        EvernoteHTTPClient *client = (EvernoteHTTPClient *)self.transport;
        client.method = name;
    }
}
@end
