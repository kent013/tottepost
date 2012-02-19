#import <Foundation/Foundation.h>
#import "AtompubCredential.h"

@interface BasicCredential : NSObject <AtompubCredential> {
  NSString *username;
  NSString *password;
}
+ (id)credentialWithUsername:(NSString *)name
                    password:(NSString *)pass;
- (id)initWithUsername:(NSString *)name
              password:(NSString *)pass;
- (void)setCredentialToRequest:(NSMutableURLRequest *)request;
@end

