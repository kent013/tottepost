//
//  Evernote.h
//  EVNConnect
//
//  Created by Kentaro ISHITOYA on 12/02/03.
//  Copyright (c) 2012 Kentaro ISHITOYA. All rights reserved.
//

#import "EvernoteProtocol.h"
#import "EvernoteRequest.h"

@protocol EvernoteSessionDelegate;

/*!
 * evernote wrapper class
 */
@interface Evernote : NSObject<EvernoteAuthDelegate, EvernoteContextDelegate, EvernoteNoteStoreClientFactoryDelegate>{
    __strong NSMutableSet *requests_;
    __strong id<EvernoteAuthProtocol> authConsumer_;
    __weak id<EvernoteSessionDelegate> sessionDelegate_;
    EvernoteAuthType authType_;

    BOOL useSandbox_;
}
@property(nonatomic, weak) id<EvernoteSessionDelegate> sessionDelegate;

#pragma - authentication
- (id)initWithAuthType:(EvernoteAuthType) authType
           consumerKey:(NSString*)consumerKey
        consumerSecret:(NSString*)consumerSecret
        callbackScheme:(NSString*)callbackScheme
            useSandBox:(BOOL) useSandbox
           andDelegate:(id<EvernoteSessionDelegate>)delegate;

- (BOOL)handleOpenURL:(NSURL *)url;
- (void)login;
- (void)logout;
- (BOOL)isSessionValid;
- (void)saveCredential;
- (void)loadCredential;
- (void)clearCredential;

#pragma mark - resource
- (EDAMResource *) createResourceFromUIImage:(UIImage *)image;
- (EDAMResource *) createResourceFromImageData:(NSData *)image andMime:(NSString *)mime;

#pragma mark - async methods
#pragma mark - notes
- (EvernoteRequest *)createNoteInNotebook:(EDAMNotebook *)notebook title:(NSString*)title content:(NSString*)content tags:(NSArray *)tags resources:(NSArray*)resources andDelegate:(id<EvernoteRequestDelegate>)delegate;

#pragma mark - sync methods
#pragma mark - tags
- (NSArray *)tags;
- (EDAMTag *)tagNamed: (NSString *)name;
- (NSArray *)findTagsWithPattern: (NSString *)pattern;
- (EDAMTag *)createTagWithName: (NSString *)tag;
- (EDAMTag *)renameTag:(EDAMTag *)tag toName:(NSString *)name;
- (void)removeTagForName: (NSString *)tagName;
- (void)removeTag:(EDAMTag *)tag;

#pragma mark - notebooks
- (NSArray *)notebooks;
- (EDAMNotebook*)notebookNamed:(NSString *)title;
- (NSArray *)findNotebooksWithPattern:(NSString *)pattern;
- (EDAMNotebook*)defaultNotebook;
- (EDAMNotebook*)createNotebookWithTitle:(NSString*)title;
- (void) updateNote: (EDAMNote *)note;

#pragma mark - notes
- (EDAMNoteList*)notesForNotebook:(EDAMNotebook *)notebook;
- (EDAMNoteList*)notesForNotebookGUID:(EDAMGuid)guid;
- (EDAMNote*)noteForNoteGUID:(EDAMGuid)guid;
- (EDAMNote*)createNoteInNotebook:(EDAMNotebook *)notebook title:(NSString*)title content:(NSString*)content tags:(NSArray *)tags andResources:(NSArray*)resources;
- (void)addResourceToNote:(EDAMNote *)note resource:(EDAMResource *)resource;
- (void)removeNoteForGUID:(EDAMGuid)guid;
@end

@protocol EvernoteSessionDelegate <NSObject>
- (void)evernoteDidLogin;
- (void)evernoteDidNotLogin;
- (void)evernoteDidLogout;

@end
