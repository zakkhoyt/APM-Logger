//
//  APM Logger
//
//  Created by Zakk Hoyt 2014
//  Copyright (c) 2014 Zakk Hoyt.
//


#import <Foundation/Foundation.h>
#import "VWWLogFileSummary.h"

@interface AP2DataPlotController : NSObject


+(void)extractFileSummaryFromLogFileAtURL:(NSURL*)url completionBlock:(VWWLogFileSummaryBlock)completionBlock;
+(void)extractDataPlotFromLogFileAtURL:(NSURL*)url completionBlock:(VWWA2PDataSetBlock)completionBlock;
@end
