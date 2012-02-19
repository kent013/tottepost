#import <Foundation/Foundation.h>
#import "AtomElement.h"

@interface AtomPerson : AtomElement {

}
+ (NSString *)elementName;
+ (DDXMLNode *)elementNamespace;
+ (AtomPerson *)person;
+ (AtomPerson *)personWithXMLElement:(DDXMLElement *)elem;
+ (AtomPerson *)personWithXMLString:(NSString *)string;

// @property NSString *email, *name;
// @property NSURL *uri;
- (NSString *)email;
- (void)setEmail:(NSString *)email;
- (NSURL *)uri;
- (void)setUri:(NSURL *)uri;
- (NSString *)name;
- (void)setName:(NSString *)name;
@end

