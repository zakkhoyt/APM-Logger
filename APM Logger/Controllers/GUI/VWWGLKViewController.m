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

@interface VWWGLKViewController ()
@property (strong, nonatomic) EAGLContext *context;
@property (nonatomic, strong) VWWScene *scene;
@end

@implementation VWWGLKViewController
@synthesize context = _context;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    if (!self.context) {
        NSLog(@"Failed to create ES context");
    }
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    [EAGLContext setCurrentContext:self.context];
    
    self.scene = [[VWWScene alloc]init];
    self.scene.clearColor = GLKVector4Make(0.1, 0.9, 0.9, 0.0);

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
    NSLog(@"x: %f y: %f", x, y);

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
    [self updateSceneBounds:toInterfaceOrientation];
//    NSLog(@"%s: bounds: %@", __PRETTY_FUNCTION__, NSStringFromCGRect(self.view.bounds));
}


-(void)updateSceneBounds:(UIInterfaceOrientation)toInterfaceOrientation{
    VWW_LOG_DEBUG(@"self.view.bounds: %@", NSStringFromCGRect(self.view.bounds));
    if(toInterfaceOrientation == UIInterfaceOrientationPortrait || toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown){
        // Moving to portrait
        float x = 1.0;
        float y = self.view.bounds.size.width / (float)self.view.bounds.size.height;
        self.scene.left   = -x;
        self.scene.right  =  x;
        self.scene.bottom = -y;
        self.scene.top    =  y;
        NSLog(@"x: %f y: %f", x, y);
        
    } else {
        float x = self.view.bounds.size.height / (float)self.view.bounds.size.width;
        float y = 1.0;
        self.scene.left   = -x;
        self.scene.right  =  x;
        self.scene.bottom = -y;
        self.scene.top    =  y;
        NSLog(@"x: %f y: %f", x, y);
    }
    
}

#pragma mark - GLKViewDelegate

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    
    [self.scene render];
}

- (void)update {
    
    [self.scene update];
}

@end