//
//  AP2DataSet.h
//  APM Logger
//
//  Created by Zakk Hoyt on 3/25/14.
//  Copyright (c) 2014 Zakk Hoyt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"



static NSString *AP2DataPlotTableKey = @"table";
static NSString *AP2DataPlotColumnsKey = @"columns";
static NSString *AP2DataPlotActiveKey = @"active";

@interface AP2DataPlot : NSObject
-(void)configureWithURL:(NSURL*)url completionBlock:(VWWBoolBlock)completionBlock;
-(void)populateDatabaseAtURL:(NSURL*)url completionBlock:(VWWBoolBlock)completionBlock;
@property (nonatomic, strong, readonly) NSString *databasePath;
@property (readonly) FMDatabase *db;
-(void)getParamsWithCompletionBlock:(VWWArrayBlock)completionBlock;
-(void)getDataForTable:(NSString*)table completionBlock:(VWWArrayBlock)completionBlock;
@end
