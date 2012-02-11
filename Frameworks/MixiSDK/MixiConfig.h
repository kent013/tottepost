/**
 * \file MixiConfig.h
 * \brief API呼び出しの設定を保持するクラスを定義します。
 *
 * Created by Platform Service Department on 11/06/29.
 * Copyright 2011 mixi Inc. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import "MixiApiType.h"

/**
 * \brief APIの設定を保持するクラス
 */
@interface MixiConfig : NSObject {
@private
    
    /** \brief OAuthクライアントID */
    NSString *clientId_;
    
    /** \brief OAuthクライアントシークレット */
    NSString *secret_;

    /** \brief mixiアプリか、mixi Graph APIか */
    MixiApiType selectorType_;
    
    /** \brief バージョン */
    NSString *version_;
    
    /** \brief 公式アプリからトークンを受け取るためのキー */
    NSString *pbkey_;
    
    /** \brief アプリケーションを開くためのURLスキーム */
    NSString *urlScheme_;
}

@property (nonatomic, copy) NSString *clientId;
@property (nonatomic, copy) NSString *secret;
@property (nonatomic, assign) MixiApiType selectorType;
@property (nonatomic, copy) NSString *version;
@property (nonatomic, readonly) NSString *pbkey;
@property (nonatomic, copy) NSString *urlScheme;

/**
 * \brief タイプを指定して設定を生成
 *
 * \param type kMixiApiTypeSelectorMixiAppまたはkMixiApiTypeSelectorGraphApi
 * \return MixiConfigインスタンス
 */
+ (id)configWithType:(MixiApiType)type;

/**
 * \brief タイプとOAuthクライアントIDとシークレットを指定して設定を生成
 *
 * \param type kMixiApiTypeSelectorMixiAppまたはkMixiApiTypeSelectorGraphApi
 * \param id OAuthクライアントID
 * \param secret OAuthクライアントシークレット
 * \return MixiConfigインスタンス
 */
+ (id)configWithType:(MixiApiType)type clientId:(NSString*)cid secret:(NSString*)secret;

/** \cond DEPRECATED */
/**
 * \brief タイプとOAuthクライアントIDとシークレットを指定して設定を生成
 *
 * \param type kMixiApiTypeSelectorMixiAppまたはkMixiApiTypeSelectorGraphApi
 * \param id OAuthクライアントID
 * \param secret OAuthクライアントシークレット
 * \param appId キーチェーンにアクセストークンを保存するために使用するApp ID
 * \return MixiConfigインスタンス
 */
+ (id)configWithType:(MixiApiType)type clientId:(NSString*)cid secret:(NSString*)secret appId:(NSString*)appId;
/** \endcond */

/**
 * \brief タイプを指定して設定を初期化
 *
 * \param type kMixiApiTypeSelectorMixiAppまたはkMixiApiTypeSelectorGraphApi
 * \return MixiConfigインスタンス
 */
- (id)initWithType:(MixiApiType)type;

/**
 * \brief タイプとOAuthクライアントIDとシークレットを指定して設定を初期化
 *
 * \param type kMixiApiTypeSelectorMixiAppまたはkMixiApiTypeSelectorGraphApi
 * \param id OAuthクライアントID
 * \param secret OAuthクライアントシークレット
 * \return MixiConfigインスタンス
 */
- (id)initWithType:(MixiApiType)type clientId:(NSString*)id secret:(NSString*)secret;

/** \cond DEPRECATED */
/**
 * \brief タイプとOAuthクライアントIDとシークレットを指定して設定を初期化
 *
 * \param type kMixiApiTypeSelectorMixiAppまたはkMixiApiTypeSelectorGraphApi
 * \param id OAuthクライアントID
 * \param secret OAuthクライアントシークレット
 * \param appId キーチェーンにアクセストークンを保存するために使用するApp ID
 * \return MixiConfigインスタンス
 */
- (id)initWithType:(MixiApiType)type clientId:(NSString*)id secret:(NSString*)secret appId:(NSString*)appId;
/** \endcond */

/**
 * \brief 必要な設定がすべて準備できているかどうか
 *
 * \return 必要な設定がすべて準備できているかどうか
 */
- (BOOL)isReady;

@end
