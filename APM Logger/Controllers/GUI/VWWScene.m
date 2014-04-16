//
//  VWWScene.m
//  RCTools
//
//  Created by Zakk Hoyt on 4/16/14.
//  Copyright (c) 2014 Zakk Hoyt. All rights reserved.
//

#import "VWWScene.h"

@implementation VWWScene

-(int)numVertices {
    return 0;
}

- (GLKVector2 *)vertices {
    if (vertexData == nil){
        vertexData = [NSMutableData dataWithLength:sizeof(GLKVector2)*self.numVertices];
    }
    return [vertexData mutableBytes];
}


-(void)render {
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 2, GL_FLOAT, GL_FALSE, 0, self.vertices);
    glDrawArrays(GL_TRIANGLES, 0, self.numVertices);
    glDisableVertexAttribArray(GLKVertexAttribPosition);
}


@end