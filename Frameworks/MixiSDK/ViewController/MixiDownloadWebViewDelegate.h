/**
 * \file MixiDownloadWebViewDelegate.h
 * \brief 公式アプリダウンロード画面用デリゲートクラスを定義します。
 *
 * Created by Platform Service Department on 11/08/23.
 * Copyright 2011 mixi Inc. All rights reserved.
 */

#import <Foundation/Foundation.h>


/**
 * \brief mixi公式iPhoneアプリダウンロード画面用デリゲート
 *
 * ダウンロード画面の閉じるボタン押下イベントを処理します。
 */
@interface MixiDownloadWebViewDelegate : NSObject<UIWebViewDelegate> {
    /** \brief ターゲット */
    id closeTarget_;
    
    /** \brief アクション */
    SEL closeAction_;
}

@property (nonatomic, assign) id closeTarget;
@property (nonatomic, assign) SEL closeAction;

/**
 * \brief 初期化
 *
 * \param target ターゲット
 * \param action アクション
 * \return MixiDownloadWebViewDelegateインスタンス 
 */
- (id)initWithCloseTarget:(id)target action:(SEL)action;

@end
