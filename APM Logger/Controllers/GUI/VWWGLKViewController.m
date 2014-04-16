//
//  SGGViewController.m
//  SimpleGLKitGame
//
//  Created by Zakk Hoyt on 4/16/14.
//  Copyright (c) 2014 Zakk Hoyt. All rights reserved.
//
//  http://www.raywenderlich.com/9743/how-to-create-a-simple-2d-iphone-game-with-opengl-es-2-0-and-glkit-part-1



#import "VWWGLKViewController.h"




@interface VWWGLKViewController ()
@property (strong, nonatomic) EAGLContext *context;
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
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

#pragma mark - GLKViewDelegate

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    glClearColor(0, 104.0/255.0, 55.0/255.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
}

- (void)update {
    
    
}

@end