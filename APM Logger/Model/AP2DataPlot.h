//
//  AP2DataSet.h
//  APM Logger
//
//  Created by Zakk Hoyt on 3/25/14.
//  Copyright (c) 2014 Zakk Hoyt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"

@interface AP2DataPlot : NSObject
-(void)configureWithURL:(NSURL*)url completionBlock:(VWWBoolBlock)completionBlock;
@property (nonatomic, strong, readonly) NSString *databasePath;
@property (readonly) FMDatabase *db;
-(void)getTablesWithCompletionBlock:(VWWArrayBlock)completionBlock;
@end
