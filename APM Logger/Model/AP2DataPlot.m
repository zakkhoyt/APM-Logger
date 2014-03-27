//
//  AP2DataSet.m
//  APM Logger
//
//  Created by Zakk Hoyt on 3/25/14.
//  Copyright (c) 2014 Zakk Hoyt. All rights reserved.
//

#import "AP2DataPlot.h"
#import <sqlite3.h>
#import "VWWFileController.h"

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


@interface AP2DataPlot ()
@property (nonatomic, strong, readwrite) NSString *databasePath;
@property (nonatomic, strong) NSURL *logFileURL;
@end

@implementation AP2DataPlot

#pragma mark Public methods

//+(AP2DataPlotController*)getSharedInstance{
//    static AP2DataPlotController *sharedInstance = nil;
//    if (!sharedInstance) {
//        sharedInstance = [[super allocWithZone:NULL]init];
//        [sharedInstance createDB];
//    }
//    return sharedInstance;
//}

-(void)configureWithURL:(NSURL*)url completionBlock:(VWWBoolBlock)completionBlock{
    NSError *error;
    NSString *contents = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
    if(error){
        VWW_LOG_ERROR(@"Could not read file from URL");
        completionBlock(NO);
    }
    
    NSArray *array = [contents componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    VWW_LOG_INFO(@"Read %ld lines", (long)array.count);
    
    self.logFileURL = url;
    if([self createDB]){
        [self populateDatabaseFromLogFileAtURL:url];
    }
    
    completionBlock(YES);
}

#pragma mark Private methods
-(BOOL)createDB{
    
    // Get the documents directory
    NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsDir = dirPaths[0];
    
    // Build the path to the database file
    NSString *databaseName = [VWWFileController nameOfFileAtURL:self.logFileURL];
    databaseName = [databaseName stringByReplacingOccurrencesOfString:@".log" withString:@".sqlite"];
    

    self.databasePath = [[NSString alloc] initWithString:[docsDir stringByAppendingPathComponent:databaseName]];
    


    // Check if db already exists. if so delete it
    NSFileManager *filemgr = [NSFileManager defaultManager];
    if ([filemgr fileExistsAtPath:self.databasePath ] == YES){
        [filemgr removeItemAtPath:self.databasePath error:nil];
    }
    
    BOOL isSuccess = YES;
    const char *dbpath = [self.databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK) {
        VWW_LOG_INFO(@"Created DB at path: %@", self.databasePath);
    } else {
        isSuccess = NO;
        VWW_LOG_INFO(@"Failed to open/create database");
    }
    
    return isSuccess;
}



-(void)populateDatabaseFromLogFileAtURL:(NSURL*)url{
    NSUInteger errorcount = 0;

    if([VWWFileController fileExistsAtURL:url] == NO){
        VWW_LOG_ERROR(@"File does not exist");
        return;
    }

    int index = 0;
    char *errMsg;
    

    // Create FMT table
    NSMutableString *createTableString = [[NSMutableString alloc]initWithString:@"CREATE TABLE 'FMT' (typeID integer PRIMARY KEY,length integer,name varchar(200),format varchar(6000),val varchar(6000));"];
    VWW_LOG_INFO(@"SQL: %@", createTableString);
    errMsg = "";
    const char *createTableStatement = [createTableString cStringUsingEncoding:NSUTF8StringEncoding];
    sqlite3_stmt *stmt;
    sqlite3_prepare_v2(database, createTableStatement, -1, &stmt, NULL);
    assert_run_query(stmt);


    // Base sql for inserting into FMT table
    NSMutableString *insertString = [[NSMutableString alloc]initWithString:@"INSERT INTO 'FMT' (typeID,length,name,format,val) values (?,?,?,?,?);"];
    VWW_LOG_INFO(@"SQL: %@", insertString);
    

    // Dictionaries to store query bases
    NSMutableDictionary *nameToInsertQuery = [@{}mutableCopy];
    NSMutableDictionary *nameToTypeString = [@{}mutableCopy];
    
    
    BOOL firstactual = YES;
    NSError *error;
    // Open file and split by lines
    NSString *logFileContents = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
    NSArray *lines = [logFileContents componentsSeparatedByString:@"\n"];
    for(NSString *line in lines){
        NSArray *linesplit = [line componentsSeparatedByString:@","];
        if(linesplit.count > 0){
            if(index == 0){
                
            }
            
            index++;
            
            // FMT is the format description table. Each line that begins with FMT describes and creates another table.
            if([line hasPrefix:@"FMT"]){
                if(linesplit.count > 4){
                    NSString *type = [linesplit[3] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    if([type isEqualToString:@"FMT"] == NO){
                        NSString *descstr = [linesplit[4] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                        nameToTypeString[type] = descstr;
                        if([descstr isEqualToString:@""]){
                            continue;
                        }

                        NSMutableString *valuestr = [[NSMutableString alloc]initWithString:@""];
                        NSMutableString *inserttable = [NSMutableString stringWithFormat:@"insert or replace into '%@' (idx", type];
                        NSMutableString *insertvalues = [[NSMutableString alloc]initWithString:@"(?"];
                        NSMutableString *mktable = [[NSMutableString alloc]initWithFormat:@"CREATE TABLE '%@' (idx integer PRIMARY KEY", type];

                        for(int i = 5; i < linesplit.count; i++){
                            NSString *name = [linesplit[i] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                            NSString *type = [descstr substringFromIndex:i - 5];
                            [valuestr appendFormat:@"%@,", name];
                            
                            VWW_LOG_DEBUG(@"%@ %@", name, type);
                            if([type isEqualToString:@"I"]){
                                [mktable appendFormat:@",%@ integer", name];
                            } else if([type isEqualToString:@"f"]){
                                [mktable appendFormat:@",%@ real", name];
                            } else if([type isEqualToString:@"h"]){
                                [mktable appendFormat:@",%@ real", name];
                            } else if([type isEqualToString:@"L"]){
                                [mktable appendFormat:@",%@ integer", name];
                            } else if([type isEqualToString:@"e"]){
                                [mktable appendFormat:@",%@ real", name];
                            } else if([type isEqualToString:@"c"]){
                                [mktable appendFormat:@",%@ real", name];
                            } else{
                                [mktable appendFormat:@",%@ real", name];
                            }

                            [inserttable appendFormat:@",%@", name];
                            [insertvalues appendFormat:@",?"];
                        }

                        [inserttable appendFormat:@")"];
                        [insertvalues appendFormat:@")"];
                        valuestr = [[valuestr substringWithRange:NSMakeRange(0, valuestr.length - 1)]mutableCopy];
                        NSString *final = [NSString stringWithFormat:@"%@ values %@;", inserttable, insertvalues];
                        VWW_LOG_INFO(@"SQL: %@", final);
                        [mktable appendFormat:@");"];

                        const char *mkTableString = [mktable cStringUsingEncoding:NSUTF8StringEncoding];
                        sqlite3_prepare_v2(database, mkTableString, -1, &stmt, NULL);
                        assert_run_query(stmt);
                        
                        const char *insertFMTString = [insertString cStringUsingEncoding:NSUTF8StringEncoding];
                        sqlite3_prepare_v2(database, insertFMTString, -1, &stmt, NULL);
                        sqlite3_bind_int(stmt, 1, index);
                        sqlite3_bind_int(stmt, 2, 0);
                        bind_string(stmt, 3, type);
                        bind_string(stmt, 4, descstr);
                        bind_string(stmt, 5, valuestr);
                        assert_run_query(stmt);
                        nameToInsertQuery[type] = final;
                    } else {
                        VWW_LOG_ERROR(@"Error with line in plot log file: %@", line);
                    }
                }

        } else {
                // These are the values that go into other tables than FMT
                if(linesplit.count > 1)
                {
                    NSString *name = [linesplit[0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    if(nameToInsertQuery[name] != nil){
                        if(firstactual == YES){
                            firstactual = NO;
                        }
                        NSString *typestr = nameToTypeString[name];

                        NSString *insert = nameToInsertQuery[name];
                        const char *insertSting = [insert cStringUsingEncoding:NSUTF8StringEncoding];
                        sqlite3_prepare_v2(database, insertSting, -1, &stmt, NULL);
                        sqlite3_bind_int(stmt, 1, index);
                        
                        if(typestr.length != linesplit.count - 1){
                            VWW_LOG_DEBUG(@"Bound values for %@ count is not correct", name);
                            errorcount++;
                        }  else {
                            for(int i = 1; i < linesplit.count; i++){
//                                I int
//                                f float
//                                h float
//                                L int
//                                e float
//                                c float
//                                else float

                                if([typestr characterAtIndex:i-1] == 'I') {
                                    sqlite3_bind_int(stmt, i+1, (int)((NSString*)linesplit[i]).integerValue);
                                } else if([typestr characterAtIndex:i-1] == 'f') {
                                    sqlite3_bind_double(stmt, i+1, ((NSString*)linesplit[i]).doubleValue);
                                } else if([typestr characterAtIndex:i-1] == 'h') {
                                    sqlite3_bind_double(stmt, i+1, ((NSString*)linesplit[i]).doubleValue);
                                } else if([typestr characterAtIndex:i-1] == 'c') {
                                    float c = ((NSString*)linesplit[i]).floatValue * 100;
                                    sqlite3_bind_double(stmt, i+1, c);
                                } else if([typestr characterAtIndex:i-1] == 'C') {
                                    sqlite3_bind_double(stmt, i+1, ((NSString*)linesplit[i]).doubleValue * 100);
                                } else if([typestr characterAtIndex:i-1] == 'e') {
                                    sqlite3_bind_double(stmt, i+1, ((NSString*)linesplit[i]).doubleValue * 100);
                                } else if([typestr characterAtIndex:i-1] == 'E') {
                                    sqlite3_bind_double(stmt, i+1, ((NSString*)linesplit[i]).doubleValue + 100);
                                } else if([typestr characterAtIndex:i-1] == 'L') {
                                    sqlite3_bind_int(stmt, i+1, (int)((NSString*)linesplit[i]).longLongValue);
                                } else {
                                    sqlite3_bind_double(stmt, i+1, ((NSString*)linesplit[i]).doubleValue);
                                }
                            }
                            assert_run_query(stmt);
                        }
                    }
                }
            }
        }
    }
    if(errorcount){
        VWW_LOG_ERROR(@"Encountered %ld errors while parsing log file", (long)errorcount);
    }
}

@end
