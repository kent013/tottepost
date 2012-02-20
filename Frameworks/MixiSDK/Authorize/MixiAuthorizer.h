/**
 * \file MixiAuthorizer.h
 * \brief 認可処理を実行するクラスの抽象親クラスを定義します。
 *
 * Created by Platform Service Department on 11/11/28.
 * Copyright 2011 mixi Inc. All rights reserved.
 */

#import <Foundation/Foundation.h>

@class Mixi;
@class MixiUserDefaults;
@protocol MixiDelegate;

/**
 * \brief 認可処理を実行するクラスの抽象親クラス
 */
@interface MixiAuthorizer : NSObject {
    /** \brief Mixiオブジェクト */
    Mixi *mixi_; // この依存除きたい・・・
    
    /** \brief 設定値保存用 */
    MixiUserDefaults *userDefaults_;
    
    /** \brief アクセストークン */
    NSString *accessToken_;
    
    /** \brief リフレッシュトークン */
    NSString *refreshToken_;
    
    /** \brief アクセストークンの有効期間 */
    NSString *expiresIn_;
    
    /** \brief 任意 */
    NSString *state_;
    
    /** \brief アクセストークンの有効期限 */
    NSDate *accessTokenExpiryDate_;
}

@property (nonatomic, assign) Mixi *mixi;
@property (nonatomic, copy) NSString *accessToken;
@property (nonatomic, copy) NSString *refreshToken;
@property (nonatomic, copy) NSString *expiresIn;
@property (nonatomic, copy) NSString *state;
@property (nonatomic, retain) NSDate *accessTokenExpiryDate;

/**
 * \brief 認可を実行
 *
 * \param permission 要求するパーミッション。可変長。最後の引数は必ずnilにすること
 * \return 認可処理の起動に成功したらYESを返します。
 */
- (BOOL)authorize:(NSString*)permission, ...;

/**
 * \brief 認可を実行
 *
 * \param permission 要求するパーミッション。複数指定する場合は","区切りすること
 * \return 認可処理の起動に成功したらYESを返します。
 */
- (BOOL)authorizeForPermission:(NSString*)permission;

/**
 * \brief 認可を実行
 *
 * \param permissions 要求するパーミッション
 * \return 認可処理の起動に成功したらYESを返します。
 */
- (BOOL)authorizeForPermissions:(NSArray*)permissions;

/**
 * \brief 有効なパーミッションかどうかを確認
 *
 * \param permissions 要求するパーミッション
 * \throw パーミッションが不正
 */
- (void)checkPermissions:(NSArray*)permissions;

/**
 * \brief リフレッシュトークンを使用してアクセストークンを同期的にリフレッシュ
 * 
 * \return 成功したらYES、そうでなければNOを返します
 */
- (BOOL)refreshAccessToken;

/**
 * \brief リフレッシュトークンを使用してアクセストークンを同期的にリフレッシュ
 *
 * \param error エラー
 * \return 成功したらYES、そうでなければNOを返します
 */
- (BOOL)refreshAccessTokenWithError:(NSError**)error;

/**
 * リフレッシュトークンを使用してアクセストークンを非同期にリフレッシュ
 * 
 * \param delegate 結果を受け取るデリゲート
 * \return コネクション。nilの場合は接続に失敗しています。
 */
- (NSURLConnection*)refreshAccessTokenWithDelegate:(id<MixiDelegate>)delegate;

/**
 * \brief アクセストークンを取得済みかどうか
 * 
 * \return アクセストークンを取得済みかどうか
 */
- (BOOL)isAuthorized;

/**
 * \brief アクセストークンが期限切れかどうか
 * 
 * \return アクセストークンが期限切れかどうか
 */
- (BOOL)isAccessTokenExpired;

/**
 * \brief リフレッシュトークンが期限切れかどうか
 * 
 * \return リフレッシュトークンが期限切れかどうか
 */
- (BOOL)isRefreshTokenExpired;

/**
 * \brief 辞書オブジェクトでプロパティをまとめて設定
 *
 * \param dict 有効なキーは"access_token"、"refresh_token"、"expires_in"、"state"
 */
- (void)setPropertiesFromDictionary:(NSDictionary*)dict;

/**
 * \brief インスタンスの情報を保持
 */
- (void)store;

/**
 * \brief インスタンスの情報を復帰
 *
 * \return 成功したらYES、そうでなければNOを返します
 */
- (BOOL)restore;

/**
 * \brief 端末が保持する認可情報クリア
 */
- (void)clear;

/**
 * \brief ログアウト
 *
 * SDKが端末上に保持している情報をクリアします。
 */
- (void)logout;

/**
 * \brief 認可状態を解除します。
 *
 * \return 呼び出しに成功したらYESを返します。公式アプリ経由で処理を実行する場合はYESを返しても解除が成功しているとは限りません。
 */
- (BOOL)revoke;

/**
 * \brief 認可状態を解除します。
 *
 * \param error エラー
 * \return 呼び出しに成功したらYESを返します。公式アプリ経由で処理を実行する場合はYESを返しても解除が成功しているとは限りません。
 */
- (BOOL)revokeWithError:(NSError**)error;

@end
