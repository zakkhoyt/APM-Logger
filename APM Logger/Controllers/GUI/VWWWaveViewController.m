//
//  VWWWaveViewController.m
//  RCTools
//
//  Created by Zakk Hoyt on 4/19/14.
//  Copyright (c) 2014 Zakk Hoyt. All rights reserved.
//

#import "VWWWaveViewController.h"
#import "VWWWaveScene.h"

@interface VWWWaveViewController ()
@property (strong, nonatomic) EAGLContext *context;
@property (nonatomic, strong) VWWWaveScene *waveScene;
@end
@implementation VWWWaveViewController


- (void)viewDidLoad
{
 
    [super viewDidLoad];

    [UIApplication sharedApplication].statusBarHidden = YES;
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    if (!self.context) {
        NSLog(@"Failed to create ES context");
    }
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    [EAGLContext setCurrentContext:self.context];
    
    self.preferredFramesPerSecond = 60;
    
    self.waveScene = [[VWWWaveScene alloc]init];
    self.waveScene.clearColor = GLKVector4Make(0.0, 0.0, 0.0, 0.0);
    self.waveScene.owner = self;
    self.waveScene.size = 34;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

//    self.waveScene.left   = -2.0;
//    self.waveScene.right  =  2.0;
//    self.waveScene.bottom = -2.0;
//    self.waveScene.top    =  2.0;
    
    // Moving to portrait
    float x = 1.0;
    float y = self.view.bounds.size.height / (float)self.view.bounds.size.width;
    self.waveScene.left   = -10*x;
    self.waveScene.right  =  10*x;
    self.waveScene.bottom = -10*y;
    self.waveScene.top    =  10*y;

}

-(BOOL)prefersStatusBarHidden{
    return YES;
}
#pragma mark - GLKViewDelegate

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    [self.waveScene render];
}

- (void)update {
    [self.waveScene update];
}
@end
