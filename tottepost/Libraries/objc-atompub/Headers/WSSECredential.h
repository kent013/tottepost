#import <Foundation/Foundation.h>
#import "BasicCredential.h"

@interface WSSECredential : BasicCredential {
}
- (void)setCredentialToRequest:(NSMutableURLRequest *)request;
@end

