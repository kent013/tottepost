#import <Foundation/Foundation.h>
#import "AtomElement.h"

@class AtomWorkspace;

@interface AtomService : AtomElement {

}
+ (NSString *)elementName;
+ (DDXMLNode *)elementNamespace;
+ (AtomService *)service;
+ (AtomService *)serviceWithXMLElement:(DDXMLElement *)elem;
+ (AtomService *)serviceWithXMLString:(NSString *)string;
- (AtomWorkspace *)workspace;
- (NSArray *)workspaces;
- (void)setWorkspace:(AtomWorkspace *)workspace;
- (void)addWorkspace:(AtomWorkspace *)workspace;
@end

