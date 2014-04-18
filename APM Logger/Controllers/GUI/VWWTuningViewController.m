//
//  VWWTuningViewController.m
//  APM Logger
//
//  Created by Zakk Hoyt on 4/12/14.
//  Copyright (c) 2014 Zakk Hoyt. All rights reserved.
//

#import "VWWTuningViewController.h"
@import GLKit;
#import "VWWGraphScene.h"
#import "VWWMotionController.h"



#define NUM_POINTS 320

@interface VWWTuningViewController () <VWWMotionControllerDelegate>
@property (strong, nonatomic) EAGLContext *context;
@property (nonatomic, strong) VWWGraphScene *graphScene;
@property (nonatomic, strong) VWWMotionController *motionController;
@property (nonatomic, strong) NSMutableArray *dataForPlot;
@end

@implementation VWWTuningViewController
@synthesize context = _context;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    self.dataForPlot = [[NSMutableArray alloc]initWithCapacity:NUM_POINTS];
    for(int x = 0; x < 320; x++){
        NSDictionary *d = @{@"x" : @(0),
                            @"y" : @(0),
                            @"z" : @(0)};
        [self.dataForPlot addObject:d];
    }
    
    
    
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    if (!self.context) {
        NSLog(@"Failed to create ES context");
    }
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    [EAGLContext setCurrentContext:self.context];
    
    self.preferredFramesPerSecond = 30;
    

    
    self.graphScene = [[VWWGraphScene alloc]init];
    self.graphScene.clearColor = GLKVector4Make(0.0, 0.0, 0.0, 0.0);
    self.graphScene.dataForPlot = self.dataForPlot;
    
    
    
    self.motionController = [VWWMotionController sharedInstance];
    self.motionController.delegate = self;
    self.motionController.updateInterval = 1/200.0;
    [self.motionController startAccelerometer];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.graphScene.left   = -1.0;
    self.graphScene.right  =  1.0;
    self.graphScene.bottom = -1.0;
    self.graphScene.top    =  1.0;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    return YES;
}

//-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
//    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
//}
//
//-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
//    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
//}
//-(void)updateSceneBounds:(UIInterfaceOrientation)toInterfaceOrientation{
//}

#pragma mark VWWMotionControllerDelegate;

-(void)motionController:(VWWMotionController*)sender didUpdateAcceleremeters:(CMAccelerometerData*)accelerometers{
    @synchronized(self.graphScene.dataForPlot){
        static NSInteger counter = 0;
        [self.dataForPlot removeObjectAtIndex:0];
        NSDictionary *d = @{@"x" : @(accelerometers.acceleration.x),
                            @"y" : @(accelerometers.acceleration.y),
                            @"z" : @(accelerometers.acceleration.z)};
        [self.dataForPlot addObject:d];
        
        counter++;
    }
    
}


#pragma mark - GLKViewDelegate

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    [self.graphScene render];
}

- (void)update {
    [self.graphScene update];
}

@end
