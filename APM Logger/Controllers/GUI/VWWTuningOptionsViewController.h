//
//  VWWTuningOptionsViewController.h
//  APM Logger
//
//  Created by Zakk Hoyt on 4/12/14.
//  Copyright (c) 2014 Zakk Hoyt. All rights reserved.
//

#import "VWWTableViewController.h"

@class VWWTuningOptionsViewController;

@protocol VWWTuningOptionsViewControllerDelegate <NSObject>



@end

@interface VWWTuningOptionsViewController : VWWTableViewController
@property (nonatomic, weak) id <VWWTuningOptionsViewControllerDelegate> delegate;
@end
