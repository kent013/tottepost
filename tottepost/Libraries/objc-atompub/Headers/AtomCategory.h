#import <Foundation/Foundation.h>
#import "AtomElement.h"

@interface AtomCategory : AtomElement {

}
+ (NSString *)elementName;
+ (DDXMLNode *)elementNamespace;
+ (AtomCategory *)category;
+ (AtomCategory *)categoryWithXMLElement:(DDXMLElement *)elem;
+ (AtomCategory *)categoryWithXMLString:(NSString *)string;

// @property NSString *term, *label, *scheme;
- (NSString *)term;
- (void)setTerm:(NSString *)term;
- (NSString *)label;
- (void)setLabel:(NSString *)label;
- (NSString *)scheme;
- (void)setScheme:(NSString *)scheme;
@end
