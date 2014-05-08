//
//  SGGViewController.m
//  SimpleGLKitGame
//
//  Created by Zakk Hoyt on 4/16/14.
//  Copyright (c) 2014 Zakk Hoyt. All rights reserved.
//
//  http://www.raywenderlich.com/9743/how-to-create-a-simple-2d-iphone-game-with-opengl-es-2-0-and-glkit-part-1
// http://games.ianterrell.com/how-to-draw-2d-shapes-with-glkit/


#import "VWWGLKViewController.h"
#import "VWWScene.h"
#import "VWWGraphScene.h"
#import "VWWMotionController.h"
#import "VWWAudioController.h"

#define NUM_POINTS 320

@interface VWWGLKViewController () <VWWMotionControllerDelegate>
@property (strong, nonatomic) EAGLContext *context;
@property (nonatomic, strong) VWWScene *scene;
@property (nonatomic, strong) VWWGraphScene *graphScene;
@property (nonatomic, strong) VWWMotionController *motionController;
@property (nonatomic, strong) NSMutableArray *dataForPlot;
@property (nonatomic, strong) VWWAudioController *audioController;
@end

@implementation VWWGLKViewController
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
    
    self.preferredFramesPerSecond = 60;
    
    self.scene = [[VWWScene alloc]init];
//    self.scene.clearColor = GLKVector4Make(0.1, 0.9, 0.9, 0.0);
//    self.scene.clearColor = GLKVector4Make(0.0, 0.0, 0.0, 0.0);

    self.graphScene = [[VWWGraphScene alloc]init];
    self.graphScene.clearColor = GLKVector4Make(0.0, 0.0, 0.0, 0.0);
    self.graphScene.dataForPlot = self.dataForPlot;

    
    
    self.motionController = [VWWMotionController sharedInstance];
    self.motionController.delegate = self;
    self.motionController.updateInterval = 1/200.0;
    [self.motionController startAccelerometer];
    
    self.audioController = [[VWWAudioController alloc]init];
    [self.audioController start];

}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    // Moving to portrait
    float x = 1.0;
    float y = self.view.bounds.size.height / (float)self.view.bounds.size.width;
    self.scene.left   = -x;
    self.scene.right  =  x;
    self.scene.bottom = -y;
    self.scene.top    =  y;

    self.graphScene.left   = -1.0;
    self.graphScene.right  =  1.0;
    self.graphScene.bottom = -1.0;
    self.graphScene.top    =  1.0;

    
    NSLog(@"x: %f y: %f", x, y);

}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.audioController stop];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
//    [self updateSceneBounds:fromInterfaceOrientation];
//    NSLog(@"%s: bounds: %@", __PRETTY_FUNCTION__, NSStringFromCGRect(self.view.bounds));
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
//    [self updateSceneBounds:toInterfaceOrientation];
//    NSLog(@"%s: bounds: %@", __PRETTY_FUNCTION__, NSStringFromCGRect(self.view.bounds));
}


-(void)updateSceneBounds:(UIInterfaceOrientation)toInterfaceOrientation{
//    VWW_LOG_DEBUG(@"self.view.bounds: %@", NSStringFromCGRect(self.view.bounds));
//    if(toInterfaceOrientation == UIInterfaceOrientationPortrait || toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown){
//        // Moving to portrait
//        float x = 1.0;
//        float y = self.view.bounds.size.width / (float)self.view.bounds.size.height;
//        self.scene.left   = -x;
//        self.scene.right  =  x;
//        self.scene.bottom = -y;
//        self.scene.top    =  y;
//        
//        self.graphScene.left   = -x;
//        self.graphScene.right  =  x;
//        self.graphScene.bottom = -y;
//        self.graphScene.top    =  y;
//
//        NSLog(@"x: %f y: %f", x, y);
//        
//    } else {
//        float x = self.view.bounds.size.height / (float)self.view.bounds.size.width;
//        float y = 1.0;
//        self.scene.left   = -x;
//        self.scene.right  =  x;
//        self.scene.bottom = -y;
//        self.scene.top    =  y;
//        
//        self.graphScene.left   = -x;
//        self.graphScene.right  =  x;
//        self.graphScene.bottom = -y;
//        self.graphScene.top    =  y;
//
//        NSLog(@"x: %f y: %f", x, y);
//    }
    
}

#pragma mark VWWMotionControllerDelegate;

-(void)motionController:(VWWMotionController*)sender didUpdateAcceleremeters:(CMAccelerometerData*)accelerometers limits:(VWWDeviceLimits *)limits{
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
    
//    [self.scene render];
    [self.graphScene render];
}

- (void)update {
    
//    [self.scene update];
    
    [self.graphScene update];
}

@end