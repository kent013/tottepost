Simple Camera Application for iOS
=========================================

<img src="http://github.com/kent013/tottepost/raw/master/AppStore/screenshot1.png"
 alt="ScreenShot1" title="ScreenShot1" height = 240 /> 
<img src="http://github.com/kent013/tottepost/raw/master/AppStore/screenshot2_en.png"
 alt="ScreenShot2" title="ScreenShot2" height = 240 />
<img src="http://github.com/kent013/tottepost/raw/master/AppStore/screenshot3_en.png"
 alt="ScreenShot3" title="ScreenShot3" height = 240 >
<img src="http://github.com/kent013/tottepost/raw/master/AppStore/screenshot4_en.png"
 alt="ScreenShot4" title="ScreenShot4" height = 240 />
<img src="http://github.com/kent013/tottepost/raw/master/AppStore/screenshot5_en.png"
 alt="ScreenShot5" title="ScreenShot5" height = 240 />

[日本語](https://github.com/kent013/tottepost/blob/master/README.ja.md)

Camera application for iOS devices, focusing on simplicity, minimum operation to take photo/video and post it to social apps.

This application is not similar to Instagram or other kind of camera application that offer users to add effects to photo. These applications are very good when sharing nice looking photos, but often feel messy to select the effects if you want to share photos instantly.

Tottepost is focusing on simplicity, thus we will not provide effects, cropping or decorating photo functionality. We provide features to take photo and share the photo to social applications or cloud services in least one tap.


[KISS](http://en.wikipedia.org/wiki/KISS_principle).

<a href="http://itunes.apple.com/us/app/single-tap-to-share-photo/id498769617?mt=8&uo=4" target="itunes_store"><img src="http://r.mzstatic.com/images/web/linkmaker/badge_appstore-lrg.gif" alt="Single tap to share photo - tottepost - ISHITOYA Kentaro" style="border: 0;"/></a>

Feature List
------------------------------------
 * Upload photo to social applications and cloud services
   * Facebook / Twitter / Flickr / Dropbox / Evernote / Picasa / Minus / Mixi / Fotolife
 * Upload video to social applications and cloud services
   * Facebook / Flickr / Dropbox / Minus
 * Save photo/video to local camera roll
 * Toggle comment / no comment
 * Toggle Geo location
 * Auto enhance image quality
 * Background upload, Automatic resume
 * Selecting uploading target album, Creating album 


PhotoSubmitter Library
------------------------------------
PhotoSubmitter is a library specially developed for tottepost. It is an abstraction layer to submit photo to various web services.

Please visit [https://github.com/kent013/PhotoSubmitter](https://github.com/kent013/PhotoSubmitter) for more detail.


How to Build
------------------------------------
Since simulator not supported camera simulation, you cannot test taking photo on simulator. So if you want to test uploading photo, tap on camera button in tottepost running on simulator. It will upload test image to web services.

And, just after cloning tottepost repository, you must run commands below to init and update submodule.
```
git submodule init
git submodule update
```
After updated submodules, open the `tottepost.xcodeproj`, and you will see the project fail to build. Because `UserVoiceAPIKey.h` and `PhotoSubmitter/Services/[ServiceName]PhotoSubmitter/[ServiceName]APIKey.h` is missing. 

`UserVoiceAPIKey.h` is needed for UserVoiceSDK. Please copy `UserVoiceAPIKey-template.h` as UserVoiceAPIKey.h. If you don't want to test UserVoice's functionality, you don't need to fill out the API-Key and API-Secret.

`PhotoSubmitter/Services/[ServiceName]PhotoSubmitter/[ServiceName]APIKey.h` are files to define API-Keys and API-Secrets for each service. Please copy `PhotoSubmitter/Services/[ServiceName]PhotoSubmitter/[ServiceName]APIKey-template.h` as `PhotoSubmitter/Services/[ServiceName]PhotoSubmitter/[ServiceName]APIKey.h`. And fill out api-key and api-secret for services which you want to enable.

If you don't want to use all of the provided services, you could delete `PhotoSubmitter/Services/[ServiceName]PhotoSubmitter` from project to do so.


**Git Tips**
For contributors reminder, if you want to update submodule to latest revision, type next command.
```
git submodule foreach 'git checkout master; git pull'
```


Localization
------------------------------------
We currently support only japanese and english.
And we are using [twine](https://github.com/mobiata/twine) for generating Localizable.string.
If you want modify localization strings, you may install twine following instruction in twine's repository. After installing twine, you can generate localization files with /strings.sh`. 


Feedback
------------------------------------
If you have an opinion or discovered a bug, please submit an issue on Github. Or use [UserVoice](http://tottepost.uservoice.com/).

Authors
------------------------------------
 * ISHITOYA Kentaro [@kent013](http://twitter.com/kent013) mail:ishitoya at rio.ne.jp
 * WATANABE Ken [@ken4500](http://twitter.com/ken4500)

Redistribution
------------------------------------
If you planning to redistribute this application in Apple App Store, you must contact me via email before do so.

License
------------------------------------
Copyright (c) 2011, ISHITOYA Kentaro.  
Copyright (c) 2011, WATANABE Ken.  

New BSD License. See [LICENSE](https://github.com/kent013/tottepost/blob/master/LICENSE) file. 

Change Log
------------------------------------
Current Apple AppStore version is 1.1.
See [CHANGELOG](https://github.com/kent013/tottepost/blob/master/CHANGELOG.md).

3rd Party Libraries and Resources
------------------------------------
See [List of 3rd Party Libraries and Resources](https://github.com/kent013/tottepost/blob/master/3RDPARTY.md)