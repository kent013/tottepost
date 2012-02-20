/**
 * \file MixiUserDefaults.h
 * \brief SDKが利用するユーザーデフォルトを管理するクラスを定義します。
 *
 * Created by Platform Service Department on 11/11/28.
 * Copyright 2011 mixi Inc. All rights reserved.
 */

#import <Foundation/Foundation.h>

@class MixiConfig;
@class MixiAuthorizer;

/**
 * \brief SDKが利用するユーザーデフォルトを管理するクラス
 */
@interface MixiUserDefaults : NSObject {
    /** \brief 設定 */
    MixiConfig *config_;
}

@property (nonatomic, retain) MixiConfig *config;

/**
 * \brief 初期化
 *
 * \param config 設定
 * \return MixiUserDefaultsインスタンス
 */
- (id)initWithConfig:(MixiConfig*)config;

/**
 * \brief インスタンスの情報を保持
 *
 * \param authorizer
 */
- (void)storeAuthorizer:(MixiAuthorizer*)authorizer;

/**
 * \brief インスタンスの情報を復帰
 *
 * \param authorizer
 * \return 成功したらYES、そうでなければNOを返します
 */
- (BOOL)restoreAuthorizer:(MixiAuthorizer*)authorizer;

/**
 * \brief クリア
 */
- (void)clear;

@end
