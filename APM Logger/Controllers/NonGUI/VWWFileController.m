//
//  APM Logger
//
//  Created by Zakk Hoyt 2014
//  Copyright (c) 2014 Zakk Hoyt.
//

#import "VWWFileController.h"

@implementation VWWFileController
#pragma mark Public methods

+(NSString*)nameOfFileAtURL:(NSURL*)url{
    return [url lastPathComponent];
}
+(NSString*)sizeOfFileAtURL:(NSURL*)url{
    NSError *error;
    NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:url.path error:&error];
    if(error){
        VWW_LOG_ERROR(@"Could not read size of file: %@", url.path);
        return 0;
    }
    UInt32 size = (UInt32)[attrs fileSize];
    return [NSString stringWithFormat:@"%ld", (long)size];
}
+(NSString*)dateOfFileAtURL:(NSURL*)url{
    NSError *error;
    NSDictionary* attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:url.path error:&error];
    
    if(error){
        VWW_LOG_ERROR(@"Could not read date of file: %@ with error: %@", url.path, error.description);
        return @"";
    }
    
    if (attrs == nil) {
        VWW_LOG_ERROR(@"Could not read date attributes of file: %@", url.path);
        return @"";
    }
    
    NSDate *date = (NSDate*)[attrs objectForKey: NSFileCreationDate];
    return [VWWUtilities stringFromDate:date];
}

+(NSURL*)urlForDocumentsDirectory{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSURL *url = [NSURL fileURLWithPath:documentsDirectory];
    return url;
}

+(NSString*)pathForDocumentsDirectory{
    NSURL *url = [VWWFileController urlForDocumentsDirectory];
    return url.path;
}


+(BOOL)copyLogFileFromBundleToLogsDir{
    NSArray *logFilePaths = [NSBundle pathsForResourcesOfType:@"log" inDirectory:[[NSBundle mainBundle] bundlePath]];
    for(NSString *logFilePath in logFilePaths){
        NSURL *logFileURL = [NSURL fileURLWithPath:logFilePath];
        [VWWFileController copyFileAtURLToLogsDir:logFileURL];
    }
    return YES;
}


#pragma mark Private methods
+(void)ensureDirectoryExistsAtURL:(NSURL*)url{
    if ([[NSFileManager defaultManager] fileExistsAtPath:url.path] == NO){
        NSError* error;
        if([[NSFileManager defaultManager]createDirectoryAtPath:url.path withIntermediateDirectories:YES attributes:nil error:&error]){
            VWW_LOG_DEBUG(@"Created dir at %@", url.path);
        } else {
            VWW_LOG_DEBUG(@"Failed to create dir :%@ with error: %@", url.path, error.description);
        }
    }
}


@end

@implementation VWWFileController (Videos)
+(NSURL*)urlForVideosDirectory{
    NSURL *documentsDir = [VWWFileController urlForDocumentsDirectory];
    NSURL *videosDir = [documentsDir URLByAppendingPathComponent:@"videos"];
    [VWWFileController ensureDirectoryExistsAtURL:videosDir];
    return videosDir;
}



+(void)printURLsForVideos{
    VWW_LOG_INFO(@"Video files:\n");
    NSURL *documentsDirURL = [VWWFileController urlForDocumentsDirectory];
    NSError *error;
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:documentsDirURL includingPropertiesForKeys:nil options:NSDirectoryEnumerationSkipsHiddenFiles error:&error];

    for(int index = 0; index < files.count; index++){
        NSURL *fileURL = [files objectAtIndex:index];
        NSString *file = fileURL.path;
        if([[file pathExtension] compare:@"mov"] == NSOrderedSame){
            NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:file error:&error];
            UInt32 size = (UInt32)[attrs fileSize];
            NSLog(@"size: %ld: path: %@", (long)size, file);
        }
    }
}

// file:///var/mobile/Applications/FD5AEE23-DDB5-401E-A616-83DA8C9F2778/Documents/FinalVideo-431.mov
+(NSArray*)urlsForVideos{
    NSURL *documentsDirURL = [VWWFileController urlForDocumentsDirectory];
    NSError *error;
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:documentsDirURL includingPropertiesForKeys:nil options:NSDirectoryEnumerationSkipsHiddenFiles error:&error];
    NSMutableArray *videos = [@[] mutableCopy];
    for(int index = 0; index < files.count; index++){
        NSString * file = [files objectAtIndex:index];
        if([[file pathExtension] compare:@"mov"] == NSOrderedSame){
            [videos addObject:file];
        }
    }
    return videos;
}


+(BOOL)deleteVideoAtURL:(NSURL*)url{
    VWW_LOG_TODO;
    return YES;
}
+(BOOL)deleteAllVideos{
    VWW_LOG_TODO;
    return YES;
}
@end

@implementation VWWFileController (Logs)



+(NSURL*)urlForLogsDirectory{
    NSURL *documentsDir = [VWWFileController urlForDocumentsDirectory];
    NSURL *logsDir = [documentsDir URLByAppendingPathComponent:@"logs"];
    [VWWFileController ensureDirectoryExistsAtURL:logsDir];
    return logsDir;
}

+(NSString*)pathForLogsDirectory{
    NSURL *url = [VWWFileController urlForLogsDirectory];
    return url.path;
}
+(BOOL)copyFileAtURLToLogsDir:(NSURL*)url{
    NSError *error;
    if([[NSFileManager defaultManager] isReadableFileAtPath:url.path]){
        NSURL *logsDirURL = [VWWFileController urlForLogsDirectory];
        NSURL *logURL = [logsDirURL URLByAppendingPathComponent:url.lastPathComponent];
        [[NSFileManager defaultManager] copyItemAtURL:url toURL:logURL error:&error];
        if(error){
            VWW_LOG_ERROR(@"Failed to copy file at path: %@ to %@ with error: %@", url.path, logsDirURL.path, error.description);
            return NO;
        }
        return YES;
    }
    return NO;
}

+(void)printURLsForLogs{
    VWW_LOG_INFO(@"Listing log files:\n");
    NSURL *logsDirURL = [VWWFileController urlForLogsDirectory];
    NSError *error;
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:logsDirURL includingPropertiesForKeys:nil options:NSDirectoryEnumerationSkipsHiddenFiles error:&error];
    
    for(int index = 0; index < files.count; index++){
        NSURL *fileURL = [files objectAtIndex:index];
        NSString *file = fileURL.path;
        if([[file pathExtension] compare:@"log"] == NSOrderedSame){
            NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:file error:&error];
            UInt32 size = (UInt32)[attrs fileSize];
            NSLog(@"size: %ld: path: %@", (long)size, file);
        }
    }
}

+(NSArray*)urlsForLogs{
    NSURL *logsDirURL = [VWWFileController urlForLogsDirectory];
    NSError *error;
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:logsDirURL includingPropertiesForKeys:nil options:NSDirectoryEnumerationSkipsHiddenFiles error:&error];
    NSMutableArray *logs = [@[] mutableCopy];
    for(int index = 0; index < files.count; index++){
        NSString * file = [files objectAtIndex:index];
        if([[file pathExtension] compare:@"log"] == NSOrderedSame){
            [logs addObject:file];
        }
    }
    return logs;
}

+(BOOL)deleteLogAtURL:(NSURL*)url{
    NSError *error;
    if([[NSFileManager defaultManager] removeItemAtURL:url error:&error] == NO){
        return NO;
    }
    if(error){
        VWW_LOG_WARNING(@"Could not delete file: %@", url.path);
        return NO;
    }
    return YES;
}
+(BOOL)deleteAllLogs{
    VWW_LOG_TODO;
    return YES;
}


@end
