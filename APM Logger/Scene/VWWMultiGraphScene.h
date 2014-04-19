//
//  VWWMultiGraphScene.h
//  RCTools
//
//  Created by Zakk Hoyt on 4/19/14.
//  Copyright (c) 2014 Zakk Hoyt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VWWSceneProtocol.h"
@interface VWWMultiGraphScene : NSObject <VWWSceneProtocol>
@property GLKVector4 clearColor;
@property float left, right, bottom, top;
@property (nonatomic, strong) NSMutableArray *dataForPlot;
-(void)update;
-(void)render;
@end
