PhotoSubmitter
===========================
The purpose of the PhotoSubmitter class library is to facilitate the development of photo upload application.

There are a lot of Social Network Services and Cloud Storage Services. And each services have their own SDK to connect to their service. Unfortunately SDKs are not compatible each other.　Especially between Social Network Services and Cloud Storage Services is completely different. 

So, I developed PhotoSubmitter library as an abstraction layer for this situation.

The Code
------------------------------------------
PhotoSubmitter supports authentication like,

```
[[PhotoSubmitterManager submitterForType:PhotoSubmitterTypeFacebook] login];
```

This code will brings up Safari or Facebook app in your iPhone for authentication. You can receive messages from PhotoSubmitter while authenticating with implementing `PhotoSubmitterAuthenticationDelegate`. 

There are a lot of supported services, Facebook, Twitter, Dropbox and so on. You can enable submitter with just calling login method.

```
[[PhotoSubmitterManager submitterForType:PhotoSubmitterTypeDropbox] login];
[[PhotoSubmitterManager submitterForType:PhotoSubmitterTypeEvernote] login];
```

Once PhotoSubmitter is enabled and authenticated, you can submit photo to the service like this,

```
PhotoSubmitterImageEntity *photo = 
    [[PhotoSubmitterImageEntity alloc] initWithData:data];
[PhotoSubmitterManager submitPhoto:photo];
```

This code is creating photo entity and submitting photo to the authenticated services asynchronously. You can receive messages from PhotoSubmitter while submitting photo with implementing `PhotoSubmitterPhotoDelegate`.

Supported Services
-------------------------------------------
Below is the list of supported Social Network and Cloud Storage services.

<table>
<tr>
<th>Service Name</th>
<th>SDK</th>
<th>Auth Type</th>
<th>Requirement</th>
<th>Upload Type</th>
<th>Album Support</th>
</tr>
<tr>
<td>Facebook</td>
<td><a href="https://github.com/facebook/facebook-ios-sdk">Facebook SDK</a></td>
<td>OAuth (Safari/FacebookApp)</td>
<td>URLScheme: fb[appId]</td>
<td>Concurrent</td>
<td>YES</td>
</tr>
<tr>
<td>Twitter</td>
<td><a href="https://developer.apple.com/library/ios/#documentation/"Twitter/Reference/TwitterFrameworkReference/_index.html">Twitter.Framework</a></td>
<td>iOS</td>
<td>-</td>
<td>Sequencial</td>
<td>NO</td>
</tr>
<tr>
<td>Dropbox</td>
<td><a href="https://www.dropbox.com/developers/reference/sdk">Dropbox SDK</a></td>
<td>OAuth (Safari/DropboxApp)</td>
<td>URLScheme: db-[appId]</td>
<td>Concurrent</td>
<td>YES</td>
</tr>
<tr>
<td>Flickr</td>
<td><a href="https://github.com/lukhnos/objectiveflickr">ObjectiveFlickr</a></td>
<td>OAuth (Safari)</td>
<td>URLScheme: photosubmitter</td>
<td>Concurrent</td>
<td>YES</td>
</tr>
<tr>
<td>Evernote</td>
<td><a href="https://github.com/kent013/EVNConnect">EVNConnect</a></td>
<td>OAuth (Safari)</td>
<td>URLScheme: photosubmitter</td>
<td>Concurrent</td>
<td>YES</td>
</tr>
<tr>
<td>Picasa</td>
<td><a href="http://code.google.com/p/gdata-objectivec-client/">gdata-objectivec-client</a></td>
<td>OAuth (In App WebView)</td>
<td>PhotoSubmitterAuthControllerDelegate</td>
<td>Concurrent</td>
<td>YES</td>
</tr>
<tr>
<td>Minus</td>
<td><a href="https://github.com/kent013/MinusConnect">MinusConnect</a></td>
<td>OAuth (In App PasswordView)</td>
<td>PhotoSubmitterAuthControllerDelegate</td>
<td>Concurrent</td>
<td>YES</td>
</tr>
<tr>
<td>Mixi</td>
<td><a href="http://developer.mixi.co.jp/connect/mixi_graph_api/ios/">Mixi SDK</a></td>
<td>OAuth (In App WebView)</td>
<td>PhotoSubmitterAuthControllerDelegate</td>
<td>Concurrent</td>
<td>YES</td>
</tr>
<tr>
<td>Fotolife</td>
<td><a href="https://github.com/kent013/objc-atompub">objc-atompub</a></td>
<td>BASIC (In App PasswordView)</td>
<td>PhotoSubmitterAuthControllerDelegate</td>
<td>Concurrent</td>
<td>NO</td>
</tr>
<tr>
<td>File</td>
<td>-</td>
<td>-</td>
<td>-</td>
<td>-</td>
<td>NO</td>
</tr>
</table>

Custom URL schema setting is needed for Safari or App authentication. See [Implementing Custom URL Schemes](https://developer.apple.com/library/ios/#DOCUMENTATION/iPhone/Conceptual/iPhoneOSProgrammingGuide/AdvancedAppTricks/AdvancedAppTricks.html)
 and [Launching Your Own Application via a Custom URL Scheme](http://iphonedevelopertips.com/cocoa/launching-your-own-application-via-a-custom-url-scheme.html) for more information.

UINavigationController is needed to present built-in WebView and PasswordView. To provide UINavigationController to the PhotoSubmitter, you may implement `PhotoSubmitterAuthControllerDelegate`'s method `(UINavigationController *) requestNavigationControllerToPresentAuthenticationView` in your client code.

Implementing New PhotoSubmitter
---------------------------------------
Rules for new class interface decralation,

1. Name new class as [Hoge]PhotoSubmitter where Hoge is service name.
2. Extend `PhotoSubmitter`.
3. Implement `PhotoSubmitterInstanceProtocol`.
4. Add new `PhotoSubmitterType`.

Rules for new class implementation,

1. Call configuration method in initialize method.  
```
    [self setSubmitterIsConcurrent:YES 
                      isSequencial:NO 
                     usesOperation:YES 
                   requiresNetwork:YES 
                  isAlbumSupported:YES];
```
   * isConcurrent indicates photo upload process uses thread.
     * When the flag is `NO`, photo upload process will called in main thread. 
   * isSequencial indicates photo upload process uses `PhotoSubmitterSequencialOperationQueue`.
     * Flag for services not permit upload multiple photo at same time like Twitter.
   * usesOperation indicates use NSOperationQueue for upload process.
   * requireNetwork indicates the PhotoSubmitter needs network. 
   * isAlbumSupported indicates the PhotoSubmitter implements album methods.
2. Implement `PhotoSubmitterInstanceProtocol`
   * `-(void)onLogin` will call when `[PhotoSubmitterProtocol login]` is called.
     * Implement login process here.
     * When login process is done, usually in the delegate method like fbLogin, you must call `[PhotoSubmitter completeLogin]`.
     * If login process is failure, usually in the delegate method like fbNotLogin, you must call `[PhotoSubmitter completeLoginFail]`.
   * `-(void)onLogout` will call when `[PhotoSubmitterProtocol logout]` is called.
     * Implement logout process here.
     * When the logout process is finished(In the delegate method, if logout process is asynchronous), you must call `[PhotoSubmitter completeLogout]`.
     * If there are no specific logout process, you must call `[PhotoSubmitter completeLogout]` in `(void)onLogout`. This method clear credentials. 
   * `-(id)onSubmitPhoto:(PhotoSubmitterImageEntity *)photo andOperationDelegate:(id<PhotoSubmitterPhotoOperationDelegate>)delegate` will call when the `[PhotoSubmitter submitPhoto]` called.
     * Implement photo upload process here. 
     * Return value of the method may not be nil(nil means upload is not started), like FBRequest, NSURLConnection or some instance represents individual request. 
     * When the upload process is finished(In the delegate method, if upload process is asynchronous), you must call `[PhotoSubmitter completeSubmitPhoto:(id)request]`. Where request must be same object as Return value.
     * If the upload process is failed, you must call `[PhotoSubmitter completeSubmitPhoto:(id)request andError:(NSError *)error]`.
   * `-(id)onCancelPhoto:(PhotoSubmitterImageEntity *)photo` will call when the `[PhotoSubmitter cancel]` called.
     * Implement cancel photo upload process here. 
     * You can obtain request object calling `[self requestForPhotoHash:photo.photoHash]`.
     * Return value of the method may not be nil(nil means upload is not started), like FBRequest, NSURLConnection or some instance represents individual request. 
3. Override `PhotoSubmitter`'s method.
   * `-(PhotoSubmitterType)type`, return PhotoSubmitterType you declared.
   * `-(NSString *)name`, return your submitter's service name like `Dropbox`, `Facebook`
   * `-(BOOL)isSessionValid`, return your submitter's authentication is valid.

Fast way to implement new PhotoSubmitter, you may copy existing PhotoSubmitter's source code.
FacebookPhotoSubmitter is suitable for Safari or App authentication. If the service needed to present WebView, copy Mixi or Picasa. And If the service needed to present PasswordView, copy Minus or Fotolife.

