//
//  MixiRequest.m
//
//  Created by Platform Service Department on 11/06/30.
//  Copyright 2011 mixi Inc. All rights reserved.
//

#import "MixiRequest.h"
#import "Mixi.h"
#import "MixiAuthorizer.h"
#import "MixiConstants.h"
#import "MixiUtils.h"
#import "NSObject+SBJson.h"

#define kMixiDefaultRequestTimeout 20

/** \cond PRIVATE */
@interface MixiRequest (Private)
- (NSString*)buildHTTPParams;
- (void)setupRequestWithAttachments:(NSMutableURLRequest*)request;
- (void)appendData:(NSData*)data toBody:(NSMutableData*)multipartBody withHeader:(NSString*)header boundary:(NSString*)boundary;
- (NSData*)getImageData:(UIImage*)image;
@end
/** \endcond */


@implementation MixiRequest

static NSString *defaultImageType = @"jpeg";
static float defaultCompressionQuality = 90.0;
static NSString *sdkUserAgent = @"tottepost";
static NSTimeInterval defaultRequestTimeout = kMixiDefaultRequestTimeout;
static NSURLRequestCachePolicy defaultRequestCachePolicy = NSURLRequestUseProtocolCachePolicy;

@synthesize endpoint=endpoint_,
    endpointBaseUrl=endpointBaseUrl_,
    body=body_,
    bodyData,
    params=params_,
    attachments=attachments_,
    httpMethod=httpMethod_,
    requestTimeout=requestTimeout_,
    cachePolicy=cachePolicy_,
    imageType=imageType_,
    compressionQuality=compressionQuality_,
    openMixiAppToAuthorizeIfNeeded=openMixiAppToAuthorizeIfNeeded_;

#pragma mark - Initialize

+ (id)requestWithEndpoint:(NSString*)endpoint {
    return [[[self alloc] initWithEndpoint:endpoint] autorelease];
}

+ (id)requestWithMethod:(NSString*)httpMethod endpoint:(NSString*)endpoint {
    return [[[self alloc] initWithMethod:httpMethod endpoint:endpoint] autorelease];
}

+ (id)requestWithMethod:(NSString*)httpMethod endpoint:(NSString*)endpoint body:(NSObject*)body {
    return [[[self alloc] initWithMethod:httpMethod endpoint:endpoint body:body] autorelease];
}

+ (id)requestWithEndpoint:(NSString*)endpoint params:(NSDictionary*)params {
    return [self getRequestWithEndpoint:endpoint params:params];
}

+ (id)getRequestWithEndpoint:(NSString*)endpoint params:(NSDictionary*)params {
    return [[[self alloc] initWithMethod:kMixiHTTPMethodGet endpoint:endpoint params:params] autorelease];
}

+ (id)postRequestWithEndpoint:(NSString*)endpoint {
    return [[[self alloc] initWithMethod:kMixiHTTPMethodPost endpoint:endpoint params:nil] autorelease];
}

+ (id)postRequestWithEndpoint:(NSString*)endpoint params:(NSDictionary*)params {
    return [[[self alloc] initWithMethod:kMixiHTTPMethodPost endpoint:endpoint params:params] autorelease];
}

+ (id)postRequestWithEndpoint:(NSString*)endpoint body:(NSObject*)body {
    return [[[self alloc] initWithMethod:kMixiHTTPMethodPost endpoint:endpoint body:body] autorelease];    
}

+ (id)postRequestWithEndpoint:(NSString*)endpoint body:(NSObject*)body params:(NSDictionary*)params {
    return [[[self alloc] initWithMethod:kMixiHTTPMethodPost endpoint:endpoint body:body params:params] autorelease];    
}

+ (id)putRequestWithEndpoint:(NSString*)endpoint params:(NSDictionary*)params {
    return [[[self alloc] initWithMethod:kMixiHTTPMethodPut endpoint:endpoint params:params] autorelease];
}

+ (id)putRequestWithEndpoint:(NSString*)endpoint body:(NSObject*)body {
    return [[[self alloc] initWithMethod:kMixiHTTPMethodPut endpoint:endpoint body:body] autorelease];
}

+ (id)putRequestWithEndpoint:(NSString*)endpoint body:(NSObject*)body params:(NSDictionary*)params {
    return [[[self alloc] initWithMethod:kMixiHTTPMethodPut endpoint:endpoint body:body params:params] autorelease];
}

+ (id)deleteRequestWithEndpoint:(NSString*)endpoint {
    return [[[self alloc] initWithMethod:kMixiHTTPMethodDelete endpoint:endpoint params:nil] autorelease];
}

+ (id)deleteRequestWithEndpoint:(NSString*)endpoint params:(NSDictionary*)params {
    return [[[self alloc] initWithMethod:kMixiHTTPMethodDelete endpoint:endpoint params:params] autorelease];
}

+ (id)deleteRequestWithEndpoint:(NSString*)endpoint body:(NSObject*)body params:(NSDictionary*)params {
    return [[[self alloc] initWithMethod:kMixiHTTPMethodDelete endpoint:endpoint body:body params:params] autorelease];    
}

+ (id)requestWithEndpoint:(NSString*)endpoint paramsAndKeys:(NSObject*)paramsKeys, ... {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    NSObject *param = paramsKeys;
	va_list args;
	va_start (args, paramsKeys);
	while ((paramsKeys = va_arg(args, id))) {
        if (param) {
            [params setValue:param forKey:(NSString*)paramsKeys];
            param = nil;
        }
        else {
            param = paramsKeys;
        }
	}
	va_end (args);
    return [self getRequestWithEndpoint:endpoint params:params];
}

+ (id)getRequestWithEndpoint:(NSString*)endpoint paramsAndKeys:(NSObject*)paramsKeys, ... {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    NSObject *param = paramsKeys;
	va_list args;
	va_start (args, paramsKeys);
	while ((paramsKeys = va_arg(args, id))) {
        if (param) {
            [params setValue:param forKey:(NSString*)paramsKeys];
            param = nil;
        }
        else {
            param = paramsKeys;
        }
	}
	va_end (args);
    return [self getRequestWithEndpoint:endpoint params:params];
}

+ (id)postRequestWithEndpoint:(NSString*)endpoint paramsAndKeys:(NSObject*)paramsKeys, ... {
    id req = [self postRequestWithEndpoint:endpoint params:nil];
    if (req) {
        NSObject *param = paramsKeys;
        va_list args;
        va_start (args, paramsKeys);
        while ((paramsKeys = va_arg(args, id))) {
            if (param) {
                [req setParam:param forKey:(NSString*)paramsKeys];
                param = nil;
            }
            else {
                param = paramsKeys;
            }
        }
        va_end (args);
    }
    return req;
}

+ (id)postRequestWithEndpoint:(NSString*)endpoint body:(NSObject*)body paramsAndKeys:(NSObject*)paramsKeys, ... {
    id req = [self postRequestWithEndpoint:endpoint body:body params:nil];
    if (req) {
        NSObject *param = paramsKeys;
        va_list args;
        va_start (args, paramsKeys);
        while ((paramsKeys = va_arg(args, id))) {
            if (param) {
                [req setParam:param forKey:(NSString*)paramsKeys];
                param = nil;
            }
            else {
                param = paramsKeys;
            }
        }
        va_end (args);
    }
    return req;    
}

+ (id)putRequestWithEndpoint:(NSString*)endpoint paramsAndKeys:(NSObject*)paramsKeys, ... {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    NSObject *param = paramsKeys;
	va_list args;
	va_start (args, paramsKeys);
	while ((paramsKeys = va_arg(args, id))) {
        if (param) {
            [params setValue:param forKey:(NSString*)paramsKeys];
            param = nil;
        }
        else {
            param = paramsKeys;
        }
	}
	va_end (args);
    return [self putRequestWithEndpoint:endpoint params:params];
}

+ (id)putRequestWithEndpoint:(NSString*)endpoint body:(NSObject*)body paramsAndKeys:(NSObject*)paramsKeys, ... {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    NSObject *param = paramsKeys;
	va_list args;
	va_start (args, paramsKeys);
	while ((paramsKeys = va_arg(args, id))) {
        if (param) {
            [params setValue:param forKey:(NSString*)paramsKeys];
            param = nil;
        }
        else {
            param = paramsKeys;
        }
	}
	va_end (args);
    return [self putRequestWithEndpoint:endpoint body:body params:params];
}

+ (id)deleteRequestWithEndpoint:(NSString*)endpoint paramsAndKeys:(NSObject*)paramsKeys, ... {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    NSObject *param = paramsKeys;
	va_list args;
	va_start (args, paramsKeys);
	while ((paramsKeys = va_arg(args, id))) {
        if (param) {
            [params setValue:param forKey:(NSString*)paramsKeys];
            param = nil;
        }
        else {
            param = paramsKeys;
        }
	}
	va_end (args);
    return [self deleteRequestWithEndpoint:endpoint params:params];
}

+ (id)deleteRequestWithEndpoint:(NSString*)endpoint body:(NSObject*)body paramsAndKeys:(NSObject*)paramsKeys, ... {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    NSObject *param = paramsKeys;
	va_list args;
	va_start (args, paramsKeys);
	while ((paramsKeys = va_arg(args, id))) {
        if (param) {
            [params setValue:param forKey:(NSString*)paramsKeys];
            param = nil;
        }
        else {
            param = paramsKeys;
        }
	}
	va_end (args);
    return [self deleteRequestWithEndpoint:endpoint body:body params:params];    
}

+ (id)requestWithMethod:(NSString*)httpMethod endpoint:(NSString*)endpoint params:(NSDictionary*)params {
    return [[[self alloc] initWithMethod:httpMethod endpoint:endpoint params:params] autorelease];
}

+ (id)requestWithMethod:(NSString*)httpMethod endpoint:(NSString*)endpoint body:(NSObject*)body params:(NSDictionary*)params {
    return [[[self alloc] initWithMethod:httpMethod endpoint:endpoint body:body params:params] autorelease];    
}

- (id)initWithEndpoint:(NSString*)endpoint {
    return [self initWithMethod:kMixiHTTPMethodGet endpoint:endpoint params:nil];
}

- (id)initWithMethod:(NSString*)httpMethod endpoint:(NSString*)endpoint {
    return [self initWithMethod:httpMethod endpoint:endpoint params:nil];
}

- (id)initWithMethod:(NSString*)httpMethod endpoint:(NSString*)endpoint body:(NSObject*)body {
    return [self initWithMethod:httpMethod endpoint:endpoint body:body params:nil];    
}

- (id)initWithEndpoint:(NSString*)endpoint params:(NSDictionary*)params {
    return [self initWithMethod:kMixiHTTPMethodGet endpoint:endpoint params:params];
}

- (id)initWithEndpoint:(NSString*)endpoint body:(NSObject*)body params:(NSDictionary*)params {
    return [self initWithMethod:kMixiHTTPMethodGet endpoint:endpoint body:body params:params];    
}

- (id)initWithMethod:(NSString*)httpMethod endpoint:(NSString*)endpoint params:(NSDictionary*)params {
    return [self initWithMethod:httpMethod endpoint:endpoint body:nil params:params];
}

- (id)initWithMethod:(NSString*)httpMethod endpoint:(NSString*)endpoint body:(NSObject*)body params:(NSDictionary*)params {
    if ((self = [super init])) {
        self.endpoint = endpoint;
        self.endpointBaseUrl = kMixiApiBaseUrl;
        self.body = body;
        params_ = [params mutableCopy];
        self.httpMethod = httpMethod;
        self.requestTimeout = defaultRequestTimeout;
        self.cachePolicy = defaultRequestCachePolicy;
        self.openMixiAppToAuthorizeIfNeeded = YES;
    }
    return self;
}

#pragma mark - Default Values

+ (void)setDefaultRequestTimeout:(NSTimeInterval)interval {
    defaultRequestTimeout = interval;
}

+ (void)setDefaultRequestCachePolicy:(NSURLRequestCachePolicy)cachePolicy {
    defaultRequestCachePolicy = cachePolicy;
}

+ (void)setDefaultImageTypeJPEG {
    defaultImageType = @"jpeg";
}

+ (void)setDefaultImageTypePNG {
    defaultImageType = @"png";
}

+ (void)setDefaultCompressionQuality:(float)quality {
    defaultCompressionQuality = quality;
}

#pragma mark -

- (void)setImageType:(NSString*)type {
    if (type == nil) return;
    type = [type lowercaseString];
    if ([type isEqualToString:@"jpg"] || [type isEqualToString:@"jpeg"]) {
        type = @"jpeg";
    }
    else if (![type isEqualToString:@"png"]) {
        @throw [NSError errorWithDomain:kMixiErrorDomain
                                   code:kMixiRequestErrorInvalidImageType
                               userInfo:[NSDictionary dictionaryWithObject:@"Invalid type. type must be 'jpeg' or 'png.'"
                                                                    forKey:@"message"]];
    }
    if (imageType_) {
        [imageType_ release];
    }
    imageType_ = [type retain];
}

#pragma mark - Params

- (void)setParamsAndKeys:(NSObject*)paramsKeys, ... {
    NSObject *param = paramsKeys;
	va_list args;
	va_start (args, paramsKeys);
	while ((paramsKeys = va_arg(args, id))) {
        if (param) {
            [self setParam:param forKey:(NSString*)paramsKeys];
            param = nil;
        }
        else {
            param = (NSObject*)paramsKeys;
        }
	}
	va_end (args);
}

- (void)setParam:(NSObject*)value forKey:(NSString*)key {
    if (!self.params) {
        self.params = [NSMutableDictionary dictionary];
    }
    if ([value isKindOfClass:[UIImage class]]) {
        [self addAttachment:(UIImage*)value forKey:key];
    }
    else {
        [self.params setValue:value forKey:key];
    }
}

- (void)clearParams {
    [self.params removeAllObjects];
}

- (void)addAttachment:(UIImage*)image forKey:(NSString*)key {
    if (!self.attachments) {
        self.attachments = [NSMutableDictionary dictionary];
    }
    [self.attachments setValue:image forKey:key];
}

#pragma mark - Construct

- (NSURLRequest*)constructURLRequest:(Mixi*)mixi {
    NSMutableURLRequest *request;
    if ([self.httpMethod isEqualToString:kMixiHTTPMethodGet] || [self.httpMethod isEqualToString:kMixiHTTPMethodDelete]) {
        NSAssert((self.body == nil || self.params == nil || [self.params count] == 0), 
                 @"The body property or the params property must be nil for a GET request.");
        NSString *body;
        if (self.body) {
            body = [[[NSString alloc] initWithData:self.bodyData encoding:NSUTF8StringEncoding] autorelease];
        }
        else {
            body = [self buildHTTPParams];
        }
        NSString *requestUrl;
        if (body && [body length] != 0) {
            requestUrl = [NSString stringWithFormat:@"%@%@?%@", self.endpointBaseUrl, self.endpoint, body];
        }
        else {
            requestUrl = [NSString stringWithFormat:@"%@%@", self.endpointBaseUrl, self.endpoint];
        }
        NSURL *url = [NSURL URLWithString:requestUrl];
        request = [NSMutableURLRequest requestWithURL:url];
    }
    else {
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", self.endpointBaseUrl, self.endpoint]];
        request = [NSMutableURLRequest requestWithURL:url];
        if (self.attachments && 0 < [self.attachments count]) {
            NSAssert(self.body == nil, @"The body property must be nil to attache files.");
            [self setupRequestWithAttachments:request];
        }
        else if (self.params && [self.params count] == 1 && [[[self.params allValues] objectAtIndex:0] isKindOfClass:[NSDictionary class]]) {
            NSAssert(self.body == nil, @"The body property must be nil to send json.");
            NSDictionary *jsonData = [[self.params allValues] objectAtIndex:0];
            [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            [request setHTTPBody:[[jsonData JSONRepresentation] dataUsingEncoding:NSUTF8StringEncoding]];
        }
        else if (self.body) {
            NSString *params = [self buildHTTPParams];
            NSString *urlString = [[request URL] absoluteString];
            NSString *connector = [urlString rangeOfString:@"?"].location == NSNotFound ? @"?" : @"&";
            NSString *contentType;
            if ([self.body isMemberOfClass:[UIImage class]]) {
                NSString *type = self.imageType != nil ? self.imageType : defaultImageType;
                contentType = [NSString stringWithFormat:@"image/%@", type];
            } else if([self.body isKindOfClass:[NSData class]]){
                contentType = @"image/jpeg";
            }
            else if ([self.body isMemberOfClass:[NSDictionary class]]) {
                contentType = @"text/json";
            }
            else {
                contentType = @"application/x-www-form-urlencoded";
            }
            [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", urlString, connector, params]]];
            [request setValue:contentType forHTTPHeaderField:@"Content-Type"];
            [request setHTTPBody:self.bodyData];                
        }
        else {
            NSString *body = [self buildHTTPParams];
            [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
            [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];                
        }
    }
    [request setHTTPMethod:self.httpMethod];
    if (mixi.authorizer.accessToken) {
        [request setValue:[NSString stringWithFormat:@"OAuth %@", mixi.authorizer.accessToken] forHTTPHeaderField:@"Authorization"];
    }
    [request setValue:[[self class] userAgent] forHTTPHeaderField:@"User-Agent"];
    [request setTimeoutInterval:self.requestTimeout];
    [request setCachePolicy:self.cachePolicy];
    return request;
}

#pragma mark - UserAgent

+ (NSString*)userAgent {
    if (!sdkUserAgent) {
        UIWebView *webView = [[UIWebView alloc] init];
        sdkUserAgent = [[NSString stringWithFormat:@"%@ %@", 
                         kMixiSDKUserAgentPrefix,
                         [webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"]] retain];
        [webView release];
    }
    return sdkUserAgent == nil ? kMixiSDKUserAgentPrefix : sdkUserAgent;
}


#pragma mark - Getter/Setter

- (void)endpoint:(NSString*)endpoint {
    if (![endpoint hasPrefix:@"/"]) {
        endpoint = [NSString stringWithFormat:@"/%@", endpoint];
    }
    if ([endpoint isEqualToString:endpoint_]) {
        return;
    }
    self.endpoint = endpoint;
}

- (NSData*)bodyData {
    if ([self.body isKindOfClass:[UIImage class]]) {
        return [self getImageData:(UIImage*)self.body];
    }
    else if ([self.body isKindOfClass:[NSDictionary class]]) {
        return [[self.body JSONRepresentation] dataUsingEncoding:NSUTF8StringEncoding];
    }
    else if ([self.body isKindOfClass:[NSString class]]) {
        return [(NSString*)self.body dataUsingEncoding:NSUTF8StringEncoding];
    }
    else if ([self.body isKindOfClass:[NSData class]]){
        return (NSData *)self.body;
    }
    else {
        return [[self.body description] dataUsingEncoding:NSUTF8StringEncoding];
    }
}

#pragma mark -

- (void)dealloc {
    self.endpoint = nil;
    self.endpointBaseUrl = nil;
    self.body = nil;
    self.params = nil;
    self.attachments = nil;
    self.httpMethod = nil;
    self.imageType = nil;
    [super dealloc];
}

#pragma mark - Private

- (NSString*)buildHTTPParams {
    BOOL isFirst = YES;
    NSMutableString *params = [NSMutableString string];
    if (self.params) {
        for (NSString *key in self.params) {
            NSString *param = [self.params objectForKey:key];
            if (!isFirst) {
                [params appendString:@"&"];
            }
            [params appendFormat:@"%@=%@", key, MixiUtilEncodeURIComponent(param)];
            isFirst = NO;
        }
    }
    return params;
}

- (void)setupRequestWithAttachments:(NSMutableURLRequest*)request {
    NSString *boundary = [NSString stringWithFormat:@"__mixi_kflLKJllkjdasfoooip348unb%d__", (int)(rand() * 1000)];
    [request setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary] forHTTPHeaderField:@"Content-Type"];                                
    NSMutableData* multipartBody = [[[NSMutableData alloc] init] autorelease];
    for (NSString *key in self.params) {
        NSObject *value = [self.params objectForKey:key];
        if ([value isKindOfClass:[NSDictionary class]]) {
            value = [value JSONRepresentation];
        }
        [self appendData:[(NSString*)value dataUsingEncoding:NSUTF8StringEncoding] 
                  toBody:multipartBody 
              withHeader:[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"", key]
                boundary:boundary];
    }
    for (NSString *key in self.attachments) {
        NSData *data = [self getImageData:[self.attachments objectForKey:key]];
        NSString *type = self.imageType != nil ? self.imageType : defaultImageType;
        NSString *disposition = [NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%d%d\"\"",
                                 key, [[NSDate date] timeIntervalSince1970], (int)(rand() * 100)];
        NSString *contentType = [NSString stringWithFormat:@"Content-Type: image/%@", type]; 
        [self appendData:data 
                  toBody:multipartBody 
              withHeader:[NSString stringWithFormat:@"%@\r\n%@", disposition, contentType] 
                boundary:boundary];
    }
    [multipartBody appendData:[[NSString stringWithFormat:@"--%@--\r\n\r\n", boundary] dataUsingEncoding:NSASCIIStringEncoding]];
    [request setHTTPBody:multipartBody];    
}

- (void)appendData:(NSData*)data toBody:(NSMutableData*)multipartBody withHeader:(NSString*)header boundary:(NSString*)boundary {
    [multipartBody appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSASCIIStringEncoding]];
    [multipartBody appendData:[[NSString stringWithFormat:@"%@\r\n\r\n", header] dataUsingEncoding:NSASCIIStringEncoding]];
    [multipartBody appendData:data];
    [multipartBody appendData:[@"\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
}

- (NSData*)getImageData:(UIImage*)image {
    NSString *type = self.imageType != nil ? self.imageType : defaultImageType;
    float quality = 1.0 <= self.compressionQuality ? self.compressionQuality : defaultCompressionQuality;
    if ([type isEqualToString:@"jpeg"]) {
        return [[[NSData alloc] initWithData:UIImageJPEGRepresentation(image, quality)] autorelease];
    }
    else {
        return [[[NSData alloc] initWithData:UIImagePNGRepresentation(image)] autorelease];
    }
}

@end
