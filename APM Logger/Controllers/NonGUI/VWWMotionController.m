//
//  APM Logger
//
//  Created by Zakk Hoyt 2014
//  Copyright (c) 2014 Zakk Hoyt.
//


#import "VWWMotionController.h"
@interface VWWMotionController ()
@property (nonatomic, strong) CMMotionManager *motionManager;
@property (nonatomic) BOOL accelerometerRunning;
@property (nonatomic) BOOL magnetometerRunning;
@property (nonatomic) BOOL gyrosRunning;
@property (nonatomic) BOOL deviceRunning;

@property (nonatomic, strong) VWWDeviceLimits *accelerometersLimits;
@property (nonatomic, strong) VWWDeviceLimits *gyroscopesLimits;
@property (nonatomic, strong) VWWDeviceLimits *magnetometersLimits;

@end


@implementation VWWMotionController
#pragma mark Public methods

+(instancetype)sharedInstance{
    static VWWMotionController *instance;
    if(instance == nil){
        instance = [[VWWMotionController alloc]init];
    }
    return instance;
}

-(id)init{
    self = [super init];
    if(self){
        [self initializeClass];
    }
    return self;
}

+(BOOL)serviceExists{
    VWW_LOG_TODO;
    return YES;
    
}

-(void)startAll{
    [self startAccelerometer];
    [self startGyroscope];
    [self startMagnetometer];
    [self startDevice];
    
}
-(void)stopAll{
    [self stopAccelerometer];
    [self stopGyroscope];
    [self stopMagnetometer];
    [self stopDevice];
    
}

-(void)resetAllLimits{
    [self.accelerometersLimits reset];
    [self.gyroscopesLimits reset];
    [self.magnetometersLimits reset];
}


-(void)setUpdateInterval:(NSTimeInterval)updateInterval{
    _updateInterval = updateInterval;
    
    if(self.accelerometerRunning){
        self.motionManager.accelerometerUpdateInterval = self.updateInterval;
    }
    
    if(self.gyrosRunning){
        self.motionManager.gyroUpdateInterval = self.updateInterval;
    }
    
    if(self.magnetometerRunning){
        self.motionManager.magnetometerUpdateInterval = self.updateInterval;
    }
    
    if(self.deviceRunning){
        self.motionManager.deviceMotionUpdateInterval = self.updateInterval;
    }
    
}

#pragma mark Private methods

-(void)initializeClass{
    self.accelerometersLimits = [[VWWDeviceLimits alloc]init];
    self.gyroscopesLimits = [[VWWDeviceLimits alloc]init];
    self.magnetometersLimits = [[VWWDeviceLimits alloc]init];

    self.motionManager = [[CMMotionManager alloc]init];
    self.updateInterval = 1/30.0f;
}


-(void)startAccelerometer{
    if(self.accelerometerRunning == YES) return;
    
    self.motionManager.accelerometerUpdateInterval = self.updateInterval;
    
    NSOperationQueue* accelerometerQueue = [[NSOperationQueue alloc] init];
    
    CMAccelerometerHandler accelerometerHandler = ^(CMAccelerometerData *accelerometerData, NSError *error) {
        
        self.accelerometersLimits.x.max = MAX(self.accelerometersLimits.x.max, accelerometerData.acceleration.x);
        self.accelerometersLimits.x.min = MIN(self.accelerometersLimits.x.min, accelerometerData.acceleration.x);
        self.accelerometersLimits.y.max = MAX(self.accelerometersLimits.y.max, accelerometerData.acceleration.y);
        self.accelerometersLimits.y.min = MIN(self.accelerometersLimits.y.min, accelerometerData.acceleration.y);
        self.accelerometersLimits.z.max = MAX(self.accelerometersLimits.z.max, accelerometerData.acceleration.z);
        self.accelerometersLimits.z.min = MIN(self.accelerometersLimits.z.min, accelerometerData.acceleration.z);
        
        if(self.delegate && [self.delegate respondsToSelector:@selector(motionController:didUpdateAcceleremeters:limits:)]){
            [self.delegate motionController:self didUpdateAcceleremeters:accelerometerData limits:self.accelerometersLimits];
        }
    };
    
    [self.motionManager startAccelerometerUpdatesToQueue:accelerometerQueue withHandler:[accelerometerHandler copy]];
    self.accelerometerRunning = YES;
    VWW_LOG_DEBUG(@"Started Accelerometer");
}


-(void)stopAccelerometer{
    if(self.accelerometerRunning == NO) return;
    
    [self.motionManager stopAccelerometerUpdates];
    self.accelerometerRunning = NO;
    VWW_LOG_DEBUG(@"Stopped Accelerometer");
}

-(void)startGyroscope{
    if(self.gyrosRunning == YES) return;
    
    self.motionManager.gyroUpdateInterval = self.updateInterval;
    
    NSOperationQueue* gyroQueue = [[NSOperationQueue alloc] init];
    
    CMGyroHandler gyroHandler = ^(CMGyroData *gyroData, NSError *error) {
        
        self.gyroscopesLimits.x.max = MAX(self.gyroscopesLimits.x.max, gyroData.rotationRate.x);
        self.gyroscopesLimits.x.min = MIN(self.gyroscopesLimits.x.min, gyroData.rotationRate.x);
        self.gyroscopesLimits.y.max = MAX(self.gyroscopesLimits.y.max, gyroData.rotationRate.y);
        self.gyroscopesLimits.y.min = MIN(self.gyroscopesLimits.y.min, gyroData.rotationRate.y);
        self.gyroscopesLimits.z.max = MAX(self.gyroscopesLimits.z.max, gyroData.rotationRate.z);
        self.gyroscopesLimits.z.min = MIN(self.gyroscopesLimits.z.min, gyroData.rotationRate.z);

        if(self.delegate && [self.delegate respondsToSelector:@selector(motionController:didUpdateGyroscopes:limits:)]){
            [self.delegate motionController:self didUpdateGyroscopes:gyroData limits:self.gyroscopesLimits];
        }
    };
    
    [self.motionManager startGyroUpdatesToQueue:gyroQueue withHandler:[gyroHandler copy]];
    self.gyrosRunning = YES;
    VWW_LOG_DEBUG(@"Started Gyros");
    
}
-(void)stopGyroscope{
    if(self.gyrosRunning == NO) return;
    
    [self.motionManager stopGyroUpdates];
    self.gyrosRunning = NO;
    VWW_LOG_DEBUG(@"Stopped Gyros");
}

-(void)startMagnetometer{
    if(self.magnetometerRunning == YES) return;
    
    self.motionManager.magnetometerUpdateInterval = self.updateInterval;
    
    NSOperationQueue* magnetometerQueue = [[NSOperationQueue alloc] init];
    
    CMMagnetometerHandler magnetometerHandler = ^(CMMagnetometerData *magnetometerData, NSError *error) {
        
        self.magnetometersLimits.x.max = MAX(self.magnetometersLimits.x.max, magnetometerData.magneticField.x);
        self.magnetometersLimits.x.min = MIN(self.magnetometersLimits.x.min, magnetometerData.magneticField.x);
        self.magnetometersLimits.y.max = MAX(self.magnetometersLimits.y.max, magnetometerData.magneticField.y);
        self.magnetometersLimits.y.min = MIN(self.magnetometersLimits.y.min, magnetometerData.magneticField.y);
        self.magnetometersLimits.z.max = MAX(self.magnetometersLimits.z.max, magnetometerData.magneticField.z);
        self.magnetometersLimits.z.min = MIN(self.magnetometersLimits.z.min, magnetometerData.magneticField.z);

        if(self.delegate && [self.delegate respondsToSelector:@selector(motionController:didUpdateMagnetometers:limits:)]){
            [self.delegate motionController:self didUpdateMagnetometers:magnetometerData limits:self.magnetometersLimits];
        }
    };
    
    [self.motionManager startMagnetometerUpdatesToQueue:magnetometerQueue withHandler:[magnetometerHandler copy]];
    self.magnetometerRunning = YES;
    VWW_LOG_DEBUG(@"Started Magnetometer");
    
}
-(void)stopMagnetometer{
    if(self.magnetometerRunning == NO) return;
    
    [self.motionManager stopMagnetometerUpdates];
    self.magnetometerRunning = NO;
    VWW_LOG_DEBUG(@"Stopped Magnetometer");
}

-(void)startDevice{
    if(self.deviceRunning == YES) return;
    
    self.motionManager.deviceMotionUpdateInterval = self.updateInterval;
    
    NSOperationQueue* deviceQueue = [[NSOperationQueue alloc] init];
    
    CMDeviceMotionHandler deviceHandler = ^(CMDeviceMotion *motion, NSError *error) {
        if(self.delegate && [self.delegate respondsToSelector:@selector(motionController:didUpdateAttitude:)]){
            [self.delegate motionController:self didUpdateAttitude:motion];
        }
    };
    
    [self.motionManager startDeviceMotionUpdatesToQueue:deviceQueue withHandler:deviceHandler];
    self.deviceRunning = YES;
    VWW_LOG_DEBUG(@"Started device motion");
    
}
-(void)stopDevice{
    if(self.deviceRunning == NO) return;
    
    [self.motionManager stopDeviceMotionUpdates];
    self.deviceRunning = NO;
    VWW_LOG_DEBUG(@"Stopped device motion");
}



@end
