#import <Foundation/Foundation.h>

@interface WSSEUsernameToken : NSObject {

}
+ (NSString *)generateUsernameTokenWithUsername:(NSString *)username
                                       password:(NSString *)password;
+ (NSString *)generateUsernameTokenWithUsername:(NSString *)username
                                       password:(NSString *)password
                                          nonce:(NSString *)nonce
                                      timestamp:(NSDate *)timestamp;
@end
