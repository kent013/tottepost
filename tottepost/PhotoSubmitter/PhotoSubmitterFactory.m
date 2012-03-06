//
//  PhotoSubmitterFactory.m
//  tottepost
//
//  Created by Kentaro ISHITOYA on 12/02/28.
//  Copyright (c) 2012 cocotomo. All rights reserved.
//

#import <objc/runtime.h>
#import <objc/message.h>
#import "PhotoSubmitterFactory.h"
#import "RegexKitLite.h"

//-----------------------------------------------------------------------------
//Private Implementations
//-----------------------------------------------------------------------------
@interface PhotoSubmitterFactory(PrivateImplementation)
+ (id<PhotoSubmitterProtocol>)getSubmitterInstance:(NSString *)type;
@end

#pragma mark - private implementations
@implementation PhotoSubmitterFactory(PrivateImplementation)
/*!
 * load classes
 */
+ (id<PhotoSubmitterProtocol>)getSubmitterInstance:(NSString *)type{
    static NSMutableDictionary *loadedClasses;
    if(loadedClasses == nil){
        loadedClasses = [[NSMutableDictionary alloc] init];
        int numClasses;
        Class *classes = NULL;
        
        classes = NULL;
        numClasses = objc_getClassList(NULL, 0);
        
        if (numClasses > 0 )
        {
            classes = (__unsafe_unretained Class *)malloc(sizeof(Class) * numClasses);
            numClasses = objc_getClassList(classes, numClasses);
            for (int i = 0; i < numClasses; i++) {
                Class cls = classes[i];
                NSString *className = [NSString stringWithUTF8String:class_getName(cls)];
                if([className isMatchedByRegex:@"PhotoSubmitter$"]){
                    id<PhotoSubmitterProtocol> submitter = [[NSClassFromString(className) alloc] init];
                    [loadedClasses setObject:submitter.type forKey:className];
                }
            }
            free(classes);
        }
    }
    
    NSString *className = [loadedClasses objectForKey:type];
    if(className == nil){
        return nil;
    }
    return [[NSClassFromString(className) alloc] init];
}
@end

//-----------------------------------------------------------------------------
//Public Implementations
//-----------------------------------------------------------------------------
#pragma mark - public implementations
@implementation PhotoSubmitterFactory
/*!
 * create submitter
 * you may add case clause when you created new submitter
 */
+ (id<PhotoSubmitterProtocol>)createWithType:(NSString *)type{
    return [self getSubmitterInstance:type];
}
@end
