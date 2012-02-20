/**
 * \file MixiRequest.h
 * \brief API呼び出しに必要な情報を保持するクラスを定義します。
 *
 * Created by Platform Service Department on 11/06/30.
 * Copyright 2011 mixi Inc. All rights reserved.
 */

#import <Foundation/Foundation.h>

@class Mixi;

/** GETメソッド */
#define kMixiHTTPMethodGet @"GET"

/** POSTメソッド */
#define kMixiHTTPMethodPost @"POST"

/** DELETEメソッド */
#define kMixiHTTPMethodDelete @"DELETE"

/** PUTメソッド */
#define kMixiHTTPMethodPut @"PUT"

/** 並び順を指定するためのリクエストパラメーターのキー */
#define kMixiRequestKeySortBy @"sortBy"

/** 昇順・降順を指定するためのリクエストパラメーターのキー */
#define kMixiRequestKeySortOrder @"sortOrder"

/** サムネイル画像が全体向けか友人向けかを指定するためのリクエストパラメーターのキー */
#define kMixiRequestKeyThumbnailPrivacy @"thumbnailPrivacy"

/** 取得する属性を指定するためのリクエストパラメーターのキー */
#define kMixiRequestKeyFields @"fields"

/**
 * \brief mixi APIのリクエストに必要な情報を保持するクラス
 *
 * 本クラスのインスタンスはAPI実行に関する以下の情報を保持します。
 * <ul>
 * <li>エンドポイント</li>
 * <li>パラメータ</li>
 * </ul>
 *
 * APIが必要とするパラメーターの値は大きく分けて文字列・JSON・画像の3種類あり、本SDKではそれらをそれぞれNSString、NSDictionary、UIImageで指定します。
 * 基本的なリクエストの生成は次のようになります。
 *
 * <pre><code>NSString *path = [[NSBundle mainBundle] pathForResource:@"yoichiro" ofType:@"png"];
 * UIImage *image = [[UIImage alloc] initWithContentsOfFile:path];
 * MixiRequest *request = [MixiRequest postRequestWithEndpoint:@"/path/to/api"
 *                                               paramsAndKeys:@"value1", @"key1",
 *                                                             @"value2", @"key2",
 *                                                             image, @"key3", nil];
 * </code></pre>
 *
 * <hr/>
 * <strong>JSON形式のリクエスト</strong>
 *
 * JSON形式で値を指定する場合は次のようになります。
 *
 * <pre><code>NSMutableDictionary *json = [NSMutableDictionary dictionary];
 * [diary setValue:@"value1" forKey:@"key1"];
 * [diary setValue:@"value2" forKey:@"key2"];
 * NSMutableDictionary *subJson = [NSMutableDictionary dictionary];
 * [subJson setValue:@"value31" forKey:@"key31"];
 * [json setValue:subJson forKey:@"key3"];
 * 
 * MixiRequest *request = [MixiRequest postRequestWithEndpoint:@"/path/to/api"
 *                                               paramsAndKeys:json, @"json", nil];
 * </code></pre>
 *
 * 上記の場合リクエストボディに設定されるJSONは次のようになります。
 *
 * <pre><code>{
 *     "key1":"value1",
 *     "key2":"value2",
 *     "key3":{
 *         "key31":"value31"
 *     }
 * }
 * </code></pre>
 * 
 * なお、JSONはリクエストボディを占有してしまうため、画像以外の値を持つ唯一のパラメータでなければいけません。つまり次のような指定はできません。
 *
 * // 以下のリクエストではjson変数はJSONとしては扱われません。
 * <pre><code>MixiRequest *request = [MixiRequest postRequestWithEndpoint:@"/path/to/api"
 *                                               paramsAndKeys:json, @"json",
 *                                                             @"wrong_value", @"wrong_key", nil];
 * </code></pre>
 *
 * <hr/>
 * <strong>さまざまなパラメータの指定方法</strong>
 *
 * パラメータをNSDictionaryオブジェクトでまとめて指定することもできます。パラメータの種類を動的に変更する場合はこちらを使用するといいでしょう。
 *
 * <pre><code>NSMutableDictionary *params = [NSMutableDictionary dictionary];
 * [params setObject:@"value1" forKey:@"key1"];
 * [params setObject:@"value2" forKey:@"key2"];
 * MixiRequest *request = [MixiRequest postRequestWithEndpoint:@"/path/to/api" params:params];
 * </code></pre>
 *
 * リクエストを作成してからパラメータを追加しても構いません。
 *
 * <pre><code>MixiRequest *request = [MixiRequest postRequestWithEndpoint:@"/path/to/api"];
 * [request setParam:@"value1" forKey:@"key1"];
 * [request setParam:@"value2" forKey:@"key2"];
 * </code></pre>
 *
 * <hr/>
 * <strong>リクエストボディを指定</strong>
 *
 * HTTPリクエストのボディを直接指定することもできます。
 * リクエストボディに直接画像データを設定することを要求するAPIがありますが、paramsの値としてUIImageオブジェクトを与えた場合はマルチパートデータとして送信されてしまいます。
 * そのような場合に、次のコンストラクタが利用できます。
 *
 * <pre><code>MixiRequest *request = [MixiRequest postRequestWithEndpoint:@"/path/to/api" body:image];
 * </code></pre>
 *
 * <hr/>
 * <strong>添付される画像の形式</strong>
 *
 * 添付される画像はデフォルトではJPEG形式ですが、次のメソッドを呼び出しておくことでデフォルトでPNG形式を使うこともできます。
 *
 * <pre><code>[MixiRequest setDefaultImageTypePNG];
 * </code></pre>
 *
 * リクエストごとに画像の形式を変更する場合はimageTypeプロパティを使用します。
 *
 * <pre><code>request.imageType = "png";
 * </code></pre>
 *
 * なお、一つのリクエストに形式の異なる画像を混在させることはできません。
 */
@interface MixiRequest : NSObject <UIWebViewDelegate> {
@private
    
    /** \brief エンドポイント */
    NSString *endpoint_;
    
    /** \brief エンドポイントのベースURL */
    NSString *endpointBaseUrl_;
    
    /** \brief リクエストボディ */
    NSObject *body_;
    
    /**
     * \brief パラメーター。
     * リクエストボディが指定されていれば、パラメーターはクエリパラメーターがエンドポイントに追加されます。
     * リクエストボディが指定されていなければ、パラメーターからリクエストボディを作成します。
     */
    NSMutableDictionary *params_;
    
    /** \brief 添付ファイル */
    NSMutableDictionary *attachments_;
    
    /** \brief HTTPメソッド */
    NSString *httpMethod_;
    
    /** \brief タイムアウト秒数 */
    NSTimeInterval requestTimeout_;
    
    /** \brief キャッシュポリシー */
    NSURLRequestCachePolicy cachePolicy_;
    
    /** \brief 画像を送信する際のファイルタイプ */
    NSString *imageType_;
    
    /** \brief JPEGで画像を送信する際の圧縮率 */
    float compressionQuality_;
    
    /** 
     * \brief リクエスト送信時にアクセストークンがなかった場合、公式アプリを開くかどうか
     * デフォルトはYES。UU集計APIなど公式アプリに遷移すると困る場合にはNOにしておきます。
     */
    BOOL openMixiAppToAuthorizeIfNeeded_;
}

@property (nonatomic, copy) NSString *endpoint;
@property (nonatomic, copy) NSString *endpointBaseUrl;
@property (nonatomic, retain) NSObject *body;
@property (readonly) NSData *bodyData;
@property (nonatomic, retain) NSMutableDictionary *params;
@property (nonatomic, retain) NSMutableDictionary *attachments;
@property (nonatomic, copy) NSString *httpMethod;
@property (nonatomic, assign) NSTimeInterval requestTimeout;
@property (nonatomic, assign) NSURLRequestCachePolicy cachePolicy;
@property (nonatomic, copy) NSString *imageType;
@property (nonatomic, assign) float compressionQuality;
@property (nonatomic, assign) BOOL openMixiAppToAuthorizeIfNeeded;

/**
 * \brief エンドポイントを指定してGETリクエストを生成
 *
 * \param endpoint APIエンドポイント
 * \return MixiRequestインスタンス
 */
+ (id)requestWithEndpoint:(NSString*)endpoint;

/**
 * \brief HTTPメソッドとエンドポイントを指定してリクエストを生成
 *
 * \param httpMethod HTTPメソッド
 * \param endpoint APIエンドポイント
 * \return MixiRequestインスタンス
 */
+ (id)requestWithMethod:(NSString*)httpMethod endpoint:(NSString*)endpoint;

/**
 * \brief HTTPメソッドとエンドポイントとリクエストボディを指定してリクエストを生成
 *
 * \param httpMethod HTTPメソッド
 * \param endpoint APIエンドポイント
 * \param body リクエストボディ
 * \return MixiRequestインスタンス
 */
+ (id)requestWithMethod:(NSString*)httpMethod endpoint:(NSString*)endpoint body:(NSObject*)body;

/**
 * \brief エンドポイントとパラメーターを指定してGETリクエストを生成
 *
 * \param endpoint APIエンドポイント
 * \param params パラメータ。値の型に応じて次のように送り分けられます。
 * - 辞書の値が<code>NSString</code>インスタンスの場合はクエリパラメータ
 * - 辞書の値が<code>UIImage</code>インスタンスの場合は画像を添付
 * - 辞書の値が<code>NSDictionary</code>インスタンスの場合はJSON文字列
 * \return MixiRequestインスタンス
 */
+ (id)requestWithEndpoint:(NSString*)endpoint params:(NSDictionary*)params;

/**
 * \brief エンドポイントとパラメーターを指定してGETリクエストを生成
 *
 * \param endpoint APIエンドポイント
 * \param params パラメータ。値の型に応じて次のように送り分けられます。
 * - 辞書の値が<code>NSString</code>インスタンスの場合はクエリパラメータ
 * - 辞書の値が<code>UIImage</code>インスタンスの場合は画像を添付
 * - 辞書の値が<code>NSDictionary</code>インスタンスの場合はJSON文字列
 * \return MixiRequestインスタンス
 */
+ (id)getRequestWithEndpoint:(NSString*)endpoint params:(NSDictionary*)params;

/**
 * \brief エンドポイントを指定してPOSTリクエストを生成
 *
 * \param endpoint APIエンドポイント
 * \return MixiRequestインスタンス
 */
+ (id)postRequestWithEndpoint:(NSString*)endpoint;

/**
 * \brief エンドポイントとパラメーターを指定してPOSTリクエストを生成
 *
 * \param endpoint APIエンドポイント
 * \param params パラメータ。値の型に応じて次のように送り分けられます。
 * - 辞書の値が<code>NSString</code>インスタンスの場合はクエリパラメータ
 * - 辞書の値が<code>UIImage</code>インスタンスの場合は画像を添付
 * - 辞書の値が<code>NSDictionary</code>インスタンスの場合はJSON文字列
 * \return MixiRequestインスタンス
 */
+ (id)postRequestWithEndpoint:(NSString*)endpoint params:(NSDictionary*)params;

/**
 * \brief エンドポイントとリクエストボディを指定してPOSTリクエストを生成
 *
 * \param endpoint APIエンドポイント
 * \param body リクエストボディ
 * \return MixiRequestインスタンス
 */
+ (id)postRequestWithEndpoint:(NSString*)endpoint body:(NSObject*)body;

/**
 * \brief エンドポイントとリクエストボディとパラメーターを指定してPOSTリクエストを生成
 *
 * \param endpoint APIエンドポイント
 * \param body リクエストボディ
 * \param params パラメータ。値の型に応じて次のように送り分けられます。
 * - 辞書の値が<code>NSString</code>インスタンスの場合はクエリパラメータ
 * - 辞書の値が<code>UIImage</code>インスタンスの場合は画像を添付
 * - 辞書の値が<code>NSDictionary</code>インスタンスの場合はJSON文字列
 * \return MixiRequestインスタンス
 */
+ (id)postRequestWithEndpoint:(NSString*)endpoint body:(NSObject*)body params:(NSDictionary*)params;

/**
 * \brief エンドポイントとパラメーターを指定してPUTリクエストを生成
 *
 * \param endpoint APIエンドポイント
 * \param params パラメータ。値の型に応じて次のように送り分けられます。
 * - 辞書の値が<code>NSString</code>インスタンスの場合はクエリパラメータ
 * - 辞書の値が<code>UIImage</code>インスタンスの場合は画像を添付
 * - 辞書の値が<code>NSDictionary</code>インスタンスの場合はJSON文字列
 * \return MixiRequestインスタンス
 */
+ (id)putRequestWithEndpoint:(NSString*)endpoint params:(NSDictionary*)params;

/**
 * \brief エンドポイントとリクエストボディを指定してPUTリクエストを生成
 *
 * \param endpoint APIエンドポイント
 * \param body リクエストボディ
 */
+ (id)putRequestWithEndpoint:(NSString*)endpoint body:(NSObject*)body;

/**
 * \brief エンドポイントとリクエストボディとパラメーターを指定してPUTリクエストを生成
 *
 * \param endpoint APIエンドポイント
 * \param body リクエストボディ
 * \param params パラメータ。値の型に応じて次のように送り分けられます。
 * - 辞書の値が<code>NSString</code>インスタンスの場合はクエリパラメータ
 * - 辞書の値が<code>UIImage</code>インスタンスの場合は画像を添付
 * - 辞書の値が<code>NSDictionary</code>インスタンスの場合はJSON文字列
 * \return MixiRequestインスタンス
 */
+ (id)putRequestWithEndpoint:(NSString*)endpoint body:(NSObject*)body params:(NSDictionary*)params;


/**
 * \brief エンドポイントを指定してDELETEリクエストを生成
 *
 * \param endpoint APIエンドポイント
 * \return MixiRequestインスタンス
 */
+ (id)deleteRequestWithEndpoint:(NSString*)endpoint;

/**
 * \brief エンドポイントとパラメーターを指定してDELETEリクエストを生成
 *
 * \param endpoint APIエンドポイント
 * \param params パラメータ。値の型に応じて次のように送り分けられます。
 * - 辞書の値が<code>NSString</code>インスタンスの場合はクエリパラメータ
 * - 辞書の値が<code>UIImage</code>インスタンスの場合は画像を添付
 * - 辞書の値が<code>NSDictionary</code>インスタンスの場合はJSON文字列
 * \return MixiRequestインスタンス
 */
+ (id)deleteRequestWithEndpoint:(NSString*)endpoint params:(NSDictionary*)params;

/**
 * \brief エンドポイントとリクエストボディとパラメーターを指定してDELETEリクエストを生成
 *
 * \param endpoint APIエンドポイント
 * \param body リクエストボディ
 * \param params パラメータ。値の型に応じて次のように送り分けられます。
 * - 辞書の値が<code>NSString</code>インスタンスの場合はクエリパラメータ
 * - 辞書の値が<code>UIImage</code>インスタンスの場合は画像を添付
 * - 辞書の値が<code>NSDictionary</code>インスタンスの場合はJSON文字列
 * \return MixiRequestインスタンス
 */
+ (id)deleteRequestWithEndpoint:(NSString*)endpoint body:(NSObject*)body params:(NSDictionary*)params;

/**
 * \brief エンドポイントとパラメーターを指定してGETリクエストを生成
 *
 * \param endpoint APIエンドポイント
 * \param paramsKeys 可変長パラメータ。偶数個指定すること。また最期の引数はnilにすること。値の型に応じて次のように送り分けられます。
 * - 辞書の値が<code>NSString</code>インスタンスの場合はクエリパラメータ
 * - 辞書の値が<code>UIImage</code>インスタンスの場合は画像を添付
 * - 辞書の値が<code>NSDictionary</code>インスタンスの場合はJSON文字列
 * \return MixiRequestインスタンス
 */
+ (id)requestWithEndpoint:(NSString*)endpoint paramsAndKeys:(NSObject*)paramsKeys, ...;

/**
 * \brief エンドポイントとパラメーターを指定してGETリクエストを生成
 *
 * \param endpoint APIエンドポイント
 * \param paramsKeys 可変長パラメータ。偶数個指定すること。また最期の引数はnilにすること。値の型に応じて次のように送り分けられます。
 * - 辞書の値が<code>NSString</code>インスタンスの場合はクエリパラメータ
 * - 辞書の値が<code>UIImage</code>インスタンスの場合は画像を添付
 * - 辞書の値が<code>NSDictionary</code>インスタンスの場合はJSON文字列
 * \return MixiRequestインスタンス
 */
+ (id)getRequestWithEndpoint:(NSString*)endpoint paramsAndKeys:(NSObject*)paramsKeys, ...;

/**
 * \brief エンドポイントとパラメーターを指定してPOSTリクエストを生成
 *
 * \param endpoint APIエンドポイント
 * \param paramsKeys 可変長パラメータ。偶数個指定すること。また最期の引数はnilにすること。値の型に応じて次のように送り分けられます。
 * - 辞書の値が<code>NSString</code>インスタンスの場合はクエリパラメータ
 * - 辞書の値が<code>UIImage</code>インスタンスの場合は画像を添付
 * - 辞書の値が<code>NSDictionary</code>インスタンスの場合はJSON文字列
 * \return MixiRequestインスタンス
 */
+ (id)postRequestWithEndpoint:(NSString*)endpoint paramsAndKeys:(NSObject*)paramsKeys, ...;

/**
 * \brief エンドポイントとリクエストボディとパラメーターを指定してPOSTリクエストを生成
 *
 * \param endpoint APIエンドポイント
 * \param リクエストボディ
 * \param paramsKeys 可変長パラメータ。偶数個指定すること。また最期の引数はnilにすること。値の型に応じて次のように送り分けられます。
 * - 辞書の値が<code>NSString</code>インスタンスの場合はクエリパラメータ
 * - 辞書の値が<code>UIImage</code>インスタンスの場合は画像を添付
 * - 辞書の値が<code>NSDictionary</code>インスタンスの場合はJSON文字列
 * \return MixiRequestインスタンス
 */
+ (id)postRequestWithEndpoint:(NSString*)endpoint body:(NSObject*)body paramsAndKeys:(NSObject*)paramsKeys, ...;

/**
 * \brief エンドポイントとパラメーターを指定してPUTリクエストを生成
 *
 * \param endpoint APIエンドポイント
 * \param paramsKeys 可変長パラメータ。偶数個指定すること。また最期の引数はnilにすること。値の型に応じて次のように送り分けられます。
 * - 辞書の値が<code>NSString</code>インスタンスの場合はクエリパラメータ
 * - 辞書の値が<code>UIImage</code>インスタンスの場合は画像を添付
 * - 辞書の値が<code>NSDictionary</code>インスタンスの場合はJSON文字列
 * \return MixiRequestインスタンス
 */
+ (id)putRequestWithEndpoint:(NSString*)endpoint paramsAndKeys:(NSObject*)paramsKeys, ...;

/**
 * \brief エンドポイントとリクエストボディとパラメーターを指定してPUTリクエストを生成
 *
 * \param endpoint APIエンドポイント
 * \param リクエストボディ
 * \param paramsKeys 可変長パラメータ。偶数個指定すること。また最期の引数はnilにすること。値の型に応じて次のように送り分けられます。
 * - 辞書の値が<code>NSString</code>インスタンスの場合はクエリパラメータ
 * - 辞書の値が<code>UIImage</code>インスタンスの場合は画像を添付
 * - 辞書の値が<code>NSDictionary</code>インスタンスの場合はJSON文字列
 * \return MixiRequestインスタンス
 */
+ (id)putRequestWithEndpoint:(NSString*)endpoint body:(NSObject*)body paramsAndKeys:(NSObject*)paramsKeys, ...;

/**
 * \brief エンドポイントとパラメーターを指定してDELETEリクエストを生成
 *
 * \param endpoint APIエンドポイント
 * \param paramsKeys 可変長パラメータ。偶数個指定すること。また最期の引数はnilにすること。値の型に応じて次のように送り分けられます。
 * - 辞書の値が<code>NSString</code>インスタンスの場合はクエリパラメータ
 * - 辞書の値が<code>UIImage</code>インスタンスの場合は画像を添付
 * - 辞書の値が<code>NSDictionary</code>インスタンスの場合はJSON文字列
 * \return MixiRequestインスタンス
 */
+ (id)deleteRequestWithEndpoint:(NSString*)endpoint paramsAndKeys:(NSObject*)paramsKeys, ...;

/**
 * \brief エンドポイントとリクエストボディとパラメーターを指定してDELETEリクエストを生成
 *
 * \param endpoint APIエンドポイント
 * \param リクエストボディ
 * \param paramsKeys 可変長パラメータ。偶数個指定すること。また最期の引数はnilにすること。値の型に応じて次のように送り分けられます。
 * - 辞書の値が<code>NSString</code>インスタンスの場合はクエリパラメータ
 * - 辞書の値が<code>UIImage</code>インスタンスの場合は画像を添付
 * - 辞書の値が<code>NSDictionary</code>インスタンスの場合はJSON文字列
 * \return MixiRequestインスタンス
 */
+ (id)deleteRequestWithEndpoint:(NSString*)endpoint body:(NSObject*)body paramsAndKeys:(NSObject*)paramsKeys, ...;

/**
 * \brief HTTPメソッドとエンドポイントとパラメーターを指定してリクエストを生成
 *
 * \param httpMethod HTTPメソッド
 * \param endpoint APIエンドポイント
 * \param params パラメータ。値の型に応じて次のように送り分けられます。
 * - 辞書の値が<code>NSString</code>インスタンスの場合はクエリパラメータ
 * - 辞書の値が<code>UIImage</code>インスタンスの場合は画像を添付
 * - 辞書の値が<code>NSDictionary</code>インスタンスの場合はJSON文字列
 * \return MixiRequestインスタンス
 */
+ (id)requestWithMethod:(NSString*)httpMethod endpoint:(NSString*)endpoint params:(NSDictionary*)params;

/**
 * \brief HTTPメソッドとエンドポイントとリクエストボディとパラメーターを指定してリクエストを生成
 *
 * \param httpMethod HTTPメソッド
 * \param endpoint APIエンドポイント
 * \param body リクエストボディ
 * \param params パラメータ。値の型に応じて次のように送り分けられます。
 * - 辞書の値が<code>NSString</code>インスタンスの場合はクエリパラメータ
 * - 辞書の値が<code>UIImage</code>インスタンスの場合は画像を添付
 * - 辞書の値が<code>NSDictionary</code>インスタンスの場合はJSON文字列
 * \return MixiRequestインスタンス
 */
+ (id)requestWithMethod:(NSString*)httpMethod endpoint:(NSString*)endpoint body:(NSObject*)body params:(NSDictionary*)params;

/**
 * \brief エンドポイントを指定してリクエストを初期化
 *
 * \param endpoint APIエンドポイント
 * \return MixiRequestインスタンス
 */
- (id)initWithEndpoint:(NSString*)endpoint;

/**
 * \brief HTTPメソッドとエンドポイントを指定してリクエストを初期化
 *
 * \param httpMethod HTTPメソッド
 * \param endpoint APIエンドポイント
 * \return MixiRequestインスタンス
 */
- (id)initWithMethod:(NSString*)httpMethod endpoint:(NSString*)endpoint;

/**
 * \brief HTTPメソッドとエンドポイントとリクエストボディを指定してリクエストを初期化
 *
 * \param httpMethod HTTPメソッド
 * \param endpoint APIエンドポイント
 * \param body リクエストボディ
 * \return MixiRequestインスタンス
 */
- (id)initWithMethod:(NSString*)httpMethod endpoint:(NSString*)endpoint body:(NSObject*)body;

/**
 * \brief エンドポイントとパラメーターを指定してリクエストを初期化
 *
 * \param endpoint APIエンドポイント
 * \param params パラメータ。値の型に応じて次のように送り分けられます。
 * - 辞書の値が<code>NSString</code>インスタンスの場合はクエリパラメータ
 * - 辞書の値が<code>UIImage</code>インスタンスの場合は画像を添付
 * - 辞書の値が<code>NSDictionary</code>インスタンスの場合はJSON文字列
 * \return MixiRequestインスタンス
 */
- (id)initWithEndpoint:(NSString*)endpoint params:(NSDictionary*)params;

/**
 * \brief エンドポイントとリクエストボディとパラメーターを指定してリクエストを初期化
 *
 * \param endpoint APIエンドポイント
 * \param body リクエストボディ
 * \param params パラメータ。値の型に応じて次のように送り分けられます。
 * - 辞書の値が<code>NSString</code>インスタンスの場合はクエリパラメータ
 * - 辞書の値が<code>UIImage</code>インスタンスの場合は画像を添付
 * - 辞書の値が<code>NSDictionary</code>インスタンスの場合はJSON文字列
 * \return MixiRequestインスタンス
 */
- (id)initWithEndpoint:(NSString*)endpoint body:(NSObject*)body params:(NSDictionary*)params;

/**
 * \brief HTTPメソッドとエンドポイントとパラメーターを指定してリクエストを初期化
 *
 * \param httpMethod HTTPメソッド
 * \param endpoint APIエンドポイント
 * \param params パラメータ。値の型に応じて次のように送り分けられます。
 * - 辞書の値が<code>NSString</code>インスタンスの場合はクエリパラメータ
 * - 辞書の値が<code>UIImage</code>インスタンスの場合は画像を添付
 * - 辞書の値が<code>NSDictionary</code>インスタンスの場合はJSON文字列
 * \return MixiRequestインスタンス
 */
- (id)initWithMethod:(NSString*)httpMethod endpoint:(NSString*)endpoint params:(NSDictionary*)params;

/**
 * \brief [指定イニシャライザ] HTTPメソッドとエンドポイントとリクエストボディとパラメーターを指定してリクエストを初期化
 *
 * \param httpMethod HTTPメソッド
 * \param endpoint APIエンドポイント
 * \param body リクエストボディ
 * \param params パラメータ。値の型に応じて次のように送り分けられます。
 * - 辞書の値が<code>NSString</code>インスタンスの場合はクエリパラメータ
 * - 辞書の値が<code>UIImage</code>インスタンスの場合は画像を添付
 * - 辞書の値が<code>NSDictionary</code>インスタンスの場合はJSON文字列
 * \return MixiRequestインスタンス
 */
- (id)initWithMethod:(NSString*)httpMethod endpoint:(NSString*)endpoint body:(NSObject*)body params:(NSDictionary*)params;

/**
 * \brief デフォルトタイムアウトを設定
 *
 * \param interval タイムアウト秒数
 */
+ (void)setDefaultRequestTimeout:(NSTimeInterval)interval;

/**
 * \brief デフォルトキャッシュポリシーを設定
 *
 * \param cachePolicy キャッシュポリシー
 */
+ (void)setDefaultRequestCachePolicy:(NSURLRequestCachePolicy)cachePolicy;

/**
 * \brief デフォルトの画像タイプをJPEGに設定
 *
 * 全リクエストでJPEGフォーマットを利用する場合に使用
 */
+ (void)setDefaultImageTypeJPEG;

/**
 * \brief デフォルトの画像タイプをPNGに設定
 *
 * 全リクエストでPNGフォーマットを利用する場合に使用
 */
+ (void)setDefaultImageTypePNG;

/**
 * \brief JPEGを使用した際のデフォルトの圧縮率を設定
 *
 * \param quality 圧縮率
 */
+ (void)setDefaultCompressionQuality:(float)quality;

/**
 * \brief パラメーターを設定
 *
 * \param paramsKeys 可変長パラメータ。偶数個指定すること。また最期の引数はnilにすること。値の型に応じて次のように送り分けられます。
 * - 値が<code>NSString</code>インスタンスの場合はクエリパラメータ
 * - 値が<code>UIImage</code>インスタンスの場合は画像を添付
 * - 値が<code>NSDictionary</code>インスタンスの場合はJSON文字列
 */
- (void)setParamsAndKeys:(NSObject*)paramsKeys, ...;

/**
 * \brief パラメーターを設定
 *
 * \param value 値の型に応じて次のように送り分けられます。
 * - 値が<code>NSString</code>インスタンスの場合はクエリパラメータ
 * - 値が<code>UIImage</code>インスタンスの場合は画像を添付
 * - 値が<code>NSDictionary</code>インスタンスの場合はJSON文字列
 * \param key キー
 */
- (void)setParam:(NSObject*)value forKey:(NSString*)key;

/**
 * \brief パラメーターをクリア
 */
- (void)clearParams;

/**
 * \brief 添付ファイルを追加
 *
 * \param image 画像
 * \param key キー
 */
- (void)addAttachment:(UIImage*)image forKey:(NSString*)key;

/**
 * \brief 自身の情報からNSURLConnectionで実際に送信するためのURLリクエストを作成
 *
 * \param mixi mixiオブジェクト
 * \return URLリクエスト
 */
- (NSURLRequest*)constructURLRequest:(Mixi*)mixi;

/**
 * \brief ユーザーエージェントを取得
 *
 * \return ユーザーエージェント
 */
+ (NSString*)userAgent;

@end
