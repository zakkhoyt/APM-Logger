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
+(NSURL*)urlForDocumentsDirectory;
+(NSString*)pathForDocumentsDirectory;
+(BOOL)copyLogFileFromBundleToLogsDir;
+(BOOL)deleteFileAtURL:(NSURL*)url;
+(BOOL)fileExistsAtURL:(NSURL*)url;
@end

@interface VWWFileController (Videos)
+(NSURL*)urlForVideosDirectory;
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
@end
