/**
 * \file MixiApiType.h
 * \brief mixiアプリとGraph APIを表す列挙型を定義します。
 *
 * Created by Platform Service Department on 11/08/25.
 * Copyright 2011 mixi Inc. All rights reserved.
 */

/** \brief 使用するAPIのタイプ */
typedef enum _MixiApiType {
    /** \brief mixiアプリ呼び出し用 */
    kMixiApiTypeSelectorMixiApp = 1,
    
    /** \brief mixi Graph API呼び出し用 */
    kMixiApiTypeSelectorGraphApi = 2,
} MixiApiType;
