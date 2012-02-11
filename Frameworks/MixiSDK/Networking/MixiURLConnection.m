//
//  MixiURLConnection.m
//
//  Created by Platform Service Department on 11/08/03.
//  Copyright 2011 mixi Inc. All rights reserved.
//

#import "MixiURLConnection.h"
#import "MixiConstants.h"
#import "MixiErrorCodes.h"
#import "MixiUtils.h"

@implementation MixiURLConnection

@synthesize connection=connection_;

static bool autoRedirect = NO;

+ (void)setAutoRedirect:(bool)aBool {
    autoRedirect = aBool;
}

+ (BOOL)canHandleRequest:(NSURLRequest *)request {
    return YES;
}

+ (NSData *)sendSynchronousRequest:(NSURLRequest *)request returningResponse:(NSURLResponse **)urlResponse error:(NSError **)error {
    NSData *ret = nil;
    
    // リダイレクト先が特殊（mixi-connect://）な場合はNSURLConnectionは使えないようなのでCFNetworkを使用する
    CFURLRef url = CFURLCreateWithString(kCFAllocatorDefault, (CFStringRef)[[request URL] absoluteString], NULL);
    CFHTTPMessageRef message = CFHTTPMessageCreateRequest(kCFAllocatorDefault, (CFStringRef)[request HTTPMethod], url, kCFHTTPVersion1_1);
    CFHTTPMessageSetBody(message, (CFDataRef)[request HTTPBody]);
    NSDictionary *headers = [request allHTTPHeaderFields];
    for (NSString *key in headers) {
        NSString *value = [headers objectForKey:key];
        CFHTTPMessageSetHeaderFieldValue(message, (CFStringRef)key, (CFStringRef)value);
    }
    
    CFReadStreamRef readStream = CFReadStreamCreateForHTTPRequest(kCFAllocatorDefault, message);
    if (CFReadStreamOpen(readStream)) {
        NSMutableString *responseText = [NSMutableString string];
        CFIndex bytes;
        UInt8 buf[1024];
        do {
            bytes = CFReadStreamRead(readStream, buf, sizeof(buf));
            if (bytes <= 0) break;
            NSString *string = [[NSString alloc] initWithBytes:buf length:bytes encoding:NSUTF8StringEncoding];
            if (string == nil) break;
            [responseText appendString:string];
            [string release];
        } while (1);
        
        CFHTTPMessageRef httpResponse = (CFHTTPMessageRef)CFReadStreamCopyProperty(readStream, kCFStreamPropertyHTTPResponseHeader);
        if(httpResponse) {
            NSDictionary *headers = [(NSDictionary*)CFHTTPMessageCopyAllHeaderFields(httpResponse) autorelease];
            CFIndex responseCode = CFHTTPMessageGetResponseStatusCode(httpResponse);
            int statusType = floor(responseCode / 100);
            if (statusType == 2) {
                *urlResponse = [[[NSURLResponse alloc] initWithURL:[request URL] 
                                                          MIMEType:[headers objectForKey:@"Content-Type"] 
                                             expectedContentLength:[responseText length]
                                                  textEncodingName:@"UTF-8"] autorelease];
                ret = [responseText dataUsingEncoding:NSUTF8StringEncoding];
            }
            else if (statusType == 3) {
                NSString *location = [headers objectForKey:@"Location"];
                if (autoRedirect) {
                    NSMutableURLRequest *req = [request mutableCopy];
                    [req setURL:[NSURL URLWithString:location]];
                    ret = [self sendSynchronousRequest:req returningResponse:urlResponse error:error];
                }
                else {
                    if ([location hasPrefix:[NSString stringWithFormat:@"%@?", kMixiAppErrorUri]]) {
                        NSDictionary *userInfo = MixiUtilParseURLStringOptionsByString(location, @"?");
                        if (error != nil) {
                            *error = [NSError errorWithDomain:kMixiErrorDomain
                                                         code:kMixiConnectionErrorAPI
                                                     userInfo:userInfo];
                        }
                    }
                    else {
                        *urlResponse = [[[NSURLResponse alloc] initWithURL:[NSURL URLWithString:location] 
                                                                  MIMEType:@"text/text" 
                                                     expectedContentLength:0
                                                          textEncodingName:@"UTF-8"] autorelease];
                        ret = [location dataUsingEncoding:NSUTF8StringEncoding];
                    }
                }
            }
            else if (error != nil) {
                *error = [NSError errorWithDomain:kMixiErrorDomain
                                             code:kMixiConnectionErrorHTTP
                                         userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                                   @"Server error or not found", @"message",
                                                   [NSString stringWithFormat:@"%d", responseCode], @"code", nil]];
            }
            CFRelease(httpResponse);
        }
        else if (error != nil) {
            *error = [NSError errorWithDomain:kMixiErrorDomain
                                         code:kMixiConnectionErrorReadStream
                                     userInfo:[NSDictionary dictionaryWithObject:@"Cannot read properties of the stream."
                                                                          forKey:@"message"]];
        }
    }
    else if (error != nil) {
        *error = [NSError errorWithDomain:kMixiErrorDomain
                                     code:kMixiConnectionErrorOpenStream
                                 userInfo:[NSDictionary dictionaryWithObject:@"Cannot open the stream."
                                                                      forKey:@"message"]];
    }
    
    CFReadStreamClose(readStream);
    CFRelease(message);
    CFRelease(readStream);
    CFRelease(url);
    
    return ret;
}

+ (NSURLConnection *)connectionWithRequest:(NSURLRequest *)request delegate:(id)delegate {
    return [NSURLConnection connectionWithRequest:request delegate:delegate];
}

- (id)initWithRequest:(NSURLRequest *)request delegate:(id)delegate {
    return [self initWithRequest:request delegate:delegate startImmediately:YES];
}

- (id)initWithRequest:(NSURLRequest *)request delegate:(id)delegate startImmediately:(BOOL)startImmediately {
    if ((self = [super init])) {
        self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:delegate startImmediately:startImmediately];
    }
    return self;
}

- (void)dealloc {
    self.connection = nil;
    [super dealloc];
}

@end
