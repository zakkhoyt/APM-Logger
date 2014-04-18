//
//  VWWDeviceLimits.m
//  RCTools
//
//  Created by Zakk Hoyt on 4/17/14.
//  Copyright (c) 2014 Zakk Hoyt. All rights reserved.
//

#import "VWWDeviceLimits.h"

@implementation VWWDeviceLimits
-(id)init{
    self = [super init];
    if(self){
        _x = [[VWWDeviceAxisLimits alloc]init];
        _y = [[VWWDeviceAxisLimits alloc]init];
        _z = [[VWWDeviceAxisLimits alloc]init];
    }
    return self;
}

-(void)reset{
    [self.x reset];
    [self.y reset];
    [self.z reset];
}
@end
