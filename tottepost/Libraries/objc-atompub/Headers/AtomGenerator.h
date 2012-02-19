#import <Foundation/Foundation.h>
#import "AtomElement.h"

@interface AtomGenerator : AtomElement {

}
+ (NSString *)elementName;
+ (DDXMLNode *)elementNamespace;
+ (AtomGenerator *)generator;
+ (AtomGenerator *)generatorWithXMLElement:(DDXMLElement *)elem;
+ (AtomGenerator *)generatorWithXMLString:(NSString *)string;

// @property NSString *name, *version;
- (NSString *)name;
- (void)setName:(NSString *)name;

- (NSString *)version;
- (void)setVersion:(NSString *)version;

// @property NSURL *url;
- (NSURL *)url;
- (void)setUrl:(NSURL *)url;

@end

