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
    float Color[4];
} Vertex;

Vertex CVertices[30] = {
//    // Front
//    {{1, -1, 0}, {1, 0, 0, 1}},
//    {{1, 1, 0}, {0, 1, 0, 1}},
//    {{-1, 1, 0}, {0, 0, 1, 1}},
//    {{-1, -1, 0}, {0, 0, 0, 1}},
//    // Back
//    {{1, 1, 0}, {1, 0, 0, 1}},
//    {{-1, -1, 0}, {0, 1, 0, 1}},
//    {{1, -1, 0}, {0, 0, 1, 1}},
//    {{-1, 1, 0}, {0, 0, 0, 1}},
//    // Left
//    {{-1, -1, 0}, {1, 0, 0, 1}},
//    {{-1, 1, 0}, {0, 1, 0, 1}},
//    {{-1, 1, 0}, {0, 0, 1, 1}},
//    {{-1, -1, 0}, {0, 0, 0, 1}},
//    // Right
//    {{1, -1, 0}, {1, 0, 0, 1}},
//    {{1, 1, 0}, {0, 1, 0, 1}},
//    {{1, 1, 0}, {0, 0, 1, 1}},
//    {{1, -1, 0}, {0, 0, 0, 1}},
//    // Top
//    {{1, 1, 0}, {1, 0, 0, 1}},
//    {{1, 1, 0}, {0, 1, 0, 1}},
//    {{-1, 1, 0}, {0, 0, 1, 1}},
//    {{-1, 1, 0}, {0, 0, 0, 1}},
//    // Bottom
//    {{1, -1, 0}, {1, 0, 0, 1}},
//    {{1, -1, 0}, {0, 1, 0, 1}},
//    {{-1, -1, 0}, {0, 0, 1, 1}},
//    {{-1, -1, 0}, {0, 0, 0, 1}}
};
GLubyte CIndices[30] = {
//    // Front
//    0, 1, 2,
//    2, 3, 0,
//    
//    // Back
//    4, 6, 5,
//    4, 5, 7,
//    
//    // Left
//    8, 9, 10,
//    10, 11, 8,
//    
//    // Right
//    12, 13, 14,
//    14, 15, 12,
//    
//    // Top
//    16, 17, 18,
//    18, 19, 16,
//    
//    // Bottom
//    20, 21, 22,
//    22, 23, 20
};// {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15};


const Vertex CircleVertices[] = {
    // Front
    {{1, -1, 0}, {1, 0, 0, 1}},
    {{1, 1, 0}, {0, 1, 0, 1}},
    {{-1, 1, 0}, {0, 0, 1, 1}},
    {{-1, -1, 0}, {0, 0, 0, 1}},
    // Back
    {{1, 1, 0}, {1, 0, 0, 1}},
    {{-1, -1, 0}, {0, 1, 0, 1}},
    {{1, -1, 0}, {0, 0, 1, 1}},
    {{-1, 1, 0}, {0, 0, 0, 1}},
    // Left
    {{-1, -1, 0}, {1, 0, 0, 1}},
    {{-1, 1, 0}, {0, 1, 0, 1}},
    {{-1, 1, 0}, {0, 0, 1, 1}},
    {{-1, -1, 0}, {0, 0, 0, 1}},
    // Right
    {{1, -1, 0}, {1, 0, 0, 1}},
    {{1, 1, 0}, {0, 1, 0, 1}},
    {{1, 1, 0}, {0, 0, 1, 1}},
    {{1, -1, 0}, {0, 0, 0, 1}},
    // Top
    {{1, 1, 0}, {1, 0, 0, 1}},
    {{1, 1, 0}, {0, 1, 0, 1}},
    {{-1, 1, 0}, {0, 0, 1, 1}},
    {{-1, 1, 0}, {0, 0, 0, 1}},
    // Bottom
    {{1, -1, 0}, {1, 0, 0, 1}},
    {{1, -1, 0}, {0, 1, 0, 1}},
    {{-1, -1, 0}, {0, 0, 1, 1}},
    {{-1, -1, 0}, {0, 0, 0, 1}}
};


const GLubyte CircleIndices[] = {
    // Front
    0, 1, 2,
    2, 3, 0,
    
    // Back
    4, 6, 5,
    4, 5, 7,
    
    // Left
    8, 9, 10,
    10, 11, 8,
    
    // Right
    12, 13, 14,
    14, 15, 12,
    
    // Top
    16, 17, 18,
    18, 19, 16,
    
    // Bottom
    20, 21, 22,
    22, 23, 20
};

@interface VWWWaveScene () {
    GLKVector4 clearColor;
    GLKBaseEffect *effect;
    float left, right, bottom, top;
    
    GLuint _vertexArray;
    GLuint _vertexBuffer;
    GLuint _indexBuffer;

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
//    glEnable(GL_CULL_FACE);
    
    // New lines
    glGenVertexArraysOES(1, &_vertexArray);
    glBindVertexArrayOES(_vertexArray);
    
    

    
    

//    glGenBuffers(1, &_vertexBuffer);
//    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
//    glBufferData(GL_ARRAY_BUFFER, sizeof(CircleVertices), CircleVertices, GL_STATIC_DRAW);
//    glGenBuffers(1, &_indexBuffer);
//    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBuffer);
//    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(CircleIndices), CircleIndices, GL_STATIC_DRAW);
//    
//    glEnableVertexAttribArray(GLKVertexAttribPosition);
//    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE,
//                          sizeof(Vertex), (const GLvoid *) offsetof(Vertex, Position));
//    glEnableVertexAttribArray(GLKVertexAttribColor);
//    glVertexAttribPointer(GLKVertexAttribColor, 4, GL_FLOAT, GL_FALSE,
//                          sizeof(Vertex), (const GLvoid *) offsetof(Vertex, Color));

//    glGenBuffers(1, &_vertexBuffer);
//    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
//    glBufferData(GL_ARRAY_BUFFER, sizeof(CVertices), CVertices, GL_STATIC_DRAW);
//    glGenBuffers(1, &_indexBuffer);
//    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBuffer);
//    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(CIndices), CIndices, GL_STATIC_DRAW);
//    
//    glEnableVertexAttribArray(GLKVertexAttribPosition);
//    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE,
//                          sizeof(Vertex), (const GLvoid *) offsetof(Vertex, Position));
//    glEnableVertexAttribArray(GLKVertexAttribColor);
//    glVertexAttribPointer(GLKVertexAttribColor, 4, GL_FLOAT, GL_FALSE,
//                          sizeof(Vertex), (const GLvoid *) offsetof(Vertex, Color));

    

    glBindVertexArrayOES(0);
    
    [self update];
}

-(void)update {
    int vertexCount = 30;
    float radius = 1.0f;
    float center_x = 0.0f;
    float center_y = 0.0f;
    
    //outer vertices of the circle
    int outerVertexCount = vertexCount-1;
    
    for (int i = 0; i < outerVertexCount; ++i){
        float percent = (i / (float) (outerVertexCount-1));
        float rad = percent * 2 * M_PI;
        
        float x = center_x + radius * cos(rad);
        float y = center_y + radius * sin(rad);
        Vertex v = {{x, y, 0}, {1, 1, 1, 1}};
        
        CVertices[i] = v;
        CIndices[i] = i;
    }
}



-(void)render {
    glClearColor(clearColor.r, clearColor.g, clearColor.b, clearColor.a);
    glClear(GL_COLOR_BUFFER_BIT);
    
    
    
//    glEnable(GL_POINT_SMOOTH);
    
    effect.transform.projectionMatrix = GLKMatrix4MakeOrtho(left, right, bottom, top, 1, -1);
    
    
    
//    glBindVertexArrayOES(_vertexArray);
    [effect prepareToDraw];
    
    glGenBuffers(1, &_vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(CVertices), CVertices, GL_STATIC_DRAW);
    glGenBuffers(1, &_indexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(CIndices), CIndices, GL_STATIC_DRAW);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE,
                          sizeof(Vertex), (const GLvoid *) offsetof(Vertex, Position));
    glEnableVertexAttribArray(GLKVertexAttribColor);
    glVertexAttribPointer(GLKVertexAttribColor, 4, GL_FLOAT, GL_FALSE,
                          sizeof(Vertex), (const GLvoid *) offsetof(Vertex, Color));

    
//    glDrawElements(GL_LINES, sizeof(CircleIndices)/sizeof(CircleIndices[0]), GL_UNSIGNED_BYTE, 0);
    
    NSUInteger sI0 = sizeof(CIndices[0]);
    NSUInteger sI = sizeof(CIndices);
    NSLog(@"sI: %ld sI0:%ld", (long)sI, (long)sI0);
    glDrawElements(GL_LINE_STRIP, sizeof(CIndices)/sizeof(CIndices[0]), GL_UNSIGNED_BYTE, 0);
    
}


@end
