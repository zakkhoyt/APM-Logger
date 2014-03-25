//
//  AP2DataPlot.m
//  APM Logger
//
//  Created by Zakk Hoyt on 3/24/14.
//  Copyright (c) 2014 Zakk Hoyt. All rights reserved.
//
//  This file will mimick the class from APM: https://github.com/diydrones/apm_planner/blob/master/src/ui/AP2DataPlotThread.cc

#import "AP2DataPlotController.h"
#import <sqlite3.h>

static sqlite3 *database = nil;
static void assert_run_query(sqlite3_stmt *stmt) {
    int res = sqlite3_step(stmt);
    sqlite3_finalize(stmt);
    (void)res;
    assert(res == SQLITE_DONE || res == SQLITE_BUSY);
}

static void bind_string(sqlite3_stmt *stmt, int col, NSString *string) {
    sqlite3_bind_text(stmt, col, [string UTF8String], -1, SQLITE_TRANSIENT);
}


@interface AP2DataPlotController ()


@end

@implementation AP2DataPlotController{
    NSString *databasePath;
}

//+(AP2DataPlotController*)getSharedInstance{
//    static AP2DataPlotController *sharedInstance = nil;
//    if (!sharedInstance) {
//        sharedInstance = [[super allocWithZone:NULL]init];
//        [sharedInstance createDB];
//    }
//    return sharedInstance;
//}

-(id)initWithURL:(NSURL*)url{
    self = [super init];
    if(self){
        NSError *error;
        NSString *contents = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
        if(error){
            VWW_LOG_ERROR(@"Could not read file from URL");
            return nil;
        }
        
        NSArray *array = [contents componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        VWW_LOG_INFO(@"Read %ld lines", (long)array.count);
        
        [self createDB];
    }
    return self;
}




#pragma mark Private methods
-(BOOL)createDB{
    
    // Get the documents directory
    NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsDir = dirPaths[0];
    
    // Build the path to the database file
    NSString *dbName = [NSString stringWithFormat:@"APM-%d.db",arc4random() % 1000];
    databasePath = [[NSString alloc] initWithString:[docsDir stringByAppendingPathComponent:dbName]];
    BOOL isSuccess = YES;
    NSFileManager *filemgr = [NSFileManager defaultManager];
    if ([filemgr fileExistsAtPath: databasePath ] == NO)
    {
        const char *dbpath = [databasePath UTF8String];
        if (sqlite3_open(dbpath, &database) == SQLITE_OK)
        {
            char *errMsg;
            const char *sql_stmt = "create table if not exists testTable (regno integer primary key, name text, department text, year text)";
            if (sqlite3_exec(database, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK) {
                isSuccess = NO;
                VWW_LOG_INFO(@"Failed to create table");
            }
            sqlite3_close(database);
            VWW_LOG_INFO(@"Created DB at path: %@", databasePath);
            return  isSuccess;
        }
        else {
            isSuccess = NO;
            VWW_LOG_INFO(@"Failed to open/create database");
        }
    }
    return isSuccess;
}







@end



























