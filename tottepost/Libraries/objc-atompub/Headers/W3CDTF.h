#import <Foundation/Foundation.h>

@interface W3CDTF : NSObject {
}
+ (NSDate *)dateFromString:(NSString *)formattedDate;
+ (NSString *)stringFromDate:(NSDate *)date;
@end
