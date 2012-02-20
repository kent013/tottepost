/**
 * \file MixiDelegate.h
 * \brief API呼び出しの結果を受け取るデリゲートプロトコルを定義します。
 *
 * Created by Platform Service Department on 11/06/30.
 * Copyright 2011 mixi Inc. All rights reserved.
 */

#import <Foundation/Foundation.h>

@class Mixi;

/**
 * \brief mixi API実行結果処理用のデリゲート
 *
 * 本プロトコルで規定されるメッセージは全てオプショナルです。
 */
@protocol MixiDelegate <NSObject>

@optional

/**
 * \brief APIの実行が終了
 *
 * 通信に成功していればAPIの実行に失敗していても呼び出され、JSONを解釈する前の生のテキストを受け取ります。主にデバッグ時の利用を想定しています。
 *
 * \param mixi mixiオブジェクト
 * \param data 実行結果の生文字列
 */
- (void)mixi:(Mixi*)mixi didFinishLoading:(NSString*)data;

/**
 * \brief APIの実行に成功
 * 
 * \param mixi mixiオブジェクト
 * \param data 実行結果のJSONを解釈したオブジェクト
 */
- (void)mixi:(Mixi*)mixi didSuccessWithJson:(id)data;

/**
 * \brief APIの接続がキャンセル
 *
 * \param mixi mixiオブジェクト
 * \param connection キャンセルされた接続
 */
- (void)mixi:(Mixi*)mixi didCancelWithConnection:(NSURLConnection*)connection;

/**
 * \brief APIの接続に失敗
 *
 * \param mixi mixiオブジェクト
 * \param connection 失敗した接続
 * \param error エラー
 */
- (void)mixi:(Mixi*)mixi didFailWithConnection:(NSURLConnection*)connection error:(NSError*)error;

/**
 * \brief APIの実行に失敗
 *
 * \param mixi mixiオブジェクト
 * \param error エラー
 */
- (void)mixi:(Mixi*)mixi didFailWithError:(NSError*)error;


/**
 * \brief 空のレスポンスを許すかどうか
 *
 * 本メソッドの実行結果がYESのときはレスポンスが空でもエラーを返しません。
 * メソッドが定義されていない場合はNOとみなされます。
 * \return 空のレスポンスを許すかどうか
 */
- (BOOL)allowBlankResponse;

@end
