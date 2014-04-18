//
//  VWWGraphScene.m
//  RCTools
//
//  Created by Zakk Hoyt on 4/17/14.
//  Copyright (c) 2014 Zakk Hoyt. All rights reserved.
//

#import "VWWGraphScene.h"



const NSUInteger kSamples = 320;
GLfloat  xVertices[kSamples * 2] = {};
//GLfloat  yVertices[kSamples] = {};
//GLfloat  zVertices[kSamples] = {};
@interface VWWGraphScene () {
    GLKVector4 clearColor;
    GLKBaseEffect *effect;
    float left, right, bottom, top;
}
@end




@implementation VWWGraphScene
@synthesize clearColor;
@synthesize left, right, bottom, top;


-(id)init{
    self = [super init];
    if(self){
        effect = [[GLKBaseEffect alloc] init];
        effect.transform.projectionMatrix = GLKMatrix4MakeOrtho(left, right, bottom, top, 1, -1);
    }
    return self;
}

-(void)update {
    //  NSLog(@"in EEScene's update");
    
    @synchronized(self.dataForPlot){
        glClearColor(clearColor.r, clearColor.g, clearColor.b, clearColor.a);
        glClear(GL_COLOR_BUFFER_BIT);
        
        for(NSInteger index = 0; index < 320 * 2; index+=2){
            int i = index / 2;
            NSDictionary *d = self.dataForPlot[i];
            NSNumber *yNumber = d[@"x"];
            
            GLfloat x = i * (2.0 / (float)320);
            x -= 1.0;
            xVertices[index] = x;
            
            GLfloat y = yNumber.floatValue / 10.0f;
            xVertices[index + 1] = y;
        }
        
        //        for(NSInteger index = 0; index < kSamples * 2; index+=2){
        //            int i = index / 2;
        //            NSDictionary *d = self.dataForPlot[i];
        //            NSNumber *yNumber = d[@"y"];
        //
        //            GLfloat x = i * (2.0 / (float)320);
        //            x -= 1.0;
        //            yVertices[index] = x;
        //
        //            GLfloat y = yNumber.floatValue / 10.0f;
        //            yVertices[index + 1] = y;
        //        }
        
    }
}




//    float vertices[] = {-1, -1,
//        1, -1,
//        0,  1};

//    float vertices[] = {-0.5, -0.5,
//        0.5, -0.5,
//        0,  0.5};

//    GLfloat vertices[24] = {
//        0.0, 0.0,
//        0.5, 0.0,
//        0.5, 0.5,
//
//        0.0, 0.0,
//        0.0, 0.5,
//        -0.5, 0.5,
//
//        0.0, 0.0,
//        -0.5, 0.0,
//        -0.5, -0.5,
//
//        0.0, 0.0,
//        0.0, -0.5,
//        0.5, -0.5,
//    };






-(void)render {
    //    effect.useConstantColor = YES;
    effect.transform.projectionMatrix = GLKMatrix4MakeOrtho(left, right, bottom, top, 1, -1);
    [effect prepareToDraw];
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 2, GL_FLOAT, GL_FALSE, 0, xVertices);
    glDrawArrays(GL_LINE_STRIP, 0, 320);
    
    
    
    
    glDisableVertexAttribArray(GLKVertexAttribPosition);
    
    
}


@end
