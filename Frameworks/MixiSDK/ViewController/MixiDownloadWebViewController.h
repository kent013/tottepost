/**
 * \file MixiDownloadWebViewController.h
 * \brief mixi公式アプリダウンロード用ビューコントローラを定義します。
 *
 * Created by Platform Service Department on 12/01/19.
 * Copyright (c) 2012 mixi Inc. All rights reserved.
 */

#import "MixiWebViewController.h"

@class MixiDownloadWebViewDelegate;

/**
 * \brief mixi公式iPhoneアプリダウンロード用ビューコントローラ
 */
@interface MixiDownloadWebViewController : MixiWebViewController {
    /** \brief ダウンロード終了処理用デリゲート */
    MixiDownloadWebViewDelegate *downloadDelegate_;
}

/**
 * \brief ダウンロード終了時の処理用ターゲットとアクションを追加.
 *
 * \param target ダウンロード終了時の処理用ターゲット
 * \param action ダウンロード終了時の処理用アクション
 */
- (void)addCloseTaget:(id)target action:(SEL)action;

@end
