/**
 * \file MixiErrorCodes.h
 * \brief エラーコードを定義します。
 *
 * Created by Platform Service Department on 11/07/04.
 * Copyright 2011 mixi Inc. All rights reserved. 
 */

/** mixi API SDK内で発生するエラー用ドメイン */
#define kMixiErrorDomain @"mixi API SDK"

/** API呼び出しエラー（JSONの解釈に失敗） */
#define kMixiAPIErrorInvalidJson 1000

/** API呼び出しエラー（JSON内にerrorメッセージが設定済み） */
#define kMixiAPIErrorReply 1001

/** アクセストークンがない場合 */
#define kMixiAPIErrorNotAuthorized 1002

/** 公式アプリ以外からURLスキームで呼び出された場合 */
#define kMixiAppErrorInvalidSource 2000

/** 公式アプリが古い、またはインストールされていない場合 */
#define kMixiAppErrorNotFound 2001

/** 公式アプリを開くためのパラメータが不正な場合 */
#define kMixiAppInvalidParameter 2002

/** 公式アプリで接続エラーでログイン画面を開けない場合 */
#define kMixiAuthErrorConnectionFailed 3000

/** 公式アプリで認証エラーでログイン画面を開けない場合 */
#define kMixiAuthErrorOAuthFailed 3001

/** 公式アプリでOAuth不正パラメータでログイン画面を開けない場合 */
#define kMixiAuthErrorInvalidOAuthParameters 3002

/** 公式アプリがネットワークエラーでトークンを取得できない場合 */
#define kMixiTokenErrorConnectionFailed 4000

/** 公式アプリが正しいリダイレクトURLを設定していない場合 */
#define kMixiTokenErrorInvalidStatusCode 4001

/** ペーストボードからトークンが取得できない場合 */
#define kMixiTokenErrorCannotRetrieve 4002

/** 公式アプリを開かない設定の時にアクセストークンが期限切れの場合 */
#define kMixiTokenErrorExpired 4003

/** 公式アプリ経由で実行したAPIが失敗した場合 */
#define kMixiTokenErrorAPIFailed 4004

/** MixiURLConnectionでHTTPステータスコードが不正な場合 */
#define kMixiConnectionErrorHTTP 5000

/** MixiURLConnectionでストリームが読めない場合 */
#define kMixiConnectionErrorReadStream 5001

/** MixiURLConnectionでストリームが開けない場合 */
#define kMixiConnectionErrorOpenStream 5002

/** MixiURLConnectionでAPI実行を失敗した場合 */
#define kMixiConnectionErrorAPI 5003

/** ネットワークが繋がらない場合 */
#define kMixiConnectionErrorUnreachable 5004

/** リクエストに含まれる画像タイプが不正 */
#define kMixiRequestErrorInvalidImageType 6000

/** リクエストがキャンセルされた場合 */
#define kMixiCancelled 9000

/** 謎のエラー */
#define kMixiErrorUnknown 9999
