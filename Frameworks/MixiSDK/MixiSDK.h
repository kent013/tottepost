/**
 * \file MixiSDK.h
 * \brief SDK 利用者は本ヘッダをインポートしてください。
 *
 * Created by Platform Service Department on 11/08/25.
 * Copyright 2011 mixi Inc. All rights reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 * http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License. 
 */

/** \mainpage mixi API SDK for iOS
 * <a href="http://developer.mixi.co.jp/">mixi API</a>を iOS から利用するための SDK です。
 *
 * 本 SDK を使用することでトークンの取得・更新、APIの呼び出しと結果の解析が容易に行なえます。
 * Xcodeの設定など、利用の準備に関する情報は README を参照してください。
 *
 * \ref README
 *
 * SDK を利用するファイルでは MixiSDK.h をインポートしてください。
 * SDK のほとんどの機能は Mixi クラスを通じて呼び出されます。
 * Mixi クラスの使用方法については Mixi クラスのドキュメントを参照してください。
 *
 * \ref Mixi
 */

#import "Mixi.h"
#import "MixiADBannerView.h"
#import "MixiApiType.h"
#import "MixiConfig.h"
#import "MixiConstants.h"
#import "MixiDelegate.h"
#import "MixiOrientationDelegate.h"
#import "MixiRequest.h"
#import "MixiUtils.h"
#import "MixiViewController.h"
#import "MixiWebViewController.h"