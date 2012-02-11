/**
 * \file MixiOrientationDelegate.h
 * \brief デバイスの向きの変更を処理するプロトコルを定義します。
 *
 * Created by Platform Service Department on 11/08/23.
 * Copyright 2011 mixi Inc. All rights reserved.
 */

#import <Foundation/Foundation.h>


/**
 * \brief デバイスの向きの変更を処理するデリゲート
 */
@protocol MixiOrientationDelegate

/**
 * \brief デバイスの向きの変更を処理するデリゲート
 * 
 * \param interfaceOrientation デバイスの向き
 * \return ビューの向きを変更するかどうか
 */
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;

@end
