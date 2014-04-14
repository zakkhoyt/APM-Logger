//
//  AP2DataSet.m
//  APM Logger
//
//  Created by Zakk Hoyt on 3/25/14.
//  Copyright (c) 2014 Zakk Hoyt. All rights reserved.
//

#import "AP2DataPlot.h"

#import "VWWFileController.h"



@interface AP2DataPlot ()
@property (nonatomic, strong, readwrite) NSString *databasePath;
@property (nonatomic, strong, readwrite) NSURL *logFileURL;
@property (nonatomic, strong) dispatch_queue_t dbQueue;
@property (readwrite) FMDatabase *db;
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

-(id)init{
    self = [super init];
    if(self){
        _dbQueue = dispatch_queue_create("com.vaporwarewolf.apmlogger.dbqueue", NULL);
    }
    return self;
}


-(void)configureWithURL:(NSURL*)url completionBlock:(VWWBoolBlock)completionBlock{
    dispatch_async(self.dbQueue, ^{
        NSError *error;
        NSString *contents = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
        if(error){
            VWW_LOG_ERROR(@"Could not read file from URL");
            completionBlock(NO);
        }
        
        NSArray *array = [contents componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        VWW_LOG_INFO(@"Read %ld lines", (long)array.count);
        
        self.logFileURL = url;
        [self createDBWithCompletionBlock:^(BOOL success) {
            if(success){
                [self populateDatabaseFromLogFileAtURL:url completionBlock:^(BOOL success) {
                    completionBlock(success);
                }];
            } else {
                completionBlock(NO);
            }
        }];
    });
}
//
//- (void)populateDatabase:(FMDatabase *)db
//{
//    [db executeUpdate:@"create table test (a text, b text, c integer, d double, e double)"];
//    
//    [db beginTransaction];
//    int i = 0;
//    while (i++ < 20) {
//        [db executeUpdate:@"insert into test (a, b, c, d, e) values (?, ?, ?, ?, ?)" ,
//         @"hi'", // look!  I put in a ', and I'm not escaping it!
//         [NSString stringWithFormat:@"number %d", i],
//         [NSNumber numberWithInt:i],
//         [NSDate date],
//         [NSNumber numberWithFloat:2.2f]];
//    }
//    [db commit];
//    
//    // do it again, just because
//    [db beginTransaction];
//    i = 0;
//    while (i++ < 20) {
//        [db executeUpdate:@"insert into test (a, b, c, d, e) values (?, ?, ?, ?, ?)" ,
//         @"hi again'", // look!  I put in a ', and I'm not escaping it!
//         [NSString stringWithFormat:@"number %d", i],
//         [NSNumber numberWithInt:i],
//         [NSDate date],
//         [NSNumber numberWithFloat:2.2f]];
//    }
//    [db commit];
//    
//    [db executeUpdate:@"create table t3 (a somevalue)"];
//    
//    [db beginTransaction];
//    for (int i=0; i < 20; i++) {
//        [db executeUpdate:@"insert into t3 (a) values (?)", [NSNumber numberWithInt:i]];
//    }
//    [db commit];
//}

#pragma mark Private methods
-(void)createDBWithCompletionBlock:(VWWBoolBlock)completionBlock{
    
    dispatch_async(self.dbQueue, ^{
        
        // Build the path to the database file
        NSString *databaseName = [VWWFileController nameOfFileAtURL:self.logFileURL];
        databaseName = [databaseName stringByReplacingOccurrencesOfString:@".log" withString:@".sqlite"];
        self.databasePath = [[NSString alloc] initWithString:[[VWWFileController urlForDatabasesDirectory].path stringByAppendingPathComponent:databaseName]];
        
        VWW_LOG_DEBUG(@"Database path: %@", self.databasePath);
        
        // Delete the old database
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager removeItemAtPath:self.databasePath error:NULL];
        self.db = [FMDatabase databaseWithPath:self.databasePath];
        if([self.db open] == NO){
            VWW_LOG_ERROR(@"Wan't able to open database");
            completionBlock(NO);
        }
        completionBlock(YES);

    });
}



-(void)populateDatabaseFromLogFileAtURL:(NSURL*)url completionBlock:(VWWBoolBlock)completionBlock{
    dispatch_async(self.dbQueue, ^{
        NSMutableString *databaseStrings = [[NSMutableString alloc]initWithCapacity:1024 * 100];
        VWW_LOG_TODO_TASK(@"This needs to run on it's own queue");
        NSUInteger errorcount = 0;
        
        if([VWWFileController fileExistsAtURL:url] == NO){
            VWW_LOG_ERROR(@"File does not exist");
            completionBlock(NO);
        }
        
        int index = 0;
        
        //    [self.db beginTransaction];
        [self.db executeUpdate:@"CREATE TABLE 'FMT' (typeID integer PRIMARY KEY,length integer,name varchar(200),format varchar(6000),val varchar(6000));"];
        //    [self.db commit];
        [databaseStrings appendFormat:@"CREATE TABLE 'FMT' (typeID integer PRIMARY KEY,length integer,name varchar(200),format varchar(6000),val varchar(6000));\n"];
        
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
                                
                                //                            VWW_LOG_DEBUG(@"%@ %@", name, type);
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
                            [mktable appendFormat:@");"];
                            
                            // Create param table
                            [databaseStrings appendFormat:@"%@\n", mktable];
                            if([self.db executeUpdate:mktable] == NO){
                                NSError *error = [self.db lastError];
                                VWW_LOG_ERROR(@"Could not exectue update: %@", error.description);
                            }
                            
                            // Write table representation into FMT table
                            [databaseStrings appendFormat:@"%@\n", insertString];
                            NSArray *args = @[@(index), @(0), type, descstr, valuestr];
                            if([self.db executeUpdate:insertString withArgumentsInArray:args] == NO){
                                NSError *error = [self.db lastError];
                                VWW_LOG_ERROR(@"Could not exectue update: %@", error.description);
                            }
                            
                            
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
                            NSMutableArray *args = [@[@(index)]mutableCopy];
                            
                            
                            
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
                                    
                                    //                                VWW_LOG_TODO_TASK(@"APM's github recieved reports of these letter formats being incorrect for one or tow of them. Pull the updates source and compare");
                                    if([typestr characterAtIndex:i-1] == 'I') {
                                        [args addObject:@((int)((NSString*)linesplit[i]).integerValue)];
                                    } else if([typestr characterAtIndex:i-1] == 'f') {
                                        [args addObject:@(((NSString*)linesplit[i]).doubleValue)];
                                    } else if([typestr characterAtIndex:i-1] == 'h') {
                                        [args addObject:@(((NSString*)linesplit[i]).doubleValue)];
                                    } else if([typestr characterAtIndex:i-1] == 'c') {
                                        float c = ((NSString*)linesplit[i]).floatValue * 100;
                                        [args addObject:@(c)];
                                    } else if([typestr characterAtIndex:i-1] == 'C') {
                                        [args addObject:@(((NSString*)linesplit[i]).doubleValue * 100)];
                                    } else if([typestr characterAtIndex:i-1] == 'e') {
                                        [args addObject:@(((NSString*)linesplit[i]).doubleValue * 100)];
                                    } else if([typestr characterAtIndex:i-1] == 'E') {
                                        [args addObject:@(((NSString*)linesplit[i]).doubleValue + 100)];
                                    } else if([typestr characterAtIndex:i-1] == 'L') {
                                        [args addObject:@((int)((NSString*)linesplit[i]).longLongValue)];
                                    } else {
                                        [args addObject:@(((NSString*)linesplit[i]).doubleValue)];
                                    }
                                }
                                
                                [self.db beginTransaction];
                                if([self.db executeUpdate:insert withArgumentsInArray:args] == NO){
                                    NSError *error = [self.db lastError];
                                    VWW_LOG_ERROR(@"Could not exectue update: %@", error.description);
                                }
                                [self.db commit];
                            }
                        }
                    }
                }
            }
        }
        if(errorcount){
            VWW_LOG_ERROR(@"Encountered %ld errors while parsing log file", (long)errorcount);
            
        }
        
        VWW_LOG_DEBUG(@"Created database with strings:\n%@", databaseStrings);
        completionBlock(YES);
    });
    

}


-(void)getTablesWithCompletionBlock:(VWWArrayBlock)completionBlock{
    dispatch_async(self.dbQueue, ^{
        FMResultSet *resultSet = [self.db executeQuery:@"SELECT name FROM sqlite_master WHERE type = \"table\""];
        if(resultSet == nil){
            return completionBlock(@[]);
        } else {
            NSMutableArray *tables = [@[]mutableCopy];
            while ([resultSet next]) {
                NSString *table = [resultSet stringForColumnIndex:0];
                [tables addObject:table];
            }
            [resultSet close];
            return completionBlock(tables);
        }
        
    });
    
}

-(void)getDataForTable:(NSString*)table completionBlock:(VWWArrayBlock)completionBlock{
    dispatch_async(self.dbQueue, ^{
        FMResultSet *resultSet = [self.db executeQuery:@"SELECT * from %@", table];
        if(resultSet == nil){
            return completionBlock(@[]);
        } else {
            NSMutableArray *tables = [@[]mutableCopy];
            while ([resultSet next]) {
                NSString *table = [resultSet stringForColumnIndex:0];
                [tables addObject:table];
            }
            [resultSet close];
            return completionBlock(tables);
        }
        
    });
    
}
@end
