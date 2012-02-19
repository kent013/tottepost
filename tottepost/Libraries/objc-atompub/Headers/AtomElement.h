#import <Foundation/Foundation.h>
#import "DDXML.h"

@interface AtomElement : NSObject {
  DDXMLElement *element;
}


+ (NSString *)elementName;

+ (DDXMLNode *)elementNamespace;

- (id)init;

- (id)initWithXMLString:(NSString *)string;

- (id)initWithXMLElement:(DDXMLElement *)elem;

// XXX: @property(readonly) DDXMLElement *element;
- (DDXMLElement *)element;

- (DDXMLDocument *)document;

- (void)addElementWithNamespace:(DDXMLNode *)namespace
                    elementName:(NSString *)elementName
                          value:(NSString *)value;

- (void)addElementWithNamespace:(DDXMLNode *)namespace
                    elementName:(NSString *)elementName
                          value:(NSString *)value
                     attributes:(NSDictionary *)attributes;

- (void)removeElementsWithNamespace:(DDXMLNode *)namespace
                        elementName:(NSString *)elementName;

- (void)setElementWithNamespace:(DDXMLNode *)namespace
                    elementName:(NSString *)elementName
                          value:(NSString *)value;

- (DDXMLElement *)getElementWithNamespace:(DDXMLNode *)namespace
                              elementName:(NSString *)elementName;

- (NSArray *)getElementsWithNamespace:(DDXMLNode *)namespace
                          elementName:(NSString *)elementName;

- (NSArray *)getElementsTextStringWithNamespace:(DDXMLNode *)namespace
                                    elementName:(NSString *)elementName;
- (NSString *)getElementTextStringWithNamespace:(DDXMLNode *)namespace
                                    elementName:(NSString *)elementName;

- (void)addElementWithNamespace:(DDXMLNode *)namespace
                    elementName:(NSString *)elementName
                        element:(DDXMLElement *)aElement;

- (void)setElementWithNamespace:(DDXMLNode *)namespace
                    elementName:(NSString *)elementName
                        element:(DDXMLElement *)aElement;

- (void)addElementWithNamespace:(DDXMLNode *)namespace
                    elementName:(NSString *)elementName
                    atomElement:(AtomElement *)atomElement;

- (void)setElementWithNamespace:(DDXMLNode *)namespace
                    elementName:(NSString *)elementName
                    atomElement:(AtomElement *)atomElement;

- (NSString *)getAttributeValueForKey:(NSString *)key;
- (void)setAttributeValue:(NSString *)value
                   forKey:(NSString *)key;

- (void)dealloc;

- (NSString *)stringValue;

- (NSArray *)getObjectsWithNamespace:(DDXMLNode *)namespace
                         elementName:(NSString *)elementName
                               class:(Class)class
                         initializer:(SEL)initializer;

- (id)getObjectWithNamespace:(DDXMLNode *)namespace
                 elementName:(NSString *)elementName
                       class:(Class)class
                 initializer:(SEL)initializer;
@end

