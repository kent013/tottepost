#import <Foundation/Foundation.h>

@class AtomService, AtomCategories, AtomFeed, AtomEntry;
@class AtompubClient;

@protocol AtompubClientDelegate
@optional
- (void)client:(AtompubClient *)client didReceiveService:(AtomService *)service;
- (void)client:(AtompubClient *)client didReceiveCategories:(AtomCategories *)categories;
- (void)client:(AtompubClient *)client didReceiveFeed:(AtomFeed *)feed;
- (void)client:(AtompubClient *)client didReceiveEntry:(AtomEntry *)entry;
- (void)client:(AtompubClient *)client didReceiveMedia:(NSData *)media;
- (void)client:(AtompubClient *)client didCreateEntry:(AtomEntry *)entry
  withLocation:(NSURL *)location;
- (void)client:(AtompubClient *)client didCreateMediaLinkEntry:(AtomEntry *)entry
  withLocation:(NSURL *)location;
- (void)clientDidUpdateEntry:(AtompubClient *)client;
- (void)clientDidUpdateMedia:(AtompubClient *)client;
- (void)clientDidDeleteEntry:(AtompubClient *)client;
- (void)clientDidDeleteMedia:(AtompubClient *)client;
- (void)client:(AtompubClient *)client
didFailWithError:(NSError *)error;
- (void)client:(AtompubClient*)request didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite;
@end
