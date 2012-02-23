//
//  ScreenStatus.m
//  Created by Mitsuharu Emoto on 2010/07/05.
//

#import "ScreenStatus.h"

#define INVERVAL (1.0/15.0)
#define THRESHOLD (0.5)

@implementation ScreenStatus

@synthesize isScreenLock;
@synthesize isPortrait;
@synthesize isLandscape;
@synthesize physicalOrientation;

#pragma mark - Lifecycle

-(id)init
{
	if ( self = [super init])
	{
	}
	return self;
}

-(void)dealloc
{
	[self stop];
}

-(void)start
{
    [[UIAccelerometer sharedAccelerometer] setUpdateInterval:INVERVAL];
    [[UIAccelerometer sharedAccelerometer] setDelegate:self];
}

-(void)stop
{
    [[UIAccelerometer sharedAccelerometer] setDelegate:nil];
}

#pragma mark - UIAccelerometerDelegate

- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration
{
	force_.x = acceleration.x;
	force_.y = acceleration.y;
	force_.z = acceleration.z;;
}

#pragma mark - Instance method

-(BOOL)isScreenLock
{	
	if ( [UIDevice currentDevice].orientation == UIDeviceOrientationPortrait )
	{		
		FORCE portrait;
		portrait.x = 0.0;
		portrait.y = -1.0;
		portrait.z = 0.0;
		
		float diff = sqrt( (portrait.x-force_.x)*(portrait.x-force_.x)
						  + (portrait.y-force_.y)*(portrait.y-force_.y)
						  + (portrait.z-force_.z)*(portrait.z-force_.z) );
		if ( diff > THRESHOLD )
		{
			return YES;
		}
	}
	
	return NO;
}

-(BOOL)isPortrait
{
    return UIDeviceOrientationIsPortrait([self physicalOrientation]);
}

-(BOOL)isLandscape
{
    return UIDeviceOrientationIsLandscape([self physicalOrientation]);
}

-(UIDeviceOrientation)physicalOrientation
{
	FORCE orient[10];
	
	orient[UIDeviceOrientationPortrait].x = 0.0;
	orient[UIDeviceOrientationPortrait].y = -1.0;
	orient[UIDeviceOrientationPortrait].z = 0.0;
	
	orient[UIDeviceOrientationPortraitUpsideDown].x = 0.0;
	orient[UIDeviceOrientationPortraitUpsideDown].y = 1.0;
	orient[UIDeviceOrientationPortraitUpsideDown].z = 0.0;

	orient[UIDeviceOrientationLandscapeLeft].x = -1.0;
	orient[UIDeviceOrientationLandscapeLeft].y = 0.0;
	orient[UIDeviceOrientationLandscapeLeft].z = 0.0;

	orient[UIDeviceOrientationLandscapeRight].x = 1.0;
	orient[UIDeviceOrientationLandscapeRight].y = 0.0;
	orient[UIDeviceOrientationLandscapeRight].z = 0.0;
	
	orient[UIDeviceOrientationFaceUp].x = 0.0;
	orient[UIDeviceOrientationFaceUp].y = 0.0;
	orient[UIDeviceOrientationFaceUp].z = -1.0;
	
	orient[UIDeviceOrientationFaceDown].x = 0.0;
	orient[UIDeviceOrientationFaceDown].y = 0.0;
	orient[UIDeviceOrientationFaceDown].z = 1.0;
	
	for( int i = UIDeviceOrientationPortrait; i <= UIDeviceOrientationFaceDown; i++ )
	{
		float diff = sqrt((orient[i].x-force_.x)*(orient[i].x-force_.x) 
						  + (orient[i].y-force_.y)*(orient[i].y-force_.y)
						  + (orient[i].z-force_.z)*(orient[i].z-force_.z) );
		if ( diff < THRESHOLD )
		{
			return i;
		}
	}
	
	return UIDeviceOrientationUnknown;	
}

#pragma mark - Class method

+(UIDeviceOrientation)orientation:(UIAcceleration *)acceleration
{
	FORCE orient[10];
	
	orient[UIDeviceOrientationPortrait].x = 0.0;
	orient[UIDeviceOrientationPortrait].y = -1.0;
	orient[UIDeviceOrientationPortrait].z = 0.0;
	
	orient[UIDeviceOrientationPortraitUpsideDown].x = 0.0;
	orient[UIDeviceOrientationPortraitUpsideDown].y = 1.0;
	orient[UIDeviceOrientationPortraitUpsideDown].z = 0.0;
    
	orient[UIDeviceOrientationLandscapeLeft].x = -1.0;
	orient[UIDeviceOrientationLandscapeLeft].y = 0.0;
	orient[UIDeviceOrientationLandscapeLeft].z = 0.0;
    
	orient[UIDeviceOrientationLandscapeRight].x = 1.0;
	orient[UIDeviceOrientationLandscapeRight].y = 0.0;
	orient[UIDeviceOrientationLandscapeRight].z = 0.0;
	
	orient[UIDeviceOrientationFaceUp].x = 0.0;
	orient[UIDeviceOrientationFaceUp].y = 0.0;
	orient[UIDeviceOrientationFaceUp].z = -1.0;
	
	orient[UIDeviceOrientationFaceDown].x = 0.0;
	orient[UIDeviceOrientationFaceDown].y = 0.0;
	orient[UIDeviceOrientationFaceDown].z = 1.0;
	
	for( int i = UIDeviceOrientationPortrait; i <= UIDeviceOrientationFaceDown; i++ )
	{
		float diff = sqrt((orient[i].x-acceleration.x)*(orient[i].x-acceleration.x) 
						  + (orient[i].y-acceleration.y)*(orient[i].y-acceleration.y)
						  + (orient[i].z-acceleration.z)*(orient[i].z-acceleration.z) );
		if ( diff < THRESHOLD )
		{
			return i;
		}
	}
	
	return UIDeviceOrientationUnknown;	
}

+(UIDeviceOrientation)orientation2:(UIAcceleration *)acceleration
{
    double X = ABS(acceleration.x),Y = ABS(acceleration.y),Z = ABS(acceleration.z);
    Z -= 0.25;
    
    if(X > Y){
        if(X > Z){//X > Y,Z
            return (acceleration.x > 0) ? UIDeviceOrientationLandscapeRight : UIDeviceOrientationLandscapeLeft;
        }else{//Z >= X,Y
            return (acceleration.z > 0) ? UIDeviceOrientationFaceDown : UIDeviceOrientationFaceUp;
        }
    }else{
        if(Y > Z){//Y >= X,Z
            return (acceleration.y > 0) ? UIDeviceOrientationPortraitUpsideDown : UIDeviceOrientationPortrait;
        }else{//Z >= X,Y
            return (acceleration.z > 0) ? UIDeviceOrientationFaceDown : UIDeviceOrientationFaceUp;            
        }
    }
}

+(BOOL)orientationIsPortrait:(UIAcceleration *)acceleration
{
    return UIDeviceOrientationIsPortrait([ScreenStatus orientation:acceleration]);
}

+(BOOL)orientationIsLandscape:(UIAcceleration *)acceleration
{
    return UIDeviceOrientationIsLandscape([ScreenStatus orientation:acceleration]);    
}

@end
