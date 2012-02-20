/**
 * \file MixiAppAuthorizer.h
 * \brief mixi公式iPhoneアプリを使用して認可を実行するクラスを定義します。
 *
 * Created by Platform Service Department on 11/11/28.
 * Copyright 2011 mixi Inc. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import "MixiAuthorizer.h"


/**
 * \brief mixi公式iPhoneアプリを使用して認可を実行するクラス
 *
 * mixi公式iPhoneアプリを経由して認可／認可解除を実行するデフォルトの認可クラスです。
 */
@interface MixiAppAuthorizer : MixiAuthorizer {
    /** \brief スコープ */
    NSArray *permissions_;

    /** \brief SDKが公式アプリから認可情報を受け取るためのURIスキーム。デフォルトではplistで最初に設定されているURL Typesに設定されます。 */
    NSString *returnScheme_;
}

@end
