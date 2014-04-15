//
//  VWWLogFilterViewController.h
//  APM Logger
//
//  Created by Zakk Hoyt on 4/14/14.
//  Copyright (c) 2014 Zakk Hoyt. All rights reserved.
//

#import "VWWViewController.h"


//static NSString *VWWLogFilterViewControllerFilterNameKey = @"filter";
//static NSString *VWWLogFilterViewControllerFilterActivatedKey = @"activated";

@interface VWWLogFilterViewController : VWWViewController
@property (nonatomic, strong) NSMutableArray *filters;
@end
