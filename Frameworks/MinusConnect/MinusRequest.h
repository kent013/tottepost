//
//  MinusRequest.h
//  MinusConnect
//
//  Created by Kentaro ISHITOYA on 12/02/21.
//  Copyright (c) 2012 Kentaro ISHITOYA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MinusProtocol.h"

@interface MinusRequest : NSObject<NSURLConnectionDelegate, NSURLConnectionDataDelegate>{
    __strong NSString *tag_;
    __strong NSURLConnection *connection_;
    __strong NSMutableData *data_;
    __weak id<MinusRequestDelegate> delegate_;
}
@property (nonatomic, readonly) NSURL *url;
@property (nonatomic, readonly) NSString *httpMethod;
@property (nonatomic, readonly) NSURLConnection *connection;
@property (nonatomic, strong) NSString *tag;
@property (nonatomic, weak) id<MinusRequestDelegate> delegate;

- (id)initWithURLRequest:(NSURLRequest*)request 
             andDelegate:(id<MinusRequestDelegate>)aDelegate;
-(void) cancel;
-(void) start;
@end
