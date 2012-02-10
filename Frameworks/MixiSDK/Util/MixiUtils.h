/**
 * \file MixiUtils.h
 * \brief さまざまなユーティリティ関数を定義します。
 *
 * Created by Platform Service Department on 11/07/01.
 * Copyright 2011 mixi Inc. All rights reserved.
 */

#import <Foundation/Foundation.h>

@class MixiWebViewController;


/**
 * \brief 文字列をURIエンコード
 *
 * \param aString エンコードされる文字列
 * \return URIエンコードされた文字列
 */
NSString* MixiUtilEncodeURIComponent(NSString* aString);

/** 
 * \brief ネットワークが使用可能かどうかを確認
 *
 * \return ネットワークが使用可能かどうか 
 */
BOOL MixiUtilIsReachable();

/**
 * \brief 文字列がJSONかどうかを大雑把に確認
 *
 * 引数が {...} または [...] または (...) という形式の場合にJSON文字列とみなします。
 *
 * \return 文字列がJSONかどうか 
 */
BOOL MixiUtilIsJson(NSString *s);

/**
 * \brief アプリケーションの全URLスキームを取得
 *
 * \return アプリケーションの全URLスキーム
 */
NSArray* MixiUtilBundleURLSchemes();

/**
 * \brief 最初のアプリケーションURLスキームを取得
 *
 * \return 最初のアプリケーションURLスキーム
 */
NSString* MixiUtilFirstBundleURLScheme();

/**
 * \brief URLパラメータをパース
 *
 * http://example.com/#k1=v1&k2=v2 というurlを受け取ると {k1=v1, k2=v2} という内容を持つ辞書オブジェクトを返します。
 *
 * \param url パース対象のURL
 * \return パラメータの内容を持つ辞書
 */
NSDictionary* MixiUtilParseURLOptions(NSURL* url);

/**
 * \brief URLパラメータをパース
 *
 * セパレータを@"#"に設定して http://example.com/#k1=v1&k2=v2 というurlを受け取ると {k1=v1, k2=v2} という内容を持つ辞書オブジェクトを返します。
 *
 * \param url パース対象のURL
 * \param sep パース対象文字列のセパレータ
 * \return パラメータの内容を持つ辞書
 */
NSDictionary* MixiUtilParseURLOptionsByString(NSURL* url, NSString* sep);

/**
 * \brief URLパラメータをパース
 *
 * http://example.com/#k1=v1&k2=v2 という文字列を受け取ると {k1=v1, k2=v2} という内容を持つ辞書オブジェクトを返します。
 *
 * \param url パース対象のURL
 * \return パラメータの内容を持つ辞書
 */
NSDictionary* MixiUtilParseURLStringOptions(NSString* url);

/**
 * \brief URLパラメータをパース
 *
 * セパレータを@"#"に設定して http://example.com/#k1=v1&k2=v2 という文字列を受け取ると {k1=v1, k2=v2} という内容を持つ辞書オブジェクトを返します。
 *
 * \param url パース対象のURL文字列
 * \param sep パース対象文字列のセパレータ
 * \return パラメータの内容を持つ辞書
 */
NSDictionary* MixiUtilParseURLStringOptionsByString(NSString* url, NSString* sep);

/**
 * \brief エラーをAlertViewで表示
 *
 * \param error エラー
 */
void MixiUtilShowError(NSError* error);

/**
 * \brief エラーメッセージをAlertViewで表示
 *
 * \param errorMessage エラーメッセージ
 */
void MixiUtilShowErrorMessage(NSString* errorMessage);

/**
 * \brief メッセージをAlertViewで表示
 *
 * \param message メッセージ
 * \param title タイトル
 */
void MixiUtilShowMessageTitle(NSString* message, NSString* title);

/**
 * \brief 公式アプリダウンロード画面を作成
 *
 * \param target ダウンロード画面で閉じるボタンを押下された場合のターゲット
 * \param action ダウンロード画面で閉じるボタンを押下された場合のアクション
 * \return 公式アプリをダウンロードするための画面コントローラー
 */
MixiWebViewController* MixiUtilDownloadViewController(id target, SEL action);

/**
 * \brief リクエストAPI実行用ビューが開いていれば閉じます。
 *
 * エラー処理用デリゲートメソッド内で利用することを想定しています。
 */
void MixiUtilDissmissRequestViewIfNeeded();

/**
 * \brief モバイルSafariからリクエストID付きで呼び出された場合に、起動URLからリクエストIDを抽出
 *
 * \param url 起動URL
 * \return リクエストID
 */
NSString* MixiUtilGetRequestIdFromURL(NSURL* url);
