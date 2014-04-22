//
//  VWWRTVideosViewController.m
//  APM Logger
//
//  Created by Zakk Hoyt on 4/12/14.
//  Copyright (c) 2014 Zakk Hoyt. All rights reserved.
//

#import "VWWRTVideosViewController.h"
#import "VWWRTVideoRecordOptionsViewController.h"

static NSString *VWWSegueVideosToRecordOptions = @"VWWSegueVideosToRecordOptions";


@interface VWWRTVideosViewController ()

@end

@implementation VWWRTVideosViewController


#pragma mark UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"VIDEO (Real Time)";
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addButtonTouchUpInside:)];
    [self.navigationItem setRightBarButtonItem:addButton animated:NO];

}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
//}



#pragma mark IBActions

-(void)addButtonTouchUpInside:(id)sender{
    [self performSegueWithIdentifier:VWWSegueVideosToRecordOptions sender:self];
}
@end
