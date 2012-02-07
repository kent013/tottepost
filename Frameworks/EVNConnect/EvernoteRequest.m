//
//  EvernoteRequest.m
//  EVNConnect
//
//  Created by Kentaro ISHITOYA on 12/02/03.
//  Copyright (c) 2012 Kentaro ISHITOYA. All rights reserved.
//

#import "EvernoteRequest.h"
#import "Evernote.h"
#import "RegexKitLite.h"
#import "UIImage+Digest.h"
#import "NSData+Digest.h"
#import "DDXML.h"

//-----------------------------------------------------------------------------
//EDAMNoteStoreClient category for get http client
//-----------------------------------------------------------------------------
@interface EDAMNoteStoreClient(SetDelegate)
@property (nonatomic, readonly) EvernoteHTTPClient *httpClient;
@end
@implementation EDAMNoteStoreClient(SetDelegate)
/*!
 * get httpclient
 */
- (EvernoteHTTPClient *)httpClient{
    EvernoteHTTPClient *client = (EvernoteHTTPClient *)[outProtocol transport];
    return client;
}
@end

//-----------------------------------------------------------------------------
//Private Implementations
//-----------------------------------------------------------------------------
@interface EvernoteRequest(PrivateImplementation)
- (NSString *) clearTextToENMLString:(NSString *)text;
@end

@implementation EvernoteRequest(PrivateImplementation)
/*!
 * convert clear text to ENML
 */
- (NSString *)clearTextToENMLString:(NSString *)text{
    if(text == nil){
        text = @"";
    }
    text = [NSString stringWithFormat: @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<!DOCTYPE en-note SYSTEM \"http://xml.evernote.com/pub/enml2.dtd\">\n<en-note>%@</en-note>", text];
    return text;
}
@end

//-----------------------------------------------------------------------------
//Public Implementations
//-----------------------------------------------------------------------------
@implementation EvernoteRequest
@synthesize delegate;
@dynamic url;
@dynamic method;

/*!
 * initialize
 */
- (id)initWithAuthToken:(NSString *)authToken noteStoreClientFactory:(id<EvernoteNoteStoreClientFactoryDelegate>)noteStoreClientFactory delegate:(id<EvernoteRequestDelegate>)inDelegate andContextDelegate:(id<EvernoteContextDelegate>)contextDelegate{
    self = [super init];
    if(self){
        authToken_ = authToken;
        noteStoreClientFactory_ = noteStoreClientFactory;
        contextDelegate_ = contextDelegate;
        self.delegate = inDelegate;
        noteStoreClient_ = [noteStoreClientFactory_ createNoteStoreClientWithDelegate:self];
    }
    return self;
}

/*!
 * cancel operation
 */
-(void)abort{
    [noteStoreClient_.httpClient abort];
}

/*!
 * get url
 */
- (NSURL *)url{
    return noteStoreClient_.httpClient.url;
}

/*!
 * get method
 */
- (NSString *)method{
    return noteStoreClient_.httpClient.method;
}

#pragma mark - tags
/*!
 * list tags
 */
- (NSArray *)tags{
	if (noteStoreClient_ == nil) {
        return nil;
    }
    @try {
        NSArray *tags = [noteStoreClient_ listTags:authToken_];
        return [NSArray arrayWithArray:tags];
    }
    @catch (NSException *exception) {
        NSLog(@"main: Caught %@: %@", [exception name], [exception reason]);
        [contextDelegate_ request:self didFailWithException:exception];
    }
	return nil;
}

/*!
 * get tag for title
 */
- (EDAMNotebook *)tagNamed:(NSString *)name{
    NSString *pattern = [NSString stringWithFormat:@"^%@$", name];
    NSArray *tags = [self findTagsWithPattern:pattern];
    if(tags.count == 0){
        return nil;
    }
    return [tags objectAtIndex:0];
}

/*!
 * note book with pattern
 */
- (NSArray *)findTagsWithPattern:(NSString *)pattern{
    NSArray *tags = [self tags];
    NSMutableArray *foundTags = [[NSMutableArray alloc] init];
    for(EDAMNotebook *tag in tags){
        if(tag.nameIsSet && [tag.name isMatchedByRegex:pattern]){
            [foundTags addObject:tag];
        }
    }
    return foundTags;
}



/*!
 * create tag
 * when a same title tag is already exist, it throws exception.
 * so you might have check before creating it.
 */
- (EDAMTag*)createTagWithName:(NSString *)name{
	if (noteStoreClient_ == nil) {
        return nil;
    }
    @try {
        EDAMTag *tag = [[EDAMTag alloc] init];
        tag.name = name;
        return [noteStoreClient_ createTag: authToken_ :tag];
    }
    @catch (NSException *exception) {
        NSLog(@"main: Caught %@: %@", [exception name], [exception reason]);
        [contextDelegate_ request:self didFailWithException:exception];
    }
	return nil;
}

/*!
 * remove tag for name
 */
- (void)removeTagForName: (NSString *)tagName{
    EDAMTag *tag = [self tagNamed:tagName];
    if(tag == nil){
        return;
    }
    [self removeTag: tag];
}

/*!
 * rename tag
 */
- (EDAMTag *)renameTag:(EDAMTag *)tag toName:(NSString *)name{
	if (noteStoreClient_ == nil) {
        return tag;
    }
    @try {
        tag.name = name;
        [noteStoreClient_ updateTag:authToken_ :tag];
    }
    @catch (NSException *exception) {
        NSLog(@"main: Caught %@: %@", [exception name], [exception reason]);
        [contextDelegate_ request:self didFailWithException:exception];
    }    
    return tag;
}

/*!
 * remove tag
 */
- (void)removeTag:(EDAMTag *)tag{
	if (noteStoreClient_ == nil) {
        return;
    }
    @try {
        [noteStoreClient_ expungeTag:authToken_ :tag.guid];
    }
    @catch (NSException *exception) {
        NSLog(@"main: Caught %@: %@", [exception name], [exception reason]);
        [contextDelegate_ request:self didFailWithException:exception];
    }
}


#pragma mark - notebooks
/*!
 * list all notebooks
 */
- (NSArray*)notebooks {
	if (noteStoreClient_ == nil) {
        return nil;
    }
    @try {
        NSArray *notebooks = [noteStoreClient_ listNotebooks:authToken_];
        return [NSArray arrayWithArray:notebooks];
    }
    @catch (NSException *exception) {
        NSLog(@"main: Caught %@: %@", [exception name], [exception reason]);
        [contextDelegate_ request:self didFailWithException:exception];
    }
	return nil;
}

/*!
 * get notebook for title
 */
- (EDAMNotebook *)notebookNamed:(NSString *)title{
    NSString *pattern = [NSString stringWithFormat:@"^%@$", title];
    NSArray *notebooks = [self findNotebooksWithPattern:pattern];
    if(notebooks.count == 0){
        return nil;
    }
    return [notebooks objectAtIndex:0];
}

/*!
 * note book with pattern
 */
- (NSArray *)findNotebooksWithPattern:(NSString *)pattern{
    NSArray *notebooks = [self notebooks];
    NSMutableArray *foundNotebooks = [[NSMutableArray alloc] init];
    for(EDAMNotebook *notebook in notebooks){
        if(notebook.nameIsSet && [notebook.name isMatchedByRegex:pattern]){
            [foundNotebooks addObject:notebook];
        }
    }
    return foundNotebooks;
}

/*!
 * get default notebook
 */
- (EDAMNotebook*)defaultNotebook {
	if (noteStoreClient_ == nil) {
        return nil;
    }    
    @try {
        return [noteStoreClient_ getDefaultNotebook:authToken_];
    }
    @catch (NSException *exception) {
        NSLog(@"main: Caught %@: %@", [exception name], [exception reason]);
        [contextDelegate_ request:self didFailWithException:exception];
    }
    return nil;
}

/*!
 * create notebook
 * when a same title notebook is already exist, it throws exception.
 * so you might have check before creating it.
 */
- (EDAMNotebook*)createNotebookWithTitle:(NSString *)title{
	if (noteStoreClient_ == nil) {
        return nil;
    }
    @try {
        EDAMNotebook *newNotebook = [[EDAMNotebook alloc] init];
        [newNotebook setName:title];
        return [noteStoreClient_ createNotebook:authToken_ :newNotebook];
    }
    @catch (NSException *exception) {
        NSLog(@"main: Caught %@: %@", [exception name], [exception reason]);
        [contextDelegate_ request:self didFailWithException:exception];
    }
	return nil;
}

#pragma mark - resource
/*!
 * create resource
 */
- (EDAMResource *) createResourceFromUIImage:(UIImage *)image{
    NSData * imageNSData = UIImageJPEGRepresentation(image, 1.0);
    return [self createResourceFromImageData:imageNSData andMime:@"image/jpeg"];
}

/*!
 * create resource from NSData
 */
- (EDAMResource *)createResourceFromImageData:(NSData *)imageNSData andMime:(NSString *)mime{
    NSString * hash = imageNSData.MD5DigestString;
    EDAMResource * imageResource = nil;
    
    EDAMData * imageData = [[EDAMData alloc] initWithBodyHash:[hash dataUsingEncoding: NSASCIIStringEncoding] size:[imageNSData length] body:imageNSData];
    EDAMResourceAttributes * imageAttributes = [[EDAMResourceAttributes alloc] init];    
    imageResource  = [[EDAMResource alloc]init];
    [imageResource setMime:mime];
    [imageResource setData:imageData];
    [imageResource setAttributes:imageAttributes];
    return imageResource;    
}

#pragma mark - notes
/*!
 * get notes in notebook
 */
- (EDAMNoteList *)notesForNotebook:(EDAMNotebook *)notebook{
    return [self notesForNotebookGUID:notebook.guid];
}

/*!
 * get notes in notebook
 */
-  (EDAMNoteList*)notesForNotebookGUID:(EDAMGuid)guid{
	if (noteStoreClient_ == nil) {
        return nil;
    }
    EDAMNoteList *notelist = nil;
	EDAMNoteFilter *filter = [[EDAMNoteFilter alloc] initWithOrder:NoteSortOrder_CREATED ascending:YES words:nil notebookGuid:guid tagGuids:nil timeZone:nil inactive:NO];	
    @try {
        notelist = [noteStoreClient_ findNotes:authToken_ :filter :0 :[EDAMLimitsConstants EDAM_USER_NOTES_MAX]];
    }
    @catch (NSException *exception) {
        NSLog(@"main: Caught %@: %@", [exception name], [exception reason]);
        [contextDelegate_ request:self didFailWithException:exception];
    }
	return notelist;
}

/*!
 * note for note guid
 */
- (EDAMNote*)noteForNoteGUID:(EDAMGuid)guid{
	if (noteStoreClient_ == nil) {
        return nil;
    }
    
    @try {
        return [noteStoreClient_ getNote:authToken_ :guid :YES :YES :YES :YES];
    }
    @catch (NSException *exception) {
        NSLog(@"main: Caught %@: %@", [exception name], [exception reason]);
        [contextDelegate_ request:self didFailWithException:exception];
    }
	return nil;
}

/*!
 * create note in notebook
 */
- (EDAMNote *)createNoteInNotebook:(EDAMNotebook *)notebook title:(NSString *)title andContent:(NSString *)content{
    return [self createNoteInNotebook:notebook title:title content:content tags:nil andResources:nil];
}

/*!
 * create note in notebook with tags
 */
- (EDAMNote*)createNoteInNotebook:(EDAMNotebook *)notebook title:(NSString *)title content:(NSString *)content andTags:(NSArray *)tags{
	return [self createNoteInNotebook:notebook title:title content:content tags:tags andResources:nil];
}

/*!
 * add(append at end of note) resource to note
 */
- (void)addResourceToNote:(EDAMNote *)note resource:(EDAMResource *)resource{
    NSString *content = note.content;
    
    NSError *error = nil;
    DDXMLDocument *document = [[DDXMLDocument alloc] initWithXMLString:content options:0 error:&error];
    
    DDXMLElement *element = [[DDXMLElement alloc] initWithName:@"en-media"];
    [element addAttribute:[DDXMLNode attributeWithName:@"type" stringValue:resource.mime]];
    [element addAttribute:[DDXMLNode attributeWithName:@"hash" stringValue:[[NSString alloc] initWithData:resource.data.bodyHash encoding:NSASCIIStringEncoding]]];
    [document.rootElement addChild:element];
    note.content = document.XMLString;
    if(note.resources == nil){
        note.resources = [[NSMutableArray alloc] init];
    }
    [note.resources addObject:resource];
}

/*!
 * create note in notebook with resource
 * @param target notebook
 * @param title of note
 * @param content of note
 * @param array of tag, can be EDAMTag or NSString
 * @param array of resource, each item must be instance of EDAMResource.
 */
- (EDAMNote*)createNoteInNotebook:(EDAMNotebook *)notebook title:(NSString *)title content:(NSString *)content tags:(NSArray *)tags andResources:(NSArray *)resources{
	if (noteStoreClient_ == nil) {
        return nil;
    }
    @try {
        if(title == nil){
            @throw [NSException exceptionWithName: @"IllegalArgument"
                                           reason: @"title is nil"
                                         userInfo: nil];
        }
        EDAMNote *newNote = [[EDAMNote alloc] init];
        [newNote setNotebookGuid:notebook.guid];
        [newNote setTitle:title];
        if(tags != nil){
            newNote.tagGuids = [[NSMutableArray alloc] init];
            newNote.tagNames = [[NSMutableArray alloc] init];
            for(id tag in tags){
                if([tag isKindOfClass:[EDAMTag class]]){
                    [newNote.tagGuids addObject:tag];
                }else if([tag isKindOfClass:[NSString class]]){
                    [newNote.tagNames addObject:tag];
                }
            }
        }
        
        if(resources != nil){
            for(id resource in resources){
                if([resource isKindOfClass:[EDAMResource class]] == NO){
                    @throw [NSException exceptionWithName: @"IllegalArgument"
                                                   reason: @"resource must be EDAMResource"
                                                 userInfo: nil];
                }
            }
        }
        
        if([content isMatchedByRegex:@"^<?xml"] == NO){
            newNote.content = [self clearTextToENMLString:content];
        }
        for(EDAMResource *resource in resources){
            [self addResourceToNote:newNote resource:resource];
        }
        
        [newNote setCreated:(long long)[[NSDate date] timeIntervalSince1970] * 1000];
        EDAMNote *createdNote = 
        [noteStoreClient_ createNote:authToken_ :newNote];
        createdNote.content = newNote.content;
        return createdNote;
    }
    @catch (NSException *exception) {
        NSLog(@"main: Caught %@: %@", [exception name], [exception reason]);
        [contextDelegate_ request:self didFailWithException:exception];
    }
	return nil;
}

/*!
 * update note
 */
-(void)updateNote:(EDAMNote *)note{
	if (noteStoreClient_ == nil) {
        return;
    }
    @try {
        [noteStoreClient_ updateNote:authToken_ :note];
    }
    @catch (NSException *exception) {
        NSLog(@"main: Caught %@: %@", [exception name], [exception reason]);
        [contextDelegate_ request:self didFailWithException:exception];
    }    
}

#pragma mark - Remove(expunge) note
/*!
 * remove note
 */
- (void)removeNoteForGUID:(EDAMGuid)guid{
	if (noteStoreClient_ == nil) {
        return;
    }
    @try {
        [noteStoreClient_ deleteNote:authToken_ :guid];
    }
    @catch (NSException *exception) {
        NSLog(@"main: Caught %@: %@", [exception name], [exception reason]);
        [contextDelegate_ request:self didFailWithException:exception];
    }
}

#pragma mark - EvernoteHTTPClientDelegate
/*!
 * client loading start
 */
- (void)clientLoading:(EvernoteHTTPClient *)client{
    if([self.delegate respondsToSelector:@selector(requestLoading:)]){
        [self.delegate requestLoading:self];
    }
}

/*!
 * did receive first response
 */
- (void)client:(EvernoteHTTPClient *)client didReceiveResponse:(NSURLResponse *)response{
    if([self.delegate respondsToSelector:@selector(request:didReceiveResponse:)]){
        [self.delegate request:self didReceiveResponse:response];
    }
}

/*!
 * progress
 */
- (void)client:(EvernoteHTTPClient *)client didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite{
    if([self.delegate respondsToSelector:@selector(request:didSendBodyData:totalBytesWritten:totalBytesExpectedToWrite:)]){
        [self.delegate request:self didSendBodyData:bytesWritten totalBytesWritten:totalBytesWritten totalBytesExpectedToWrite:totalBytesExpectedToWrite];
    }
}

/*!
 * client did faild with error
 */
- (void)client:(EvernoteHTTPClient *)client didFailWithError:(NSError *)error{
    if([self.delegate respondsToSelector:@selector(request:didFailWithError:)]){
        [self.delegate request:self didFailWithError:error];
    }    
}

/*!
 * did load
 */
- (void)client:(EvernoteHTTPClient *)client didLoad:(id)result{
    if([self.delegate respondsToSelector:@selector(request:didLoad:)]){
        [self.delegate request:self didLoad:result];
    }
}

/*!
 * did load raw response
 */
- (void)client:(EvernoteHTTPClient *)client didLoadRawResponse:(NSData *)data{
    if([self.delegate respondsToSelector:@selector(request:didLoadRawResponse:)]){
        [self.delegate request:self didLoadRawResponse:data];
    }
}
@end