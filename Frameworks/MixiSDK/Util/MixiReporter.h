/**
 * \file MixiReporter.h
 * \brief UU測定APIを実行するクラスを定義します。
 *
 * Created by Platform Service Department on 11/08/12.
 * Copyright 2011 mixi Inc. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import "MixiDelegate.h"

@class Mixi;


/**
 * \brief UU測定APIを実行するクラス
 */
@interface MixiReporter : NSObject <MixiDelegate> {
@private
    
    /** \brief エンドポイント */
    NSString *endpoint_;

    /** \brief 再送を遅延させる秒数 */
    int delay_;
    
    /**
     * \brief 最大リトライ回数
     *
     * デフォルトでは成功するまでリトライします。
     */
    int maxRetryCount_;
    
    /** \brief リトライ回数 */
    int retryCount_;
    
    /** \brief コネクション */
    NSURLConnection *connection_;
    
    /** \brief 最期に送信成功した日時 */
    NSDate *successDate_;
}

@property (nonatomic, copy) NSString *endpoint;
@property (nonatomic, assign) int maxRetryCount;
@property (nonatomic, assign) int retry;
@property (nonatomic, retain) NSURLConnection *connection;
@property (nonatomic, retain) NSDate *successDate;

/**
 * \brief UU測定用レポーターを取得
 *
 * \return UU測定用レポーター
 */
+ (id)pingReporter;

/**
 * \brief mAP用レポーターを取得
 *
 * \return mAP測定用レポーター
 */
+ (id)mapReporter;

/**
 * \brief エンドポイントを指定して初期化
 *
 * \param endpoint レポートに使用するエンドポイント
 * \return レポーター
 */
- (id)initWithEndpoint:(NSString*)endpoint;

/**
 * \brief レポートに失敗しても再送しません
 */
- (void)setRetryNever;

/**
 * \brief レポートに成功するまで再送します
 */
- (void)setRetryForever;

/**
 * \brief APIを実行します
 */
- (void)ping;

/**
 * \brief メソッド呼び出し日にまだ一度もAPIを実行していなければ実行します
 */
- (void)pingIfNeededWithMixi:(Mixi*)mixi;

/**
 * \brief APIを実行します
 *
 * \param mixi API実行用オブジェクト
 */
- (void)pingWithMixi:(Mixi*)mixi;

/**
 * \brief API呼び出しをキャンセル
 */
- (void)cancel;

@end
