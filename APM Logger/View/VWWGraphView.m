//
//  VWWGraphView.m
//  RCTools
//
//  Created by Zakk Hoyt on 4/15/14.
//  Copyright (c) 2014 Zakk Hoyt. All rights reserved.
//

#import "VWWGraphView.h"
@import CoreText;
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
    @synchronized(self.dataSource){
        CGContextRef cgContext = UIGraphicsGetCurrentContext();

        CGContextBeginPath(cgContext);
        
        
        
        
        const NSUInteger kSamples = 80;
        

        
        NSUInteger startIndex = self.dataSource.count - kSamples;
        CGFloat yFactor = self.bounds.size.height / 5.0;
        CGFloat xFactor = self.bounds.size.width / (float)kSamples;
//        CGFloat xBaseline = self.bounds.size.height / 4.0;
//        CGFloat yBaseline = 2*xBaseline;
//        CGFloat zBaseline = 3*xBaseline;
        CGFloat xBaseline = self.bounds.size.height / 2.0;
        CGFloat yBaseline = xBaseline;
        CGFloat zBaseline = xBaseline;

        
        CGContextSetLineWidth(cgContext, 2.0f);
//        // +1/-1
        CGContextSetStrokeColorWithColor(cgContext , [UIColor greenColor].CGColor);
//        CGContextSetLineWidth(cgContext, 0.5f);
//        CGContextMoveToPoint(cgContext, 0, xBaseline + yFactor);
//        CGContextAddLineToPoint(cgContext, self.bounds.size.width, xBaseline + yFactor);
//        CGContextMoveToPoint(cgContext, 0, xBaseline - yFactor);
//        CGContextAddLineToPoint(cgContext, self.bounds.size.width, xBaseline - yFactor);
//        CGContextStrokePath(cgContext);
//        CGContextSetLineWidth(cgContext, 2.0f);
        for(NSInteger index = 0; index < kSamples; index++){
            NSDictionary *d = self.dataSource[startIndex + index];
            NSNumber *yNumber = d[@"x"];
            CGFloat y = yNumber.floatValue * yFactor + xBaseline;
            if(index == 0){
                CGContextMoveToPoint(cgContext, 0, y);
            } else {
                CGFloat x = index * xFactor;
                CGContextAddLineToPoint(cgContext, x, y);
            }
        }
        CGContextStrokePath(cgContext);
        
        
//        // +1/-1
        CGContextSetStrokeColorWithColor(cgContext , [UIColor redColor].CGColor);
//        CGContextSetLineWidth(cgContext, 0.5f);
//        CGContextMoveToPoint(cgContext, 0, yBaseline + yFactor);
//        CGContextAddLineToPoint(cgContext, self.bounds.size.width, yBaseline + yFactor);
//        CGContextMoveToPoint(cgContext, 0, yBaseline - yFactor);
//        CGContextAddLineToPoint(cgContext, self.bounds.size.width, yBaseline - yFactor);
//        CGContextStrokePath(cgContext);
//        CGContextSetLineWidth(cgContext, 2.0f);
        for(NSInteger index = 0; index < kSamples; index++){
            NSDictionary *d = self.dataSource[startIndex + index];
            NSNumber *yNumber = d[@"y"];
            CGFloat y = yNumber.floatValue * yFactor + yBaseline;
            if(index == 0){
                CGContextMoveToPoint(cgContext, 0, y);
            } else {
                CGFloat x = index * xFactor;
                CGContextAddLineToPoint(cgContext, x, y);
            }
        }
        CGContextStrokePath(cgContext);
        
//        // +1/-1
        CGContextSetStrokeColorWithColor(cgContext , [UIColor yellowColor].CGColor);
//        CGContextSetLineWidth(cgContext, 0.5f);
//        CGContextMoveToPoint(cgContext, 0, zBaseline + yFactor);
//        CGContextAddLineToPoint(cgContext, self.bounds.size.width, zBaseline + yFactor);
//        CGContextMoveToPoint(cgContext, 0, zBaseline - yFactor);
//        CGContextAddLineToPoint(cgContext, self.bounds.size.width, zBaseline - yFactor);
//        CGContextStrokePath(cgContext);
//        CGContextSetLineWidth(cgContext, 2.0f);
        for(NSInteger index = 0; index < kSamples; index++){
            NSDictionary *d = self.dataSource[startIndex + index];
            NSNumber *yNumber = d[@"z"];
            CGFloat y = yNumber.floatValue * yFactor + zBaseline;
            if(index == 0){
                CGContextMoveToPoint(cgContext, 0, y);
            } else {
                CGFloat x = index * xFactor;
                CGContextAddLineToPoint(cgContext, x, y);
            }
        }
        CGContextStrokePath(cgContext);

    

        // Text
        CGMutablePathRef path = CGPathCreateMutable(); //1
        //    CGPathAddRect(path, NULL, self.bounds);
        CGPathAddRect(path, NULL, CGRectMake(10, 10, 300, 20));
        
        NSDictionary *d = self.dataSource[self.dataSource.count - 1];
        NSNumber *xyNumber = d[@"y"];
        NSString *s = [NSString stringWithFormat:@"%.4f", xyNumber.floatValue];
        NSAttributedString* attString = [[NSAttributedString alloc] initWithString:s attributes:@{NSForegroundColorAttributeName : [UIColor greenColor]}];
        
        CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef) attString);
        CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, [attString length]), path, NULL);
        
        // Flip the coordinate system
        CGContextSetTextMatrix(cgContext, CGAffineTransformIdentity);
        CGContextTranslateCTM(cgContext, 0, self.bounds.size.height);
        CGContextScaleCTM(cgContext, 1.0, -1.0);
        
        
        CTFrameDraw(frame, cgContext); //4
        
        CFRelease(frame); //5
        CFRelease(path);
        CFRelease(framesetter);

    }
}


@end
