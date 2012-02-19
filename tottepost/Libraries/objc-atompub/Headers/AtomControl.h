#import <Foundation/Foundation.h>
#import "AtomElement.h"

@interface AtomControl : AtomElement {

}

+ (NSString *)elementName;
+ (DDXMLNode *)elementNamespace;
+ (AtomControl *)control;
+ (AtomControl *)controlWithXMLElement:(DDXMLElement *)elem;
+ (AtomControl *)controlWithXMLString:(NSString *)string;

// @property BOOL draft;
- (BOOL)draft;
- (void)setDraft:(BOOL)draft;
@end

