//
//  VWWOpenGLViewController.m
//  RCTools
//
//  Created by Zakk Hoyt on 4/18/14.
//  Copyright (c) 2014 Zakk Hoyt. All rights reserved.
//

#import "VWWOpenGLViewController.h"
@import  QuartzCore;



typedef struct {
    float Position[3];
    float Color[4];
    float TexCoord[2];
    float Normal[3];
} Vertex;

//const Vertex Vertices[] = {
//    {{1, -1, 0}, {1, 0, 0, 1}, {1, 0}},
//    {{1, 1, 0}, {0, 1, 0, 1}, {1, 1}},
//    {{-1, 1, 0}, {0, 0, 1, 1}, {0, 1}},
//    {{-1, -1, 0}, {0, 0, 0, 1}, {0, 0}}
//};



//const Vertex Vertices[] = {
//    // Front
//    {{1, -1, 1}, {1, 0, 0, 1}, {1, 0}},
//    {{1, 1, 1}, {0, 1, 0, 1}, {1, 1}},
//    {{-1, 1, 1}, {0, 0, 1, 1}, {0, 1}},
//    {{-1, -1, 1}, {0, 0, 0, 1}, {0, 0}},
//    // Back
//    {{1, 1, -1}, {1, 0, 0, 1}, {0, 1}},
//    {{-1, -1, -1}, {0, 1, 0, 1}, {1, 0}},
//    {{1, -1, -1}, {0, 0, 1, 1}, {0, 0}},
//    {{-1, 1, -1}, {0, 0, 0, 1}, {1, 1}},
//    // Left
//    {{-1, -1, 1}, {1, 0, 0, 1}, {1, 0}},
//    {{-1, 1, 1}, {0, 1, 0, 1}, {1, 1}},
//    {{-1, 1, -1}, {0, 0, 1, 1}, {0, 1}},
//    {{-1, -1, -1}, {0, 0, 0, 1}, {0, 0}},
//    // Right
//    {{1, -1, -1}, {1, 0, 0, 1}, {1, 0}},
//    {{1, 1, -1}, {0, 1, 0, 1}, {1, 1}},
//    {{1, 1, 1}, {0, 0, 1, 1}, {0, 1}},
//    {{1, -1, 1}, {0, 0, 0, 1}, {0, 0}},
//    // Top
//    {{1, 1, 1}, {1, 0, 0, 1}, {1, 0}},
//    {{1, 1, -1}, {0, 1, 0, 1}, {1, 1}},
//    {{-1, 1, -1}, {0, 0, 1, 1}, {0, 1}},
//    {{-1, 1, 1}, {0, 0, 0, 1}, {0, 0}},
//    
//    // Bottom
//    {{1, -1, -1}, {1, 0, 0, 1}, {1, 0}},
//    {{1, -1, 1}, {0, 1, 0, 1}, {1, 1}},
//    {{-1, -1, 1}, {0, 0, 1, 1}, {0, 1}},
//    {{-1, -1, -1}, {0, 0, 0, 1}, {0, 0}}
//};


const Vertex Vertices[] = {
    // Front
    {{1, -1, 1}, {1, 0, 0, 1}, {1, 0}, {0, 0, 1}},
    {{1, 1, 1}, {0, 1, 0, 1}, {1, 1}, {0, 0, 1}},
    {{-1, 1, 1}, {0, 0, 1, 1}, {0, 1}, {0, 0, 1}},
    {{-1, -1, 1}, {0, 0, 0, 1}, {0, 0}, {0, 0, 1}},
    // Back
    {{1, 1, -1}, {1, 0, 0, 1}, {0, 1}, {0, 0, -1}},
    {{-1, -1, -1}, {0, 1, 0, 1}, {1, 0}, {0, 0, -1}},
    {{1, -1, -1}, {0, 0, 1, 1}, {0, 0}, {0, 0, -1}},
    {{-1, 1, -1}, {0, 0, 0, 1}, {1, 1}, {0, 0, -1}},
    // Left
    {{-1, -1, 1}, {1, 0, 0, 1}, {1, 0}, {-1, 0, 0}},
    {{-1, 1, 1}, {0, 1, 0, 1}, {1, 1}, {-1, 0, 0}},
    {{-1, 1, -1}, {0, 0, 1, 1}, {0, 1}, {-1, 0, 0}},
    {{-1, -1, -1}, {0, 0, 0, 1}, {0, 0}, {-1, 0, 0}},
    // Right
    {{1, -1, -1}, {1, 0, 0, 1}, {1, 0}, {1, 0, 0}},
    {{1, 1, -1}, {0, 1, 0, 1}, {1, 1}, {1, 0, 0}},
    {{1, 1, 1}, {0, 0, 1, 1}, {0, 1}, {1, 0, 0}},
    {{1, -1, 1}, {0, 0, 0, 1}, {0, 0}, {1, 0, 0}},
    // Top
    {{1, 1, 1}, {1, 0, 0, 1}, {1, 0}, {0, 1, 0}},
    {{1, 1, -1}, {0, 1, 0, 1}, {1, 1}, {0, 1, 0}},
    {{-1, 1, -1}, {0, 0, 1, 1}, {0, 1}, {0, 1, 0}},
    {{-1, 1, 1}, {0, 0, 0, 1}, {0, 0}, {0, 1, 0}},
    // Bottom
    {{1, -1, -1}, {1, 0, 0, 1}, {1, 0}, {0, -1, 0}},
    {{1, -1, 1}, {0, 1, 0, 1}, {1, 1}, {0, -1, 0}},
    {{-1, -1, 1}, {0, 0, 1, 1}, {0, 1}, {0, -1, 0}},
    {{-1, -1, -1}, {0, 0, 0, 1}, {0, 0}, {0, -1, 0}}
};


//const GLubyte Indices[] = {
//    0, 1, 2,
//    2, 3, 0 };

const GLubyte Indices[] = {
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



@interface VWWOpenGLViewController (){
    float _curRed;
    BOOL _increasing;
    
    GLuint _vertexBuffer;
    GLuint _indexBuffer;
    
    GLKBaseEffect * _effect;
    
    float _rotation;
    
    
    GLuint _vertexArray;
    
    float _lightRotation;
}
@property (strong, nonatomic) EAGLContext *context;
@end

@implementation VWWOpenGLViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController setNavigationBarHidden:YES];
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    if (!self.context) {
        NSLog(@"Failed to create ES context");
    }
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableMultisample = GLKViewDrawableMultisample4X;
    
    [EAGLContext setCurrentContext:self.context];
    self.preferredFramesPerSecond = 60;

    
    _increasing = YES;
    _curRed = 0.0;
    
    
    
    
    [self setupGL];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    
    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
    self.context = nil;
    
    
    _effect = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    NSLog(@"timeSinceLastUpdate: %f", self.timeSinceLastUpdate);
    NSLog(@"timeSinceLastDraw: %f", self.timeSinceLastDraw);
    NSLog(@"timeSinceFirstResume: %f", self.timeSinceFirstResume);
    NSLog(@"timeSinceLastResume: %f", self.timeSinceLastResume);
//    self.paused = !self.paused;
}


#pragma mark IBActions
- (IBAction)diffuseChanged:(id)sender {
    UISlider * slider = (UISlider *)sender;
    _effect.light0.diffuseColor =
    GLKVector4Make(0, slider.value, slider.value, 1);
}
- (IBAction)ambientChanged:(id)sender {
    UISlider * slider = (UISlider *)sender;
    _effect.light0.ambientColor =
    GLKVector4Make(0, slider.value, slider.value, 1);
}
- (IBAction)specularChanged:(id)sender {
    UISlider * slider = (UISlider *)sender;
    _effect.light0.specularColor =
    GLKVector4Make(0, slider.value, slider.value, 1);
}
- (IBAction)shininessChanged:(id)sender {
    UISlider * slider = (UISlider *)sender;
    _effect.material.shininess = slider.value;
}

- (IBAction)cutoffValueChanged:(id)sender {
    UISlider * slider = (UISlider *)sender;
    _effect.light0.spotCutoff = slider.value;
}
- (IBAction)exponentValueChanged:(id)sender {
    UISlider * slider = (UISlider *)sender;
    _effect.light0.spotExponent = slider.value;
}
- (IBAction)constantValueChanged:(id)sender {
    UISlider * slider = (UISlider *)sender;
    _effect.light0.constantAttenuation = slider.value;
}
- (IBAction)linearValueChanged:(id)sender {
    UISlider * slider = (UISlider *)sender;
    _effect.light0.linearAttenuation = slider.value;
}
- (IBAction)quadraticValueChanged:(id)sender {
    UISlider * slider = (UISlider *)sender;
    _effect.light0.quadraticAttenuation = slider.value;
}



#pragma mark Private


- (void)setupGL {
//    [EAGLContext setCurrentContext:_context];
//    
//    glGenBuffers(1, &_vertexBuffer);
//    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
//    glBufferData(GL_ARRAY_BUFFER, sizeof(Vertices), Vertices, GL_STATIC_DRAW);
//    
//    glGenBuffers(1, &_indexBuffer);
//    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBuffer);
//    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(Indices), Indices, GL_STATIC_DRAW);
//    
//    _effect = [[GLKBaseEffect alloc] init];
    
    
    
    // Old stuff
    [EAGLContext setCurrentContext:_context];
    
    glEnable(GL_CULL_FACE);
    
    // New lines
    glGenVertexArraysOES(1, &_vertexArray);
    glBindVertexArrayOES(_vertexArray);
    
    // Old stuff
    glGenBuffers(1, &_vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(Vertices), Vertices, GL_STATIC_DRAW);
    glGenBuffers(1, &_indexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(Indices), Indices, GL_STATIC_DRAW);
    
    // New lines (were previously in glkView:drawInRect:
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE,
                          sizeof(Vertex), (const GLvoid *) offsetof(Vertex, Position));
    glEnableVertexAttribArray(GLKVertexAttribColor);
    glVertexAttribPointer(GLKVertexAttribColor, 4, GL_FLOAT, GL_FALSE,
                          sizeof(Vertex), (const GLvoid *) offsetof(Vertex, Color));
    
    // Texture
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE,
                          sizeof(Vertex), (const GLvoid *) offsetof(Vertex, TexCoord));
    
    // Normals
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE,
                          sizeof(Vertex), (const GLvoid *) offsetof(Vertex, Normal));
    
    glEnableVertexAttribArray(GLKVertexAttribTexCoord1);
    glVertexAttribPointer(GLKVertexAttribTexCoord1, 2, GL_FLOAT, GL_FALSE,
                          sizeof(Vertex), (const GLvoid *) offsetof(Vertex, TexCoord));
    
    glBindVertexArrayOES(0);
    
    // Old stuff
    _effect = [[GLKBaseEffect alloc] init];
    
    
    
    // Texture stuff
    NSDictionary * options = @{GLKTextureLoaderOriginBottomLeft: @YES};
    NSError *error;
    NSString *path = [[NSBundle mainBundle] pathForResource:@"tile_floor" ofType:@"png"];
    GLKTextureInfo *info = [GLKTextureLoader textureWithContentsOfFile:path options:options error:&error];
    if (info == nil) {
        NSLog(@"Error loading file: %@", error.localizedDescription);
    }
    _effect.texture2d0.name = info.name;
    _effect.texture2d0.enabled = true;
    
    // MultiTexture (alpha sandwich)
    path = [[NSBundle mainBundle] pathForResource:@"item_powerup_fish" ofType:@"png"];
    info = [GLKTextureLoader textureWithContentsOfFile:path options:options error:&error];
    if (info == nil) {
        NSLog(@"Error loading file: %@",
              error.localizedDescription);
    }
    _effect.texture2d1.name = info.name;
    _effect.texture2d1.enabled = true;
    _effect.texture2d1.envMode = GLKTextureEnvModeDecal;
    
    
    // Lights
    _effect.light0.enabled = GL_TRUE;
    _effect.light0.diffuseColor = GLKVector4Make(0, 1, 1, 1);
    _effect.light0.ambientColor = GLKVector4Make(0, 0, 0, 1);
    _effect.light0.specularColor = GLKVector4Make(0, 0, 0, 1);
    _effect.lightModelAmbientColor = GLKVector4Make(0, 0, 0, 1);
    _effect.material.specularColor = GLKVector4Make(1, 1, 1, 1);
    _effect.light0.position = GLKVector4Make(0, 1.5, -6, 1);
    _effect.lightingType = GLKLightingTypePerPixel;
    _effect.light0.spotDirection = GLKVector3Make(0, -1, 0);
    
    
    _effect.light1.enabled = GL_TRUE;
    _effect.light1.diffuseColor = GLKVector4Make(1.0, 1.0, 0.8, 1.0);
    _effect.light1.position = GLKVector4Make(0, 0, 1.5, 1);

    // Fog
    _effect.fog.color = GLKVector4Make(0, 0, 0, 1.0);
    _effect.fog.enabled = YES;
    _effect.fog.end = 5.5;
    _effect.fog.start = 5.0;
    _effect.fog.mode = GLKFogModeLinear;
    
    
}



#pragma mark GLKViewDelegate


- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {

//    glClearColor(_curRed, 0.0, 0.0, 1.0);
//    glClear(GL_COLOR_BUFFER_BIT);
//
//    [_effect prepareToDraw];
//    
//    
//    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
//    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBuffer);
//    glEnableVertexAttribArray(GLKVertexAttribPosition);
//    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE,
//                          sizeof(Vertex),
//                          (const GLvoid *) offsetof(Vertex, Position));
//    glEnableVertexAttribArray(GLKVertexAttribColor);
//    glVertexAttribPointer(GLKVertexAttribColor, 4, GL_FLOAT, GL_FALSE,
//                          sizeof(Vertex),
//                          (const GLvoid *) offsetof(Vertex, Color));
//    
//    
//    glDrawElements(GL_TRIANGLES, sizeof(Indices)/sizeof(Indices[0]), GL_UNSIGNED_BYTE, 0);
    
    
    
    glClearColor(_curRed, 0.0, 0.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    [_effect prepareToDraw];
    glBindVertexArrayOES(_vertexArray);
    glDrawElements(GL_TRIANGLES, sizeof(Indices)/sizeof(Indices[0]), GL_UNSIGNED_BYTE, 0);
}


- (void)update {

    if (_increasing) {
        _curRed += 1.0 * self.timeSinceLastUpdate;
    } else {
        _curRed -= 1.0 * self.timeSinceLastUpdate;
    }
    if (_curRed >= 1.0) {
        _curRed = 1.0;
        _increasing = NO;
    }
    if (_curRed <= 0.0) {
        _curRed = 0.0;
        _increasing = YES;
    }
    
    
    
    float aspect = fabsf(self.view.bounds.size.width / self.view.bounds.size.height);
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(100.0f), aspect, 4.0f, 10.0f);
    _effect.transform.projectionMatrix = projectionMatrix;
    
    // Setup moving light (light1)
    GLKMatrix4 lightModelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, -6.0f);
    _lightRotation += -90 * self.timeSinceLastUpdate;
    lightModelViewMatrix = GLKMatrix4Rotate(lightModelViewMatrix,
                                            GLKMathDegreesToRadians(25), 1, 0, 0);
    lightModelViewMatrix = GLKMatrix4Rotate(lightModelViewMatrix,
                                            GLKMathDegreesToRadians(_lightRotation), 0, 1, 0);
    _effect.transform.modelviewMatrix = lightModelViewMatrix;
    _effect.light1.position = GLKVector4Make(0, 0, 1.5, 1);
    
    
//    GLKMatrix4 modelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, -6.0f);
//    _rotation += 90 * self.timeSinceLastUpdate;
//    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix,  GLKMathDegreesToRadians(_rotation), 0, 0, 1);
//    _effect.transform.modelviewMatrix = modelViewMatrix;
    
    GLKMatrix4 modelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, -6.0f);
    _rotation += 90 * self.timeSinceLastUpdate;
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, GLKMathDegreesToRadians(2 * _rotation), 1, 0, 0);
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, GLKMathDegreesToRadians(_rotation), 0, 1, 0);
    _effect.transform.modelviewMatrix = modelViewMatrix;
}

@end
