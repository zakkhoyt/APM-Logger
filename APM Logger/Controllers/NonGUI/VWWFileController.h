//
//  APM Logger
//
//  Created by Zakk Hoyt 2014
//  Copyright (c) 2014 Zakk Hoyt.
//


#import <Foundation/Foundation.h>

@interface VWWFileController : NSObject
+(NSString*)nameOfFileAtURL:(NSURL*)url;
+(NSString*)sizeOfFileAtURL:(NSURL*)url;
+(NSString*)dateOfFileAtURL:(NSURL*)url;
@end

@interface VWWFileController (Videos)
+(NSURL*)urlForDocumentsDirectory;
+(NSString*)pathForDocumentsDirectory;
+(void)printURLsForVideos;
+(NSArray*)urlsForVideos;
+(BOOL)deleteVideoAtURL:(NSURL*)url;
+(BOOL)deleteAllVideos;
@end

@interface VWWFileController (Logs)
+(NSURL*)urlForLogsDirectory;
+(NSString*)pathForLogsDirectory;
+(BOOL)copyFileAtURLToLogsDir:(NSURL*)url;
+(void)printURLsForLogs;
+(NSArray*)urlsForLogs;
+(BOOL)deleteLogAtURL:(NSURL*)url;
+(BOOL)deleteAllLogs;

+(BOOL)extractFileAttributesFromLogFileAtURL:(NSURL*)url;
@end
