/**
 * \file MixiImageButtonView.h
 * \brief 画像ボタンクラスを定義します。
 *
 * Created by Platform Service Department on 11/08/31.
 * Copyright 2011 mixi Inc. All rights reserved.
 */

#import <Foundation/Foundation.h>


/**
 * \brief 画像ボタンクラス
 *
 * タップすると登録されたアクションを実行する画像ビューです。
 */
@interface MixiImageButtonView : UIImageView {
    /** \brief アクションターゲット */
    id target_;
    
    /** \brief アクション */
    SEL action_;
    
    /** \brief アクション引数 */
    id argument_;
}

@property (nonatomic, assign) id target;
@property (nonatomic, assign) SEL action;
@property (nonatomic, retain) id argument;

/**
 * \brief アクションを追加します。
 *
 * \param target アクションターゲット
 * \param action アクション
 */
- (void)addTarget:(id)target action:(SEL)action;

/**
 * \brief アクションを追加します。
 *
 * \param target アクションターゲット
 * \param action アクション
 * \param argument アクション引数
 */
- (void)addTarget:(id)target action:(SEL)action withObject:(id)argument;

@end
