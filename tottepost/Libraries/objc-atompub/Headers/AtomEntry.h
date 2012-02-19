#import <Foundation/Foundation.h>
#import "AtomCoreElement.h"

@class AtomControl;

@interface AtomEntry : AtomCoreElement {

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
@end

