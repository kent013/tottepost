#import <Foundation/Foundation.h>

@class AtompubCache;

@interface AtompubCacheStorage : NSObject {
  NSMutableDictionary *storage;
}
+ (AtompubCacheStorage *)storage;
- (id)init;
- (void)setCache:(AtompubCache *)cache
          forURL:(NSURL *)url;
- (AtompubCache *)cacheForURL:(NSURL *)url;
- (void)removeCacheForURL:(NSURL *)url;
- (void)dealloc;
@end

