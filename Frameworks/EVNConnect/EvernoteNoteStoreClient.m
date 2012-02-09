//
//  EvernoteNoteStoreClient.m
//  Wrapper class of NoteStoreClient
//
//  Created by conv.php on 2012/02/09 21:05:08.
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
  @try{
    [self send_getSyncState: authenticationToken];
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
  }
}
/*!
 * recieve getSyncState result
 */
- (void) client:(EvernoteHTTPClient *)client getSyncStateDidLoad:(NSData *)result{
  @try{
    EDAMSyncState *retval = [self recv_getSyncState];

    if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
      [delegate_ client:client didLoad:retval];
    }
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
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
  @try{
    [self send_getSyncChunk: authenticationToken : afterUSN : maxEntries : fullSyncOnly];
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
  }
}
/*!
 * recieve getSyncChunk result
 */
- (void) client:(EvernoteHTTPClient *)client getSyncChunkDidLoad:(NSData *)result{
  @try{
    EDAMSyncChunk *retval = [self recv_getSyncChunk];

    if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
      [delegate_ client:client didLoad:retval];
    }
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
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
  @try{
    [self send_getFilteredSyncChunk: authenticationToken : afterUSN : maxEntries : filter];
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
  }
}
/*!
 * recieve getFilteredSyncChunk result
 */
- (void) client:(EvernoteHTTPClient *)client getFilteredSyncChunkDidLoad:(NSData *)result{
  @try{
    EDAMSyncChunk *retval = [self recv_getFilteredSyncChunk];

    if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
      [delegate_ client:client didLoad:retval];
    }
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
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
  @try{
    [self send_getLinkedNotebookSyncState: authenticationToken : linkedNotebook];
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
  }
}
/*!
 * recieve getLinkedNotebookSyncState result
 */
- (void) client:(EvernoteHTTPClient *)client getLinkedNotebookSyncStateDidLoad:(NSData *)result{
  @try{
    EDAMSyncState *retval = [self recv_getLinkedNotebookSyncState];

    if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
      [delegate_ client:client didLoad:retval];
    }
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
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
  @try{
    [self send_getLinkedNotebookSyncChunk: authenticationToken : linkedNotebook : afterUSN : maxEntries : fullSyncOnly];
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
  }
}
/*!
 * recieve getLinkedNotebookSyncChunk result
 */
- (void) client:(EvernoteHTTPClient *)client getLinkedNotebookSyncChunkDidLoad:(NSData *)result{
  @try{
    EDAMSyncChunk *retval = [self recv_getLinkedNotebookSyncChunk];

    if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
      [delegate_ client:client didLoad:retval];
    }
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
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
  @try{
    [self send_listNotebooks: authenticationToken];
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
  }
}
/*!
 * recieve listNotebooks result
 */
- (void) client:(EvernoteHTTPClient *)client listNotebooksDidLoad:(NSData *)result{
  @try{
    NSMutableArray *retval = [self recv_listNotebooks];

    if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
      [delegate_ client:client didLoad:retval];
    }
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
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
  @try{
    [self send_getNotebook: authenticationToken : guid];
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
  }
}
/*!
 * recieve getNotebook result
 */
- (void) client:(EvernoteHTTPClient *)client getNotebookDidLoad:(NSData *)result{
  @try{
    EDAMNotebook *retval = [self recv_getNotebook];

    if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
      [delegate_ client:client didLoad:retval];
    }
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
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
  @try{
    [self send_getDefaultNotebook: authenticationToken];
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
  }
}
/*!
 * recieve getDefaultNotebook result
 */
- (void) client:(EvernoteHTTPClient *)client getDefaultNotebookDidLoad:(NSData *)result{
  @try{
    EDAMNotebook *retval = [self recv_getDefaultNotebook];

    if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
      [delegate_ client:client didLoad:retval];
    }
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
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
  @try{
    [self send_createNotebook: authenticationToken : notebook];
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
  }
}
/*!
 * recieve createNotebook result
 */
- (void) client:(EvernoteHTTPClient *)client createNotebookDidLoad:(NSData *)result{
  @try{
    EDAMNotebook *retval = [self recv_createNotebook];

    if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
      [delegate_ client:client didLoad:retval];
    }
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
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
  @try{
    [self send_updateNotebook: authenticationToken : notebook];
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
  }
}
/*!
 * recieve updateNotebook result
 */
- (void) client:(EvernoteHTTPClient *)client updateNotebookDidLoad:(NSData *)result{
  @try{
    int32_t rawResult = [self recv_updateNotebook];
    NSNumber *retval = [NSNumber numberWithInt:rawResult];

    if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
      [delegate_ client:client didLoad:retval];
    }
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
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
  @try{
    [self send_expungeNotebook: authenticationToken : guid];
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
  }
}
/*!
 * recieve expungeNotebook result
 */
- (void) client:(EvernoteHTTPClient *)client expungeNotebookDidLoad:(NSData *)result{
  @try{
    int32_t rawResult = [self recv_expungeNotebook];
    NSNumber *retval = [NSNumber numberWithInt:rawResult];

    if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
      [delegate_ client:client didLoad:retval];
    }
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
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
  @try{
    [self send_listTags: authenticationToken];
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
  }
}
/*!
 * recieve listTags result
 */
- (void) client:(EvernoteHTTPClient *)client listTagsDidLoad:(NSData *)result{
  @try{
    NSMutableArray *retval = [self recv_listTags];

    if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
      [delegate_ client:client didLoad:retval];
    }
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
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
  @try{
    [self send_listTagsByNotebook: authenticationToken : notebookGuid];
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
  }
}
/*!
 * recieve listTagsByNotebook result
 */
- (void) client:(EvernoteHTTPClient *)client listTagsByNotebookDidLoad:(NSData *)result{
  @try{
    NSMutableArray *retval = [self recv_listTagsByNotebook];

    if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
      [delegate_ client:client didLoad:retval];
    }
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
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
  @try{
    [self send_getTag: authenticationToken : guid];
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
  }
}
/*!
 * recieve getTag result
 */
- (void) client:(EvernoteHTTPClient *)client getTagDidLoad:(NSData *)result{
  @try{
    EDAMTag *retval = [self recv_getTag];

    if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
      [delegate_ client:client didLoad:retval];
    }
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
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
  @try{
    [self send_createTag: authenticationToken : tag];
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
  }
}
/*!
 * recieve createTag result
 */
- (void) client:(EvernoteHTTPClient *)client createTagDidLoad:(NSData *)result{
  @try{
    EDAMTag *retval = [self recv_createTag];

    if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
      [delegate_ client:client didLoad:retval];
    }
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
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
  @try{
    [self send_updateTag: authenticationToken : tag];
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
  }
}
/*!
 * recieve updateTag result
 */
- (void) client:(EvernoteHTTPClient *)client updateTagDidLoad:(NSData *)result{
  @try{
    int32_t rawResult = [self recv_updateTag];
    NSNumber *retval = [NSNumber numberWithInt:rawResult];

    if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
      [delegate_ client:client didLoad:retval];
    }
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
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
  @try{
    [self send_expungeTag: authenticationToken : guid];
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
  }
}
/*!
 * recieve expungeTag result
 */
- (void) client:(EvernoteHTTPClient *)client expungeTagDidLoad:(NSData *)result{
  @try{
    int32_t rawResult = [self recv_expungeTag];
    NSNumber *retval = [NSNumber numberWithInt:rawResult];

    if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
      [delegate_ client:client didLoad:retval];
    }
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
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
  @try{
    [self send_listSearches: authenticationToken];
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
  }
}
/*!
 * recieve listSearches result
 */
- (void) client:(EvernoteHTTPClient *)client listSearchesDidLoad:(NSData *)result{
  @try{
    NSMutableArray *retval = [self recv_listSearches];

    if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
      [delegate_ client:client didLoad:retval];
    }
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
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
  @try{
    [self send_getSearch: authenticationToken : guid];
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
  }
}
/*!
 * recieve getSearch result
 */
- (void) client:(EvernoteHTTPClient *)client getSearchDidLoad:(NSData *)result{
  @try{
    EDAMSavedSearch *retval = [self recv_getSearch];

    if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
      [delegate_ client:client didLoad:retval];
    }
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
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
  @try{
    [self send_createSearch: authenticationToken : search];
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
  }
}
/*!
 * recieve createSearch result
 */
- (void) client:(EvernoteHTTPClient *)client createSearchDidLoad:(NSData *)result{
  @try{
    EDAMSavedSearch *retval = [self recv_createSearch];

    if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
      [delegate_ client:client didLoad:retval];
    }
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
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
  @try{
    [self send_updateSearch: authenticationToken : search];
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
  }
}
/*!
 * recieve updateSearch result
 */
- (void) client:(EvernoteHTTPClient *)client updateSearchDidLoad:(NSData *)result{
  @try{
    int32_t rawResult = [self recv_updateSearch];
    NSNumber *retval = [NSNumber numberWithInt:rawResult];

    if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
      [delegate_ client:client didLoad:retval];
    }
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
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
  @try{
    [self send_expungeSearch: authenticationToken : guid];
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
  }
}
/*!
 * recieve expungeSearch result
 */
- (void) client:(EvernoteHTTPClient *)client expungeSearchDidLoad:(NSData *)result{
  @try{
    int32_t rawResult = [self recv_expungeSearch];
    NSNumber *retval = [NSNumber numberWithInt:rawResult];

    if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
      [delegate_ client:client didLoad:retval];
    }
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
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
  @try{
    [self send_findNotes: authenticationToken : filter : offset : maxNotes];
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
  }
}
/*!
 * recieve findNotes result
 */
- (void) client:(EvernoteHTTPClient *)client findNotesDidLoad:(NSData *)result{
  @try{
    EDAMNoteList *retval = [self recv_findNotes];

    if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
      [delegate_ client:client didLoad:retval];
    }
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
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
  @try{
    [self send_findNoteOffset: authenticationToken : filter : guid];
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
  }
}
/*!
 * recieve findNoteOffset result
 */
- (void) client:(EvernoteHTTPClient *)client findNoteOffsetDidLoad:(NSData *)result{
  @try{
    int32_t rawResult = [self recv_findNoteOffset];
    NSNumber *retval = [NSNumber numberWithInt:rawResult];

    if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
      [delegate_ client:client didLoad:retval];
    }
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
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
  @try{
    [self send_findNotesMetadata: authenticationToken : filter : offset : maxNotes : resultSpec];
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
  }
}
/*!
 * recieve findNotesMetadata result
 */
- (void) client:(EvernoteHTTPClient *)client findNotesMetadataDidLoad:(NSData *)result{
  @try{
    EDAMNotesMetadataList *retval = [self recv_findNotesMetadata];

    if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
      [delegate_ client:client didLoad:retval];
    }
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
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
  @try{
    [self send_findNoteCounts: authenticationToken : filter : withTrash];
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
  }
}
/*!
 * recieve findNoteCounts result
 */
- (void) client:(EvernoteHTTPClient *)client findNoteCountsDidLoad:(NSData *)result{
  @try{
    EDAMNoteCollectionCounts *retval = [self recv_findNoteCounts];

    if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
      [delegate_ client:client didLoad:retval];
    }
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
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
  @try{
    [self send_getNote: authenticationToken : guid : withContent : withResourcesData : withResourcesRecognition : withResourcesAlternateData];
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
  }
}
/*!
 * recieve getNote result
 */
- (void) client:(EvernoteHTTPClient *)client getNoteDidLoad:(NSData *)result{
  @try{
    EDAMNote *retval = [self recv_getNote];

    if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
      [delegate_ client:client didLoad:retval];
    }
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
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
  @try{
    [self send_getNoteApplicationData: authenticationToken : guid];
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
  }
}
/*!
 * recieve getNoteApplicationData result
 */
- (void) client:(EvernoteHTTPClient *)client getNoteApplicationDataDidLoad:(NSData *)result{
  @try{
    EDAMLazyMap *retval = [self recv_getNoteApplicationData];

    if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
      [delegate_ client:client didLoad:retval];
    }
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
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
  @try{
    [self send_getNoteApplicationDataEntry: authenticationToken : guid : key];
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
  }
}
/*!
 * recieve getNoteApplicationDataEntry result
 */
- (void) client:(EvernoteHTTPClient *)client getNoteApplicationDataEntryDidLoad:(NSData *)result{
  @try{
    NSString *retval = [self recv_getNoteApplicationDataEntry];

    if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
      [delegate_ client:client didLoad:retval];
    }
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
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
  @try{
    [self send_setNoteApplicationDataEntry: authenticationToken : guid : key : value];
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
  }
}
/*!
 * recieve setNoteApplicationDataEntry result
 */
- (void) client:(EvernoteHTTPClient *)client setNoteApplicationDataEntryDidLoad:(NSData *)result{
  @try{
    int32_t rawResult = [self recv_setNoteApplicationDataEntry];
    NSNumber *retval = [NSNumber numberWithInt:rawResult];

    if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
      [delegate_ client:client didLoad:retval];
    }
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
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
  @try{
    [self send_unsetNoteApplicationDataEntry: authenticationToken : guid : key];
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
  }
}
/*!
 * recieve unsetNoteApplicationDataEntry result
 */
- (void) client:(EvernoteHTTPClient *)client unsetNoteApplicationDataEntryDidLoad:(NSData *)result{
  @try{
    int32_t rawResult = [self recv_unsetNoteApplicationDataEntry];
    NSNumber *retval = [NSNumber numberWithInt:rawResult];

    if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
      [delegate_ client:client didLoad:retval];
    }
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
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
  @try{
    [self send_getNoteContent: authenticationToken : guid];
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
  }
}
/*!
 * recieve getNoteContent result
 */
- (void) client:(EvernoteHTTPClient *)client getNoteContentDidLoad:(NSData *)result{
  @try{
    NSString *retval = [self recv_getNoteContent];

    if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
      [delegate_ client:client didLoad:retval];
    }
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
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
  @try{
    [self send_getNoteSearchText: authenticationToken : guid : noteOnly : tokenizeForIndexing];
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
  }
}
/*!
 * recieve getNoteSearchText result
 */
- (void) client:(EvernoteHTTPClient *)client getNoteSearchTextDidLoad:(NSData *)result{
  @try{
    NSString *retval = [self recv_getNoteSearchText];

    if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
      [delegate_ client:client didLoad:retval];
    }
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
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
  @try{
    [self send_getResourceSearchText: authenticationToken : guid];
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
  }
}
/*!
 * recieve getResourceSearchText result
 */
- (void) client:(EvernoteHTTPClient *)client getResourceSearchTextDidLoad:(NSData *)result{
  @try{
    NSString *retval = [self recv_getResourceSearchText];

    if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
      [delegate_ client:client didLoad:retval];
    }
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
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
  @try{
    [self send_getNoteTagNames: authenticationToken : guid];
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
  }
}
/*!
 * recieve getNoteTagNames result
 */
- (void) client:(EvernoteHTTPClient *)client getNoteTagNamesDidLoad:(NSData *)result{
  @try{
    NSMutableArray *retval = [self recv_getNoteTagNames];

    if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
      [delegate_ client:client didLoad:retval];
    }
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
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
  @try{
    [self send_createNote: authenticationToken : note];
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
  }
}
/*!
 * recieve createNote result
 */
- (void) client:(EvernoteHTTPClient *)client createNoteDidLoad:(NSData *)result{
  @try{
    EDAMNote *retval = [self recv_createNote];

    if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
      [delegate_ client:client didLoad:retval];
    }
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
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
  @try{
    [self send_updateNote: authenticationToken : note];
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
  }
}
/*!
 * recieve updateNote result
 */
- (void) client:(EvernoteHTTPClient *)client updateNoteDidLoad:(NSData *)result{
  @try{
    EDAMNote *retval = [self recv_updateNote];

    if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
      [delegate_ client:client didLoad:retval];
    }
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
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
  @try{
    [self send_deleteNote: authenticationToken : guid];
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
  }
}
/*!
 * recieve deleteNote result
 */
- (void) client:(EvernoteHTTPClient *)client deleteNoteDidLoad:(NSData *)result{
  @try{
    int32_t rawResult = [self recv_deleteNote];
    NSNumber *retval = [NSNumber numberWithInt:rawResult];

    if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
      [delegate_ client:client didLoad:retval];
    }
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
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
  @try{
    [self send_expungeNote: authenticationToken : guid];
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
  }
}
/*!
 * recieve expungeNote result
 */
- (void) client:(EvernoteHTTPClient *)client expungeNoteDidLoad:(NSData *)result{
  @try{
    int32_t rawResult = [self recv_expungeNote];
    NSNumber *retval = [NSNumber numberWithInt:rawResult];

    if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
      [delegate_ client:client didLoad:retval];
    }
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
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
  @try{
    [self send_expungeNotes: authenticationToken : noteGuids];
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
  }
}
/*!
 * recieve expungeNotes result
 */
- (void) client:(EvernoteHTTPClient *)client expungeNotesDidLoad:(NSData *)result{
  @try{
    int32_t rawResult = [self recv_expungeNotes];
    NSNumber *retval = [NSNumber numberWithInt:rawResult];

    if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
      [delegate_ client:client didLoad:retval];
    }
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
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
  @try{
    [self send_expungeInactiveNotes: authenticationToken];
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
  }
}
/*!
 * recieve expungeInactiveNotes result
 */
- (void) client:(EvernoteHTTPClient *)client expungeInactiveNotesDidLoad:(NSData *)result{
  @try{
    int32_t rawResult = [self recv_expungeInactiveNotes];
    NSNumber *retval = [NSNumber numberWithInt:rawResult];

    if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
      [delegate_ client:client didLoad:retval];
    }
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
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
  @try{
    [self send_copyNote: authenticationToken : noteGuid : toNotebookGuid];
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
  }
}
/*!
 * recieve copyNote result
 */
- (void) client:(EvernoteHTTPClient *)client copyNoteDidLoad:(NSData *)result{
  @try{
    EDAMNote *retval = [self recv_copyNote];

    if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
      [delegate_ client:client didLoad:retval];
    }
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
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
  @try{
    [self send_listNoteVersions: authenticationToken : noteGuid];
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
  }
}
/*!
 * recieve listNoteVersions result
 */
- (void) client:(EvernoteHTTPClient *)client listNoteVersionsDidLoad:(NSData *)result{
  @try{
    NSMutableArray *retval = [self recv_listNoteVersions];

    if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
      [delegate_ client:client didLoad:retval];
    }
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
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
  @try{
    [self send_getNoteVersion: authenticationToken : noteGuid : updateSequenceNum : withResourcesData : withResourcesRecognition : withResourcesAlternateData];
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
  }
}
/*!
 * recieve getNoteVersion result
 */
- (void) client:(EvernoteHTTPClient *)client getNoteVersionDidLoad:(NSData *)result{
  @try{
    EDAMNote *retval = [self recv_getNoteVersion];

    if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
      [delegate_ client:client didLoad:retval];
    }
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
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
  @try{
    [self send_getResource: authenticationToken : guid : withData : withRecognition : withAttributes : withAlternateData];
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
  }
}
/*!
 * recieve getResource result
 */
- (void) client:(EvernoteHTTPClient *)client getResourceDidLoad:(NSData *)result{
  @try{
    EDAMResource *retval = [self recv_getResource];

    if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
      [delegate_ client:client didLoad:retval];
    }
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
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
  @try{
    [self send_getResourceApplicationData: authenticationToken : guid];
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
  }
}
/*!
 * recieve getResourceApplicationData result
 */
- (void) client:(EvernoteHTTPClient *)client getResourceApplicationDataDidLoad:(NSData *)result{
  @try{
    EDAMLazyMap *retval = [self recv_getResourceApplicationData];

    if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
      [delegate_ client:client didLoad:retval];
    }
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
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
  @try{
    [self send_getResourceApplicationDataEntry: authenticationToken : guid : key];
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
  }
}
/*!
 * recieve getResourceApplicationDataEntry result
 */
- (void) client:(EvernoteHTTPClient *)client getResourceApplicationDataEntryDidLoad:(NSData *)result{
  @try{
    NSString *retval = [self recv_getResourceApplicationDataEntry];

    if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
      [delegate_ client:client didLoad:retval];
    }
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
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
  @try{
    [self send_setResourceApplicationDataEntry: authenticationToken : guid : key : value];
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
  }
}
/*!
 * recieve setResourceApplicationDataEntry result
 */
- (void) client:(EvernoteHTTPClient *)client setResourceApplicationDataEntryDidLoad:(NSData *)result{
  @try{
    int32_t rawResult = [self recv_setResourceApplicationDataEntry];
    NSNumber *retval = [NSNumber numberWithInt:rawResult];

    if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
      [delegate_ client:client didLoad:retval];
    }
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
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
  @try{
    [self send_unsetResourceApplicationDataEntry: authenticationToken : guid : key];
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
  }
}
/*!
 * recieve unsetResourceApplicationDataEntry result
 */
- (void) client:(EvernoteHTTPClient *)client unsetResourceApplicationDataEntryDidLoad:(NSData *)result{
  @try{
    int32_t rawResult = [self recv_unsetResourceApplicationDataEntry];
    NSNumber *retval = [NSNumber numberWithInt:rawResult];

    if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
      [delegate_ client:client didLoad:retval];
    }
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
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
  @try{
    [self send_updateResource: authenticationToken : resource];
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
  }
}
/*!
 * recieve updateResource result
 */
- (void) client:(EvernoteHTTPClient *)client updateResourceDidLoad:(NSData *)result{
  @try{
    int32_t rawResult = [self recv_updateResource];
    NSNumber *retval = [NSNumber numberWithInt:rawResult];

    if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
      [delegate_ client:client didLoad:retval];
    }
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
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
  @try{
    [self send_getResourceData: authenticationToken : guid];
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
  }
}
/*!
 * recieve getResourceData result
 */
- (void) client:(EvernoteHTTPClient *)client getResourceDataDidLoad:(NSData *)result{
  @try{
    NSData *retval = [self recv_getResourceData];

    if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
      [delegate_ client:client didLoad:retval];
    }
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
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
  @try{
    [self send_getResourceByHash: authenticationToken : noteGuid : contentHash : withData : withRecognition : withAlternateData];
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
  }
}
/*!
 * recieve getResourceByHash result
 */
- (void) client:(EvernoteHTTPClient *)client getResourceByHashDidLoad:(NSData *)result{
  @try{
    EDAMResource *retval = [self recv_getResourceByHash];

    if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
      [delegate_ client:client didLoad:retval];
    }
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
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
  @try{
    [self send_getResourceRecognition: authenticationToken : guid];
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
  }
}
/*!
 * recieve getResourceRecognition result
 */
- (void) client:(EvernoteHTTPClient *)client getResourceRecognitionDidLoad:(NSData *)result{
  @try{
    NSData *retval = [self recv_getResourceRecognition];

    if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
      [delegate_ client:client didLoad:retval];
    }
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
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
  @try{
    [self send_getResourceAlternateData: authenticationToken : guid];
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
  }
}
/*!
 * recieve getResourceAlternateData result
 */
- (void) client:(EvernoteHTTPClient *)client getResourceAlternateDataDidLoad:(NSData *)result{
  @try{
    NSData *retval = [self recv_getResourceAlternateData];

    if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
      [delegate_ client:client didLoad:retval];
    }
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
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
  @try{
    [self send_getResourceAttributes: authenticationToken : guid];
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
  }
}
/*!
 * recieve getResourceAttributes result
 */
- (void) client:(EvernoteHTTPClient *)client getResourceAttributesDidLoad:(NSData *)result{
  @try{
    EDAMResourceAttributes *retval = [self recv_getResourceAttributes];

    if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
      [delegate_ client:client didLoad:retval];
    }
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
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
  @try{
    [self send_getAccountSize: authenticationToken];
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
  }
}
/*!
 * recieve getAccountSize result
 */
- (void) client:(EvernoteHTTPClient *)client getAccountSizeDidLoad:(NSData *)result{
  @try{
    int64_t rawRetval = [self recv_getAccountSize];
    NSNumber *retval = [NSNumber numberWithLong:rawRetval];

    if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
      [delegate_ client:client didLoad:retval];
    }
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
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
  @try{
    [self send_getAds: authenticationToken : adParameters];
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
  }
}
/*!
 * recieve getAds result
 */
- (void) client:(EvernoteHTTPClient *)client getAdsDidLoad:(NSData *)result{
  @try{
    NSMutableArray *retval = [self recv_getAds];

    if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
      [delegate_ client:client didLoad:retval];
    }
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
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
  @try{
    [self send_getRandomAd: authenticationToken : adParameters];
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
  }
}
/*!
 * recieve getRandomAd result
 */
- (void) client:(EvernoteHTTPClient *)client getRandomAdDidLoad:(NSData *)result{
  @try{
    EDAMAd *retval = [self recv_getRandomAd];

    if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
      [delegate_ client:client didLoad:retval];
    }
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
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
  @try{
    [self send_getPublicNotebook: userId : publicUri];
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
  }
}
/*!
 * recieve getPublicNotebook result
 */
- (void) client:(EvernoteHTTPClient *)client getPublicNotebookDidLoad:(NSData *)result{
  @try{
    EDAMNotebook *retval = [self recv_getPublicNotebook];

    if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
      [delegate_ client:client didLoad:retval];
    }
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
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
  @try{
    [self send_createSharedNotebook: authenticationToken : sharedNotebook];
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
  }
}
/*!
 * recieve createSharedNotebook result
 */
- (void) client:(EvernoteHTTPClient *)client createSharedNotebookDidLoad:(NSData *)result{
  @try{
    EDAMSharedNotebook *retval = [self recv_createSharedNotebook];

    if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
      [delegate_ client:client didLoad:retval];
    }
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
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
  @try{
    [self send_sendMessageToSharedNotebookMembers: authenticationToken : notebookGuid : messageText : recipients];
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
  }
}
/*!
 * recieve sendMessageToSharedNotebookMembers result
 */
- (void) client:(EvernoteHTTPClient *)client sendMessageToSharedNotebookMembersDidLoad:(NSData *)result{
  @try{
    int32_t rawResult = [self recv_sendMessageToSharedNotebookMembers];
    NSNumber *retval = [NSNumber numberWithInt:rawResult];

    if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
      [delegate_ client:client didLoad:retval];
    }
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
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
  @try{
    [self send_listSharedNotebooks: authenticationToken];
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
  }
}
/*!
 * recieve listSharedNotebooks result
 */
- (void) client:(EvernoteHTTPClient *)client listSharedNotebooksDidLoad:(NSData *)result{
  @try{
    NSMutableArray *retval = [self recv_listSharedNotebooks];

    if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
      [delegate_ client:client didLoad:retval];
    }
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
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
  @try{
    [self send_expungeSharedNotebooks: authenticationToken : sharedNotebookIds];
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
  }
}
/*!
 * recieve expungeSharedNotebooks result
 */
- (void) client:(EvernoteHTTPClient *)client expungeSharedNotebooksDidLoad:(NSData *)result{
  @try{
    int32_t rawResult = [self recv_expungeSharedNotebooks];
    NSNumber *retval = [NSNumber numberWithInt:rawResult];

    if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
      [delegate_ client:client didLoad:retval];
    }
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
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
  @try{
    [self send_createLinkedNotebook: authenticationToken : linkedNotebook];
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
  }
}
/*!
 * recieve createLinkedNotebook result
 */
- (void) client:(EvernoteHTTPClient *)client createLinkedNotebookDidLoad:(NSData *)result{
  @try{
    EDAMLinkedNotebook *retval = [self recv_createLinkedNotebook];

    if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
      [delegate_ client:client didLoad:retval];
    }
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
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
  @try{
    [self send_updateLinkedNotebook: authenticationToken : linkedNotebook];
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
  }
}
/*!
 * recieve updateLinkedNotebook result
 */
- (void) client:(EvernoteHTTPClient *)client updateLinkedNotebookDidLoad:(NSData *)result{
  @try{
    int32_t rawResult = [self recv_updateLinkedNotebook];
    NSNumber *retval = [NSNumber numberWithInt:rawResult];

    if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
      [delegate_ client:client didLoad:retval];
    }
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
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
  @try{
    [self send_listLinkedNotebooks: authenticationToken];
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
  }
}
/*!
 * recieve listLinkedNotebooks result
 */
- (void) client:(EvernoteHTTPClient *)client listLinkedNotebooksDidLoad:(NSData *)result{
  @try{
    NSMutableArray *retval = [self recv_listLinkedNotebooks];

    if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
      [delegate_ client:client didLoad:retval];
    }
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
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
  @try{
    [self send_expungeLinkedNotebook: authenticationToken : guid];
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
  }
}
/*!
 * recieve expungeLinkedNotebook result
 */
- (void) client:(EvernoteHTTPClient *)client expungeLinkedNotebookDidLoad:(NSData *)result{
  @try{
    int32_t rawResult = [self recv_expungeLinkedNotebook];
    NSNumber *retval = [NSNumber numberWithInt:rawResult];

    if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
      [delegate_ client:client didLoad:retval];
    }
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
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
  @try{
    [self send_authenticateToSharedNotebook: shareKey : authenticationToken];
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
  }
}
/*!
 * recieve authenticateToSharedNotebook result
 */
- (void) client:(EvernoteHTTPClient *)client authenticateToSharedNotebookDidLoad:(NSData *)result{
  @try{
    EDAMAuthenticationResult *retval = [self recv_authenticateToSharedNotebook];

    if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
      [delegate_ client:client didLoad:retval];
    }
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
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
  @try{
    [self send_getSharedNotebookByAuth: authenticationToken];
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
  }
}
/*!
 * recieve getSharedNotebookByAuth result
 */
- (void) client:(EvernoteHTTPClient *)client getSharedNotebookByAuthDidLoad:(NSData *)result{
  @try{
    EDAMSharedNotebook *retval = [self recv_getSharedNotebookByAuth];

    if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
      [delegate_ client:client didLoad:retval];
    }
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
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
  @try{
    [self send_shareNote: authenticationToken : guid];
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
  }
}
/*!
 * recieve shareNote result
 */
- (void) client:(EvernoteHTTPClient *)client shareNoteDidLoad:(NSData *)result{
  @try{
    NSString *retval = [self recv_shareNote];

    if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
      [delegate_ client:client didLoad:retval];
    }
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
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
  @try{
    [self send_authenticateToSharedNote: guid : noteKey];
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
  }
}
/*!
 * recieve authenticateToSharedNote result
 */
- (void) client:(EvernoteHTTPClient *)client authenticateToSharedNoteDidLoad:(NSData *)result{
  @try{
    EDAMAuthenticationResult *retval = [self recv_authenticateToSharedNote];

    if([delegate_ respondsToSelector:@selector(client:didLoad:)]){
      [delegate_ client:client didLoad:retval];
    }
  }@catch(NSException *exception){
    if([delegate_ respondsToSelector:@selector(client:didFailWithException:)]){
      [delegate_ client:client didFailWithException:exception];
    }
  }
}
@end
