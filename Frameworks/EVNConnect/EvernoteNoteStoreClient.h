//
//  EvernoteNoteStoreClient.m
//  Wrapper class of NoteStoreClient
//
//  Created by conv.php on 2012/02/09 21:05:08.
//  Copyright (c) 2012 Kentaro ISHITOYA. All rights reserved.
//


#import "NoteStore.h"
#import "EvernoteProtocol.h"

@interface EvernoteNoteStoreClient : EDAMNoteStoreClient{
    __weak id<EvernoteHTTPClientDelegate> delegate_;
}
@property (nonatomic, readonly) EvernoteHTTPClient *httpClient;
- (void) getSyncState: (NSString *) authenticationToken andDelegate:(id<EvernoteHTTPClientDelegate>) delegate;
- (void) getSyncChunk: (NSString *) authenticationToken : (int32_t) afterUSN : (int32_t) maxEntries : (BOOL) fullSyncOnly andDelegate:(id<EvernoteHTTPClientDelegate>) delegate;
- (void) getFilteredSyncChunk: (NSString *) authenticationToken : (int32_t) afterUSN : (int32_t) maxEntries : (EDAMSyncChunkFilter *) filter andDelegate:(id<EvernoteHTTPClientDelegate>) delegate;
- (void) getLinkedNotebookSyncState: (NSString *) authenticationToken : (EDAMLinkedNotebook *) linkedNotebook andDelegate:(id<EvernoteHTTPClientDelegate>) delegate;
- (void) getLinkedNotebookSyncChunk: (NSString *) authenticationToken : (EDAMLinkedNotebook *) linkedNotebook : (int32_t) afterUSN : (int32_t) maxEntries : (BOOL) fullSyncOnly andDelegate:(id<EvernoteHTTPClientDelegate>) delegate;
- (void) listNotebooks: (NSString *) authenticationToken andDelegate:(id<EvernoteHTTPClientDelegate>) delegate;
- (void) getNotebook: (NSString *) authenticationToken : (EDAMGuid) guid andDelegate:(id<EvernoteHTTPClientDelegate>) delegate;
- (void) getDefaultNotebook: (NSString *) authenticationToken andDelegate:(id<EvernoteHTTPClientDelegate>) delegate;
- (void) createNotebook: (NSString *) authenticationToken : (EDAMNotebook *) notebook andDelegate:(id<EvernoteHTTPClientDelegate>) delegate;
- (void) updateNotebook: (NSString *) authenticationToken : (EDAMNotebook *) notebook andDelegate:(id<EvernoteHTTPClientDelegate>) delegate;
- (void) expungeNotebook: (NSString *) authenticationToken : (EDAMGuid) guid andDelegate:(id<EvernoteHTTPClientDelegate>) delegate;
- (void) listTags: (NSString *) authenticationToken andDelegate:(id<EvernoteHTTPClientDelegate>) delegate;
- (void) listTagsByNotebook: (NSString *) authenticationToken : (EDAMGuid) notebookGuid andDelegate:(id<EvernoteHTTPClientDelegate>) delegate;
- (void) getTag: (NSString *) authenticationToken : (EDAMGuid) guid andDelegate:(id<EvernoteHTTPClientDelegate>) delegate;
- (void) createTag: (NSString *) authenticationToken : (EDAMTag *) tag andDelegate:(id<EvernoteHTTPClientDelegate>) delegate;
- (void) updateTag: (NSString *) authenticationToken : (EDAMTag *) tag andDelegate:(id<EvernoteHTTPClientDelegate>) delegate;
- (void) expungeTag: (NSString *) authenticationToken : (EDAMGuid) guid andDelegate:(id<EvernoteHTTPClientDelegate>) delegate;
- (void) listSearches: (NSString *) authenticationToken andDelegate:(id<EvernoteHTTPClientDelegate>) delegate;
- (void) getSearch: (NSString *) authenticationToken : (EDAMGuid) guid andDelegate:(id<EvernoteHTTPClientDelegate>) delegate;
- (void) createSearch: (NSString *) authenticationToken : (EDAMSavedSearch *) search andDelegate:(id<EvernoteHTTPClientDelegate>) delegate;
- (void) updateSearch: (NSString *) authenticationToken : (EDAMSavedSearch *) search andDelegate:(id<EvernoteHTTPClientDelegate>) delegate;
- (void) expungeSearch: (NSString *) authenticationToken : (EDAMGuid) guid andDelegate:(id<EvernoteHTTPClientDelegate>) delegate;
- (void) findNotes: (NSString *) authenticationToken : (EDAMNoteFilter *) filter : (int32_t) offset : (int32_t) maxNotes andDelegate:(id<EvernoteHTTPClientDelegate>) delegate;
- (void) findNoteOffset: (NSString *) authenticationToken : (EDAMNoteFilter *) filter : (EDAMGuid) guid andDelegate:(id<EvernoteHTTPClientDelegate>) delegate;
- (void) findNotesMetadata: (NSString *) authenticationToken : (EDAMNoteFilter *) filter : (int32_t) offset : (int32_t) maxNotes : (EDAMNotesMetadataResultSpec *) resultSpec andDelegate:(id<EvernoteHTTPClientDelegate>) delegate;
- (void) findNoteCounts: (NSString *) authenticationToken : (EDAMNoteFilter *) filter : (BOOL) withTrash andDelegate:(id<EvernoteHTTPClientDelegate>) delegate;
- (void) getNote: (NSString *) authenticationToken : (EDAMGuid) guid : (BOOL) withContent : (BOOL) withResourcesData : (BOOL) withResourcesRecognition : (BOOL) withResourcesAlternateData andDelegate:(id<EvernoteHTTPClientDelegate>) delegate;
- (void) getNoteApplicationData: (NSString *) authenticationToken : (EDAMGuid) guid andDelegate:(id<EvernoteHTTPClientDelegate>) delegate;
- (void) getNoteApplicationDataEntry: (NSString *) authenticationToken : (EDAMGuid) guid : (NSString *) key andDelegate:(id<EvernoteHTTPClientDelegate>) delegate;
- (void) setNoteApplicationDataEntry: (NSString *) authenticationToken : (EDAMGuid) guid : (NSString *) key : (NSString *) value andDelegate:(id<EvernoteHTTPClientDelegate>) delegate;
- (void) unsetNoteApplicationDataEntry: (NSString *) authenticationToken : (EDAMGuid) guid : (NSString *) key andDelegate:(id<EvernoteHTTPClientDelegate>) delegate;
- (void) getNoteContent: (NSString *) authenticationToken : (EDAMGuid) guid andDelegate:(id<EvernoteHTTPClientDelegate>) delegate;
- (void) getNoteSearchText: (NSString *) authenticationToken : (EDAMGuid) guid : (BOOL) noteOnly : (BOOL) tokenizeForIndexing andDelegate:(id<EvernoteHTTPClientDelegate>) delegate;
- (void) getResourceSearchText: (NSString *) authenticationToken : (EDAMGuid) guid andDelegate:(id<EvernoteHTTPClientDelegate>) delegate;
- (void) getNoteTagNames: (NSString *) authenticationToken : (EDAMGuid) guid andDelegate:(id<EvernoteHTTPClientDelegate>) delegate;
- (void) createNote: (NSString *) authenticationToken : (EDAMNote *) note andDelegate:(id<EvernoteHTTPClientDelegate>) delegate;
- (void) updateNote: (NSString *) authenticationToken : (EDAMNote *) note andDelegate:(id<EvernoteHTTPClientDelegate>) delegate;
- (void) deleteNote: (NSString *) authenticationToken : (EDAMGuid) guid andDelegate:(id<EvernoteHTTPClientDelegate>) delegate;
- (void) expungeNote: (NSString *) authenticationToken : (EDAMGuid) guid andDelegate:(id<EvernoteHTTPClientDelegate>) delegate;
- (void) expungeNotes: (NSString *) authenticationToken : (NSMutableArray *) noteGuids andDelegate:(id<EvernoteHTTPClientDelegate>) delegate;
- (void) expungeInactiveNotes: (NSString *) authenticationToken andDelegate:(id<EvernoteHTTPClientDelegate>) delegate;
- (void) copyNote: (NSString *) authenticationToken : (EDAMGuid) noteGuid : (EDAMGuid) toNotebookGuid andDelegate:(id<EvernoteHTTPClientDelegate>) delegate;
- (void) listNoteVersions: (NSString *) authenticationToken : (EDAMGuid) noteGuid andDelegate:(id<EvernoteHTTPClientDelegate>) delegate;
- (void) getNoteVersion: (NSString *) authenticationToken : (EDAMGuid) noteGuid : (int32_t) updateSequenceNum : (BOOL) withResourcesData : (BOOL) withResourcesRecognition : (BOOL) withResourcesAlternateData andDelegate:(id<EvernoteHTTPClientDelegate>) delegate;
- (void) getResource: (NSString *) authenticationToken : (EDAMGuid) guid : (BOOL) withData : (BOOL) withRecognition : (BOOL) withAttributes : (BOOL) withAlternateData andDelegate:(id<EvernoteHTTPClientDelegate>) delegate;
- (void) getResourceApplicationData: (NSString *) authenticationToken : (EDAMGuid) guid andDelegate:(id<EvernoteHTTPClientDelegate>) delegate;
- (void) getResourceApplicationDataEntry: (NSString *) authenticationToken : (EDAMGuid) guid : (NSString *) key andDelegate:(id<EvernoteHTTPClientDelegate>) delegate;
- (void) setResourceApplicationDataEntry: (NSString *) authenticationToken : (EDAMGuid) guid : (NSString *) key : (NSString *) value andDelegate:(id<EvernoteHTTPClientDelegate>) delegate;
- (void) unsetResourceApplicationDataEntry: (NSString *) authenticationToken : (EDAMGuid) guid : (NSString *) key andDelegate:(id<EvernoteHTTPClientDelegate>) delegate;
- (void) updateResource: (NSString *) authenticationToken : (EDAMResource *) resource andDelegate:(id<EvernoteHTTPClientDelegate>) delegate;
- (void) getResourceData: (NSString *) authenticationToken : (EDAMGuid) guid andDelegate:(id<EvernoteHTTPClientDelegate>) delegate;
- (void) getResourceByHash: (NSString *) authenticationToken : (EDAMGuid) noteGuid : (NSData *) contentHash : (BOOL) withData : (BOOL) withRecognition : (BOOL) withAlternateData andDelegate:(id<EvernoteHTTPClientDelegate>) delegate;
- (void) getResourceRecognition: (NSString *) authenticationToken : (EDAMGuid) guid andDelegate:(id<EvernoteHTTPClientDelegate>) delegate;
- (void) getResourceAlternateData: (NSString *) authenticationToken : (EDAMGuid) guid andDelegate:(id<EvernoteHTTPClientDelegate>) delegate;
- (void) getResourceAttributes: (NSString *) authenticationToken : (EDAMGuid) guid andDelegate:(id<EvernoteHTTPClientDelegate>) delegate;
- (void) getAccountSize: (NSString *) authenticationToken andDelegate:(id<EvernoteHTTPClientDelegate>) delegate;
- (void) getAds: (NSString *) authenticationToken : (EDAMAdParameters *) adParameters andDelegate:(id<EvernoteHTTPClientDelegate>) delegate;
- (void) getRandomAd: (NSString *) authenticationToken : (EDAMAdParameters *) adParameters andDelegate:(id<EvernoteHTTPClientDelegate>) delegate;
- (void) getPublicNotebook: (EDAMUserID) userId : (NSString *) publicUri andDelegate:(id<EvernoteHTTPClientDelegate>) delegate;
- (void) createSharedNotebook: (NSString *) authenticationToken : (EDAMSharedNotebook *) sharedNotebook andDelegate:(id<EvernoteHTTPClientDelegate>) delegate;
- (void) sendMessageToSharedNotebookMembers: (NSString *) authenticationToken : (EDAMGuid) notebookGuid : (NSString *) messageText : (NSMutableArray *) recipients andDelegate:(id<EvernoteHTTPClientDelegate>) delegate;
- (void) listSharedNotebooks: (NSString *) authenticationToken andDelegate:(id<EvernoteHTTPClientDelegate>) delegate;
- (void) expungeSharedNotebooks: (NSString *) authenticationToken : (NSMutableArray *) sharedNotebookIds andDelegate:(id<EvernoteHTTPClientDelegate>) delegate;
- (void) createLinkedNotebook: (NSString *) authenticationToken : (EDAMLinkedNotebook *) linkedNotebook andDelegate:(id<EvernoteHTTPClientDelegate>) delegate;
- (void) updateLinkedNotebook: (NSString *) authenticationToken : (EDAMLinkedNotebook *) linkedNotebook andDelegate:(id<EvernoteHTTPClientDelegate>) delegate;
- (void) listLinkedNotebooks: (NSString *) authenticationToken andDelegate:(id<EvernoteHTTPClientDelegate>) delegate;
- (void) expungeLinkedNotebook: (NSString *) authenticationToken : (EDAMGuid) guid andDelegate:(id<EvernoteHTTPClientDelegate>) delegate;
- (void) authenticateToSharedNotebook: (NSString *) shareKey : (NSString *) authenticationToken andDelegate:(id<EvernoteHTTPClientDelegate>) delegate;
- (void) getSharedNotebookByAuth: (NSString *) authenticationToken andDelegate:(id<EvernoteHTTPClientDelegate>) delegate;
- (void) shareNote: (NSString *) authenticationToken : (EDAMGuid) guid andDelegate:(id<EvernoteHTTPClientDelegate>) delegate;
- (void) authenticateToSharedNote: (NSString *) guid : (NSString *) noteKey andDelegate:(id<EvernoteHTTPClientDelegate>) delegate;
@end
