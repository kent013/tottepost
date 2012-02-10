/**
 * \file MixiURLDelegate.h
 * \brief API呼び出しの通信をの結果を処理するクラスを定義します。
 *
 * Created by Platform Service Department on 11/08/03.
 * Copyright 2011 mixi Inc. All rights reserved.
 */

#import <Foundation/Foundation.h>

@class Mixi;
@protocol MixiDelegate;

/**
 * \brief 内部的に使用されるMixiDelegateをラップしてNSURLConnectionに渡すためのクラス
 *
 * SDK外で直接使用することはありません。
 */
@interface MixiURLDelegate : NSObject {
@private
    
    /** \brief mixiオブジェクト */
    Mixi* mixi_;
    
    /** \brief デリゲート */
    id<MixiDelegate> delegate_;
    
    /** \brief 読み込み済みのデータ */
    NSMutableData *data_;
}

@property (nonatomic, retain) Mixi* mixi;
@property (nonatomic, retain) id<MixiDelegate> delegate;

/**
 * \brief デリゲートを指定して生成
 *
 * \param mixi mixiオブジェクト
 * \param delegate デリゲート
 * \return MixiURLDelegateインスタンス
 */
+ (id)delegateWithMixi:(Mixi*)mixi delegate:(id<MixiDelegate>)delegate;

/**
 * \brief デリゲートを指定して初期化
 *
 * \param mixi mixiオブジェクト
 * \param delegate デリゲート
 * \return MixiURLDelegateインスタンス
 */
- (id)initWithMixi:(Mixi*)mixi delegate:(id<MixiDelegate>)delegate;

@end
