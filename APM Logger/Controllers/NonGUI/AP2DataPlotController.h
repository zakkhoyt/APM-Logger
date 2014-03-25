//
//  AP2DataPlot.h
//  APM Logger
//
//  Created by Zakk Hoyt on 3/24/14.
//  Copyright (c) 2014 Zakk Hoyt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VWWLogFileSummary.h"

@interface AP2DataPlotController : NSObject
-(id)initWithURL:(NSURL*)url;

+(void)extractFileSummaryFromLogFileAtURL:(NSURL*)url completionBlock:(VWWLogFileSummaryBlock)completionBlock;
@end
