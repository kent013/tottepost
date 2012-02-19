#import <Foundation/Foundation.h>

@interface AtompubCache : NSObject {
  NSString *lastModified;
  NSString *etag;
  NSData   *resource;
}
+ (AtompubCache *)cache;
- (id)init;
- (void)dealloc;
- (NSString *)lastModified;
- (void)setLastModified:(NSString *)date;
- (NSString *)etag;
- (void)setEtag:(NSString *)etag;
- (NSData *)resource;
- (void)setResource:(NSData *)resource;
@end

