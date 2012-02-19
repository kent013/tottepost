#import <Foundation/Foundation.h>
#import "AtomElement.h"

@interface AtomLink : AtomElement {

}
+ (NSString *)elementName;
+ (DDXMLNode *)elementNamespace;
+ (AtomLink *)link;
+ (AtomLink *)linkWithXMLElement:(DDXMLElement *)elem;
+ (AtomLink *)linkWithXMLString:(NSString *)string;

// @property NSString *rel, *type, *hreflang, *title;
// @property int length;
// @property NSURL *href;

- (NSURL *)href;
- (void)setHref:(NSURL *)url;
- (NSString *)rel;
- (void)setRel:(NSString *)rel;
- (NSString *)type;
- (void)setType:(NSString *)type;
- (NSString *)hreflang;
- (void)setHreflang:(NSString *)hreflang;
- (NSString *)title;
- (void)setTitle:(NSString *)title;
- (int)length;
- (void)setLength:(int)length;

@end

