/**
 * \file MixiWebViewController.h
 * \brief SDK用のウェブビューコントローラーを定義します。
 *
 * Created by Platform Service Department on 11/08/22.
 * Copyright 2011 mixi Inc. All rights reserved.
 */

#import <UIKit/UIKit.h>

@protocol MixiOrientationDelegate;

/**
 * \brief ウェブビューコントローラ
 *
 * 公式アプリダウンロード以外の用途は現在のところ想定していません。
 *
 * なお、デフォルトの設定ではデバイスが縦向きの場合にしか対応していません。
 * 横向きに対応するには次のようにしてください。
 * <pre><code>MixiWebViewController *viewController = [mixi buildViewControllerWithRequest:request delegate:mixiDelegate];
 * viewController.orietationDelegate = self;
 * </code></pre> 
 * ただし、上記はMixiOrientationDelegateプロトコルを実装し、横向きにも対応したビューコントローラー内で呼び出されているものと仮定しています。 
 */
@interface MixiWebViewController : UIViewController {
    /** \brief ツールバー */
    IBOutlet UIToolbar *toolbar_;
    
    /** \brief タイトル */
    NSString *toolbarTitle_;
    
    /** \brief ツールバーの色 */
    UIColor *toolbarColor_;

    /** \brief ツールバー上の閉じるボタン */
    IBOutlet UIBarButtonItem *closeButton_;
    
    /** \brief ツールバー上のタイトルラベル */
    IBOutlet UILabel *titleLabel_;

    /** \brief ウェブビュー */
    IBOutlet UIWebView *webView_;

    /** \brief ウェブビューで表示する画面のURL */
    NSURL *url_;
    
    /** \brief ウェブビューで表示するHTML */
    NSString *html_;

    /** \brief ウェブビュー内での閉じるボタン押下を処理するデリゲート */
    id<UIWebViewDelegate> delegate_;
    
    /** \brief デバイスの向きに同反応するかを処理するデリゲート */
    id<MixiOrientationDelegate> orietationDelegate_;
}

@property (nonatomic, retain) NSURL *url;
@property (nonatomic, assign) NSString *html;
@property (nonatomic, assign) id<UIWebViewDelegate> delegate;
@property (nonatomic, assign) id<MixiOrientationDelegate> orientationDelegate;
@property (nonatomic, copy) NSString *toolbarTitle;
@property (nonatomic, retain) UIColor *toolbarColor;

/**
 * \brief 閉じるボタンクリックを処理
 *
 * \param sender イベント発生元
 */
- (IBAction)close:(id)sender;

/**
 * \brief 初期化
 *
 * \param url URL
 * \return MixiWebViewControllerインスタンス
 */
- (id)initWithURL:(NSURL*)url;

/**
 * \brief 初期化
 *
 * \param url URL
 * \param delegate 閉じるボタン押下を処理するデリゲート
 * \return MixiWebViewControllerインスタンス
 */
- (id)initWithURL:(NSURL*)url delegate:(id<UIWebViewDelegate>)delegate;

/**
 * \brief 初期化
 *
 * \param html HTML
 * \param delegate 閉じるボタン押下を処理するデリゲート
 * \return MixiWebViewControllerインスタンス
 */
- (id)initWithHTML:(NSString*)html delegate:(id<UIWebViewDelegate>)delegate;

@end
