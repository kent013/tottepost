//
//  EvernoteRequest.h
//  EVNConnect
//
//  Created by Kentaro ISHITOYA on 12/02/03.
//  Copyright (c) 2012 Kentaro ISHITOYA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "UserStore.h"
#import "NoteStore.h"
#import "EvernoteProtocol.h"
#import "EvernoteHTTPClient.h"

@class Evernote;
@protocol EvernoteContextDelegate;

@interface EvernoteRequest : NSObject<EvernoteHTTPClientDelegate> {
	EDAMNoteStoreClient	*noteStoreClient_;
    __strong NSString *authToken_;
    __weak id<EvernoteContextDelegate> contextDelegate_;
    __weak id<EvernoteNoteStoreClientFactoryDelegate> noteStoreClientFactory_;
}

@property (nonatomic, weak) id<EvernoteRequestDelegate> delegate;
@property (nonatomic, readonly) NSURL *url;
@property (nonatomic, readonly) NSString *method;

-(id) initWithAuthToken:(NSString *)authToken noteStoreClientFactory:(id<EvernoteNoteStoreClientFactoryDelegate>)noteStoreClientFactory delegate:(id<EvernoteRequestDelegate>) delegate andContextDelegate:(id<EvernoteContextDelegate>)contextDelegate;
-(void) abort;
#pragma mark - resource
- (EDAMResource *) createResourceFromUIImage:(UIImage *)image;
- (EDAMResource *) createResourceFromImageData:(NSData *)image andMime:(NSString *)mime;

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
- (EDAMNote*)createNoteInNotebook:(EDAMNotebook *)notebook title:(NSString*)title andContent:(NSString*)content;
- (EDAMNote*)createNoteInNotebook:(EDAMNotebook *)notebook title:(NSString*)title content:(NSString*)content andTags:(NSArray*)tags;
- (EDAMNote*)createNoteInNotebook:(EDAMNotebook *)notebook title:(NSString*)title content:(NSString*)content tags:(NSArray *)tags andResources:(NSArray*)resources;
- (void)addResourceToNote:(EDAMNote *)note resource:(EDAMResource *)resource;
- (void)removeNoteForGUID:(EDAMGuid)guid;
@end

@protocol EvernoteContextDelegate <NSObject>
- (void)request:(EvernoteRequest *)request didFailWithException:(NSException *)exception;
@end

