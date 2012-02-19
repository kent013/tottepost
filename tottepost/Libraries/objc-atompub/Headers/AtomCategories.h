#import <Foundation/Foundation.h>
#import "AtomElement.h"

@class AtomCategory;

@interface AtomCategories : AtomElement {

}
+ (NSString *)elementName;
+ (DDXMLNode *)elementNamespace;
+ (AtomCategories *)categories;
+ (AtomCategories *)categoriesWithXMLElement:(DDXMLElement *)elem;
+ (AtomCategories *)categoriesWithXMLString:(NSString *)string;

- (NSArray *)categories;
- (void)addCategory:(AtomCategory *)cat;

// @property AtomCategory *category;
- (AtomCategory *)category;
- (void)setCategory:(AtomCategory *)cat;

// @property NSString *scheme;
// @property NSURL *href;
// @property BOOL fixed;
- (NSString *)scheme;
- (void)setScheme:(NSString *)scheme;
- (NSURL *)href;
- (void)setHref:(NSURL *)href;
- (BOOL)fixed;
- (void)setFixed:(BOOL)fixed;
@end

