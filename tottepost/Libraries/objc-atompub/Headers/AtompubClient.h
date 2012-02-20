#import <Foundation/Foundation.h>
#import "AtompubCredential.h"

#define defaultTimeoutInterval 60.0

typedef enum {
    None,
    GettingService,
    GettingCategories,
    GettingFeed,
    GettingEntry,
    GettingMedia,
    PostingEntry,
    PostingMedia,
    PuttingEntry,
    PuttingMedia,
    DeletingEntry,
    DeletingMedia
} AtompubClientFetchMode;

@class AtompubCacheStorage, AtomEntry;
@protocol AtompubClientDelegate;

@interface AtompubClient : NSObject {
    NSObject <AtompubCredential> *credential;
    NSObject <AtompubClientDelegate> *delegate;
    NSTimeInterval timeoutInterval;
    NSString *agentName;
    AtompubClientFetchMode fetchMode;
    NSMutableData *responseData;
    NSHTTPURLResponse *lastResponse;
    NSURLConnection *connection;
    AtompubCacheStorage *cacheStorage;
    NSURL *lastRequestURL;
}

@property(nonatomic, assign) NSString* tag;
@property(nonatomic, assign) BOOL enableDebugOutput;

+ (AtompubClient *)client;
- (id)init;
- (BOOL)isFetching;
- (NSString *)agentName;
- (void)setAgentName:(NSString *)name;
- (AtompubCacheStorage *)cacheStorage;
- (void)setCacheStorage:(AtompubCacheStorage *)storage;
- (NSObject <AtompubClientDelegate> *)delegate;
- (void)setDelegate:(NSObject <AtompubClientDelegate> *)target;
- (void)setCredential:(NSObject <AtompubCredential> *)aCredential;
- (NSTimeInterval)timeoutInterval;
- (void)setTimeoutInterval:(NSTimeInterval)interval;
- (NSData *)responseData;
- (NSHTTPURLResponse *)lastResponse;
- (NSURL *)lastRequestURL;
- (void)startLoadingServiceWithURL:(NSURL *)url;
- (void)startLoadingCategoriesWithURL:(NSURL *)url;
- (void)startLoadingFeedWithURL:(NSURL *)url;
- (void)startLoadingEntryWithURL:(NSURL *)url;
- (void)startLoadingMediaWithURL:(NSURL *)url;
- (void)startCreatingEntry:(AtomEntry *)entry
                   withURL:(NSURL *)url;
- (void)startCreatingEntry:(AtomEntry *)entry
                   withURL:(NSURL *)url
                      slug:(NSString *)slug;
- (void)startCreatingMedia:(NSData *)resource
                   withURL:(NSURL *)url
               contentType:(NSString *)aType;
- (void)startCreatingMedia:(NSData *)resource
                   withURL:(NSURL *)url
               contentType:(NSString *)aType
                      slug:(NSString *)slug;
- (void)cancel;
- (void)closeConnection;
- (void)clear;
- (void)dealloc;
@end


@interface AtompubClient (PrivateMethods)
- (void)connection:(NSURLConnection *)conn
didReceiveResponse:(NSURLResponse *)response;
- (void)connection:(NSURLConnection *)conn
    didReceiveData:(NSData *)data;
- (void)connection:(NSURLConnection *)conn
  didFailWithError:(NSError *)error;
- (void)connectionDidFinishLoading:(NSURLConnection *)conn;
- (void)startLoadingResponseWithURL:(NSURL *)url
                               mode:(AtompubClientFetchMode)mode;
- (void)startConnectionWithRequest:(NSMutableURLRequest *)request
                              mode:(AtompubClientFetchMode)mode;
- (void)dispatchErrorWithStatus:(int)status
                    description:(NSString *)description;
- (void)startCreatingResource:(NSData *)resource
                      withURL:(NSURL *)url
                  contentType:(NSString *)aType
                         slug:(NSString *)slug
                         mode:(AtompubClientFetchMode)mode;
- (void)startUpdatingResource:(NSData *)resource
                      withURL:(NSURL *)url
                  contentType:(NSString *)aType
                         mode:(AtompubClientFetchMode)mode;
- (void)startDeletingResourceWithURL:(NSURL *)url
                                mode:(AtompubClientFetchMode)mode;
- (void)handleResponseWithType:(NSString *)aType
                    dispatcher:(SEL)dispatcher
class:(Class)class;
- (void)handleResponseForGettingEntry;
- (void)handleResponseForGettingMedia;
- (void)handleResponseForPostingResourceWithDispatcher:(SEL)dispatcher;
- (void)handleResponseForPuttingOrDeletingResourceWithDispatcher:(SEL)dispatcher;
@end
