#import "Foundation/Foundation.h"
#import "AtomElement.h"

@interface AtomContent : AtomElement {

}
+ (NSString *)elementName;
+ (DDXMLNode *)elementNamespace;
+ (AtomContent *)content;
+ (AtomContent *)contentWithXMLElement:(DDXMLElement *)elem;
+ (AtomContent *)contentWithXMLString:(NSString *)string;
- (NSString *)type;
- (void)setType:(NSString *)aType;
- (NSString *)mode;
- (void)setMode:(NSString *)aMode;
- (NSURL *)src;
- (void)setSrc:(NSURL *)aSrc;
- (NSString *)body;
- (void)setBodyAsTextContent:(NSString *)aTextContent;
- (void)setBodyWithString:(NSString *)aBody;
- (void)setBodyWithXMLElement:(DDXMLElement *)aBody;
@end
