//
//  APM Logger
//
//  Created by Zakk Hoyt 2014
//  Copyright (c) 2014 Zakk Hoyt.
//


#import <Foundation/Foundation.h>
#import <CoreMotion/CoreMotion.h>

@class VWWMotionController;

@protocol VWWMotionControllerDelegate <NSObject>
@optional
-(void)motionController:(VWWMotionController*)sender didUpdateAcceleremeters:(CMAccelerometerData*)accelerometers;
-(void)motionController:(VWWMotionController*)sender didUpdateGyroscopes:(CMGyroData*)gyroscopes;
-(void)motionController:(VWWMotionController*)sender didUpdateMagnetometers:(CMMagnetometerData*)magnetometers;
-(void)motionController:(VWWMotionController*)sender didUpdateAttitude:(CMDeviceMotion*)attitude;
@end


@interface VWWMotionController : NSObject
+(VWWMotionController*)sharedInstance;
@property (nonatomic, weak) id <VWWMotionControllerDelegate> delegate;
@property (nonatomic) NSTimeInterval updateInterval;

-(void)startAccelerometer;
-(void)stopAccelerometer;

-(void)startAll;
-(void)stopAll;
-(void)resetAll;
@end
