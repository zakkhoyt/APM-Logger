//
//  VWWScene.h
//  RCTools
//
//  Created by Zakk Hoyt on 4/16/14.
//  Copyright (c) 2014 Zakk Hoyt. All rights reserved.
//

#import <Foundation/Foundation.h>
@import GLKit;

@interface VWWScene : NSObject{
    NSMutableData *vertexData;
}

@property(readonly) int numVertices;
@property(readonly) GLKVector2 *vertices;
-(void)render;
@end
