//
//  MinusConnect.m
//  MinusConnect
//
//  Created by Kentaro ISHITOYA on 12/02/21.
//  Copyright (c) 2012 Kentaro ISHITOYA. All rights reserved.
//

#import "MinusConnect.h"

static NSString* kUserAgent = @"MinusConnect";
static NSString* kStringBoundary = @"3i2ndDfv2rTHiSisAbouNdArYfORhtTPEefj3q2f";
static NSString* kHTTPGET = @"GET";
static NSString* kHTTPPOST = @"POST";
static NSString* kHTTPPUT = @"PUT";
static NSString* kHTTPDELETE = @"DELETE";

static const NSTimeInterval kTimeoutInterval = 180.0;

//-----------------------------------------------------------------------------
//Private Implementations
//-----------------------------------------------------------------------------
@interface MinusConnect(PrivateImplementation)
- (void)setupInitialState;
- (void)utfAppendBody:(NSMutableData *)body data:(NSString *)data;
- (NSString*)serializeURL:(NSString *)baseUrl
                   params:(NSDictionary *)params
               httpMethod:(NSString *)httpMethod;
- (NSString *)serializeURL:(NSString *)baseUrl
                    params:(NSDictionary *)params;
- (NSMutableData *)generatePostBody:(NSDictionary *)params 
                    dataContentType:(NSString*)dataContentType;
- (MinusRequest *) createRequestWithURLString:(NSString *)url 
                                        param:(NSDictionary *)params 
                                   httpMethod:(NSString *)httpMethod
                              dataContentType:(NSString *)dataContentType
                                  andDelegate:(id<MinusRequestDelegate>)delegate;
- (MinusRequest *) createRequestWithURLString:(NSString *)url 
                                        param:(NSDictionary *)params 
                                   httpMethod:(NSString *)httpMethod
                                  andDelegate:(id<MinusRequestDelegate>)delegate;
@end

@implementation MinusConnect(PrivateImplementation)
/*!
 * initialize
 */
- (void)setupInitialState{
    requests_ = [[NSMutableSet alloc] init];
}

/*!
  * Body append for POST method
  */
- (void)utfAppendBody:(NSMutableData *)body data:(NSString *)data {
    [body appendData:[data dataUsingEncoding:NSUTF8StringEncoding]];
}

/**
 * Generate get URL
 */
- (NSString *)serializeURL:(NSString *)baseUrl
                    params:(NSDictionary *)params {
    return [self serializeURL:baseUrl params:params httpMethod:kHTTPGET];
}

/**
 * Generate get URL
 */
- (NSString*)serializeURL:(NSString *)baseUrl
                   params:(NSDictionary *)params
               httpMethod:(NSString *)httpMethod {
    baseUrl = [NSString stringWithFormat:@"%@/%@", kMinusBaseURL, baseUrl];
    NSURL* parsedURL = [NSURL URLWithString:baseUrl];
    NSString* queryPrefix = parsedURL.query ? @"&" : @"?";
    
    NSMutableArray* pairs = [NSMutableArray array];
    for (NSString* key in [params keyEnumerator]) {
        if (([[params valueForKey:key] isKindOfClass:[UIImage class]])
            ||([[params valueForKey:key] isKindOfClass:[NSData class]])) {
            if ([httpMethod isEqualToString:@"GET"]) {
                NSLog(@"can not use GET to upload a file");
            }
            continue;
        }
        
        NSString* escaped_value = 
        (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(NULL, 
                                                            (__bridge CFStringRef)[params objectForKey:key],
                                                            NULL,
                                                            (__bridge CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                            kCFStringEncodingUTF8);
        
        [pairs addObject:[NSString stringWithFormat:@"%@=%@", key, escaped_value]];
    }
    NSString* query = [pairs componentsJoinedByString:@"&"];
    
    return [NSString stringWithFormat:@"%@%@%@&bearer_token=%@", baseUrl, queryPrefix, query, auth_.credential.accessToken];
}

/*!
 * Generate body for POST method
 */
- (NSMutableData *)generatePostBody:(NSDictionary *)params dataContentType:(NSString *)dataContentType{
    NSMutableData *body = [NSMutableData data];
    NSString *endLine = [NSString stringWithFormat:@"\r\n--%@\r\n", kStringBoundary];
    NSMutableDictionary *dataDictionary = [NSMutableDictionary dictionary];
    
    [self utfAppendBody:body data:[NSString stringWithFormat:@"--%@\r\n", kStringBoundary]];
    
    for (id key in [params keyEnumerator]) {
        
        if (([[params valueForKey:key] isKindOfClass:[UIImage class]])
            ||([[params valueForKey:key] isKindOfClass:[NSData class]])) {
            
            [dataDictionary setObject:[params valueForKey:key] forKey:key];
            continue;
            
        }
        
        [self utfAppendBody:body
                       data:[NSString
                             stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",
                             key]];
        [self utfAppendBody:body data:[params valueForKey:key]];
        
        [self utfAppendBody:body data:endLine];
    }
    
    if ([dataDictionary count] > 0) {
        for (id key in dataDictionary) {
            NSObject *dataParam = [dataDictionary valueForKey:key];
            if ([dataParam isKindOfClass:[UIImage class]]) {
                dataParam = UIImageJPEGRepresentation((UIImage*)dataParam, 1.0);
            }
            NSAssert([dataParam isKindOfClass:[NSData class]],
                     @"dataParam must be a UIImage or NSData");
            [self utfAppendBody:body
                           data:[NSString stringWithFormat:
                                 @"Content-Disposition: form-data; filename=\"%@\"\r\n", key]];
            if(dataContentType){
                [self utfAppendBody:body
                               data:[NSString stringWithFormat:@"Content-Type: %@\r\n\r\n", dataContentType]];
            }else{
                [self utfAppendBody:body
                               data:[NSString stringWithString:@"Content-Type: content/unknown\r\n\r\n"]];
            }
            [body appendData:(NSData*)dataParam];
            [self utfAppendBody:body data:endLine];
            
        }
    }
    
    return body;
}

/*!
 * create request
 */
- (MinusRequest *) createRequestWithURLString:(NSString *)url param:(NSDictionary *)params httpMethod:(NSString *)httpMethod andDelegate:(id<MinusRequestDelegate>)delegate{
    return [self createRequestWithURLString:url param:params httpMethod:httpMethod dataContentType:nil andDelegate:delegate];
}

/*!
 * create request
 */
- (MinusRequest *)createRequestWithURLString:(NSString *)url param:(NSDictionary *)params httpMethod:(NSString *)httpMethod dataContentType:(NSString *)dataContentType andDelegate:(id<MinusRequestDelegate>)delegate{
    NSString *serializedUrl = [self serializeURL:url params:params httpMethod:httpMethod];
    NSMutableURLRequest* request =
    [NSMutableURLRequest requestWithURL:[NSURL URLWithString:serializedUrl]
                            cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                        timeoutInterval:kTimeoutInterval];
    [request setValue:kUserAgent forHTTPHeaderField:@"User-Agent"];
    
    
    [request setHTTPMethod:httpMethod];
    if ([httpMethod isEqualToString: @"POST"]) {
        NSString* contentType = [NSString
                                 stringWithFormat:@"multipart/form-data; boundary=%@", kStringBoundary];
        [request setValue:contentType forHTTPHeaderField:@"Content-Type"];
        
        [request setHTTPBody:[self generatePostBody:params dataContentType:dataContentType]];
    }
    return [[MinusRequest alloc] initWithURLRequest:request andDelegate:delegate];    
}
@end
//-----------------------------------------------------------------------------
//Public Implementations
//-----------------------------------------------------------------------------
#pragma mark - public implementation
@implementation MinusConnect
@synthesize sessionDelegate = sessionDelegate_;
/*!
 * initialize
 */
- (id)initWithClientId:(NSString *)clientId 
          clientSecret:(NSString *)clientSecret 
           andDelegate:(id<MinusSessionDelegate>)delegate{
    self = [super init];
    if(self){
        auth_ = [[MinusAuth alloc] initWithClientId:clientId
                                       clientSecret:clientSecret 
                                        andDelegate:self];
        self.sessionDelegate = delegate;
        [auth_ loadCredential];
        [self setupInitialState];
    }
    return self;
}

#pragma mark - authentication
/*!
 * login
 */
- (void)loginWithUsername:(NSString *)username password:(NSString *)password andPermission:(NSArray *)permission{
    if([auth_ isSessionValid] == NO){
        [auth_ loginWithUsername:username password:password andPermission:permission];
    }else{
        [self minusDidLogin];
    }
}

/*!
 * logout
 */
- (void)logout{
    if([auth_ isSessionValid]){
        [auth_ logout];
    }
    [self minusDidLogout];
}

/*!
 * did logined
 */
- (void)minusDidLogin{
    [auth_ saveCredential];
    [self.sessionDelegate minusDidLogin];
}

/*!
 * did logout
 */
- (void)minusDidLogout{
    [auth_ clearCredential];
    [self.sessionDelegate minusDidLogout];
}

/*!
 * did not login
 */
- (void)minusDidNotLogin{
    [auth_ clearCredential];
    [self.sessionDelegate minusDidNotLogin];
}

/*!
 * is session valid
 */
- (BOOL)isSessionValid{
    return [auth_ isSessionValid];
}

/*!
 * refresh token
 */
- (void)refreshCredentialWithUsername:(NSString *)username password:(NSString *)password{
    [auth_ refreshCredentialWithUsername:username password:password];
}

#pragma mark - user
/*!
 * get active user.
 */
- (MinusRequest *)activeUserWithDelegate:(id<MinusRequestDelegate>) delegate{
    MinusRequest *request = [self createRequestWithURLString:@"activeuser" param:nil httpMethod:kHTTPGET andDelegate:delegate];
    request.tag = kMinusRequestActiveUser;
    [request start];
    return request;
}

/*!
 * get user
 */
- (MinusRequest *)userWithUserId:(NSString *)userId andDelegate:(id<MinusRequestDelegate>)delegate{
    NSString *path = [NSString stringWithFormat:@"users/%@", userId];
    MinusRequest *request = [self createRequestWithURLString:path param:nil httpMethod:kHTTPGET andDelegate:delegate];
    request.tag = kMinusRequestUserWithUserId;
    [request start];
    return request;    
}

#pragma mark - file
/*!
 * get file
 */
- (MinusRequest *)fileWithFileId:(NSString *)fileId andDelegate:(id<MinusRequestDelegate>)delegate{
    NSString *path = [NSString stringWithFormat:@"files/%@", fileId];
    MinusRequest *request = [self createRequestWithURLString:path param:nil httpMethod:kHTTPGET andDelegate:delegate];
    request.tag = kMinusRequestFileWithFileId;
    [request start];
    return request;
}

/*!
 * get files in a folder
 */
- (MinusRequest *)filesWithFolderId:(NSString *)folderId andDelegate:(id<MinusRequestDelegate>)delegate{
    NSString *path = [NSString stringWithFormat:@"folders/%@/files", folderId];
    MinusRequest *request = [self createRequestWithURLString:path param:nil httpMethod:kHTTPGET andDelegate:delegate];
    
    request.tag = kMinusRequestFilesWithFolderId;
    [request start];
    return request;    
}

/*!
 * create file
 */
- (MinusRequest *)createFileWithFolderId:(NSString *)folderId 
                                 caption:(NSString *)caption 
                                filename:(NSString *)filename 
                                    data:(id)data
                         dataContentType:(NSString *)dataContentType 
                             andDelegate:(id<MinusRequestDelegate>)delegate{
    NSString *path = [NSString stringWithFormat:@"folders/%@/files", folderId];
    if(caption == nil){
        caption = @"";
    }
    NSDictionary *param = [[NSMutableDictionary alloc] initWithObjectsAndKeys:caption, @"caption", filename, @"filename", data, @"file", nil];
    
    MinusRequest *request = [self createRequestWithURLString:path param:param httpMethod:kHTTPPOST dataContentType:dataContentType andDelegate:delegate];
    request.tag = kMinusRequestCreateFile;
    [request start];
    return request;
}

#pragma mark - folder
/*!
 * get folder
 */
- (MinusRequest *)folderWithFolderId:(NSString *)folderId andDelegate:(id<MinusRequestDelegate>)delegate{
    NSString *path = [NSString stringWithFormat:@"folders/%@", folderId];
    MinusRequest *request = [self createRequestWithURLString:path param:nil 
                                                  httpMethod:kHTTPGET andDelegate:delegate];
    request.tag = kMinusRequestFolderWithFolderId;
    [request start];
    return request;    
}

/*!
 * get folders
 */
- (MinusRequest *)foldersWithUsername:(NSString *)username andDelegate:(id<MinusRequestDelegate>) delegate{
    NSString *path = [NSString stringWithFormat:@"users/%@/folders", username];
    MinusRequest *request = [self createRequestWithURLString:path param:nil 
                                                  httpMethod:kHTTPGET andDelegate:delegate];
    request.tag = kMinusRequestFoldersWithUsername;
    [request start];
    return request;
}

/*!
 * create folder
 */
- (MinusRequest *)createFolderWithUsername:(NSString *)username name:(NSString *)name isPublic:(BOOL)isPublic andDelegate:(id<MinusRequestDelegate>)delegate{
    NSString *path = [NSString stringWithFormat:@"users/%@/folders", username];
    NSString *isPublicStr = @"0";
    if(isPublic){
        isPublicStr = @"1";
    }
    NSDictionary *param = [[NSMutableDictionary alloc] initWithObjectsAndKeys:name, @"name", isPublicStr, @"is_public", nil];
    MinusRequest *request = [self createRequestWithURLString:path param:param httpMethod:kHTTPPOST andDelegate:delegate];
    request.tag = kMinusRequestCreateFolder;
    [request start];
    return request;
}
@end
