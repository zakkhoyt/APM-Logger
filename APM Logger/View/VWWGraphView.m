//
//  VWWGraphView.m
//  RCTools
//
//  Created by Zakk Hoyt on 4/15/14.
//  Copyright (c) 2014 Zakk Hoyt. All rights reserved.
//

#import "VWWGraphView.h"

@implementation VWWGraphView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGContextRef cgContext = UIGraphicsGetCurrentContext();
    
    

    CGFloat red = 0, green = 0, blue = 0, alpha = 0;;
    [[UIColor greenColor] getRed:&red green:&green blue:&blue alpha:&alpha];
    CGFloat greenColor[4] = {red, green, blue, alpha};
    [[UIColor redColor] getRed:&red green:&green blue:&blue alpha:&alpha];
    CGFloat redColor[4] = {red, green, blue, alpha};
    [[UIColor yellowColor] getRed:&red green:&green blue:&blue alpha:&alpha];
    CGFloat yellowColor[4] = {red, green, blue, alpha};
    
    
    
    
    float lastXX = 0;
    float lastXY = 0;
    float lastYX = 0;
    float lastYY = 0;
    float lastZX = 0;
    float lastZY = 0;


    
    CGContextBeginPath(cgContext);
    
    CGContextSetLineWidth(cgContext, 2.0f);
    CGContextSetStrokeColor(cgContext, greenColor);

    for(NSInteger index = 0; index < 320; index++){
        if(index >= self.dataSource.count - 1) break;
        NSDictionary *d = self.dataSource[index];
        
        {
            // X
//            CGContextSetStrokeColor(cgContext, greenColor);
            NSNumber *xyNumber = d[@"x"];
            CGFloat xyFactor = self.bounds.size.height / 10.0;
            CGFloat xy = xyNumber.floatValue * xyFactor + self.bounds.size.height / 2.0;
            CGFloat xxFactor = self.bounds.size.width / (float)320;
            CGFloat xx = index * xxFactor;
            if(index == 0){
                lastXX = xx;
                lastXY = xy;
                continue;
            }
            CGContextMoveToPoint(cgContext,
                                 lastXX,
                                 lastXY);
            CGContextAddLineToPoint(cgContext,
                                    xx,
                                    xy);
            lastXX = xx;
            lastXY = xy;
        }

//        {
//            // Y
////            CGContextSetStrokeColor(cgContext, redColor);
//            NSNumber *yyNumber = d[@"y"];
//            CGFloat yyFactor = self.bounds.size.height / 10.0;
//            CGFloat yy = yyNumber.floatValue * yyFactor + self.bounds.size.height / 2.0;
//            CGFloat yxFactor = self.bounds.size.width / (float)320;
//            CGFloat yx = index * yxFactor;
//            if(index == 0){
//                lastYX = yx;
//                lastYY = yy;
//                continue;
//            }
//            CGContextMoveToPoint(cgContext,
//                                 lastYX,
//                                 lastYY);
//            CGContextAddLineToPoint(cgContext,
//                                    yx,
//                                    yy);
//            lastYX = yx;
//            lastYY = yy;
//        }
//        
//        {
//            // Z
////            CGContextSetStrokeColor(cgContext, yellowColor);
//            NSNumber *zyNumber = d[@"z"];
//            CGFloat zyFactor = self.bounds.size.height / 10.0;
//            CGFloat zy = zyNumber.floatValue * zyFactor + self.bounds.size.height / 2.0;
//            CGFloat zxFactor = self.bounds.size.width / (float)320;
//            CGFloat zx = index * zxFactor;
//            if(index == 0){
//                lastZX = zx;
//                lastZY = zy;
//                continue;
//            }
//            CGContextMoveToPoint(cgContext,
//                                 lastZX,
//                                 lastZY);
//            CGContextAddLineToPoint(cgContext,
//                                    zx,
//                                    zy);
//            lastZX = zx;
//            lastZY = zy;
//        }
    }
    CGContextStrokePath(cgContext);
}


@end
