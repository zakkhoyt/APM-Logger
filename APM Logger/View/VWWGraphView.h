//
//  VWWGraphView.h
//  RCTools
//
//  Created by Zakk Hoyt on 4/15/14.
//  Copyright (c) 2014 Zakk Hoyt. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VWWGraphView : UIView
@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic, strong) UIColor *lineColor;
@property (nonatomic, strong) NSString *key;
@end
