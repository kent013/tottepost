/**
 * \file MixiADBannerView.h
 * \brief mixi Ad Programビュークラスを定義します。
 *
 * Created by Platform Service Department on 11/08/29.
 * Copyright 2011 mixi Inc. All rights reserved.
 */

#import <UIKit/UIKit.h>
#import "MixiReporter.h"

#define kMixiADBannerContentSizeIdentifierPortrait 1
#define kMixiADBannerContentSizeIdentifierLandscape 2

/**
 * \brief mixi Ad Programビュークラス
 *
 * mixi Ad Programを利用する場合はアプリケーションの上部に本ビューを表示してください。
 * デバイスの向きに応じて表示を変える場合はuseOrientationプロパティをYESに設定するか、
 * shouldAutorotateToInterfaceOrientation: メソッド内で明示的に orientation プロパティを設定してください。
 * 
 * <pre><code>― (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 *     self.mixiAdBannerView.orientation = interfaceOrientation;
 * }
 * </code></pre>
 */
@interface MixiADBannerView : UIView {
    /** \brief 現在のビューの向き */
    int currentContentSizeIdentifier_;
    
    /** 
     * \brief デバイスの向きに応じて表示を変更するかどうか
     *
     * デフォルトではNO
     */
    BOOL useOrientation_;
    
    /** \brief mAPレポーター */
    MixiReporter *mapReporter_;
}

@property (nonatomic, assign) int currentContentSizeIdentifier;
@property (nonatomic, assign) BOOL useOrientation;
@property (nonatomic, assign) int orientation;
@property (nonatomic, retain) MixiReporter *mapReporter;

/**
 * \brief 共有インスタンスを取得
 *
 * \return 共有インスタンス
 */
+ (MixiADBannerView*)sharedView;

/**
 * \brief ウィンドウのルートビューの上にADビューを表示
 */
- (void)addOnTop;

/**
 * \brief 指定されたビューの上にADビューを表示
 *
 * \param view ビュー
 */
- (void)addOn:(UIView*)view;

/** \cond HIDDEN */
/* ウィンドウのルートビューのサイズを調節 */
- (void)arrange;

/* 指定されたビューのサイズを調節 */
- (void)arrangeOn:(UIView*)view;
/** \endcond */

@end
