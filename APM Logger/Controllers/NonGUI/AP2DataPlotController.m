//
//  APM Logger
//
//  Created by Zakk Hoyt 2014
//  Copyright (c) 2014 Zakk Hoyt.
//
//  This file will mimick the class from APM: https://github.com/diydrones/apm_planner/blob/master/src/ui/AP2DataPlotThread.cc

#import "AP2DataPlotController.h"
#import "VWWFileController.h"
#import "AP2DataPlot.h"



@interface AP2DataPlotController ()

@end

@implementation AP2DataPlotController







+(void)extractFileSummaryFromLogFileAtURL:(NSURL*)url completionBlock:(VWWLogFileSummaryBlock)completionBlock{
    VWWLogFileSummary *summary = [[VWWLogFileSummary alloc]init];

    summary.filename = [VWWFileController nameOfFileAtURL:url];
    summary.size = [VWWFileController sizeOfFileAtURL:url];
    summary.date = [VWWFileController dateOfFileAtURL:url];
    
    
    NSError *error;
    // Open file and split by lines
    NSString *logFileContents = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
    NSArray *lines = [logFileContents componentsSeparatedByString:@"\n"];
    if(lines.count >= 1) summary.version = lines[0];
    if(lines.count >= 3) summary.firmware = lines[2];
    if(lines.count >= 4) summary.freeRAM = lines[3];
    if(lines.count >= 5) summary.software = lines[4];
        
    VWW_LOG_TODO_TASK(@"Finish reading summary");
    completionBlock(summary);
}

+(void)extractDataPlotFromLogFileAtURL:(NSURL*)url completionBlock:(VWWA2PDataSetBlock)extractBlock{
    AP2DataPlot *dataSet = [[AP2DataPlot alloc]init];
    [dataSet configureWithURL:url completionBlock:^(BOOL success){
        extractBlock(dataSet);
    }];
    
}











@end



























