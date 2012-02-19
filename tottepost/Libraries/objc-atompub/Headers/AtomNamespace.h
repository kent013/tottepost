#import <Foundation/Foundation.h>
#import "DDXML.h"

@interface AtomNamespace : NSObject {
}
+ (DDXMLNode *)atom;
+ (DDXMLNode *)atomWithPrefix;
+ (DDXMLNode *)app;
+ (DDXMLNode *)appWithPrefix;
+ (DDXMLNode *)openSearch;
+ (DDXMLNode *)threading;
@end

