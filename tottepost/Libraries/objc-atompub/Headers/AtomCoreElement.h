#import <Foundation/Foundation.h>
#import "AtomElement.h"

@class AtomLink, AtomCategory, AtomPerson;

@interface AtomCoreElement : AtomElement {

}

// @property NSString *ID;
- (NSString *)ID;
- (void)setID:(NSString *)value;
// @property NSString *title;
- (NSString *)title;
- (void)setTitle:(NSString *)title;
// @property NSString *rights;
- (NSString *)rights;
- (void)setRights:(NSString *)rights;
// @property NSDate *updated;
- (NSDate *)updated;
- (void)setUpdated:(NSDate *)updated;

- (NSArray *)links;
- (AtomLink *)link;
- (void)setLink:(AtomLink *)link;
- (void)addLink:(AtomLink *)link;
- (NSArray *)categories;
- (AtomCategory *)category;
- (void)setCategory:(AtomCategory *)category;
- (void)addCategory:(AtomCategory *)category;
- (NSArray *)authors;
- (AtomPerson *)author;
- (void)setAuthor:(AtomPerson *)author;
- (void)addAuthor:(AtomPerson *)author;
- (NSArray *)contributors;
- (AtomPerson *)contributor;
- (void)setContributor:(AtomPerson *)contributor;
- (void)addContributor:(AtomPerson *)contributor;
- (NSURL *)linkURLForRelType:(NSString *)relType;
- (NSArray *)linkURLsForRelType:(NSString *)relType;
- (void)setLinkURL:(NSURL *)url
        forRelType:(NSString *)relType;
- (void)addLinkURL:(NSURL *)url
        forRelType:(NSString *)relType;
- (NSURL *)alternateLink;
- (NSArray *)alternateLinks;
- (void)setAlternateLink:(NSURL *)link;
- (void)addAlternateLink:(NSURL *)link;
- (NSURL *)selfLink;
- (NSArray *)selfLinks;
- (void)setSelfLink:(NSURL *)link;
- (void)addSelfLink:(NSURL *)link;
- (NSURL *)editLink;
- (NSArray *)editLinks;
- (void)setEditLink:(NSURL *)link;
- (void)addEditLink:(NSURL *)link;
- (NSURL *)mediaLink;
- (NSArray *)mediaLinks;
- (void)setMediaLink:(NSURL *)link;
- (void)addMediaLink:(NSURL *)link;
- (NSURL *)editMediaLink;
- (NSArray *)editMediaLinks;
- (void)setEditMediaLink:(NSURL *)link;
- (void)addEditMediaLink:(NSURL *)link;
- (NSURL *)relatedLink;
- (NSArray *)relatedLinks;
- (void)setRelatedLink:(NSURL *)link;
- (void)addRelatedLink:(NSURL *)link;
- (NSURL *)enclosureLink;
- (NSArray *)enclosureLinks;
- (void)setEnclosureLink:(NSURL *)link;
- (void)addEnclosureLink:(NSURL *)link;
- (NSURL *)viaLink;
- (NSArray *)viaLinks;
- (void)setViaLink:(NSURL *)link;
- (void)addViaLink:(NSURL *)link;
- (NSURL *)firstLink;
- (void)setFirstLink:(NSURL *)link;
- (NSURL *)lastLink;
- (void)setLastLink:(NSURL *)link;
- (NSURL *)previousLink;
- (void)setPreviousLink:(NSURL *)link;
- (NSURL *)nextLink;
- (void)setNextLink:(NSURL *)link;
@end

