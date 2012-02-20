/**
 * \file MixiSDKAuthorizer.h
 * \brief SDK自身で認可を実行するクラスを定義します。
 *
 * Created by Platform Service Department on 11/11/30.
 * Copyright 2011 mixi Inc. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import "MixiDelegate.h"
#import "MixiAuthorizer.h"

@protocol MixiSDKAuthorizerDelegate;
@class MixiWebViewController;

/**
 * \brief Graph APIの場合に、SDK自身で認可を実行するクラス
 *
 * <strong>注：本クラスはmixiアプリには利用できません。mixiアプリの場合は MixiAppAuthorizer を使用してmixi公式iPhoneアプリ経由で認可を実行してください。</strong>
 * 
 */
@interface MixiSDKAuthorizer : MixiAuthorizer<UIWebViewDelegate,MixiDelegate> {
    /** \brief 認可結果を受け取るデリゲート */
    id<MixiSDKAuthorizerDelegate> authorizerDelegate_;

    /** \brief 認可画面の親ビューコントローラ */
    UIViewController *parentViewController_;
    
    /** \brief 結果取得用リダイレクトURL */
    NSString *redirectUrl_;
    
    /** \brief ツールバーの色 */
    UIColor *toolbarColor_;
}

@property (nonatomic, assign) id<MixiSDKAuthorizerDelegate> delegate;
@property (nonatomic, retain) UIViewController *parentViewController;
@property (nonatomic, copy) NSString *redirectUrl;
@property (nonatomic, retain) UIColor *toolbarColor;

/**
 * \brief リダイレクトURLを指定してインスタンスを取得
 *
 * \param redirectUrl sap.mixi.jpでアプリケーションに設定したリダイレクトURL
 * \return インスタンス
 */
+ (id)authorizerWithRedirectUrl:(NSString*)redirectUrl;

/**
 * \brief リダイレクトURLと親ビューコントローラを指定してインスタンスを取得
 *
 * \param redirectUrl sap.mixi.jpでアプリケーションに設定したリダイレクトURL
 * \param parentViewController 認可画面を表示するウェブビューコントローラの親ビューコントローラ
 * \return インスタンス
 */
+ (id)authorizerWithRedirectUrl:(NSString*)redirectUrl parentViewController:(UIViewController*)parentViewController;

/**
 * \brief リダイレクトURLを指定して初期化
 *
 * \param redirectUrl sap.mixi.jpでアプリケーションに設定したリダイレクトURL
 * \return インスタンス
 */
- (id)initWithRedirectUrl:(NSString*)redirectUrl;

/**
 * \brief リダイレクトURLと親ビューコントローラを指定して初期化
 *
 * \param redirectUrl sap.mixi.jpでアプリケーションに設定したリダイレクトURL
 * \param parentViewController 認可画面を表示するウェブビューコントローラの親ビューコントローラ
 * \return インスタンス
 */
- (id)initWithRedirectUrl:(NSString*)redirectUrl parentViewController:(UIViewController*)parentViewController;

/**
 * \brief 認可用ビューコントローラ取得
 *
 * \param permissions 取得するスコープ
 * \return 認可用ビューコントローラ
 */
- (MixiWebViewController*)authorizerViewController:(NSArray*)permissions;

/**
 * \brief 認可解除用ビューコントローラ取得
 *
 * \param error エラー
 * \return 認可解除用ビューコントローラ
 */
- (MixiWebViewController*)revokerViewControllerWithError:(NSError**)error;

@end


/**
 * \brief 認可結果を受け取るデリゲート
 */
@protocol MixiSDKAuthorizerDelegate <NSObject>

@optional

/**
 * \brief 認可／認可解除成功
 *
 * \param authorizer
 * \param endpoint エンドポイント（kMixiApiTokenEndpoint, kMixiApiRevokeEndpoint, kMixiApiUnknownEndpoint）
 */
- (void)authorizer:(MixiSDKAuthorizer*)authorizer didSuccessWithEndpoint:(NSString*)endpoint;

/**
 * \brief 認可／認可解除キャンセル
 *
 * \param authorizer
 * \param endpoint エンドポイント（kMixiApiTokenEndpoint, kMixiApiRevokeEndpoint, kMixiApiUnknownEndpoint）
 */
- (void)authorizer:(MixiSDKAuthorizer*)authorizer didCancelWithEndpoint:(NSString*)endpoint;

/**
 * \brief 認可／認可解除失敗
 *
 * \param authorizer
 * \param endpoint エンドポイント（kMixiApiTokenEndpoint, kMixiApiRevokeEndpoint, kMixiApiUnknownEndpoint）
 * \param error エラー
 */
- (void)authorizer:(MixiSDKAuthorizer*)authorizer didFailWithEndpoint:(NSString*)endpoint error:(NSError*)error;

@end