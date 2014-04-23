//
//  VWWWaveScene.m
//  RCTools
//
//  Created by Zakk Hoyt on 4/19/14.
//  Copyright (c) 2014 Zakk Hoyt. All rights reserved.
//

#import "VWWWaveScene.h"


typedef struct {
    float Position[3];
//    float Color[4];
} Vertex;

const NSUInteger kCount = 60;
//Vertex CVertices[] = {};
//GLushort CIndices[] = {};

//const NSUInteger kCount = 60;
//Vertex CVertices[kCount] = {{{1.000000, 0.000000, 0.000000}, {1.000000, 1.000000, 1.000000, 1.000000}},{{0.994138, 0.108119, 0.000000}, {1.000000, 1.000000, 1.000000, 1.000000}},{{0.976621, 0.214970, 0.000000}, {1.000000, 1.000000, 1.000000, 1.000000}},{{0.947653, 0.319302, 0.000000}, {1.000000, 1.000000, 1.000000, 1.000000}},{{0.907575, 0.419889, 0.000000}, {1.000000, 1.000000, 1.000000, 1.000000}},{{0.856857, 0.515554, 0.000000}, {1.000000, 1.000000, 1.000000, 1.000000}},{{0.796093, 0.605174, 0.000000}, {1.000000, 1.000000, 1.000000, 1.000000}},{{0.725995, 0.687699, 0.000000}, {1.000000, 1.000000, 1.000000, 1.000000}},{{0.647386, 0.762162, 0.000000}, {1.000000, 1.000000, 1.000000, 1.000000}},{{0.561187, 0.827689, 0.000000}, {1.000000, 1.000000, 1.000000, 1.000000}},{{0.468408, 0.883512, 0.000000}, {1.000000, 1.000000, 1.000000, 1.000000}},{{0.370138, 0.928977, 0.000000}, {1.000000, 1.000000, 1.000000, 1.000000}},{{0.267528, 0.963550, 0.000000}, {1.000000, 1.000000, 1.000000, 1.000000}},{{0.161782, 0.986827, 0.000000}, {1.000000, 1.000000, 1.000000, 1.000000}},{{0.054139, 0.998533, 0.000000}, {1.000000, 1.000000, 1.000000, 1.000000}},{{-0.054139, 0.998533, 0.000000}, {1.000000, 1.000000, 1.000000, 1.000000}},{{-0.161782, 0.986827, 0.000000}, {1.000000, 1.000000, 1.000000, 1.000000}},{{-0.267528, 0.963550, 0.000000}, {1.000000, 1.000000, 1.000000, 1.000000}},{{-0.370138, 0.928977, 0.000000}, {1.000000, 1.000000, 1.000000, 1.000000}},{{-0.468408, 0.883512, 0.000000}, {1.000000, 1.000000, 1.000000, 1.000000}},{{-0.561187, 0.827689, 0.000000}, {1.000000, 1.000000, 1.000000, 1.000000}},{{-0.647386, 0.762162, 0.000000}, {1.000000, 1.000000, 1.000000, 1.000000}},{{-0.725995, 0.687699, 0.000000}, {1.000000, 1.000000, 1.000000, 1.000000}},{{-0.796093, 0.605174, 0.000000}, {1.000000, 1.000000, 1.000000, 1.000000}},{{-0.856857, 0.515554, 0.000000}, {1.000000, 1.000000, 1.000000, 1.000000}},{{-0.907575, 0.419889, 0.000000}, {1.000000, 1.000000, 1.000000, 1.000000}},{{-0.947653, 0.319302, 0.000000}, {1.000000, 1.000000, 1.000000, 1.000000}},{{-0.976621, 0.214970, 0.000000}, {1.000000, 1.000000, 1.000000, 1.000000}},{{-0.994138, 0.108119, 0.000000}, {1.000000, 1.000000, 1.000000, 1.000000}},{{-1.000000, -0.000000, 0.000000}, {1.000000, 1.000000, 1.000000, 1.000000}},{{-0.994138, -0.108119, 0.000000}, {1.000000, 1.000000, 1.000000, 1.000000}},{{-0.976620, -0.214971, 0.000000}, {1.000000, 1.000000, 1.000000, 1.000000}},{{-0.947653, -0.319301, 0.000000}, {1.000000, 1.000000, 1.000000, 1.000000}},{{-0.907575, -0.419889, 0.000000}, {1.000000, 1.000000, 1.000000, 1.000000}},{{-0.856857, -0.515554, 0.000000}, {1.000000, 1.000000, 1.000000, 1.000000}},{{-0.796093, -0.605174, 0.000000}, {1.000000, 1.000000, 1.000000, 1.000000}},{{-0.725996, -0.687699, 0.000000}, {1.000000, 1.000000, 1.000000, 1.000000}},{{-0.647386, -0.762162, 0.000000}, {1.000000, 1.000000, 1.000000, 1.000000}},{{-0.561187, -0.827689, 0.000000}, {1.000000, 1.000000, 1.000000, 1.000000}},{{-0.468409, -0.883512, 0.000000}, {1.000000, 1.000000, 1.000000, 1.000000}},{{-0.370138, -0.928977, 0.000000}, {1.000000, 1.000000, 1.000000, 1.000000}},{{-0.267528, -0.963550, 0.000000}, {1.000000, 1.000000, 1.000000, 1.000000}},{{-0.161782, -0.986826, 0.000000}, {1.000000, 1.000000, 1.000000, 1.000000}},{{-0.054139, -0.998533, 0.000000}, {1.000000, 1.000000, 1.000000, 1.000000}},{{0.054139, -0.998533, 0.000000}, {1.000000, 1.000000, 1.000000, 1.000000}},{{0.161782, -0.986826, 0.000000}, {1.000000, 1.000000, 1.000000, 1.000000}},{{0.267528, -0.963550, 0.000000}, {1.000000, 1.000000, 1.000000, 1.000000}},{{0.370138, -0.928977, 0.000000}, {1.000000, 1.000000, 1.000000, 1.000000}},{{0.468409, -0.883512, 0.000000}, {1.000000, 1.000000, 1.000000, 1.000000}},{{0.561187, -0.827689, 0.000000}, {1.000000, 1.000000, 1.000000, 1.000000}},{{0.647386, -0.762162, 0.000000}, {1.000000, 1.000000, 1.000000, 1.000000}},{{0.725996, -0.687699, 0.000000}, {1.000000, 1.000000, 1.000000, 1.000000}},{{0.796093, -0.605174, 0.000000}, {1.000000, 1.000000, 1.000000, 1.000000}},{{0.856857, -0.515554, 0.000000}, {1.000000, 1.000000, 1.000000, 1.000000}},{{0.907575, -0.419889, 0.000000}, {1.000000, 1.000000, 1.000000, 1.000000}},{{0.947653, -0.319302, 0.000000}, {1.000000, 1.000000, 1.000000, 1.000000}},{{0.976620, -0.214971, 0.000000}, {1.000000, 1.000000, 1.000000, 1.000000}},{{0.994138, -0.108119, 0.000000}, {1.000000, 1.000000, 1.000000, 1.000000}},{{1.000000, 0.000000, 0.000000}, {1.000000, 1.000000, 1.000000, 1.000000}}};
//GLushort CIndices[kCount] = {0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58};

Vertex CVertices[kCount] = {{1.000000, 0.000000, 0.000000},{0.994138, 0.108119, 0.000000},{0.976621, 0.214970, 0.000000},{0.947653, 0.319302, 0.000000},{0.907575, 0.419889, 0.000000},{0.856857, 0.515554, 0.000000},{0.796093, 0.605174, 0.000000},{0.725995, 0.687699, 0.000000},{0.647386, 0.762162, 0.000000},{0.561187, 0.827689, 0.000000},{0.468408, 0.883512, 0.000000},{0.370138, 0.928977, 0.000000},{0.267528, 0.963550, 0.000000},{0.161782, 0.986827, 0.000000},{0.054139, 0.998533, 0.000000},{-0.054139, 0.998533, 0.000000},{-0.161782, 0.986827, 0.000000},{-0.267528, 0.963550, 0.000000},{-0.370138, 0.928977, 0.000000},{-0.468408, 0.883512, 0.000000},{-0.561187, 0.827689, 0.000000},{-0.647386, 0.762162, 0.000000},{-0.725995, 0.687699, 0.000000},{-0.796093, 0.605174, 0.000000},{-0.856857, 0.515554, 0.000000},{-0.907575, 0.419889, 0.000000},{-0.947653, 0.319302, 0.000000},{-0.976621, 0.214970, 0.000000},{-0.994138, 0.108119, 0.000000},{-1.000000, -0.000000, 0.000000},{-0.994138, -0.108119, 0.000000},{-0.976620, -0.214971, 0.000000},{-0.947653, -0.319301, 0.000000},{-0.907575, -0.419889, 0.000000},{-0.856857, -0.515554, 0.000000},{-0.796093, -0.605174, 0.000000},{-0.725996, -0.687699, 0.000000},{-0.647386, -0.762162, 0.000000},{-0.561187, -0.827689, 0.000000},{-0.468409, -0.883512, 0.000000},{-0.370138, -0.928977, 0.000000},{-0.267528, -0.963550, 0.000000},{-0.161782, -0.986826, 0.000000},{-0.054139, -0.998533, 0.000000},{0.054139, -0.998533, 0.000000},{0.161782, -0.986826, 0.000000},{0.267528, -0.963550, 0.000000},{0.370138, -0.928977, 0.000000},{0.468409, -0.883512, 0.000000},{0.561187, -0.827689, 0.000000},{0.647386, -0.762162, 0.000000},{0.725996, -0.687699, 0.000000},{0.796093, -0.605174, 0.000000},{0.856857, -0.515554, 0.000000},{0.907575, -0.419889, 0.000000},{0.947653, -0.319302, 0.000000},{0.976620, -0.214971, 0.000000},{0.994138, -0.108119, 0.000000},{1.000000, 0.000000, 0.000000}};
GLushort CIndices[kCount] = {0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58};


@interface VWWWaveScene () {
    GLKVector4 clearColor;
    GLKBaseEffect *effect;
    float left, right, bottom, top;
    
    GLuint _vertexBuffer;
    GLuint _indexBuffer;
    
    
    float _rotation;
    float _rotationSmall;
    
}

@end

@implementation VWWWaveScene

@synthesize clearColor;
@synthesize left, right, bottom, top;



-(id)init{
    self = [super init];
    if(self){
        
        [self setupGL];
    }
    return self;
}

-(void)setupGL{
    effect = [[GLKBaseEffect alloc] init];
    
    effect.useConstantColor = GL_TRUE;
    effect.constantColor = GLKVector4Make(1, 0, 0, 1);
    
    glEnable(GL_CULL_FACE);
    
    glGenBuffers(1, &_vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(CVertices), CVertices, GL_STATIC_DRAW);
    glGenBuffers(1, &_indexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(CIndices), CIndices, GL_STATIC_DRAW);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE,
                          sizeof(Vertex), (const GLvoid *) offsetof(Vertex, Position));
//    glEnableVertexAttribArray(GLKVertexAttribColor);
//    glVertexAttribPointer(GLKVertexAttribColor, 4, GL_FLOAT, GL_FALSE,
//                          sizeof(Vertex), (const GLvoid *) offsetof(Vertex, Color));
//    [self generateData];
}


-(void)generateData{
//    int vertexCount = kCount;
//    float radius = 1.0f;
//    float center_x = 0.0f;
//    float center_y = 0.0f;
//
//    //outer vertices of the circle
//    int outerVertexCount = vertexCount-1;
//
//    for (int i = 0; i < outerVertexCount; ++i){
//        float percent = (i / (float) (outerVertexCount-1));
//        float rad = percent * 2 * M_PI;
//
//        float x = center_x + radius * cos(rad);
//        float y = center_y + radius * sin(rad);
//        Vertex v = {x, y, 0};
//
//        CVertices[i] = v;
//        CIndices[i] = i;
//    }
//
//
//
//    // This will print out data for our verticies. No need to compute every cycle when we can predefine
//
//    NSMutableString *vertices = [[NSMutableString alloc]initWithString:@"{"];
//    NSMutableString *indices = [[NSMutableString alloc]initWithString:@"{"];
//    for (int i = 0; i < outerVertexCount; ++i){
//        Vertex v = CVertices[i];
//        float *Position= v.Position;
////        float *Color = v.Color;
//
////        NSString *vertex = [NSString stringWithFormat:@"{{%f, %f, %f}, {%f, %f, %f, %f}},",
////                            Position[0],
////                            Position[1],
////                            Position[2],
////                            Color[0],
////                            Color[1],
////                            Color[2],
////                            Color[3]];
//        NSString *vertex = [NSString stringWithFormat:@"{%f, %f, %f},",
//                            Position[0],
//                            Position[1],
//                            Position[2]];
//
//
//        [vertices appendFormat:@"%@", vertex];
//
////        (const GLvoid *) offsetof(Vertex, Color)
//
//
//        [indices appendFormat:@"%ld,", (long)i];
//    }
//
//    [vertices appendFormat:@"}\n"];
//    [indices appendFormat:@"}\n"];
//
//
//    NSLog(@"Vertices: \n%@", vertices);
//    NSLog(@"Indices: \n%@", indices);
//    int i = 0;
}
-(void)update {


}



-(void)render {
    // Setup scene
    glClearColor(clearColor.r, clearColor.g, clearColor.b, clearColor.a);
    glClear(GL_COLOR_BUFFER_BIT);
    effect.transform.projectionMatrix = GLKMatrix4MakeOrtho(left, right, bottom, top, 2, -2);
    
    // Draw multiple circles
    float offsetRotationSmall = 360 / self.size;
    
    NSInteger yMax = self.size / 2;
    NSInteger yMin = -yMax;
    NSInteger xMax = yMax / 2;
    NSInteger xMin = -xMax;
    
    for(NSInteger y = yMin; y <= yMax; y++){
        for(NSInteger x = xMin; x <= xMax; x++){
            
            // 1. matrix
            GLKMatrix4 modelViewMatrix = GLKMatrix4Identity;
            modelViewMatrix = GLKMatrix4Translate(modelViewMatrix, 1.2 * x, 1.2 * y, 0);
            effect.transform.modelviewMatrix = modelViewMatrix;
            
            // 1. color
            effect.constantColor = GLKVector4Make(0.5, 0.5, 0.5, 1);
            
            // 1. width
            glLineWidth(1.0f);
            
            // 1.
            [effect prepareToDraw];
            glDrawElements(GL_LINE_STRIP, sizeof(CIndices)/sizeof(CIndices[0]), GL_UNSIGNED_SHORT, 0);

            
            // 2. Matrix
            float yy = y * offsetRotationSmall;
            float xx = x * offsetRotationSmall;
            float rr = _rotationSmall + xx + yy;
            float x = 5 * cos(GLKMathDegreesToRadians(rr));
            float y = 5 * sin(GLKMathDegreesToRadians(rr));
            modelViewMatrix = GLKMatrix4Scale(modelViewMatrix, 0.2, 0.2, 0);
            modelViewMatrix  = GLKMatrix4Translate(modelViewMatrix, x, y, 0);
            effect.transform.modelviewMatrix = modelViewMatrix;
            
            // 2. Matrix
            effect.constantColor = GLKVector4Make(1, 1, 1, 1);
            
            // 2. width
            glLineWidth(1.0f);
            
            // 2. draw
            [effect prepareToDraw];
            glDrawElements(GL_LINE_STRIP, sizeof(CIndices)/sizeof(CIndices[0]), GL_UNSIGNED_SHORT, 0);
        }
    }

    _rotationSmall += 180 * self.owner.timeSinceLastUpdate;
}


@end
