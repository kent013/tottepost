#import <Foundation/Foundation.h>
#import "AtomElement.h"

@class AtomCollection;

@interface AtomWorkspace : AtomElement {

}
+ (NSString *)elementName;
+ (DDXMLNode *)elementNamespace;
+ (AtomWorkspace *)workspace;
+ (AtomWorkspace *)workspaceWithXMLElement:(DDXMLElement *)elem;
+ (AtomWorkspace *)workspaceWithXMLString:(NSString *)string;
// @property NSString *title;
- (NSString *)title;
- (void)setTitle:(NSString *)title;
// @property AtomCollection *collection;
- (AtomCollection *)collection;
- (NSArray *)collections;
- (void)setCollection:(AtomCollection *)coll;
- (void)addCollection:(AtomCollection *)coll;
@end

