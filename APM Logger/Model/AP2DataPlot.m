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
    [self createDB];
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
    BOOL isSuccess = YES;
    VWW_LOG_TODO_TASK(@"Check if database already exists");
    NSFileManager *filemgr = [NSFileManager defaultManager];
    if ([filemgr fileExistsAtPath:self.databasePath ] == NO)
    {
        const char *dbpath = [self.databasePath UTF8String];
        if (sqlite3_open(dbpath, &database) == SQLITE_OK)
        {
            char *errMsg;
            const char *sql_stmt = "create table if not exists testTable (regno integer primary key, name text, department text, year text)";
            if (sqlite3_exec(database, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK) {
                isSuccess = NO;
                VWW_LOG_INFO(@"Failed to create table");
            }
            sqlite3_close(database);
            VWW_LOG_INFO(@"Created DB at path: %@", self.databasePath);
            return  isSuccess;
        }
        else {
            isSuccess = NO;
            VWW_LOG_INFO(@"Failed to open/create database");
        }
    } else {
        
        VWW_LOG_DEBUG(@"Database already exists");
    }
    return isSuccess;
}

//void AP2DataPlotThread::run()
//{
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
//    
//    if (!m_db->transaction())
//    {
//        emit error("Unable to start database transaction");
//        return;
//    }
//    
//    QSqlQuery fmttablecreate(*m_db);
//    fmttablecreate.prepare("CREATE TABLE 'FMT' (typeID integer PRIMARY KEY,length integer,name varchar(200),format varchar(6000),val varchar(6000));");
//    if (!fmttablecreate.exec())
//    {
//        emit error("Error creating FMT table: " + m_db->lastError().text());
//        return;
//    }
//    QSqlQuery fmtinsertquery;
//    if (!fmtinsertquery.prepare("INSERT INTO 'FMT' (typeID,length,name,format,val) values (?,?,?,?,?);"))
//    {
//        emit error("Error preparing FMT insert statement: " + fmtinsertquery.lastError().text());
//        return;
//    }
//    QMap<QString,QSqlQuery*> nameToInsertQuery;
//    QMap<QString,QString> nameToTypeString;
//    if (!m_db->commit())
//    {
//        emit error("Unable to commit database transaction 1");
//        return;
//    }
//    bool firstactual = true;
//    while (!logfile.atEnd() && !m_stop)
//    {
//        emit loadProgress(logfile.pos(),logfile.size());
//        QString line = logfile.readLine();
//        emit lineRead(line);
//        QStringList linesplit = line.replace("\r","").replace("\n","").split(",");
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
//            index++;
//            if (line.startsWith("FMT"))
//            {
//                //Format line
//                if (linesplit.size() > 4)
//                {
//                    QString type = linesplit[3].trimmed();
//                    if (type != "FMT")
//                    {
//                        QString descstr = linesplit[4].trimmed();
//                        nameToTypeString[type] = descstr;
//                        if (descstr == "")
//                        {
//                            continue;
//                        }
//                        QString valuestr = "";
//                        QString inserttable = "insert or replace into '" + type + "' (idx";
//                        QString insertvalues = "(?";
//                        QString mktable = "CREATE TABLE '" + type + "' (idx integer PRIMARY KEY";
//                        for (int i=5;i<linesplit.size();i++)
//                        {
//                            QString name = linesplit[i].trimmed();
//                            char type = descstr.at(i-5).toAscii();
//                            valuestr += name + ",";
//                            qDebug() << name << type;
//                            if (type == 'I') //uint32_t
//                            {
//                                mktable.append("," + name + " integer");
//                            }
//                            else if (type == 'f') //float
//                            {
//                                mktable.append("," + name + " real");
//                            }
//                            else if (type == 'h') //int16_t
//                            {
//                                mktable.append("," + name + " real");
//                            }
//                            else if (type == 'L') //int32_t (lat/long)
//                            {
//                                mktable.append("," + name + " integer");
//                            }
//                            else if (type == 'e') //int32_t * 100
//                            {
//                                mktable.append("," + name + " real");
//                            }
//                            else if (type == 'c') //int16_t * 100
//                            {
//                                mktable.append("," + name + " real");
//                            }
//                            else
//                            {
//                                mktable.append("," + name + " real");
//                            }
//                            inserttable.append("," + name);
//                            insertvalues.append(",?");
//                            
//                            //fieldnames.append(linesplit[i].trimmed());
//                        }
//                        inserttable.append(")");
//                        insertvalues.append(")");
//                        valuestr = valuestr.mid(0,valuestr.length()-1);
//                        QString final = inserttable + " values " + insertvalues + ";";
//                        
//                        
//                        mktable.append(");");
//                        QSqlQuery mktablequery(*m_db);
//                        mktablequery.prepare(mktable);
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
//                }
//                else
//                {
//                    QLOG_ERROR() << "Error with line in plot log file:" << line;
//                }
//            }
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
//    }

@end
