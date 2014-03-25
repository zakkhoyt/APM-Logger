//
//  VWWFileController.h
//  RC Video
//
//  Created by Zakk Hoyt on 3/10/14.
//  Copyright (c) 2014 Zakk Hoyt. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VWWFileController : NSObject
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
@end
