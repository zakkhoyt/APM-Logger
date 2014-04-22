//
//  VWWVideoRecordOptionsViewController.m
//  APM Logger
//
//  Created by Zakk Hoyt on 4/12/14.
//  Copyright (c) 2014 Zakk Hoyt. All rights reserved.
//

#import "VWWRTVideoRecordOptionsViewController.h"


static NSString *VWWSegueVideoRecordOptionsToRecord = @"VWWSegueVideoRecordOptionsToRecord";

@interface VWWRTVideoRecordOptionsViewController ()

@end

@implementation VWWRTVideoRecordOptionsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"OPTIONS";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


#pragma mark IBActions
- (IBAction)readyButtonTouchUpInside:(id)sender {
    [self performSegueWithIdentifier:VWWSegueVideoRecordOptionsToRecord sender:self];
}



@end
