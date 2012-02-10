/**
 * \file MixiURLConnection.h
 * \brief API呼び出しの通信を処理するクラスを定義します。
 *
 * Created by Platform Service Department on 11/08/03.
 * Copyright 2011 mixi Inc. All rights reserved.
 */

#import <Foundation/Foundation.h>


/**
 * \brief NSURLConnectionが特殊なURLスキームへのリダイレクトを処理できないので代わりに使用するクラス
 */
@interface MixiURLConnection : NSObject {
@private
    
    /** \brief 処理を移譲するURLコネクション */
    NSURLConnection *connection_;
}

@property (nonatomic, retain) NSURLConnection *connection;

/**
 * \brief リダイレクトを自動的に処理するかどうか
 *
 * \param aBool リダイレクトを自動的に処理するかどうか
 */
+ (void)setAutoRedirect:(bool)aBool;

/**
 * \brief リクエストを処理できるかどうか。
 * 
 * 常にYES。
 *
 * \param request
 * \return リクエストを処理できるかどうか
 */
+ (BOOL)canHandleRequest:(NSURLRequest *)request;

/**
 * \brief 同期的にリクエストを送信
 *
 * \param request リクエスト
 * \param response レスポンス
 * \param error エラー
 * \return レスポンスボディ
 */
+ (NSData *)sendSynchronousRequest:(NSURLRequest *)request returningResponse:(NSURLResponse **)response error:(NSError **)error;

/**
 * \brief NSURLConnection#connectionWithRequest:delegate: に移譲
 *
 * \return URLコネクション
 */
+ (NSURLConnection *)connectionWithRequest:(NSURLRequest *)request delegate:(id)delegate;

/**
 * \brief NSURLConnection#initWithRequest:delegate: に移譲
 *
 * \return MixiURLConnectionインスタンス
 */
- (id)initWithRequest:(NSURLRequest *)request delegate:(id)delegate;

/**
 * \brief NSURLConnection#initWithRequest:delegate:startImmediately: に移譲
 *
 * \return MixiURLConnectionインスタンス
 */
- (id)initWithRequest:(NSURLRequest *)request delegate:(id)delegate startImmediately:(BOOL)startImmediately;

@end
