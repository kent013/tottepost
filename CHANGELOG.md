Change Log
===========

You can download each version of tottepost from [tags](https://github.com/kent013/tottepost/tags).


version 1.1.1 (2012-03-11)
------------------------------
**tottepost updates**

* Separated [PhotoSubmitter Library](https://github.com/kent013/PhotoSubmitter) and tottepost.
* Added support for iPad.
* Added support for debugging on simulator.
* Added UserVoice for FeedBack.
* Added "Rate this App" button in Feedback (#31)
* Added strings.txt for Localization to use twine.
* Improved UX of creating album (#30)
* Fixed bug that update timing of PhotoSubmitterSummary view (#27)

**PhotoSubmitter updates**

* Separated PhotoSubmitterAPIKey.h to individual APIKey file.
* Added SVProgressHUD to indicate progress of login.
* Added feature to auto enhance image quality.
* Fixed bug that Fotolife sometime returns authentication cache.
* Fixed bug that checkmarks remains after select albums.
* Fixed bug that Mixi login switch does not turn off when login canceled.
* Fixed bug that Minus will not accept photo with no album selected.
* Fixed bug that Mixi will not accept photo with no album selected.

version 1.1 (2012-02-23)
------------------------------
* Added services  
  Evernote / Picasa / Minus / Fotolife / Mixi (#7, #8, #16)
* Added feature to select album (#5)
* Added feature to create album in setting view.
* Disabled interface rotation
* Added feature to rotate buttons when device rotated (#4, #13)
* Added feature to Twitter to select account when multiple accounts configured (#1)
* Fixed bugs in resuming, canceling upload (#2, #3, #21)
* Fixed bugs in zooming (#6)
* Fixed bug in service indicator (#14)
* Fixed bug that comment field disappears when device rotated (#26)
* Improved comment interface (#9)
* Improved UX of first launch (#10)

version 1.0 (2012-02-05)
------------------------------
* Supported services  
Facebook / Twitter / Flickr / Dropbox
* Save local camera roll
* Toggle comment / no comment
* Toggle Geo location
* Upload in background
* Automatic resume
* Canceling upload