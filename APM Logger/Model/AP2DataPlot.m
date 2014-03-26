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
        completionBlock(nil);
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
    databaseName = [databaseName stringByReplacingOccurrencesOfString:@".log" withString:@".db"];
    

    self.databasePath = [[NSString alloc] initWithString:[docsDir stringByAppendingPathComponent:databaseName]];
    


    // Check if db already exists. if so delete it
    NSFileManager *filemgr = [NSFileManager defaultManager];
    if ([filemgr fileExistsAtPath:self.databasePath ] == YES){
        [filemgr removeItemAtPath:self.databasePath error:nil];
    }
    
    BOOL isSuccess = YES;
    const char *dbpath = [self.databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        //            char *errMsg;
        //            const char *sql_stmt = "create table if not exists testTable (regno integer primary key, name text, department text, year text)";
        //            if (sqlite3_exec(database, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK) {
        //                isSuccess = NO;
        //                VWW_LOG_INFO(@"Failed to create table");
        //            }
        //            sqlite3_close(database);
        VWW_LOG_INFO(@"Created DB at path: %@", self.databasePath);
    }
    else {
        isSuccess = NO;
        VWW_LOG_INFO(@"Failed to open/create database");
    }
    
    return isSuccess;
}



// This is a sql sample from another project:
//- (void)done {
//    dispatch_async(self.dbQueue, ^{
//        sqlite3 *db = 0;
//        sqlite3_open([self.dbPath UTF8String], &db);
//        
//        sqlite3_exec(db, "BEGIN TRANSACTION", NULL, NULL, NULL);
//        
//        sqlite3_stmt *stmt;
//        
//        if (self.albumName) {
//            sqlite3_prepare_v2(db, "INSERT OR IGNORE INTO albums (url, name, priority, enable_uploading, private) VALUES (?, ?, ?, ?, ?)", -1, &stmt, NULL);
//            bind_string(stmt, 1, self.albumURL);
//            bind_string(stmt, 2, self.albumName);
//            sqlite3_bind_int(stmt, 3, self.priority);
//            sqlite3_bind_int(stmt, 4, self.enable);
//            sqlite3_bind_int(stmt, 5, self.private);
//            assert_run_query(stmt);
//            
//            sqlite3_prepare_v2(db, "DELETE FROM album_assets WHERE album_id = (SELECT id from albums WHERE url = ?)", -1, &stmt, NULL);
//            bind_string(stmt, 1, self.albumURL);
//            assert_run_query(stmt);
//        }
//        
//        for (NSUInteger i = 0; i < [self.assetURLs count]; ++i) {
//            sqlite3_prepare_v2(db, "INSERT OR IGNORE INTO assets (url, date) VALUES (?, ?)", -1, &stmt, NULL);
//            bind_string(stmt, 1, self.assetURLs[i]);
//            sqlite3_bind_double(stmt, 2, [self.assetDates[i] doubleValue]);
//            assert_run_query(stmt);
//            
//            sqlite3_prepare_v2(db, "INSERT INTO album_assets (album_id, asset_id) VALUES ((SELECT id FROM albums WHERE url = ?), (SELECT id FROM assets WHERE url = ?))", -1, &stmt, NULL);
//            bind_string(stmt, 1, self.albumURL);
//            bind_string(stmt, 2, self.assetURLs[i]);
//            assert_run_query(stmt);
//        }
//        
//        sqlite3_exec(db, "COMMIT TRANSACTION", NULL, NULL, NULL);
//        sqlite3_close(db);
//        
//        [self.assetURLs removeAllObjects];
//        [self.assetDates removeAllObjects];
//    });
//}

-(void)populateDatabaseFromLogFileAtURL:(NSURL*)url{
    

//    int errorcount = 0;
//    m_stop = false;
//    emit startLoad();
//    qint64 msecs = QDateTime::currentMSecsSinceEpoch();
//    QFile logfile(m_fileName);
//    if (!logfile.open(QIODevice::ReadOnly))
//    {
//        emit error("Unable to open log file");
//        return;
//    }
//    int index = 0;
    int index = 0;
    char *errMsg;
//    
//    if (!m_db->transaction())
//    {
//        emit error("Unable to start database transaction");
//        return;
//    }
//
    
//    QSqlQuery fmttablecreate(*m_db);
    NSMutableString *createTableString = [[NSMutableString alloc]initWithString:@"CREATE TABLE 'FMT' (typeID integer PRIMARY KEY,length integer,name varchar(200),format varchar(6000),val varchar(6000));"];
//    fmttablecreate.prepare("CREATE TABLE 'FMT' (typeID integer PRIMARY KEY,length integer,name varchar(200),format varchar(6000),val varchar(6000));");
//    if (!fmttablecreate.exec())
//    {
//        emit error("Error creating FMT table: " + m_db->lastError().text());
//        return;
//    }

    errMsg = "";
    const char *createTableStatement = [createTableString cStringUsingEncoding:NSUTF8StringEncoding];
    sqlite3_stmt *stmt;
    sqlite3_prepare_v2(database, createTableStatement, -1, &stmt, NULL);
    assert_run_query(stmt);
//    if (sqlite3_exec(database, createTableStatement, NULL, NULL, &errMsg) != SQLITE_OK) {
//        VWW_LOG_INFO(@"Failed to create table");
//    }
    
//    QSqlQuery fmtinsertquery;
    NSMutableString *insertString = [[NSMutableString alloc]initWithString:@"INSERT INTO 'FMT' (typeID,length,name,format,val) values (?,?,?,?,?);"];
//    if (!fmtinsertquery.prepare("INSERT INTO 'FMT' (typeID,length,name,format,val) values (?,?,?,?,?);"))
//    {
//        emit error("Error preparing FMT insert statement: " + fmtinsertquery.lastError().text());
//        return;
//    }
    errMsg = "";
    const char *insertIntoFMTStatement = [insertString cStringUsingEncoding:NSUTF8StringEncoding];
    sqlite3_prepare_v2(database, insertIntoFMTStatement, -1, &stmt, NULL);
    assert_run_query(stmt);
    
//    if (sqlite3_exec(database, insertIntoFMTStatement, NULL, NULL, &errMsg) != SQLITE_OK) {
//        VWW_LOG_INFO(@"Failed to insert into FMT");
//    }
    
    
//    QMap<QString,QSqlQuery*> nameToInsertQuery;
    NSMutableDictionary *nameToInsertQuery = [@{}mutableCopy];

//    QMap<QString,QString> nameToTypeString;
    NSMutableDictionary *nameToTypeString = [@{}mutableCopy];
//    if (!m_db->commit())
//    {
//        emit error("Unable to commit database transaction 1");
//        return;
//    }
//    bool firstactual = true;
    NSError *error;
    NSString *logFileContents = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
    NSArray *lines = [logFileContents componentsSeparatedByString:@"\n"];
    for(NSString *line in lines){
//    while (!logfile.atEnd() && !m_stop)
//    {
//        emit loadProgress(logfile.pos(),logfile.size());
//        QString line = logfile.readLine();
//        emit lineRead(line);
//        QStringList linesplit = line.replace("\r","").replace("\n","").split(",");
        NSArray *linesplit = [line componentsSeparatedByString:@","];
        if(linesplit.count > 0){
//        if (linesplit.size() > 0)
//        {
//            if (index == 0)
//            {
//                //First record
//                if (!m_db->transaction())
//                {
//                    emit error("Unable to start database transaction");
//                    return;
//                }
//            }
            if(index == 0){
                
            }
//            index++;
            
            index++;
            

//            if (line.startsWith("FMT"))
//            {
            if([line hasPrefix:@"FMT"]){

//                //Format line
//                if (linesplit.size() > 4)
//                {
                if(linesplit.count > 4){
//                    QString type = linesplit[3].trimmed();
//                    text = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]
                    NSString *type = [linesplit[3] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//                    if (type != "FMT")
//                    {
                    if([type isEqualToString:@"FMT"]){
//                        QString descstr = linesplit[4].trimmed();
                        NSString *descstr = [linesplit[4] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//                        nameToTypeString[type] = descstr;
                        nameToTypeString[type] = descstr;
//                        if (descstr == "")
//                        {
//                            continue;
//                        }
                        if([descstr isEqualToString:@""]){
                            continue;
                        }
//                        QString valuestr = "";
//                        QString inserttable = "insert or replace into '" + type + "' (idx";
//                        QString insertvalues = "(?";
//                        QString mktable = "CREATE TABLE '" + type + "' (idx integer PRIMARY KEY";
                        NSMutableString *valuestr = [[NSMutableString alloc]initWithString:@""];
                        NSMutableString *inserttable = [NSMutableString stringWithFormat:@"insert or replace into '%@' (idx", type];
                        NSMutableString *insertvalues = [[NSMutableString alloc]initWithString:@"(?"];
                        NSMutableString *mktable = [[NSMutableString alloc]initWithFormat:@"CREATE TABLE '%@' (idx integer PRIMARY KEY", type];
//                        for (int i=5;i<linesplit.size();i++)
//                        {
                        for(int i = 5; i < linesplit.count; i++){
//                            QString name = linesplit[i].trimmed();
                            NSString *name = [linesplit[i] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//                            char type = descstr.at(i-5).toAscii();
                            NSString *type = [descstr substringFromIndex:i - 5];
//                            valuestr += name + ",";
                            [valuestr appendFormat:@"%@,", name];
//                            qDebug() << name << type;
                            VWW_LOG_DEBUG(@"%@ %@", name, type);
//                            if (type == 'I') //uint32_t
//                            {
//                                mktable.append("," + name + " integer");
//                            }
                            if([type isEqualToString:@"I"]){
                                [mktable appendFormat:@",%@ integer", name];
                            }
//                            else if (type == 'f') //float
//                            {
//                                mktable.append("," + name + " real");
//                            }
                            else if([type isEqualToString:@"f"]){
                                [mktable appendFormat:@",%@ real", name];
                            }
//                            else if (type == 'h') //int16_t
//                            {
//                                mktable.append("," + name + " real");
//                            }
                            else if([type isEqualToString:@"h"]){
                                [mktable appendFormat:@",%@ real", name];
                            }
//                            else if (type == 'L') //int32_t (lat/long)
//                            {
//                                mktable.append("," + name + " integer");
//                            }
                            else if([type isEqualToString:@"L"]){
                                [mktable appendFormat:@",%@ integer", name];
                            }
//                            else if (type == 'e') //int32_t * 100
//                            {
//                                mktable.append("," + name + " real");
//                            }
                            else if([type isEqualToString:@"e"]){
                                [mktable appendFormat:@",%@ real", name];
                            }
//                            else if (type == 'c') //int16_t * 100
//                            {
//                                mktable.append("," + name + " real");
//                            }
                            else if([type isEqualToString:@"c"]){
                                [mktable appendFormat:@",%@ real", name];
                            }
//                            else
//                            {
//                                mktable.append("," + name + " real");
//                            }
                            else{
                                [mktable appendFormat:@",%@ real", name];
                            }
//                            inserttable.append("," + name);
//                            insertvalues.append(",?");
//
                            [inserttable appendFormat:@",%@", name];
                            [insertvalues appendFormat:@",?"];
//                            //fieldnames.append(linesplit[i].trimmed());
//                        }
                        }
//                        inserttable.append(")");
//                        insertvalues.append(")");
//                        valuestr = valuestr.mid(0,valuestr.length()-1);
//                        QString final = inserttable + " values " + insertvalues + ";";
//                        mktable.append(");");
                        [inserttable appendFormat:@")"];
                        [insertvalues appendFormat:@")"];
                        valuestr = [[valuestr substringWithRange:NSMakeRange(0, valuestr.length - 1)]mutableCopy];
                        NSString *final = [NSString stringWithFormat:@"%@ values %@;", inserttable, insertvalues];
                        [mktable appendFormat:@"};"];

//                        QSqlQuery mktablequery(*m_db);
//                        mktablequery.prepare(mktable);
                        
                        const char *insertString = [mktable cStringUsingEncoding:NSUTF8StringEncoding];
                        sqlite3_prepare_v2(database, insertString, -1, &stmt, NULL);
                        assert_run_query(stmt);
                        
//                        if (!mktablequery.exec())
//                        {
//                            emit error("Error creating table for: " + type + " : " + m_db->lastError().text());
//                            return;
//                        }
//                        QSqlQuery *query = new QSqlQuery(*m_db);
//                        if (!query->prepare(final))
//                        {
//                            emit error("Error preparing inserttable: " + final + " Error is: " + query->lastError().text());
//                            return;
//                        }
//                        //typeID,length,name,format
//                        fmtinsertquery.bindValue(0,index);
//                        fmtinsertquery.bindValue(1,0);
//                        fmtinsertquery.bindValue(2,type);
//                        fmtinsertquery.bindValue(3,descstr);
//                        fmtinsertquery.bindValue(4,valuestr);
//                        fmtinsertquery.exec();
//                        nameToInsertQuery[type] = query;
//                    }
                    }
//                }
//                else
//                {
//                    QLOG_ERROR() << "Error with line in plot log file:" << line;
//                }
                }
//            }
        }
//            else
//            {
//                if (linesplit.size() > 1)
//                {
//                    QString name = linesplit[0].trimmed();
//                    if (nameToInsertQuery.contains(name))
//                    {
//                        if (firstactual)
//                        {
//                            if (!m_db->commit())
//                            {
//                                emit error("Unable to commit database transaction 2");
//                                return;
//                            }
//                            if (!m_db->transaction())
//                            {
//                                emit error("Unable to start database transaction 3");
//                                return;
//                            }
//                            firstactual = false;
//                        }
//                        QString typestr = nameToTypeString[name];
//                        nameToInsertQuery[name]->bindValue(0,index);
//                        if (typestr.size() != linesplit.size() - 1)
//                        {
//                            QLOG_DEBUG() << "Bound values for" << name << "count:" << nameToInsertQuery[name]->boundValues().values().size() << "actual" << linesplit.size() << typestr.size();
//                            QLOG_DEBUG() << "Error in line:" << index << "param" << name << "parameter mismatch";
//                            errorcount++;
//                        }
//                        else
//                        {
//                            for (int i=1;i<linesplit.size();i++)
//                            {
//                                if (typestr.at(i-1).toAscii() == 'I')
//                                {
//                                    nameToInsertQuery[name]->bindValue(i,linesplit[i].toInt());
//                                }
//                                else if (typestr.at(i-1).toAscii() == 'f')
//                                {
//                                    nameToInsertQuery[name]->bindValue(i,linesplit[i].toFloat());
//                                }
//                                else if (typestr.at(i-1).toAscii() == 'h')
//                                {
//                                    nameToInsertQuery[name]->bindValue(i,linesplit[i].toInt());
//                                }
//                                else if (typestr.at(i-1).toAscii() == 'c')
//                                {
//                                    nameToInsertQuery[name]->bindValue(i,linesplit[i].toInt() * 100);
//                                }
//                                else if (typestr.at(i-1).toAscii() == 'C')
//                                {
//                                    nameToInsertQuery[name]->bindValue(i,linesplit[i].toInt() * 100);
//                                }
//                                else if (typestr.at(i-1).toAscii() == 'e')
//                                {
//                                    nameToInsertQuery[name]->bindValue(i,linesplit[i].toInt() * 100);
//                                }
//                                else if (typestr.at(i-1).toAscii() == 'E')
//                                {
//                                    nameToInsertQuery[name]->bindValue(i,linesplit[i].toInt() * 100);
//                                }
//                                else if (typestr.at(i-1).toAscii() == 'L')
//                                {
//                                    nameToInsertQuery[name]->bindValue(i,(qlonglong)linesplit[i].toLong());
//                                }
//                                else
//                                {
//                                    nameToInsertQuery[name]->bindValue(i,linesplit[i].toFloat());
//                                }
//                            }
//                            if (!nameToInsertQuery[name]->exec())
//                            {
//                                emit error("Error execing:" + nameToInsertQuery[name]->executedQuery() + " error was " + nameToInsertQuery[name]->lastError().text());
//                                return;
//                            }
//                        }
//                    }
//                }
//                
//            }
//        }
        }
    }
    
}

@end
