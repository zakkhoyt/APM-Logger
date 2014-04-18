//
//  APM Logger
//
//  Created by Zakk Hoyt 2014
//  Copyright (c) 2014 Zakk Hoyt.
//


#import <Foundation/Foundation.h>
#import <CoreMotion/CoreMotion.h>
#import "VWWDeviceLimits.h"


@class VWWMotionController;

@protocol VWWMotionControllerDelegate <NSObject>
@required

@optional
-(void)motionController:(VWWMotionController*)sender didUpdateAcceleremeters:(CMAccelerometerData*)accelerometers limits:(VWWDeviceLimits*)limits;
-(void)motionController:(VWWMotionController*)sender didUpdateGyroscopes:(CMGyroData*)gyroscopes limits:(VWWDeviceLimits*)limits;
-(void)motionController:(VWWMotionController*)sender didUpdateMagnetometers:(CMMagnetometerData*)magnetometers limits:(VWWDeviceLimits*)limits;
-(void)motionController:(VWWMotionController*)sender didUpdateAttitude:(CMDeviceMotion*)attitude;

@end


@interface VWWMotionController : NSObject
+(VWWMotionController*)sharedInstance;
@property (nonatomic, weak) id <VWWMotionControllerDelegate> delegate;
@property (nonatomic) NSTimeInterval updateInterval;

-(void)startAccelerometer;
-(void)stopAccelerometer;


-(void)startGyroscope;
-(void)stopGyroscope;


-(void)startMagnetometer;
-(void)stopMagnetometer;


-(void)startAll;
-(void)stopAll;
-(void)resetAllLimits;
@end
