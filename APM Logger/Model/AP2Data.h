//
//  AP2DataSet.h
//  APM Logger
//
//  Created by Zakk Hoyt on 3/25/14.
//  Copyright (c) 2014 Zakk Hoyt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"
#import "VWWLogFileSummary.h"


static NSString *AP2DataPlotTableKey = @"table";
static NSString *AP2DataPlotColumnsKey = @"columns";
static NSString *AP2DataPlotActiveKey = @"active";

@interface AP2Data : NSObject

+(void)summaryFromLogFileAtURL:(NSURL*)url completionBlock:(VWWLogFileSummaryBlock)completionBlock;
+(void)dataPlotFromLogFileAtURL:(NSURL*)url completionBlock:(VWWA2PDataSetBlock)completionBlock;

-(void)configureWithURL:(NSURL*)url completionBlock:(VWWBoolBlock)completionBlock;
-(void)populateDatabaseAtURL:(NSURL*)url completionBlock:(VWWBoolBlock)completionBlock;
-(void)getParamsWithCompletionBlock:(VWWArrayBlock)completionBlock;
-(void)getDataForTable:(NSString*)table completionBlock:(VWWArrayBlock)completionBlock;
@end
