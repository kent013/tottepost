//
//  EvernoteNoteStoreClient.m
//  Wrapper class of NoteStoreClient
//
//  Created by conv.php on 2012/02/09 02:26:04.
//  Copyright (c) 2012 Kentaro ISHITOYA. All rights reserved.
//

#import "EvernoteNoteStoreClient.h"
#import "EvernoteHTTPClient.h"
#import "NoteStore.h"
#import "EDAMNoteStoreClient+PrivateMethods.h"	
//-----------------------------------------------------------------------------
//Private Implementations
//-----------------------------------------------------------------------------
@interface EvernoteNoteStoreClient(PrivateImplementation)
@end

@implementation EvernoteNoteStoreClient(PrivateImplementation)
@end
//-----------------------------------------------------------------------------
//Public Implementations
//-----------------------------------------------------------------------------
@implementation EvernoteNoteStoreClient
/*!
 * get httpclient
 */
- (EvernoteHTTPClient *)httpClient{
	EvernoteHTTPClient *client = (EvernoteHTTPClient *)[outProtocol transport];
	return client;
}

/*!
 * send getSyncState request
 */
- (void) getSyncState: (NSString *) authenticationToken andDelegate:(id<EvernoteHTTPClientDelegate>) delegate
{
  EvernoteHTTPClient *client = (EvernoteHTTPClient *)[outProtocol transport];
  delegate_ = delegate;
  client.delegate = delegate;
  [client setTarget:self action:@selector(client:getSyncStateDidLoad:)];
  [self send_getSyncState: authenticationToken];
}

/*!
 * recieve getSyncState result
 */
- (void) client:(EvernoteHTTPClient *)client getSyncStateDidLoad:(NSData *)result{
  EDAMSyncState *retval = [self recv_getSyncState];

  if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
    [delegate_ client:client didLoad:retval];
  }
}


/*!
 * send getSyncChunk request
 */
- (void) getSyncChunk: (NSString *) authenticationToken : (int32_t) afterUSN : (int32_t) maxEntries : (BOOL) fullSyncOnly andDelegate:(id<EvernoteHTTPClientDelegate>) delegate
{
  EvernoteHTTPClient *client = (EvernoteHTTPClient *)[outProtocol transport];
  delegate_ = delegate;
  client.delegate = delegate;
  [client setTarget:self action:@selector(client:getSyncChunkDidLoad:)];
  [self send_getSyncChunk: authenticationToken : afterUSN : maxEntries : fullSyncOnly];
}

/*!
 * recieve getSyncChunk result
 */
- (void) client:(EvernoteHTTPClient *)client getSyncChunkDidLoad:(NSData *)result{
  EDAMSyncChunk *retval = [self recv_getSyncChunk];

  if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
    [delegate_ client:client didLoad:retval];
  }
}


/*!
 * send getFilteredSyncChunk request
 */
- (void) getFilteredSyncChunk: (NSString *) authenticationToken : (int32_t) afterUSN : (int32_t) maxEntries : (EDAMSyncChunkFilter *) filter andDelegate:(id<EvernoteHTTPClientDelegate>) delegate
{
  EvernoteHTTPClient *client = (EvernoteHTTPClient *)[outProtocol transport];
  delegate_ = delegate;
  client.delegate = delegate;
  [client setTarget:self action:@selector(client:getFilteredSyncChunkDidLoad:)];
  [self send_getFilteredSyncChunk: authenticationToken : afterUSN : maxEntries : filter];
}

/*!
 * recieve getFilteredSyncChunk result
 */
- (void) client:(EvernoteHTTPClient *)client getFilteredSyncChunkDidLoad:(NSData *)result{
  EDAMSyncChunk *retval = [self recv_getFilteredSyncChunk];

  if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
    [delegate_ client:client didLoad:retval];
  }
}


/*!
 * send getLinkedNotebookSyncState request
 */
- (void) getLinkedNotebookSyncState: (NSString *) authenticationToken : (EDAMLinkedNotebook *) linkedNotebook andDelegate:(id<EvernoteHTTPClientDelegate>) delegate
{
  EvernoteHTTPClient *client = (EvernoteHTTPClient *)[outProtocol transport];
  delegate_ = delegate;
  client.delegate = delegate;
  [client setTarget:self action:@selector(client:getLinkedNotebookSyncStateDidLoad:)];
  [self send_getLinkedNotebookSyncState: authenticationToken : linkedNotebook];
}

/*!
 * recieve getLinkedNotebookSyncState result
 */
- (void) client:(EvernoteHTTPClient *)client getLinkedNotebookSyncStateDidLoad:(NSData *)result{
  EDAMSyncState *retval = [self recv_getLinkedNotebookSyncState];

  if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
    [delegate_ client:client didLoad:retval];
  }
}


/*!
 * send getLinkedNotebookSyncChunk request
 */
- (void) getLinkedNotebookSyncChunk: (NSString *) authenticationToken : (EDAMLinkedNotebook *) linkedNotebook : (int32_t) afterUSN : (int32_t) maxEntries : (BOOL) fullSyncOnly andDelegate:(id<EvernoteHTTPClientDelegate>) delegate
{
  EvernoteHTTPClient *client = (EvernoteHTTPClient *)[outProtocol transport];
  delegate_ = delegate;
  client.delegate = delegate;
  [client setTarget:self action:@selector(client:getLinkedNotebookSyncChunkDidLoad:)];
  [self send_getLinkedNotebookSyncChunk: authenticationToken : linkedNotebook : afterUSN : maxEntries : fullSyncOnly];
}

/*!
 * recieve getLinkedNotebookSyncChunk result
 */
- (void) client:(EvernoteHTTPClient *)client getLinkedNotebookSyncChunkDidLoad:(NSData *)result{
  EDAMSyncChunk *retval = [self recv_getLinkedNotebookSyncChunk];

  if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
    [delegate_ client:client didLoad:retval];
  }
}


/*!
 * send listNotebooks request
 */
- (void) listNotebooks: (NSString *) authenticationToken andDelegate:(id<EvernoteHTTPClientDelegate>) delegate
{
  EvernoteHTTPClient *client = (EvernoteHTTPClient *)[outProtocol transport];
  delegate_ = delegate;
  client.delegate = delegate;
  [client setTarget:self action:@selector(client:listNotebooksDidLoad:)];
  [self send_listNotebooks: authenticationToken];
}

/*!
 * recieve listNotebooks result
 */
- (void) client:(EvernoteHTTPClient *)client listNotebooksDidLoad:(NSData *)result{
  NSMutableArray *retval = [self recv_listNotebooks];

  if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
    [delegate_ client:client didLoad:retval];
  }
}


/*!
 * send getNotebook request
 */
- (void) getNotebook: (NSString *) authenticationToken : (EDAMGuid) guid andDelegate:(id<EvernoteHTTPClientDelegate>) delegate
{
  EvernoteHTTPClient *client = (EvernoteHTTPClient *)[outProtocol transport];
  delegate_ = delegate;
  client.delegate = delegate;
  [client setTarget:self action:@selector(client:getNotebookDidLoad:)];
  [self send_getNotebook: authenticationToken : guid];
}

/*!
 * recieve getNotebook result
 */
- (void) client:(EvernoteHTTPClient *)client getNotebookDidLoad:(NSData *)result{
  EDAMNotebook *retval = [self recv_getNotebook];

  if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
    [delegate_ client:client didLoad:retval];
  }
}


/*!
 * send getDefaultNotebook request
 */
- (void) getDefaultNotebook: (NSString *) authenticationToken andDelegate:(id<EvernoteHTTPClientDelegate>) delegate
{
  EvernoteHTTPClient *client = (EvernoteHTTPClient *)[outProtocol transport];
  delegate_ = delegate;
  client.delegate = delegate;
  [client setTarget:self action:@selector(client:getDefaultNotebookDidLoad:)];
  [self send_getDefaultNotebook: authenticationToken];
}

/*!
 * recieve getDefaultNotebook result
 */
- (void) client:(EvernoteHTTPClient *)client getDefaultNotebookDidLoad:(NSData *)result{
  EDAMNotebook *retval = [self recv_getDefaultNotebook];

  if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
    [delegate_ client:client didLoad:retval];
  }
}


/*!
 * send createNotebook request
 */
- (void) createNotebook: (NSString *) authenticationToken : (EDAMNotebook *) notebook andDelegate:(id<EvernoteHTTPClientDelegate>) delegate
{
  EvernoteHTTPClient *client = (EvernoteHTTPClient *)[outProtocol transport];
  delegate_ = delegate;
  client.delegate = delegate;
  [client setTarget:self action:@selector(client:createNotebookDidLoad:)];
  [self send_createNotebook: authenticationToken : notebook];
}

/*!
 * recieve createNotebook result
 */
- (void) client:(EvernoteHTTPClient *)client createNotebookDidLoad:(NSData *)result{
  EDAMNotebook *retval = [self recv_createNotebook];

  if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
    [delegate_ client:client didLoad:retval];
  }
}


/*!
 * send updateNotebook request
 */
- (void) updateNotebook: (NSString *) authenticationToken : (EDAMNotebook *) notebook andDelegate:(id<EvernoteHTTPClientDelegate>) delegate
{
  EvernoteHTTPClient *client = (EvernoteHTTPClient *)[outProtocol transport];
  delegate_ = delegate;
  client.delegate = delegate;
  [client setTarget:self action:@selector(client:updateNotebookDidLoad:)];
  [self send_updateNotebook: authenticationToken : notebook];
}

/*!
 * recieve updateNotebook result
 */
- (void) client:(EvernoteHTTPClient *)client updateNotebookDidLoad:(NSData *)result{
  int32_t rawResult = [self recv_updateNotebook];
  NSNumber *retval = [NSNumber numberWithInt:rawResult];

  if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
    [delegate_ client:client didLoad:retval];
  }
}


/*!
 * send expungeNotebook request
 */
- (void) expungeNotebook: (NSString *) authenticationToken : (EDAMGuid) guid andDelegate:(id<EvernoteHTTPClientDelegate>) delegate
{
  EvernoteHTTPClient *client = (EvernoteHTTPClient *)[outProtocol transport];
  delegate_ = delegate;
  client.delegate = delegate;
  [client setTarget:self action:@selector(client:expungeNotebookDidLoad:)];
  [self send_expungeNotebook: authenticationToken : guid];
}

/*!
 * recieve expungeNotebook result
 */
- (void) client:(EvernoteHTTPClient *)client expungeNotebookDidLoad:(NSData *)result{
  int32_t rawResult = [self recv_expungeNotebook];
  NSNumber *retval = [NSNumber numberWithInt:rawResult];

  if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
    [delegate_ client:client didLoad:retval];
  }
}


/*!
 * send listTags request
 */
- (void) listTags: (NSString *) authenticationToken andDelegate:(id<EvernoteHTTPClientDelegate>) delegate
{
  EvernoteHTTPClient *client = (EvernoteHTTPClient *)[outProtocol transport];
  delegate_ = delegate;
  client.delegate = delegate;
  [client setTarget:self action:@selector(client:listTagsDidLoad:)];
  [self send_listTags: authenticationToken];
}

/*!
 * recieve listTags result
 */
- (void) client:(EvernoteHTTPClient *)client listTagsDidLoad:(NSData *)result{
  NSMutableArray *retval = [self recv_listTags];

  if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
    [delegate_ client:client didLoad:retval];
  }
}


/*!
 * send listTagsByNotebook request
 */
- (void) listTagsByNotebook: (NSString *) authenticationToken : (EDAMGuid) notebookGuid andDelegate:(id<EvernoteHTTPClientDelegate>) delegate
{
  EvernoteHTTPClient *client = (EvernoteHTTPClient *)[outProtocol transport];
  delegate_ = delegate;
  client.delegate = delegate;
  [client setTarget:self action:@selector(client:listTagsByNotebookDidLoad:)];
  [self send_listTagsByNotebook: authenticationToken : notebookGuid];
}

/*!
 * recieve listTagsByNotebook result
 */
- (void) client:(EvernoteHTTPClient *)client listTagsByNotebookDidLoad:(NSData *)result{
  NSMutableArray *retval = [self recv_listTagsByNotebook];

  if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
    [delegate_ client:client didLoad:retval];
  }
}


/*!
 * send getTag request
 */
- (void) getTag: (NSString *) authenticationToken : (EDAMGuid) guid andDelegate:(id<EvernoteHTTPClientDelegate>) delegate
{
  EvernoteHTTPClient *client = (EvernoteHTTPClient *)[outProtocol transport];
  delegate_ = delegate;
  client.delegate = delegate;
  [client setTarget:self action:@selector(client:getTagDidLoad:)];
  [self send_getTag: authenticationToken : guid];
}

/*!
 * recieve getTag result
 */
- (void) client:(EvernoteHTTPClient *)client getTagDidLoad:(NSData *)result{
  EDAMTag *retval = [self recv_getTag];

  if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
    [delegate_ client:client didLoad:retval];
  }
}


/*!
 * send createTag request
 */
- (void) createTag: (NSString *) authenticationToken : (EDAMTag *) tag andDelegate:(id<EvernoteHTTPClientDelegate>) delegate
{
  EvernoteHTTPClient *client = (EvernoteHTTPClient *)[outProtocol transport];
  delegate_ = delegate;
  client.delegate = delegate;
  [client setTarget:self action:@selector(client:createTagDidLoad:)];
  [self send_createTag: authenticationToken : tag];
}

/*!
 * recieve createTag result
 */
- (void) client:(EvernoteHTTPClient *)client createTagDidLoad:(NSData *)result{
  EDAMTag *retval = [self recv_createTag];

  if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
    [delegate_ client:client didLoad:retval];
  }
}


/*!
 * send updateTag request
 */
- (void) updateTag: (NSString *) authenticationToken : (EDAMTag *) tag andDelegate:(id<EvernoteHTTPClientDelegate>) delegate
{
  EvernoteHTTPClient *client = (EvernoteHTTPClient *)[outProtocol transport];
  delegate_ = delegate;
  client.delegate = delegate;
  [client setTarget:self action:@selector(client:updateTagDidLoad:)];
  [self send_updateTag: authenticationToken : tag];
}

/*!
 * recieve updateTag result
 */
- (void) client:(EvernoteHTTPClient *)client updateTagDidLoad:(NSData *)result{
  int32_t rawResult = [self recv_updateTag];
  NSNumber *retval = [NSNumber numberWithInt:rawResult];

  if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
    [delegate_ client:client didLoad:retval];
  }
}


/*!
 * send expungeTag request
 */
- (void) expungeTag: (NSString *) authenticationToken : (EDAMGuid) guid andDelegate:(id<EvernoteHTTPClientDelegate>) delegate
{
  EvernoteHTTPClient *client = (EvernoteHTTPClient *)[outProtocol transport];
  delegate_ = delegate;
  client.delegate = delegate;
  [client setTarget:self action:@selector(client:expungeTagDidLoad:)];
  [self send_expungeTag: authenticationToken : guid];
}

/*!
 * recieve expungeTag result
 */
- (void) client:(EvernoteHTTPClient *)client expungeTagDidLoad:(NSData *)result{
  int32_t rawResult = [self recv_expungeTag];
  NSNumber *retval = [NSNumber numberWithInt:rawResult];

  if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
    [delegate_ client:client didLoad:retval];
  }
}


/*!
 * send listSearches request
 */
- (void) listSearches: (NSString *) authenticationToken andDelegate:(id<EvernoteHTTPClientDelegate>) delegate
{
  EvernoteHTTPClient *client = (EvernoteHTTPClient *)[outProtocol transport];
  delegate_ = delegate;
  client.delegate = delegate;
  [client setTarget:self action:@selector(client:listSearchesDidLoad:)];
  [self send_listSearches: authenticationToken];
}

/*!
 * recieve listSearches result
 */
- (void) client:(EvernoteHTTPClient *)client listSearchesDidLoad:(NSData *)result{
  NSMutableArray *retval = [self recv_listSearches];

  if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
    [delegate_ client:client didLoad:retval];
  }
}


/*!
 * send getSearch request
 */
- (void) getSearch: (NSString *) authenticationToken : (EDAMGuid) guid andDelegate:(id<EvernoteHTTPClientDelegate>) delegate
{
  EvernoteHTTPClient *client = (EvernoteHTTPClient *)[outProtocol transport];
  delegate_ = delegate;
  client.delegate = delegate;
  [client setTarget:self action:@selector(client:getSearchDidLoad:)];
  [self send_getSearch: authenticationToken : guid];
}

/*!
 * recieve getSearch result
 */
- (void) client:(EvernoteHTTPClient *)client getSearchDidLoad:(NSData *)result{
  EDAMSavedSearch *retval = [self recv_getSearch];

  if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
    [delegate_ client:client didLoad:retval];
  }
}


/*!
 * send createSearch request
 */
- (void) createSearch: (NSString *) authenticationToken : (EDAMSavedSearch *) search andDelegate:(id<EvernoteHTTPClientDelegate>) delegate
{
  EvernoteHTTPClient *client = (EvernoteHTTPClient *)[outProtocol transport];
  delegate_ = delegate;
  client.delegate = delegate;
  [client setTarget:self action:@selector(client:createSearchDidLoad:)];
  [self send_createSearch: authenticationToken : search];
}

/*!
 * recieve createSearch result
 */
- (void) client:(EvernoteHTTPClient *)client createSearchDidLoad:(NSData *)result{
  EDAMSavedSearch *retval = [self recv_createSearch];

  if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
    [delegate_ client:client didLoad:retval];
  }
}


/*!
 * send updateSearch request
 */
- (void) updateSearch: (NSString *) authenticationToken : (EDAMSavedSearch *) search andDelegate:(id<EvernoteHTTPClientDelegate>) delegate
{
  EvernoteHTTPClient *client = (EvernoteHTTPClient *)[outProtocol transport];
  delegate_ = delegate;
  client.delegate = delegate;
  [client setTarget:self action:@selector(client:updateSearchDidLoad:)];
  [self send_updateSearch: authenticationToken : search];
}

/*!
 * recieve updateSearch result
 */
- (void) client:(EvernoteHTTPClient *)client updateSearchDidLoad:(NSData *)result{
  int32_t rawResult = [self recv_updateSearch];
  NSNumber *retval = [NSNumber numberWithInt:rawResult];

  if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
    [delegate_ client:client didLoad:retval];
  }
}


/*!
 * send expungeSearch request
 */
- (void) expungeSearch: (NSString *) authenticationToken : (EDAMGuid) guid andDelegate:(id<EvernoteHTTPClientDelegate>) delegate
{
  EvernoteHTTPClient *client = (EvernoteHTTPClient *)[outProtocol transport];
  delegate_ = delegate;
  client.delegate = delegate;
  [client setTarget:self action:@selector(client:expungeSearchDidLoad:)];
  [self send_expungeSearch: authenticationToken : guid];
}

/*!
 * recieve expungeSearch result
 */
- (void) client:(EvernoteHTTPClient *)client expungeSearchDidLoad:(NSData *)result{
  int32_t rawResult = [self recv_expungeSearch];
  NSNumber *retval = [NSNumber numberWithInt:rawResult];

  if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
    [delegate_ client:client didLoad:retval];
  }
}


/*!
 * send findNotes request
 */
- (void) findNotes: (NSString *) authenticationToken : (EDAMNoteFilter *) filter : (int32_t) offset : (int32_t) maxNotes andDelegate:(id<EvernoteHTTPClientDelegate>) delegate
{
  EvernoteHTTPClient *client = (EvernoteHTTPClient *)[outProtocol transport];
  delegate_ = delegate;
  client.delegate = delegate;
  [client setTarget:self action:@selector(client:findNotesDidLoad:)];
  [self send_findNotes: authenticationToken : filter : offset : maxNotes];
}

/*!
 * recieve findNotes result
 */
- (void) client:(EvernoteHTTPClient *)client findNotesDidLoad:(NSData *)result{
  EDAMNoteList *retval = [self recv_findNotes];

  if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
    [delegate_ client:client didLoad:retval];
  }
}


/*!
 * send findNoteOffset request
 */
- (void) findNoteOffset: (NSString *) authenticationToken : (EDAMNoteFilter *) filter : (EDAMGuid) guid andDelegate:(id<EvernoteHTTPClientDelegate>) delegate
{
  EvernoteHTTPClient *client = (EvernoteHTTPClient *)[outProtocol transport];
  delegate_ = delegate;
  client.delegate = delegate;
  [client setTarget:self action:@selector(client:findNoteOffsetDidLoad:)];
  [self send_findNoteOffset: authenticationToken : filter : guid];
}

/*!
 * recieve findNoteOffset result
 */
- (void) client:(EvernoteHTTPClient *)client findNoteOffsetDidLoad:(NSData *)result{
  int32_t rawResult = [self recv_findNoteOffset];
  NSNumber *retval = [NSNumber numberWithInt:rawResult];

  if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
    [delegate_ client:client didLoad:retval];
  }
}


/*!
 * send findNotesMetadata request
 */
- (void) findNotesMetadata: (NSString *) authenticationToken : (EDAMNoteFilter *) filter : (int32_t) offset : (int32_t) maxNotes : (EDAMNotesMetadataResultSpec *) resultSpec andDelegate:(id<EvernoteHTTPClientDelegate>) delegate
{
  EvernoteHTTPClient *client = (EvernoteHTTPClient *)[outProtocol transport];
  delegate_ = delegate;
  client.delegate = delegate;
  [client setTarget:self action:@selector(client:findNotesMetadataDidLoad:)];
  [self send_findNotesMetadata: authenticationToken : filter : offset : maxNotes : resultSpec];
}

/*!
 * recieve findNotesMetadata result
 */
- (void) client:(EvernoteHTTPClient *)client findNotesMetadataDidLoad:(NSData *)result{
  EDAMNotesMetadataList *retval = [self recv_findNotesMetadata];

  if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
    [delegate_ client:client didLoad:retval];
  }
}


/*!
 * send findNoteCounts request
 */
- (void) findNoteCounts: (NSString *) authenticationToken : (EDAMNoteFilter *) filter : (BOOL) withTrash andDelegate:(id<EvernoteHTTPClientDelegate>) delegate
{
  EvernoteHTTPClient *client = (EvernoteHTTPClient *)[outProtocol transport];
  delegate_ = delegate;
  client.delegate = delegate;
  [client setTarget:self action:@selector(client:findNoteCountsDidLoad:)];
  [self send_findNoteCounts: authenticationToken : filter : withTrash];
}

/*!
 * recieve findNoteCounts result
 */
- (void) client:(EvernoteHTTPClient *)client findNoteCountsDidLoad:(NSData *)result{
  EDAMNoteCollectionCounts *retval = [self recv_findNoteCounts];

  if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
    [delegate_ client:client didLoad:retval];
  }
}


/*!
 * send getNote request
 */
- (void) getNote: (NSString *) authenticationToken : (EDAMGuid) guid : (BOOL) withContent : (BOOL) withResourcesData : (BOOL) withResourcesRecognition : (BOOL) withResourcesAlternateData andDelegate:(id<EvernoteHTTPClientDelegate>) delegate
{
  EvernoteHTTPClient *client = (EvernoteHTTPClient *)[outProtocol transport];
  delegate_ = delegate;
  client.delegate = delegate;
  [client setTarget:self action:@selector(client:getNoteDidLoad:)];
  [self send_getNote: authenticationToken : guid : withContent : withResourcesData : withResourcesRecognition : withResourcesAlternateData];
}

/*!
 * recieve getNote result
 */
- (void) client:(EvernoteHTTPClient *)client getNoteDidLoad:(NSData *)result{
  EDAMNote *retval = [self recv_getNote];

  if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
    [delegate_ client:client didLoad:retval];
  }
}


/*!
 * send getNoteApplicationData request
 */
- (void) getNoteApplicationData: (NSString *) authenticationToken : (EDAMGuid) guid andDelegate:(id<EvernoteHTTPClientDelegate>) delegate
{
  EvernoteHTTPClient *client = (EvernoteHTTPClient *)[outProtocol transport];
  delegate_ = delegate;
  client.delegate = delegate;
  [client setTarget:self action:@selector(client:getNoteApplicationDataDidLoad:)];
  [self send_getNoteApplicationData: authenticationToken : guid];
}

/*!
 * recieve getNoteApplicationData result
 */
- (void) client:(EvernoteHTTPClient *)client getNoteApplicationDataDidLoad:(NSData *)result{
  EDAMLazyMap *retval = [self recv_getNoteApplicationData];

  if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
    [delegate_ client:client didLoad:retval];
  }
}


/*!
 * send getNoteApplicationDataEntry request
 */
- (void) getNoteApplicationDataEntry: (NSString *) authenticationToken : (EDAMGuid) guid : (NSString *) key andDelegate:(id<EvernoteHTTPClientDelegate>) delegate
{
  EvernoteHTTPClient *client = (EvernoteHTTPClient *)[outProtocol transport];
  delegate_ = delegate;
  client.delegate = delegate;
  [client setTarget:self action:@selector(client:getNoteApplicationDataEntryDidLoad:)];
  [self send_getNoteApplicationDataEntry: authenticationToken : guid : key];
}

/*!
 * recieve getNoteApplicationDataEntry result
 */
- (void) client:(EvernoteHTTPClient *)client getNoteApplicationDataEntryDidLoad:(NSData *)result{
  NSString *retval = [self recv_getNoteApplicationDataEntry];

  if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
    [delegate_ client:client didLoad:retval];
  }
}


/*!
 * send setNoteApplicationDataEntry request
 */
- (void) setNoteApplicationDataEntry: (NSString *) authenticationToken : (EDAMGuid) guid : (NSString *) key : (NSString *) value andDelegate:(id<EvernoteHTTPClientDelegate>) delegate
{
  EvernoteHTTPClient *client = (EvernoteHTTPClient *)[outProtocol transport];
  delegate_ = delegate;
  client.delegate = delegate;
  [client setTarget:self action:@selector(client:setNoteApplicationDataEntryDidLoad:)];
  [self send_setNoteApplicationDataEntry: authenticationToken : guid : key : value];
}

/*!
 * recieve setNoteApplicationDataEntry result
 */
- (void) client:(EvernoteHTTPClient *)client setNoteApplicationDataEntryDidLoad:(NSData *)result{
  int32_t rawResult = [self recv_setNoteApplicationDataEntry];
  NSNumber *retval = [NSNumber numberWithInt:rawResult];

  if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
    [delegate_ client:client didLoad:retval];
  }
}


/*!
 * send unsetNoteApplicationDataEntry request
 */
- (void) unsetNoteApplicationDataEntry: (NSString *) authenticationToken : (EDAMGuid) guid : (NSString *) key andDelegate:(id<EvernoteHTTPClientDelegate>) delegate
{
  EvernoteHTTPClient *client = (EvernoteHTTPClient *)[outProtocol transport];
  delegate_ = delegate;
  client.delegate = delegate;
  [client setTarget:self action:@selector(client:unsetNoteApplicationDataEntryDidLoad:)];
  [self send_unsetNoteApplicationDataEntry: authenticationToken : guid : key];
}

/*!
 * recieve unsetNoteApplicationDataEntry result
 */
- (void) client:(EvernoteHTTPClient *)client unsetNoteApplicationDataEntryDidLoad:(NSData *)result{
  int32_t rawResult = [self recv_unsetNoteApplicationDataEntry];
  NSNumber *retval = [NSNumber numberWithInt:rawResult];

  if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
    [delegate_ client:client didLoad:retval];
  }
}


/*!
 * send getNoteContent request
 */
- (void) getNoteContent: (NSString *) authenticationToken : (EDAMGuid) guid andDelegate:(id<EvernoteHTTPClientDelegate>) delegate
{
  EvernoteHTTPClient *client = (EvernoteHTTPClient *)[outProtocol transport];
  delegate_ = delegate;
  client.delegate = delegate;
  [client setTarget:self action:@selector(client:getNoteContentDidLoad:)];
  [self send_getNoteContent: authenticationToken : guid];
}

/*!
 * recieve getNoteContent result
 */
- (void) client:(EvernoteHTTPClient *)client getNoteContentDidLoad:(NSData *)result{
  NSString *retval = [self recv_getNoteContent];

  if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
    [delegate_ client:client didLoad:retval];
  }
}


/*!
 * send getNoteSearchText request
 */
- (void) getNoteSearchText: (NSString *) authenticationToken : (EDAMGuid) guid : (BOOL) noteOnly : (BOOL) tokenizeForIndexing andDelegate:(id<EvernoteHTTPClientDelegate>) delegate
{
  EvernoteHTTPClient *client = (EvernoteHTTPClient *)[outProtocol transport];
  delegate_ = delegate;
  client.delegate = delegate;
  [client setTarget:self action:@selector(client:getNoteSearchTextDidLoad:)];
  [self send_getNoteSearchText: authenticationToken : guid : noteOnly : tokenizeForIndexing];
}

/*!
 * recieve getNoteSearchText result
 */
- (void) client:(EvernoteHTTPClient *)client getNoteSearchTextDidLoad:(NSData *)result{
  NSString *retval = [self recv_getNoteSearchText];

  if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
    [delegate_ client:client didLoad:retval];
  }
}


/*!
 * send getResourceSearchText request
 */
- (void) getResourceSearchText: (NSString *) authenticationToken : (EDAMGuid) guid andDelegate:(id<EvernoteHTTPClientDelegate>) delegate
{
  EvernoteHTTPClient *client = (EvernoteHTTPClient *)[outProtocol transport];
  delegate_ = delegate;
  client.delegate = delegate;
  [client setTarget:self action:@selector(client:getResourceSearchTextDidLoad:)];
  [self send_getResourceSearchText: authenticationToken : guid];
}

/*!
 * recieve getResourceSearchText result
 */
- (void) client:(EvernoteHTTPClient *)client getResourceSearchTextDidLoad:(NSData *)result{
  NSString *retval = [self recv_getResourceSearchText];

  if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
    [delegate_ client:client didLoad:retval];
  }
}


/*!
 * send getNoteTagNames request
 */
- (void) getNoteTagNames: (NSString *) authenticationToken : (EDAMGuid) guid andDelegate:(id<EvernoteHTTPClientDelegate>) delegate
{
  EvernoteHTTPClient *client = (EvernoteHTTPClient *)[outProtocol transport];
  delegate_ = delegate;
  client.delegate = delegate;
  [client setTarget:self action:@selector(client:getNoteTagNamesDidLoad:)];
  [self send_getNoteTagNames: authenticationToken : guid];
}

/*!
 * recieve getNoteTagNames result
 */
- (void) client:(EvernoteHTTPClient *)client getNoteTagNamesDidLoad:(NSData *)result{
  NSMutableArray *retval = [self recv_getNoteTagNames];

  if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
    [delegate_ client:client didLoad:retval];
  }
}


/*!
 * send createNote request
 */
- (void) createNote: (NSString *) authenticationToken : (EDAMNote *) note andDelegate:(id<EvernoteHTTPClientDelegate>) delegate
{
  EvernoteHTTPClient *client = (EvernoteHTTPClient *)[outProtocol transport];
  delegate_ = delegate;
  client.delegate = delegate;
  [client setTarget:self action:@selector(client:createNoteDidLoad:)];
  [self send_createNote: authenticationToken : note];
}

/*!
 * recieve createNote result
 */
- (void) client:(EvernoteHTTPClient *)client createNoteDidLoad:(NSData *)result{
  EDAMNote *retval = [self recv_createNote];

  if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
    [delegate_ client:client didLoad:retval];
  }
}


/*!
 * send updateNote request
 */
- (void) updateNote: (NSString *) authenticationToken : (EDAMNote *) note andDelegate:(id<EvernoteHTTPClientDelegate>) delegate
{
  EvernoteHTTPClient *client = (EvernoteHTTPClient *)[outProtocol transport];
  delegate_ = delegate;
  client.delegate = delegate;
  [client setTarget:self action:@selector(client:updateNoteDidLoad:)];
  [self send_updateNote: authenticationToken : note];
}

/*!
 * recieve updateNote result
 */
- (void) client:(EvernoteHTTPClient *)client updateNoteDidLoad:(NSData *)result{
  EDAMNote *retval = [self recv_updateNote];

  if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
    [delegate_ client:client didLoad:retval];
  }
}


/*!
 * send deleteNote request
 */
- (void) deleteNote: (NSString *) authenticationToken : (EDAMGuid) guid andDelegate:(id<EvernoteHTTPClientDelegate>) delegate
{
  EvernoteHTTPClient *client = (EvernoteHTTPClient *)[outProtocol transport];
  delegate_ = delegate;
  client.delegate = delegate;
  [client setTarget:self action:@selector(client:deleteNoteDidLoad:)];
  [self send_deleteNote: authenticationToken : guid];
}

/*!
 * recieve deleteNote result
 */
- (void) client:(EvernoteHTTPClient *)client deleteNoteDidLoad:(NSData *)result{
  int32_t rawResult = [self recv_deleteNote];
  NSNumber *retval = [NSNumber numberWithInt:rawResult];

  if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
    [delegate_ client:client didLoad:retval];
  }
}


/*!
 * send expungeNote request
 */
- (void) expungeNote: (NSString *) authenticationToken : (EDAMGuid) guid andDelegate:(id<EvernoteHTTPClientDelegate>) delegate
{
  EvernoteHTTPClient *client = (EvernoteHTTPClient *)[outProtocol transport];
  delegate_ = delegate;
  client.delegate = delegate;
  [client setTarget:self action:@selector(client:expungeNoteDidLoad:)];
  [self send_expungeNote: authenticationToken : guid];
}

/*!
 * recieve expungeNote result
 */
- (void) client:(EvernoteHTTPClient *)client expungeNoteDidLoad:(NSData *)result{
  int32_t rawResult = [self recv_expungeNote];
  NSNumber *retval = [NSNumber numberWithInt:rawResult];

  if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
    [delegate_ client:client didLoad:retval];
  }
}


/*!
 * send expungeNotes request
 */
- (void) expungeNotes: (NSString *) authenticationToken : (NSMutableArray *) noteGuids andDelegate:(id<EvernoteHTTPClientDelegate>) delegate
{
  EvernoteHTTPClient *client = (EvernoteHTTPClient *)[outProtocol transport];
  delegate_ = delegate;
  client.delegate = delegate;
  [client setTarget:self action:@selector(client:expungeNotesDidLoad:)];
  [self send_expungeNotes: authenticationToken : noteGuids];
}

/*!
 * recieve expungeNotes result
 */
- (void) client:(EvernoteHTTPClient *)client expungeNotesDidLoad:(NSData *)result{
  int32_t rawResult = [self recv_expungeNotes];
  NSNumber *retval = [NSNumber numberWithInt:rawResult];

  if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
    [delegate_ client:client didLoad:retval];
  }
}


/*!
 * send expungeInactiveNotes request
 */
- (void) expungeInactiveNotes: (NSString *) authenticationToken andDelegate:(id<EvernoteHTTPClientDelegate>) delegate
{
  EvernoteHTTPClient *client = (EvernoteHTTPClient *)[outProtocol transport];
  delegate_ = delegate;
  client.delegate = delegate;
  [client setTarget:self action:@selector(client:expungeInactiveNotesDidLoad:)];
  [self send_expungeInactiveNotes: authenticationToken];
}

/*!
 * recieve expungeInactiveNotes result
 */
- (void) client:(EvernoteHTTPClient *)client expungeInactiveNotesDidLoad:(NSData *)result{
  int32_t rawResult = [self recv_expungeInactiveNotes];
  NSNumber *retval = [NSNumber numberWithInt:rawResult];

  if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
    [delegate_ client:client didLoad:retval];
  }
}


/*!
 * send copyNote request
 */
- (void) copyNote: (NSString *) authenticationToken : (EDAMGuid) noteGuid : (EDAMGuid) toNotebookGuid andDelegate:(id<EvernoteHTTPClientDelegate>) delegate
{
  EvernoteHTTPClient *client = (EvernoteHTTPClient *)[outProtocol transport];
  delegate_ = delegate;
  client.delegate = delegate;
  [client setTarget:self action:@selector(client:copyNoteDidLoad:)];
  [self send_copyNote: authenticationToken : noteGuid : toNotebookGuid];
}

/*!
 * recieve copyNote result
 */
- (void) client:(EvernoteHTTPClient *)client copyNoteDidLoad:(NSData *)result{
  EDAMNote *retval = [self recv_copyNote];

  if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
    [delegate_ client:client didLoad:retval];
  }
}


/*!
 * send listNoteVersions request
 */
- (void) listNoteVersions: (NSString *) authenticationToken : (EDAMGuid) noteGuid andDelegate:(id<EvernoteHTTPClientDelegate>) delegate
{
  EvernoteHTTPClient *client = (EvernoteHTTPClient *)[outProtocol transport];
  delegate_ = delegate;
  client.delegate = delegate;
  [client setTarget:self action:@selector(client:listNoteVersionsDidLoad:)];
  [self send_listNoteVersions: authenticationToken : noteGuid];
}

/*!
 * recieve listNoteVersions result
 */
- (void) client:(EvernoteHTTPClient *)client listNoteVersionsDidLoad:(NSData *)result{
  NSMutableArray *retval = [self recv_listNoteVersions];

  if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
    [delegate_ client:client didLoad:retval];
  }
}


/*!
 * send getNoteVersion request
 */
- (void) getNoteVersion: (NSString *) authenticationToken : (EDAMGuid) noteGuid : (int32_t) updateSequenceNum : (BOOL) withResourcesData : (BOOL) withResourcesRecognition : (BOOL) withResourcesAlternateData andDelegate:(id<EvernoteHTTPClientDelegate>) delegate
{
  EvernoteHTTPClient *client = (EvernoteHTTPClient *)[outProtocol transport];
  delegate_ = delegate;
  client.delegate = delegate;
  [client setTarget:self action:@selector(client:getNoteVersionDidLoad:)];
  [self send_getNoteVersion: authenticationToken : noteGuid : updateSequenceNum : withResourcesData : withResourcesRecognition : withResourcesAlternateData];
}

/*!
 * recieve getNoteVersion result
 */
- (void) client:(EvernoteHTTPClient *)client getNoteVersionDidLoad:(NSData *)result{
  EDAMNote *retval = [self recv_getNoteVersion];

  if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
    [delegate_ client:client didLoad:retval];
  }
}


/*!
 * send getResource request
 */
- (void) getResource: (NSString *) authenticationToken : (EDAMGuid) guid : (BOOL) withData : (BOOL) withRecognition : (BOOL) withAttributes : (BOOL) withAlternateData andDelegate:(id<EvernoteHTTPClientDelegate>) delegate
{
  EvernoteHTTPClient *client = (EvernoteHTTPClient *)[outProtocol transport];
  delegate_ = delegate;
  client.delegate = delegate;
  [client setTarget:self action:@selector(client:getResourceDidLoad:)];
  [self send_getResource: authenticationToken : guid : withData : withRecognition : withAttributes : withAlternateData];
}

/*!
 * recieve getResource result
 */
- (void) client:(EvernoteHTTPClient *)client getResourceDidLoad:(NSData *)result{
  EDAMResource *retval = [self recv_getResource];

  if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
    [delegate_ client:client didLoad:retval];
  }
}


/*!
 * send getResourceApplicationData request
 */
- (void) getResourceApplicationData: (NSString *) authenticationToken : (EDAMGuid) guid andDelegate:(id<EvernoteHTTPClientDelegate>) delegate
{
  EvernoteHTTPClient *client = (EvernoteHTTPClient *)[outProtocol transport];
  delegate_ = delegate;
  client.delegate = delegate;
  [client setTarget:self action:@selector(client:getResourceApplicationDataDidLoad:)];
  [self send_getResourceApplicationData: authenticationToken : guid];
}

/*!
 * recieve getResourceApplicationData result
 */
- (void) client:(EvernoteHTTPClient *)client getResourceApplicationDataDidLoad:(NSData *)result{
  EDAMLazyMap *retval = [self recv_getResourceApplicationData];

  if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
    [delegate_ client:client didLoad:retval];
  }
}


/*!
 * send getResourceApplicationDataEntry request
 */
- (void) getResourceApplicationDataEntry: (NSString *) authenticationToken : (EDAMGuid) guid : (NSString *) key andDelegate:(id<EvernoteHTTPClientDelegate>) delegate
{
  EvernoteHTTPClient *client = (EvernoteHTTPClient *)[outProtocol transport];
  delegate_ = delegate;
  client.delegate = delegate;
  [client setTarget:self action:@selector(client:getResourceApplicationDataEntryDidLoad:)];
  [self send_getResourceApplicationDataEntry: authenticationToken : guid : key];
}

/*!
 * recieve getResourceApplicationDataEntry result
 */
- (void) client:(EvernoteHTTPClient *)client getResourceApplicationDataEntryDidLoad:(NSData *)result{
  NSString *retval = [self recv_getResourceApplicationDataEntry];

  if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
    [delegate_ client:client didLoad:retval];
  }
}


/*!
 * send setResourceApplicationDataEntry request
 */
- (void) setResourceApplicationDataEntry: (NSString *) authenticationToken : (EDAMGuid) guid : (NSString *) key : (NSString *) value andDelegate:(id<EvernoteHTTPClientDelegate>) delegate
{
  EvernoteHTTPClient *client = (EvernoteHTTPClient *)[outProtocol transport];
  delegate_ = delegate;
  client.delegate = delegate;
  [client setTarget:self action:@selector(client:setResourceApplicationDataEntryDidLoad:)];
  [self send_setResourceApplicationDataEntry: authenticationToken : guid : key : value];
}

/*!
 * recieve setResourceApplicationDataEntry result
 */
- (void) client:(EvernoteHTTPClient *)client setResourceApplicationDataEntryDidLoad:(NSData *)result{
  int32_t rawResult = [self recv_setResourceApplicationDataEntry];
  NSNumber *retval = [NSNumber numberWithInt:rawResult];

  if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
    [delegate_ client:client didLoad:retval];
  }
}


/*!
 * send unsetResourceApplicationDataEntry request
 */
- (void) unsetResourceApplicationDataEntry: (NSString *) authenticationToken : (EDAMGuid) guid : (NSString *) key andDelegate:(id<EvernoteHTTPClientDelegate>) delegate
{
  EvernoteHTTPClient *client = (EvernoteHTTPClient *)[outProtocol transport];
  delegate_ = delegate;
  client.delegate = delegate;
  [client setTarget:self action:@selector(client:unsetResourceApplicationDataEntryDidLoad:)];
  [self send_unsetResourceApplicationDataEntry: authenticationToken : guid : key];
}

/*!
 * recieve unsetResourceApplicationDataEntry result
 */
- (void) client:(EvernoteHTTPClient *)client unsetResourceApplicationDataEntryDidLoad:(NSData *)result{
  int32_t rawResult = [self recv_unsetResourceApplicationDataEntry];
  NSNumber *retval = [NSNumber numberWithInt:rawResult];

  if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
    [delegate_ client:client didLoad:retval];
  }
}


/*!
 * send updateResource request
 */
- (void) updateResource: (NSString *) authenticationToken : (EDAMResource *) resource andDelegate:(id<EvernoteHTTPClientDelegate>) delegate
{
  EvernoteHTTPClient *client = (EvernoteHTTPClient *)[outProtocol transport];
  delegate_ = delegate;
  client.delegate = delegate;
  [client setTarget:self action:@selector(client:updateResourceDidLoad:)];
  [self send_updateResource: authenticationToken : resource];
}

/*!
 * recieve updateResource result
 */
- (void) client:(EvernoteHTTPClient *)client updateResourceDidLoad:(NSData *)result{
  int32_t rawResult = [self recv_updateResource];
  NSNumber *retval = [NSNumber numberWithInt:rawResult];

  if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
    [delegate_ client:client didLoad:retval];
  }
}


/*!
 * send getResourceData request
 */
- (void) getResourceData: (NSString *) authenticationToken : (EDAMGuid) guid andDelegate:(id<EvernoteHTTPClientDelegate>) delegate
{
  EvernoteHTTPClient *client = (EvernoteHTTPClient *)[outProtocol transport];
  delegate_ = delegate;
  client.delegate = delegate;
  [client setTarget:self action:@selector(client:getResourceDataDidLoad:)];
  [self send_getResourceData: authenticationToken : guid];
}

/*!
 * recieve getResourceData result
 */
- (void) client:(EvernoteHTTPClient *)client getResourceDataDidLoad:(NSData *)result{
  NSData *retval = [self recv_getResourceData];

  if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
    [delegate_ client:client didLoad:retval];
  }
}


/*!
 * send getResourceByHash request
 */
- (void) getResourceByHash: (NSString *) authenticationToken : (EDAMGuid) noteGuid : (NSData *) contentHash : (BOOL) withData : (BOOL) withRecognition : (BOOL) withAlternateData andDelegate:(id<EvernoteHTTPClientDelegate>) delegate
{
  EvernoteHTTPClient *client = (EvernoteHTTPClient *)[outProtocol transport];
  delegate_ = delegate;
  client.delegate = delegate;
  [client setTarget:self action:@selector(client:getResourceByHashDidLoad:)];
  [self send_getResourceByHash: authenticationToken : noteGuid : contentHash : withData : withRecognition : withAlternateData];
}

/*!
 * recieve getResourceByHash result
 */
- (void) client:(EvernoteHTTPClient *)client getResourceByHashDidLoad:(NSData *)result{
  EDAMResource *retval = [self recv_getResourceByHash];

  if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
    [delegate_ client:client didLoad:retval];
  }
}


/*!
 * send getResourceRecognition request
 */
- (void) getResourceRecognition: (NSString *) authenticationToken : (EDAMGuid) guid andDelegate:(id<EvernoteHTTPClientDelegate>) delegate
{
  EvernoteHTTPClient *client = (EvernoteHTTPClient *)[outProtocol transport];
  delegate_ = delegate;
  client.delegate = delegate;
  [client setTarget:self action:@selector(client:getResourceRecognitionDidLoad:)];
  [self send_getResourceRecognition: authenticationToken : guid];
}

/*!
 * recieve getResourceRecognition result
 */
- (void) client:(EvernoteHTTPClient *)client getResourceRecognitionDidLoad:(NSData *)result{
  NSData *retval = [self recv_getResourceRecognition];

  if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
    [delegate_ client:client didLoad:retval];
  }
}


/*!
 * send getResourceAlternateData request
 */
- (void) getResourceAlternateData: (NSString *) authenticationToken : (EDAMGuid) guid andDelegate:(id<EvernoteHTTPClientDelegate>) delegate
{
  EvernoteHTTPClient *client = (EvernoteHTTPClient *)[outProtocol transport];
  delegate_ = delegate;
  client.delegate = delegate;
  [client setTarget:self action:@selector(client:getResourceAlternateDataDidLoad:)];
  [self send_getResourceAlternateData: authenticationToken : guid];
}

/*!
 * recieve getResourceAlternateData result
 */
- (void) client:(EvernoteHTTPClient *)client getResourceAlternateDataDidLoad:(NSData *)result{
  NSData *retval = [self recv_getResourceAlternateData];

  if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
    [delegate_ client:client didLoad:retval];
  }
}


/*!
 * send getResourceAttributes request
 */
- (void) getResourceAttributes: (NSString *) authenticationToken : (EDAMGuid) guid andDelegate:(id<EvernoteHTTPClientDelegate>) delegate
{
  EvernoteHTTPClient *client = (EvernoteHTTPClient *)[outProtocol transport];
  delegate_ = delegate;
  client.delegate = delegate;
  [client setTarget:self action:@selector(client:getResourceAttributesDidLoad:)];
  [self send_getResourceAttributes: authenticationToken : guid];
}

/*!
 * recieve getResourceAttributes result
 */
- (void) client:(EvernoteHTTPClient *)client getResourceAttributesDidLoad:(NSData *)result{
  EDAMResourceAttributes *retval = [self recv_getResourceAttributes];

  if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
    [delegate_ client:client didLoad:retval];
  }
}


/*!
 * send getAccountSize request
 */
- (void) getAccountSize: (NSString *) authenticationToken andDelegate:(id<EvernoteHTTPClientDelegate>) delegate
{
  EvernoteHTTPClient *client = (EvernoteHTTPClient *)[outProtocol transport];
  delegate_ = delegate;
  client.delegate = delegate;
  [client setTarget:self action:@selector(client:getAccountSizeDidLoad:)];
  [self send_getAccountSize: authenticationToken];
}

/*!
 * recieve getAccountSize result
 */
- (void) client:(EvernoteHTTPClient *)client getAccountSizeDidLoad:(NSData *)result{
  int64_t rawRetval = [self recv_getAccountSize];
  NSNumber *retval = [NSNumber numberWithLong:rawRetval];

  if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
    [delegate_ client:client didLoad:retval];
  }
}


/*!
 * send getAds request
 */
- (void) getAds: (NSString *) authenticationToken : (EDAMAdParameters *) adParameters andDelegate:(id<EvernoteHTTPClientDelegate>) delegate
{
  EvernoteHTTPClient *client = (EvernoteHTTPClient *)[outProtocol transport];
  delegate_ = delegate;
  client.delegate = delegate;
  [client setTarget:self action:@selector(client:getAdsDidLoad:)];
  [self send_getAds: authenticationToken : adParameters];
}

/*!
 * recieve getAds result
 */
- (void) client:(EvernoteHTTPClient *)client getAdsDidLoad:(NSData *)result{
  NSMutableArray *retval = [self recv_getAds];

  if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
    [delegate_ client:client didLoad:retval];
  }
}


/*!
 * send getRandomAd request
 */
- (void) getRandomAd: (NSString *) authenticationToken : (EDAMAdParameters *) adParameters andDelegate:(id<EvernoteHTTPClientDelegate>) delegate
{
  EvernoteHTTPClient *client = (EvernoteHTTPClient *)[outProtocol transport];
  delegate_ = delegate;
  client.delegate = delegate;
  [client setTarget:self action:@selector(client:getRandomAdDidLoad:)];
  [self send_getRandomAd: authenticationToken : adParameters];
}

/*!
 * recieve getRandomAd result
 */
- (void) client:(EvernoteHTTPClient *)client getRandomAdDidLoad:(NSData *)result{
  EDAMAd *retval = [self recv_getRandomAd];

  if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
    [delegate_ client:client didLoad:retval];
  }
}


/*!
 * send getPublicNotebook request
 */
- (void) getPublicNotebook: (EDAMUserID) userId : (NSString *) publicUri andDelegate:(id<EvernoteHTTPClientDelegate>) delegate
{
  EvernoteHTTPClient *client = (EvernoteHTTPClient *)[outProtocol transport];
  delegate_ = delegate;
  client.delegate = delegate;
  [client setTarget:self action:@selector(client:getPublicNotebookDidLoad:)];
  [self send_getPublicNotebook: userId : publicUri];
}

/*!
 * recieve getPublicNotebook result
 */
- (void) client:(EvernoteHTTPClient *)client getPublicNotebookDidLoad:(NSData *)result{
  EDAMNotebook *retval = [self recv_getPublicNotebook];

  if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
    [delegate_ client:client didLoad:retval];
  }
}


/*!
 * send createSharedNotebook request
 */
- (void) createSharedNotebook: (NSString *) authenticationToken : (EDAMSharedNotebook *) sharedNotebook andDelegate:(id<EvernoteHTTPClientDelegate>) delegate
{
  EvernoteHTTPClient *client = (EvernoteHTTPClient *)[outProtocol transport];
  delegate_ = delegate;
  client.delegate = delegate;
  [client setTarget:self action:@selector(client:createSharedNotebookDidLoad:)];
  [self send_createSharedNotebook: authenticationToken : sharedNotebook];
}

/*!
 * recieve createSharedNotebook result
 */
- (void) client:(EvernoteHTTPClient *)client createSharedNotebookDidLoad:(NSData *)result{
  EDAMSharedNotebook *retval = [self recv_createSharedNotebook];

  if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
    [delegate_ client:client didLoad:retval];
  }
}


/*!
 * send sendMessageToSharedNotebookMembers request
 */
- (void) sendMessageToSharedNotebookMembers: (NSString *) authenticationToken : (EDAMGuid) notebookGuid : (NSString *) messageText : (NSMutableArray *) recipients andDelegate:(id<EvernoteHTTPClientDelegate>) delegate
{
  EvernoteHTTPClient *client = (EvernoteHTTPClient *)[outProtocol transport];
  delegate_ = delegate;
  client.delegate = delegate;
  [client setTarget:self action:@selector(client:sendMessageToSharedNotebookMembersDidLoad:)];
  [self send_sendMessageToSharedNotebookMembers: authenticationToken : notebookGuid : messageText : recipients];
}

/*!
 * recieve sendMessageToSharedNotebookMembers result
 */
- (void) client:(EvernoteHTTPClient *)client sendMessageToSharedNotebookMembersDidLoad:(NSData *)result{
  int32_t rawResult = [self recv_sendMessageToSharedNotebookMembers];
  NSNumber *retval = [NSNumber numberWithInt:rawResult];

  if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
    [delegate_ client:client didLoad:retval];
  }
}


/*!
 * send listSharedNotebooks request
 */
- (void) listSharedNotebooks: (NSString *) authenticationToken andDelegate:(id<EvernoteHTTPClientDelegate>) delegate
{
  EvernoteHTTPClient *client = (EvernoteHTTPClient *)[outProtocol transport];
  delegate_ = delegate;
  client.delegate = delegate;
  [client setTarget:self action:@selector(client:listSharedNotebooksDidLoad:)];
  [self send_listSharedNotebooks: authenticationToken];
}

/*!
 * recieve listSharedNotebooks result
 */
- (void) client:(EvernoteHTTPClient *)client listSharedNotebooksDidLoad:(NSData *)result{
  NSMutableArray *retval = [self recv_listSharedNotebooks];

  if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
    [delegate_ client:client didLoad:retval];
  }
}


/*!
 * send expungeSharedNotebooks request
 */
- (void) expungeSharedNotebooks: (NSString *) authenticationToken : (NSMutableArray *) sharedNotebookIds andDelegate:(id<EvernoteHTTPClientDelegate>) delegate
{
  EvernoteHTTPClient *client = (EvernoteHTTPClient *)[outProtocol transport];
  delegate_ = delegate;
  client.delegate = delegate;
  [client setTarget:self action:@selector(client:expungeSharedNotebooksDidLoad:)];
  [self send_expungeSharedNotebooks: authenticationToken : sharedNotebookIds];
}

/*!
 * recieve expungeSharedNotebooks result
 */
- (void) client:(EvernoteHTTPClient *)client expungeSharedNotebooksDidLoad:(NSData *)result{
  int32_t rawResult = [self recv_expungeSharedNotebooks];
  NSNumber *retval = [NSNumber numberWithInt:rawResult];

  if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
    [delegate_ client:client didLoad:retval];
  }
}


/*!
 * send createLinkedNotebook request
 */
- (void) createLinkedNotebook: (NSString *) authenticationToken : (EDAMLinkedNotebook *) linkedNotebook andDelegate:(id<EvernoteHTTPClientDelegate>) delegate
{
  EvernoteHTTPClient *client = (EvernoteHTTPClient *)[outProtocol transport];
  delegate_ = delegate;
  client.delegate = delegate;
  [client setTarget:self action:@selector(client:createLinkedNotebookDidLoad:)];
  [self send_createLinkedNotebook: authenticationToken : linkedNotebook];
}

/*!
 * recieve createLinkedNotebook result
 */
- (void) client:(EvernoteHTTPClient *)client createLinkedNotebookDidLoad:(NSData *)result{
  EDAMLinkedNotebook *retval = [self recv_createLinkedNotebook];

  if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
    [delegate_ client:client didLoad:retval];
  }
}


/*!
 * send updateLinkedNotebook request
 */
- (void) updateLinkedNotebook: (NSString *) authenticationToken : (EDAMLinkedNotebook *) linkedNotebook andDelegate:(id<EvernoteHTTPClientDelegate>) delegate
{
  EvernoteHTTPClient *client = (EvernoteHTTPClient *)[outProtocol transport];
  delegate_ = delegate;
  client.delegate = delegate;
  [client setTarget:self action:@selector(client:updateLinkedNotebookDidLoad:)];
  [self send_updateLinkedNotebook: authenticationToken : linkedNotebook];
}

/*!
 * recieve updateLinkedNotebook result
 */
- (void) client:(EvernoteHTTPClient *)client updateLinkedNotebookDidLoad:(NSData *)result{
  int32_t rawResult = [self recv_updateLinkedNotebook];
  NSNumber *retval = [NSNumber numberWithInt:rawResult];

  if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
    [delegate_ client:client didLoad:retval];
  }
}


/*!
 * send listLinkedNotebooks request
 */
- (void) listLinkedNotebooks: (NSString *) authenticationToken andDelegate:(id<EvernoteHTTPClientDelegate>) delegate
{
  EvernoteHTTPClient *client = (EvernoteHTTPClient *)[outProtocol transport];
  delegate_ = delegate;
  client.delegate = delegate;
  [client setTarget:self action:@selector(client:listLinkedNotebooksDidLoad:)];
  [self send_listLinkedNotebooks: authenticationToken];
}

/*!
 * recieve listLinkedNotebooks result
 */
- (void) client:(EvernoteHTTPClient *)client listLinkedNotebooksDidLoad:(NSData *)result{
  NSMutableArray *retval = [self recv_listLinkedNotebooks];

  if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
    [delegate_ client:client didLoad:retval];
  }
}


/*!
 * send expungeLinkedNotebook request
 */
- (void) expungeLinkedNotebook: (NSString *) authenticationToken : (EDAMGuid) guid andDelegate:(id<EvernoteHTTPClientDelegate>) delegate
{
  EvernoteHTTPClient *client = (EvernoteHTTPClient *)[outProtocol transport];
  delegate_ = delegate;
  client.delegate = delegate;
  [client setTarget:self action:@selector(client:expungeLinkedNotebookDidLoad:)];
  [self send_expungeLinkedNotebook: authenticationToken : guid];
}

/*!
 * recieve expungeLinkedNotebook result
 */
- (void) client:(EvernoteHTTPClient *)client expungeLinkedNotebookDidLoad:(NSData *)result{
  int32_t rawResult = [self recv_expungeLinkedNotebook];
  NSNumber *retval = [NSNumber numberWithInt:rawResult];

  if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
    [delegate_ client:client didLoad:retval];
  }
}


/*!
 * send authenticateToSharedNotebook request
 */
- (void) authenticateToSharedNotebook: (NSString *) shareKey : (NSString *) authenticationToken andDelegate:(id<EvernoteHTTPClientDelegate>) delegate
{
  EvernoteHTTPClient *client = (EvernoteHTTPClient *)[outProtocol transport];
  delegate_ = delegate;
  client.delegate = delegate;
  [client setTarget:self action:@selector(client:authenticateToSharedNotebookDidLoad:)];
  [self send_authenticateToSharedNotebook: shareKey : authenticationToken];
}

/*!
 * recieve authenticateToSharedNotebook result
 */
- (void) client:(EvernoteHTTPClient *)client authenticateToSharedNotebookDidLoad:(NSData *)result{
  EDAMAuthenticationResult *retval = [self recv_authenticateToSharedNotebook];

  if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
    [delegate_ client:client didLoad:retval];
  }
}


/*!
 * send getSharedNotebookByAuth request
 */
- (void) getSharedNotebookByAuth: (NSString *) authenticationToken andDelegate:(id<EvernoteHTTPClientDelegate>) delegate
{
  EvernoteHTTPClient *client = (EvernoteHTTPClient *)[outProtocol transport];
  delegate_ = delegate;
  client.delegate = delegate;
  [client setTarget:self action:@selector(client:getSharedNotebookByAuthDidLoad:)];
  [self send_getSharedNotebookByAuth: authenticationToken];
}

/*!
 * recieve getSharedNotebookByAuth result
 */
- (void) client:(EvernoteHTTPClient *)client getSharedNotebookByAuthDidLoad:(NSData *)result{
  EDAMSharedNotebook *retval = [self recv_getSharedNotebookByAuth];

  if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
    [delegate_ client:client didLoad:retval];
  }
}


/*!
 * send shareNote request
 */
- (void) shareNote: (NSString *) authenticationToken : (EDAMGuid) guid andDelegate:(id<EvernoteHTTPClientDelegate>) delegate
{
  EvernoteHTTPClient *client = (EvernoteHTTPClient *)[outProtocol transport];
  delegate_ = delegate;
  client.delegate = delegate;
  [client setTarget:self action:@selector(client:shareNoteDidLoad:)];
  [self send_shareNote: authenticationToken : guid];
}

/*!
 * recieve shareNote result
 */
- (void) client:(EvernoteHTTPClient *)client shareNoteDidLoad:(NSData *)result{
  NSString *retval = [self recv_shareNote];

  if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
    [delegate_ client:client didLoad:retval];
  }
}


/*!
 * send authenticateToSharedNote request
 */
- (void) authenticateToSharedNote: (NSString *) guid : (NSString *) noteKey andDelegate:(id<EvernoteHTTPClientDelegate>) delegate
{
  EvernoteHTTPClient *client = (EvernoteHTTPClient *)[outProtocol transport];
  delegate_ = delegate;
  client.delegate = delegate;
  [client setTarget:self action:@selector(client:authenticateToSharedNoteDidLoad:)];
  [self send_authenticateToSharedNote: guid : noteKey];
}

/*!
 * recieve authenticateToSharedNote result
 */
- (void) client:(EvernoteHTTPClient *)client authenticateToSharedNoteDidLoad:(NSData *)result{
  EDAMAuthenticationResult *retval = [self recv_authenticateToSharedNote];

  if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
    [delegate_ client:client didLoad:retval];
  }
}
@end
