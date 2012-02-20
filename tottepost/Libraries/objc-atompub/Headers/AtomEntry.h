#import <Foundation/Foundation.h>
#import "AtomCoreElement.h"

@class AtomControl, AtomContent, AtomGenerator;

@interface AtomEntry : AtomCoreElement {
    NSArray *contents;
}
+ (NSString *)elementName;
+ (DDXMLNode *)elementNamespace;
+ (AtomEntry *)entry;
+ (AtomEntry *)entryWithXMLElement:(DDXMLElement *)elem;
+ (AtomEntry *)entryWithXMLString:(NSString *)string;
- (NSString *)summary;
- (void)setSummary:(NSString *)summary;
- (NSDate *)published;
- (void)setPublished:(NSDate *)published;
- (NSString *)source;
- (void)setSource:(NSString *)source;
- (AtomControl *)control;
- (NSArray *)controls;
- (void)setControl:(AtomControl *)control;
- (void)addControl:(AtomControl *)control;
- (NSDate *)edited;
- (void)setEdited:(NSDate *)edited;
- (AtomContent *)content;
- (void)setContent:(AtomContent *)content;
- (AtomGenerator *)generator;
- (void)setGenerator:(AtomGenerator *)generator;
@end

