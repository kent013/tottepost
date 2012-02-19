#import <Foundation/Foundation.h>

@protocol AtompubCredential
- (void)setCredentialToRequest:(NSMutableURLRequest *)request;
@end

