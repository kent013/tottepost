#import <Foundation/Foundation.h>
#import "AtomCoreElement.h"

@class AtomEntry, AtomGenerator;

@interface AtomFeed : AtomCoreElement {

}

+ (NSString *)elementName;
+ (DDXMLNode *)elementNamespace;
- (NSURL *)icon;
- (void)setIcon:(NSURL *)icon;
- (NSURL *)logo;
- (void)setLogo:(NSURL *)logo;
- (NSString *)subtitle;
- (void)setSubtitle:(NSString *)subtitle;
- (AtomGenerator *)generator;
- (void)setGenerator:(AtomGenerator *)generator;
- (NSString *)version;
- (void)setVersion:(NSString *)version;
- (int)totalResults;
- (void)setTotalResults:(int)num;
- (int)startIndex;
- (void)setStartIndex:(int)num;
- (int)itemsPerPage;
- (void)setItemsPerPage:(int)num;
- (AtomEntry *)entry;
- (NSArray *)entries;
- (void)setEntry:(AtomEntry *)entry;
- (void)addEntry:(AtomEntry *)entry;
@end

