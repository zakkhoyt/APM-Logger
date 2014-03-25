//
//  APM Logger
//
//  Created by Zakk Hoyt 2014
//  Copyright (c) 2014 Zakk Hoyt.
//


#import <Foundation/Foundation.h>
#import "VWWLogFileSummary.h"

@interface AP2DataPlotController : NSObject
-(id)initWithURL:(NSURL*)url;

+(void)extractFileSummaryFromLogFileAtURL:(NSURL*)url completionBlock:(VWWLogFileSummaryBlock)completionBlock;
@end
