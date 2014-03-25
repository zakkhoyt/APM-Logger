//
//  APM Logger
//
//  Created by Zakk Hoyt 2014
//  Copyright (c) 2014 Zakk Hoyt.
//


#import <Foundation/Foundation.h>
@protocol VWWModelProtocol <NSObject>
@required
-(id)initWithDictionary:(NSDictionary*)dictionary;
-(NSDictionary*)dictionary;
-(NSString *)description;
@end

