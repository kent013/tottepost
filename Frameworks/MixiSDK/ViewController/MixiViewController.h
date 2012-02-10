/**
 * \file MixiViewController.h
 * \brief リクエストAPIなどの画面を伴うAPI用のクラスを定義します。
 *
 * Created by Platform Service Department on 11/07/27.
 * Copyright 2011 mixi Inc. All rights reserved.
 */

#import <UIKit/UIKit.h>
#import "MixiDelegate.h"

@class Mixi;
@class MixiRequest;
@protocol MixiOrientationDelegate;

/**
 * \brief リクエストAPIなどの画面を伴うAPI用のビューコントローラ
 *
 * 主な使用方法は次のようになります。
 * <pre><code>if ([mixi isAuthorized]) {
 *     NSString *message = ＠"こんにちはこんにちは";
 *     NSString *recipients = ＠"abcdefghijklm";
 *     NSString *url = ＠"http://mixi.jp/run_appli.pl?id=xxxxx";
 *     NSString *mobileUrl = ＠"http://ma.mixi.net/xxxxx/";
 *     NSString *image = ＠"http://profile.img.mixi.jp/photo/user/mlkjihgfedcba_12345678901.jpg,image/jpeg";
 *
 *     MixiRequest *request = [MixiRequest requestWithEndpoint:＠"/dialog/requests"
 *                                               paramsAndKeys:message, ＠"message",
 *                                                             recipients, ＠"recipients",
 *                                                             url, ＠"url",
 *                                                             mobileUrl, ＠"mobile_url",
 *                                                             image, ＠"image", 
 *                                                             nil];
 *     UIViewController *viewController = [mixi buildViewControllerWithRequest:request delegate:mixiDelegate];
 *     [self presentModalViewController:viewController animated:YES];
 * }
 * else {
 *     [mixi authorizeForPermission:＠"mixi_apps"];
 * }
 * </code></pre>
 *
 * なお、デフォルトの設定ではデバイスが縦向きの場合にしか対応していません。
 * 横向きに対応するには次のようにしてください。
 * <pre><code>MixiViewController *viewController = [mixi buildViewControllerWithRequest:request delegate:mixiDelegate];
 * viewController.orietationDelegate = self;
 * </code></pre> 
 * ただし、上記はMixiOrientationDelegateプロトコルを実装し、横向きにも対応したビューコントローラー内で呼び出されているものと仮定しています。
 */
@interface MixiViewController : UIViewController<MixiDelegate, UIWebViewDelegate> {
@private
    
    /** \brief mixiオブジェクト */
    Mixi *mixi_;
    
    /** \brief 処理するリクエスト */
    MixiRequest *request_;
    
    /** \brief リクエスト結果を処理するデリゲート */
    id<MixiDelegate> delegate_;
    
    /** \brief デバイスの向きに同反応するかを処理するデリゲート */
    id<MixiOrientationDelegate> orietationDelegate_;
    
    /** \brief リクエスト内容表示用WebView */
    IBOutlet UIWebView *webView_;

    /** \brief 閉じるボタン */
    IBOutlet UIBarButtonItem *closeButton_;
    
    /** \brief インジケーター */
    IBOutlet UIActivityIndicatorView *indicator_;
}

@property (nonatomic, retain) Mixi *mixi;
@property (nonatomic, retain) MixiRequest *request;
@property (nonatomic, assign) id<MixiDelegate> delegate;
@property (nonatomic, assign) id<MixiOrientationDelegate> orientationDelegate;

/**
 * \brief リクエストとデリゲートを受け取って初期化.
 *
 * \param request リクエスト
 * \param delegate デリゲート
 * \return MixiViewControllerインスタンス
 */
- (id)initWithMixi:(Mixi*)mixi request:(MixiRequest*)request delegate:(id<MixiDelegate>)delegate;

/**
 * \brief リクエスト処理結果を受け取るハンドラ
 *
 * \param url リクエスト処理結果。フラグメント部にJSON形式で結果が収められています。
 */
- (void)openURL:(NSURL*)url;

/**
 * \brief 画面を閉じる
 */
- (IBAction)close:(id)sender;

@end
