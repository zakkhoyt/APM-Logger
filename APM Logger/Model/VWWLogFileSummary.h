//
//  APM Logger
//
//  Created by Zakk Hoyt 2014
//  Copyright (c) 2014 Zakk Hoyt.
//


#import <Foundation/Foundation.h>

@interface VWWLogFileSummary : NSObject
// The name of the log file
@property (nonatomic, strong) NSString *filename;
// The size of the log file in bytes
@property (nonatomic, strong) NSString *size;
// The date the log file was created
@property (nonatomic, strong) NSString *date;
// The version as read from the first line of the file
@property (nonatomic, strong) NSString *version;
// The firmware which generated the log files
@property (nonatomic, strong) NSString *firmware;
// The free RAM reported in the log file
@property (nonatomic, strong) NSString *freeRAM;
// Teh software that generated the log file
@property (nonatomic, strong) NSString *software;
@end
