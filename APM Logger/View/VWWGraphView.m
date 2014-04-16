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
    [self.lineColor getRed:&red green:&green blue:&blue alpha:&alpha];
    CGFloat lineColor[4] = {red, green, blue, alpha};
    float lastX = 0;
    float lastY = 0;
    CGContextBeginPath(cgContext);
    
    CGContextSetLineWidth(cgContext, 0.5f);
    CGContextSetStrokeColor(cgContext, lineColor);

    for(NSInteger index = 0; index < 320; index++){
//    for(NSInteger index = 0; index < self.bounds.size.width; index++){

//        NSNumber *yNumber = self.dataSource[index];
        NSDictionary *d = self.dataSource[index];
        NSNumber *yNumber = d[self.key];
        CGFloat yFactor = self.bounds.size.height / 10.0;
        CGFloat y = yNumber.floatValue * yFactor + self.bounds.size.height / 2.0;

        CGFloat xFactor = self.bounds.size.width / (float)320;
        CGFloat x = index * xFactor;
        if(index == 0){
            lastX = x;
            lastY = y;
            continue;
        }
        
        
        CGContextMoveToPoint(cgContext,
                             lastX,
                             lastY);
        
        CGContextAddLineToPoint(cgContext,
                                x,
                                y);
        
        
        lastX = x;
        lastY = y;

    }
    CGContextStrokePath(cgContext);
}


@end
