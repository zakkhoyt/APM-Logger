//
//  AP2DataSet.m
//  APM Logger
//
//  Created by Zakk Hoyt on 3/25/14.
//  Copyright (c) 2014 Zakk Hoyt. All rights reserved.
//

#import "VWWAP2DataController.h"
#import "FMDB.h"
#import "VWWFileController.h"



@interface VWWAP2DataController ()
@property (nonatomic, strong, readwrite) NSString *databasePath;
@property (nonatomic, strong, readwrite) NSURL *logFileURL;
@property (nonatomic, strong) dispatch_queue_t dbQueue;
@property FMDatabase *db;
@end

@implementation VWWAP2DataController

#pragma mark Public methods


//+(AP2DataPlotController*)getSharedInstance{
//    static AP2DataPlotController *sharedInstance = nil;
//    if (!sharedInstance) {
//        sharedInstance = [[super allocWithZone:NULL]init];
//        [sharedInstance createDB];
//    }
//    return sharedInstance;
//}



+(void)summaryFromLogFileAtURL:(NSURL*)url completionBlock:(VWWLogFileSummaryBlock)completionBlock{
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

+(void)dataPlotFromLogFileAtURL:(NSURL*)url completionBlock:(VWWA2PDataSetBlock)extractBlock{
    VWWAP2DataController *dataSet = [[VWWAP2DataController alloc]init];
    [dataSet configureWithURL:url completionBlock:^(BOOL success){
        dispatch_async(dispatch_get_main_queue(), ^{
            extractBlock(dataSet);
        });
    }];
    
}




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
//                [self populateDatabaseAtURL:url completionBlock:^(BOOL success) {
//                    completionBlock(success);
//                }];
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


-(void)populateDatabaseAtURL:(NSURL*)url completionBlock:(VWWBoolBlock)completionBlock{
    dispatch_async(self.dbQueue, ^{
        if([VWWFileController fileExistsAtURL:url] == NO){
            VWW_LOG_ERROR(@"Database does not exist");
            completionBlock(NO);
        }

        

        [self.db executeUpdate:@"CREATE TABLE 'FMT' (typeID integer PRIMARY KEY,length integer,name varchar(200),format varchar(6000),val varchar(6000));"];
        
        [self.db executeUpdate:@"CREATE TABLE 'PARM' (idx integer PRIMARY KEY,Name text,Value real);"];
        [self.db executeUpdate:@"INSERT INTO 'FMT' (typeID,length,name,format,val) values (7,0,\"PARM\",\"Nf\",\"Name,Value\");"];
        
        [self.db executeUpdate:@"CREATE TABLE 'GPS' (idx integer PRIMARY KEY,Status integer,TimeMS integer,Week integer,NSats integer,HDop real,Lat integer,Lng integer,RelAlt real,Alt real,Spd real,GCrs real,VZ real,T integer);"];
        [self.db executeUpdate:@"INSERT INTO 'FMT' (typeID,length,name,format,val) values (8,0,\"GPS\",\"BIHBcLLeeEefI\",\"Status,TimeMS,Week,NSats,HDop,Lat,Lng,RelAlt,Alt,Spd,GCrs,VZ,T\");"];
        
        [self.db executeUpdate:@"CREATE TABLE 'IMU' (idx integer PRIMARY KEY,TimeMS integer,GyrX real,GyrY real,GyrZ real,AccX real,AccY real,AccZ real);"];
        [self.db executeUpdate:@"INSERT INTO 'FMT' (typeID,length,name,format,val) values (9,0,\"IMU\",\"Iffffff\",\"TimeMS,GyrX,GyrY,GyrZ,AccX,AccY,AccZ\");"];
        
        [self.db executeUpdate:@"CREATE TABLE 'MSG' (idx integer PRIMARY KEY,Message text);"];
        [self.db executeUpdate:@"INSERT INTO 'FMT' (typeID,length,name,format,val) values (10,0,\"MSG\",\"Z\",\"Message\");"];
        
        [self.db executeUpdate:@"CREATE TABLE 'ATUN' (idx integer PRIMARY KEY,Axis integer,TuneStep integer,RateMin real,RateMax real,RPGain real,RDGain real,SPGain real);"];
        [self.db executeUpdate:@"INSERT INTO 'FMT' (typeID,length,name,format,val) values (11,0,\"ATUN\",\"BBfffff\",\"Axis,TuneStep,RateMin,RateMax,RPGain,RDGain,SPGain\");"];
        
        [self.db executeUpdate:@"CREATE TABLE 'ATDE' (idx integer PRIMARY KEY,Angle real,Rate real);"];
        [self.db executeUpdate:@"INSERT INTO 'FMT' (typeID,length,name,format,val) values (12,0,\"ATDE\",\"cf\",\"Angle,Rate\");"];
        
        [self.db executeUpdate:@"CREATE TABLE 'CURR' (idx integer PRIMARY KEY,ThrOut integer,ThrInt integer,Volt integer,Curr integer,Vcc integer,CurrTot real);"];
        [self.db executeUpdate:@"INSERT INTO 'FMT' (typeID,length,name,format,val) values (13,0,\"CURR\",\"hIhhhf\",\"ThrOut,ThrInt,Volt,Curr,Vcc,CurrTot\");"];
        
        [self.db executeUpdate:@"CREATE TABLE 'MOT' (idx integer PRIMARY KEY,Mot1 integer,Mot2 integer,Mot3 integer,Mot4 integer);"];
        [self.db executeUpdate:@"INSERT INTO 'FMT' (typeID,length,name,format,val) values (14,0,\"MOT\",\"hhhh\",\"Mot1,Mot2,Mot3,Mot4\");"];
        
        [self.db executeUpdate:@"CREATE TABLE 'OF' (idx integer PRIMARY KEY,Dx integer,Dy integer,SQual integer,X real,Y real,Lat real,Lng real,Roll real,Pitch real);"];
        [self.db executeUpdate:@"INSERT INTO 'FMT' (typeID,length,name,format,val) values (15,0,\"OF\",\"hhBccffee\",\"Dx,Dy,SQual,X,Y,Lat,Lng,Roll,Pitch\");"];
        
        [self.db executeUpdate:@"CREATE TABLE 'NTUN' (idx integer PRIMARY KEY,WPDst real,WPBrg real,PErX real,PErY real,DVelX real,DVelY real,VelX real,VelY real,DAcX real,DAcY real,DRol real,DPit real);"];
        [self.db executeUpdate:@"INSERT INTO 'FMT' (typeID,length,name,format,val) values (16,0,\"NTUN\",\"Ecffffffffee\",\"WPDst,WPBrg,PErX,PErY,DVelX,DVelY,VelX,VelY,DAcX,DAcY,DRol,DPit\");"];
        
        [self.db executeUpdate:@"CREATE TABLE 'CTUN' (idx integer PRIMARY KEY,ThrIn integer,SonAlt real,BarAlt real,WPAlt real,DesSonAlt real,AngBst integer,CRate integer,ThrOut integer,DCRate integer);"];
        [self.db executeUpdate:@"INSERT INTO 'FMT' (typeID,length,name,format,val) values (17,0,\"CTUN\",\"hcefchhhh\",\"ThrIn,SonAlt,BarAlt,WPAlt,DesSonAlt,AngBst,CRate,ThrOut,DCRate\");"];
        
        [self.db executeUpdate:@"CREATE TABLE 'MAG' (idx integer PRIMARY KEY,MagX integer,MagY integer,MagZ integer,OfsX integer,OfsY integer,OfsZ integer,MOfsX integer,MOfsY integer,MOfsZ integer);"];
        [self.db executeUpdate:@"INSERT INTO 'FMT' (typeID,length,name,format,val) values (18,0,\"MAG\",\"hhhhhhhhh\",\"MagX,MagY,MagZ,OfsX,OfsY,OfsZ,MOfsX,MOfsY,MOfsZ\");"];
        
        [self.db executeUpdate:@"CREATE TABLE 'PM' (idx integer PRIMARY KEY,RenCnt integer,RenBlw integer,NLon integer,NLoop integer,MaxT integer,PMT integer,I2CErr integer,INSErr integer,INAVErr integer);"];
        [self.db executeUpdate:@"INSERT INTO 'FMT' (typeID,length,name,format,val) values (19,0,\"PM\",\"BBHHIhBHB\",\"RenCnt,RenBlw,NLon,NLoop,MaxT,PMT,I2CErr,INSErr,INAVErr\");"];
        
        [self.db executeUpdate:@"CREATE TABLE 'CMD' (idx integer PRIMARY KEY,CTot integer,CNum integer,CId integer,COpt integer,Prm1 integer,Alt real,Lat integer,Lng integer);"];
        [self.db executeUpdate:@"INSERT INTO 'FMT' (typeID,length,name,format,val) values (20,0,\"CMD\",\"BBBBBeLL\",\"CTot,CNum,CId,COpt,Prm1,Alt,Lat,Lng\");"];
        
        [self.db executeUpdate:@"CREATE TABLE 'ATT' (idx integer PRIMARY KEY,RollIn real,Roll real,PitchIn real,Pitch real,YawIn real,Yaw real,NavYaw real);"];
        [self.db executeUpdate:@"INSERT INTO 'FMT' (typeID,length,name,format,val) values (21,0,\"ATT\",\"cccccCC\",\"RollIn,Roll,PitchIn,Pitch,YawIn,Yaw,NavYaw\");"];
        
        [self.db executeUpdate:@"CREATE TABLE 'INAV' (idx integer PRIMARY KEY,BAlt real,IAlt real,IClb real,ACorrX real,ACorrY real,ACorrZ real,GLat integer,GLng integer,ILat real,ILng real);"];
        [self.db executeUpdate:@"INSERT INTO 'FMT' (typeID,length,name,format,val) values (22,0,\"INAV\",\"cccfffiiff\",\"BAlt,IAlt,IClb,ACorrX,ACorrY,ACorrZ,GLat,GLng,ILat,ILng\");"];
        
        [self.db executeUpdate:@"CREATE TABLE 'MODE' (idx integer PRIMARY KEY,Mode integer,ThrCrs integer);"];
        [self.db executeUpdate:@"INSERT INTO 'FMT' (typeID,length,name,format,val) values (23,0,\"MODE\",\"Mh\",\"Mode,ThrCrs\");"];
        
        [self.db executeUpdate:@"CREATE TABLE 'EV' (idx integer PRIMARY KEY,Id integer);"];
        [self.db executeUpdate:@"INSERT INTO 'FMT' (typeID,length,name,format,val) values (25,0,\"EV\",\"B\",\"Id\");"];
        
        [self.db executeUpdate:@"CREATE TABLE 'D16' (idx integer PRIMARY KEY,Id integer,Value integer);"];
        [self.db executeUpdate:@"INSERT INTO 'FMT' (typeID,length,name,format,val) values (26,0,\"D16\",\"Bh\",\"Id,Value\");"];
        
        [self.db executeUpdate:@"CREATE TABLE 'DU16' (idx integer PRIMARY KEY,Id integer,Value integer);"];
        [self.db executeUpdate:@"INSERT INTO 'FMT' (typeID,length,name,format,val) values (27,0,\"DU16\",\"BH\",\"Id,Value\");"];
        
        [self.db executeUpdate:@"CREATE TABLE 'D32' (idx integer PRIMARY KEY,Id integer,Value integer);"];
        [self.db executeUpdate:@"INSERT INTO 'FMT' (typeID,length,name,format,val) values (28,0,\"D32\",\"Bi\",\"Id,Value\");"];
        
        [self.db executeUpdate:@"CREATE TABLE 'DU32' (idx integer PRIMARY KEY,Id integer,Value integer);"];
        [self.db executeUpdate:@"INSERT INTO 'FMT' (typeID,length,name,format,val) values (29,0,\"DU32\",\"BI\",\"Id,Value\");"];
        
        [self.db executeUpdate:@"CREATE TABLE 'DFLT' (idx integer PRIMARY KEY,Id integer,Value real);"];
        [self.db executeUpdate:@"INSERT INTO 'FMT' (typeID,length,name,format,val) values (30,0,\"DFLT\",\"Bf\",\"Id,Value\");"];
        
        [self.db executeUpdate:@"CREATE TABLE 'PID' (idx integer PRIMARY KEY,Id integer,Error integer,P integer,I integer,D integer,Out integer,Gain real);"];
        [self.db executeUpdate:@"INSERT INTO 'FMT' (typeID,length,name,format,val) values (31,0,\"PID\",\"Biiiiif\",\"Id,Error,P,I,D,Out,Gain\");"];
        
        [self.db executeUpdate:@"CREATE TABLE 'CAM' (idx integer PRIMARY KEY,GPSTime integer,GPSWeek integer,Lat integer,Lng integer,Alt real,Roll real,Pitch real,Yaw real);"];
        [self.db executeUpdate:@"INSERT INTO 'FMT' (typeID,length,name,format,val) values (32,0,\"CAM\",\"IHLLeccC\",\"GPSTime,GPSWeek,Lat,Lng,Alt,Roll,Pitch,Yaw\");"];
        
        [self.db executeUpdate:@"CREATE TABLE 'ERR' (idx integer PRIMARY KEY,Subsys integer,ECode integer);"];
        [self.db executeUpdate:@"INSERT INTO 'FMT' (typeID,length,name,format,val) values (33,0,\"ERR\",\"BB\",\"Subsys,ECode\");"];
        VWW_LOG_DEBUG(@"Created unpopulated database at path: %@", url.path);
        completionBlock(YES);
    });

}

-(void)populateDatabaseFromLogFileAtURL:(NSURL*)url completionBlock:(VWWBoolBlock)completionBlock{
    dispatch_async(self.dbQueue, ^{
        NSMutableString *databaseStrings = [[NSMutableString alloc]initWithCapacity:1024 * 100];
        VWW_LOG_TODO_TASK(@"This needs to run on it's own queue");
        NSUInteger errorcount = 0;
        
        if([VWWFileController fileExistsAtURL:url] == NO){
            VWW_LOG_ERROR(@"Database does not exist");
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
                                NSString *type = [descstr substringWithRange:NSMakeRange(i-5, 1)];
                                [valuestr appendFormat:@"%@,", name];
              
//                            VWW_LOG_DEBUG(@"%@ %@", name, type);
                                if([type isEqualToString:@"b"]){
                                    [mktable appendFormat:@",%@ integer", name];
                                } else if([type isEqualToString:@"B"]){
                                    [mktable appendFormat:@",%@ integer", name];
                                } else if([type isEqualToString:@"h"]){
                                    [mktable appendFormat:@",%@ integer", name];
                                } else if([type isEqualToString:@"H"]){
                                    [mktable appendFormat:@",%@ integer", name];
                                } else if([type isEqualToString:@"i"]){
                                    [mktable appendFormat:@",%@ integer", name];
                                } else if([type isEqualToString:@"I"]){
                                    [mktable appendFormat:@",%@ integer", name];
                                } else if([type isEqualToString:@"f"]){
                                    [mktable appendFormat:@",%@ real", name];
                                } else if([type isEqualToString:@"N"]){
                                    [mktable appendFormat:@",%@ text", name];
                                } else if([type isEqualToString:@"Z"]){
                                    [mktable appendFormat:@",%@ text", name];
                                } else if([type isEqualToString:@"c"]){
                                    [mktable appendFormat:@",%@ real", name];
                                } else if([type isEqualToString:@"C"]){
                                    [mktable appendFormat:@",%@ real", name];
                                } else if([type isEqualToString:@"e"]){
                                    [mktable appendFormat:@",%@ real", name];
                                } else if([type isEqualToString:@"E"]){
                                    [mktable appendFormat:@",%@ real", name];
                                } else if([type isEqualToString:@"L"]){
                                    [mktable appendFormat:@",%@ integer", name];
                                } else if([type isEqualToString:@"M"]){
                                    [mktable appendFormat:@",%@ integer", name];
                                } else {
                                    VWW_LOG_WARNING(@"Unknown data type: %@", type);
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
                            

                            NSArray *args = @[@(index), @(0), type, descstr, valuestr];
                            NSMutableString *params = [[NSMutableString alloc]initWithString:@"("];
                            for(id arg in args){
                                if([arg isKindOfClass:[NSString class]]){
                                    [params appendFormat:@"\\\"%@\\\",", arg];
                                } else {
                                    [params appendFormat:@"%@,", arg];
                                }
                                
                            }
                            NSString *p = [params substringToIndex:[params length] - 1];
                            p = [NSString stringWithFormat:@"%@)", p];
                            
                            
                            NSString* istr = [insertString stringByReplacingOccurrencesOfString:@"(?,?,?,?,?)" withString:p];
                            [databaseStrings appendFormat:@"%@\n", istr];
                            if([self.db executeUpdate:insertString withArgumentsInArray:args] == NO){
                                NSError *error = [self.db lastError];
                                VWW_LOG_ERROR(@"Could not exectue update: %@", error.description);
                            }
                            
                            
                            nameToInsertQuery[type] = final;
                        } else {
                            // FMT, 128, 89, FMT, BBnNZ, Type,Length,Name,Format
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
                                    
                                    if([typestr characterAtIndex:i-1] == 'b') {
                                        // Uint 8
                                        NSString *line = linesplit[i];
                                        uint8_t val = line.integerValue;
                                        [args addObject:@(val)];
                                    } else if([typestr characterAtIndex:i-1] == 'B') {
                                        // Uint 8
                                        NSString *line = linesplit[i];
                                        uint8_t val = line.integerValue;
                                        [args addObject:@(val)];
                                    } else if([typestr characterAtIndex:i-1] == 'h') {
                                        // Uint 16
                                        NSString *line = linesplit[i];
                                        uint16_t val = line.integerValue;
                                        [args addObject:@(val)];
                                    } else if([typestr characterAtIndex:i-1] == 'H') {
                                        // Uint 16
                                        NSString *line = linesplit[i];
                                        uint16_t val = line.integerValue;
                                        [args addObject:@(val)];
                                    } else if([typestr characterAtIndex:i-1] == 'i') {
                                        // Uint 32
                                        NSString *line = linesplit[i];
                                        uint32_t val = (uint32_t)line.longLongValue;
                                        [args addObject:@(val)];
                                    } else if([typestr characterAtIndex:i-1] == 'I') {
                                        // Uint 32
                                        NSString *line = linesplit[i];
                                        uint32_t val = (uint32_t)line.longLongValue;
                                        [args addObject:@(val)];
                                    } else if([typestr characterAtIndex:i-1] == 'f') {
                                        // float
                                        NSString *line = linesplit[i];
                                        float val = line.floatValue;
                                        [args addObject:@(val)];
                                    } else if([typestr characterAtIndex:i-1] == 'n') {
                                        // char(4)
                                        NSString *line = linesplit[i];
                                        //uint8_t val = line.floatValue;
                                        [args addObject:line];
                                    } else if([typestr characterAtIndex:i-1] == 'N') {
                                        // char(16
                                        NSString *line = linesplit[i];
                                        //uint8_t val = line.floatValue;
                                        [args addObject:line];
                                    } else if([typestr characterAtIndex:i-1] == 'Z') {
                                        // char 64
                                        NSString *line = linesplit[i];
                                        //uint8_t val = line.floatValue;
                                        [args addObject:line];
                                    } else if([typestr characterAtIndex:i-1] == 'c') {
                                        // uint16 * 100
                                        NSString *line = linesplit[i];
                                        uint16_t val = line.integerValue;
                                        val /= 100;
                                        [args addObject:@(val)];
                                    } else if([typestr characterAtIndex:i-1] == 'C') {
                                        // uint16 * 100
                                        NSString *line = linesplit[i];
                                        uint16_t val = line.integerValue;
                                        val /= 100;
                                        [args addObject:@(val)];
                                    } else if([typestr characterAtIndex:i-1] == 'e') {
                                        // uint32 * 100
                                        NSString *line = linesplit[i];
                                        uint32_t val = (uint32_t)line.longLongValue;
                                        val /= 100.0;
                                        [args addObject:@(val)];
                                    } else if([typestr characterAtIndex:i-1] == 'E') {
                                        // uint32 * 100
                                        NSString *line = linesplit[i];
                                        uint32_t val = (uint32_t)line.longLongValue;
                                        val /= 100.0;
                                        [args addObject:@(val)];
                                    } else if([typestr characterAtIndex:i-1] == 'L') {
                                        //uint32_t GPS Lon/Lat * 10000000
                                        NSString *line = linesplit[i];
                                        double val = line.doubleValue;
                                        val *= 10000000;
                                        [args addObject:@(val)];
                                    } else if([typestr characterAtIndex:i-1] == 'M') {
                                        // Uint 8
                                        NSString *line = linesplit[i];
                                        uint8_t val = line.integerValue;
                                        [args addObject:@(val)];
                                    } else {
                                        char type = [typestr characterAtIndex:i-1];
                                        VWW_LOG_WARNING(@"Unknown data type: %c", type);
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


-(void)getParamsWithCompletionBlock:(VWWArrayBlock)completionBlock{
    dispatch_async(self.dbQueue, ^{

        
//        FMResultSet *resultSet = [self.db executeQuery:@"SELECT name FROM sqlite_master WHERE type = \"table\""];
//        if(resultSet == nil){
//            return completionBlock(@[]);
//        } else {
//            NSMutableArray *tables = [@[]mutableCopy];
//            while ([resultSet next]) {
//                NSString *table = [resultSet stringForColumnIndex:0];
//                [tables addObject:table];
//            }
//            [resultSet close];
//            return completionBlock(tables);
//        }
        
        
//        FMResultSet *tablesSet = [self.db executeQuery:@"SELECT name FROM sqlite_master WHERE type = \"table\""];
//        if(tablesSet == nil){
//            VWW_LOG_WARNING(@"Could not get a list of tables");
//            return completionBlock(@[]);
//        } else {
//            NSMutableArray *filters = [@[]mutableCopy];
//            while ([tablesSet next]) {
//                NSString *table = [tablesSet stringForColumnIndex:0];
//                NSString *columnString = [NSString stringWithFormat:@"SELECT val FROM FMT where name = \"%@\"", table];
//                FMResultSet *columnsSet = [self.db executeQuery:columnString];
//                while([columnsSet next]){
//                    NSString *columnsString = [columnsSet stringForColumn:@"val"];
//                    NSArray *columns = [columnsString componentsSeparatedByString:@","];
////                    for(NSString *column in columns){
//                        NSDictionary *filter = @{AP2DataPlotTableKey : table,
//                                            AP2DataPlotColumnsKey : columns};
//                        [filters addObject:filter];
////                    }
//                    break;
//                }
//                [columnsSet close];
//            }
//            [tablesSet close];
//            return completionBlock(filters);
//        }

        
        FMResultSet *tablesSet = [self.db executeQuery:@"SELECT name FROM sqlite_master WHERE type = \"table\""];
        if(tablesSet == nil){
            VWW_LOG_WARNING(@"Could not get a list of tables");
            return completionBlock(@[]);
        } else {
            NSMutableArray *filters = [@[]mutableCopy];
            while ([tablesSet next]) {
                NSString *table = [tablesSet stringForColumnIndex:0];
                NSString *columnString = [NSString stringWithFormat:@"SELECT val FROM FMT where name = \"%@\"", table];
                FMResultSet *columnsSet = [self.db executeQuery:columnString];
                while([columnsSet next]){
                    NSString *columnsString = [columnsSet stringForColumn:@"val"];
                    NSArray *columns = [columnsString componentsSeparatedByString:@","];
                    NSArray *sortedColumns = [self sortColumns:columns];
                    for(NSString *column in sortedColumns){
                        NSDictionary *filter = @{AP2DataPlotTableKey : table,
                                                 AP2DataPlotColumnKey : column,
                                                 AP2DataPlotActiveKey : @(0)};
                        [filters addObject:filter];
                    }
                    
                }
                [columnsSet close];
            }
            [tablesSet close];
            
            
            NSArray *sortedFilters = [self sortTables:filters];
            
            return completionBlock(sortedFilters);
        }

    });
    
}

-(NSArray*)sortColumns:(NSArray*)unsortedArray{
    NSArray* sortedStacks = [unsortedArray sortedArrayUsingComparator:^NSComparisonResult(NSString *column1, NSString *column2) {
        return [column1 compare:column2];
    }];
    return sortedStacks;
}


-(NSArray*)sortTables:(NSArray*)unsortedArray{
    NSArray* sortedStacks = [unsortedArray sortedArrayUsingComparator:^NSComparisonResult(NSDictionary *item1, NSDictionary *item2) {
        NSDate *table1 = item1[AP2DataPlotTableKey];
        NSDate *table2 = item2[AP2DataPlotTableKey];
        return [table1 compare:table2];
    }];
    return sortedStacks;
}


-(void)getDataForTable:(NSString*)table completionBlock:(VWWArrayBlock)completionBlock{
    dispatch_async(self.dbQueue, ^{
        NSString *queryString = [NSString stringWithFormat:@"SELECT * from %@", table];
        FMResultSet *resultSet = [self.db executeQuery:queryString];
        if(resultSet == nil){
            return completionBlock(@[]);
        } else {
            NSMutableArray *data = [@[]mutableCopy];
            NSInteger index = 0;
            while ([resultSet next]) {
                NSNumber *latitude = @([resultSet intForColumn:@"NavYaw"]);
//                NSNumber *latitude = @([resultSet intForColumn:@"Lat"]);
//                NSNumber *longitude = @([resultSet intForColumn:@"Lon"]);

                NSDictionary *dict = @{@"x" : @(index),
                                       @"y" : latitude};
                [data addObject:dict];
                index++;
            }
            [resultSet close];
            return completionBlock(data);
        }
        
    });
    
}
@end
