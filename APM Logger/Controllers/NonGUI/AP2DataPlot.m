//
//  AP2DataPlot.m
//  APM Logger
//
//  Created by Zakk Hoyt on 3/24/14.
//  Copyright (c) 2014 Zakk Hoyt. All rights reserved.
//

#import "AP2DataPlot.h"

@implementation AP2DataPlot

-(id)initWithURL:(NSURL*)url{
    self = [super init];
    if(self){
        NSError *error;
        NSString *contents = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
        if(error){
            VWW_LOG_ERROR(@"Could not read file from URL");
            return nil;
        }
        
        NSArray *array = [contents componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        VWW_LOG_INFO(@"Read %ld lines", (long)array.count);
        
        
    }
    return self;
}
@end
