//
//  UVSession.m
//  UserVoice
//
//  Created by UserVoice on 10/22/09.
//  Copyright 2009 UserVoice Inc. All rights reserved.
//

#import "UVSession.h"
#import "UVConfig.h"
#import "UVStyleSheet.h"
#import "UVUser.h"
#import "YOAuth.h"
#import "UVClientConfig.h"
#import "UVForum.h"
#import "UVTopic.h"

@implementation UVSession

@synthesize isModal;
@synthesize config;
@synthesize clientConfig;
@synthesize currentToken;
@synthesize info;
@synthesize userCache, startTime;

static UVSession *currentUVSession;
+ (void) clearCurrentSession{
    currentUVSession = nil;
}

+ (UVSession *)currentSession {
	@synchronized(self) {
		if (!currentUVSession) {
			currentUVSession = [[UVSession alloc] init];
			currentUVSession.startTime = [NSDate date];
		}
	}
	
	return currentUVSession;
}

- (BOOL)loggedIn {
	return self.user != nil;
}

- (UVUser *)user {
    return user;
}

- (void)setUser:(UVUser *)theUser {
    [user release];
    user = theUser;
    [user retain];
    // reload the topic because it owns the number of available votes for the current user
    if (clientConfig)
        [UVClientConfig getWithDelegate:self];
}

- (id)init {
	if (self = [super init]) {
		self.userCache = [NSMutableDictionary dictionary];
	}
	return self;
}

- (void)didRetrieveClientConfig:(UVClientConfig *)config {
    // Do nothing. The UVClientConfig already sets the config on the current session.
}

- (YOAuthConsumer *)yOAuthConsumer {
	if (!yOAuthConsumer) {
		yOAuthConsumer = [[YOAuthConsumer alloc] initWithKey:self.config.key
											       andSecret:self.config.secret];
	}
	return yOAuthConsumer;
}

@end
