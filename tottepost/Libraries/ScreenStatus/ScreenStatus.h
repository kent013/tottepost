//
//  ScreenStatus.h
//  Created by Mitsuharu Emoto on 2010/07/05.
//

// 2010/07/05 （リリース）
// ・加速度センサーを使って端末の向きを検出する
// ・画面ロック中でも検出可能

// 2011/11/03
// ・ARC対応化に関して修正
// ・クラスメソッドを追加．傾き変化を検出したいときはimport元でdelegateを設定して，accelerationを調べる

#import <Foundation/Foundation.h>

typedef struct FORCE 
{
	float x;
	float y;
	float z;
}FORCE;

@interface ScreenStatus : NSObject < UIAccelerometerDelegate >
{
	FORCE force_;
}

-(void)start;
-(void)stop;
-(BOOL)isScreenLock;
-(BOOL)isPortrait;  
-(BOOL)isLandscape;
-(UIDeviceOrientation)physicalOrientation;

+(UIDeviceOrientation)orientation:(UIAcceleration *)acceleration;
+(UIDeviceOrientation)orientation2:(UIAcceleration *)acceleration;
+(BOOL)orientationIsPortrait:(UIAcceleration *)acceleration;  
+(BOOL)orientationIsLandscape:(UIAcceleration *)acceleration;

@property (getter=isScreenLock, readonly) BOOL isScreenLock;
@property (getter=isPortrait, readonly) BOOL isPortrait;
@property (getter=isLandscape, readonly) BOOL isLandscape;
@property (getter=physicalOrientation, readonly) UIDeviceOrientation physicalOrientation;

@end
