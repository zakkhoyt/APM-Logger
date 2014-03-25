//
//  VWWLogFileSummaryTableViewController.m
//  APM Logger
//
//  Created by Zakk Hoyt on 3/25/14.
//  Copyright (c) 2014 Zakk Hoyt. All rights reserved.
//

#import "VWWLogFileSummaryTableViewController.h"
#import "AP2DataPlotController.h"


@interface VWWLogFileSummaryTableViewController ()
@property (weak, nonatomic) IBOutlet UILabel *filenameLabel;
@property (weak, nonatomic) IBOutlet UILabel *sizeLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property (weak, nonatomic) IBOutlet UILabel *firmwareLabel;
@property (weak, nonatomic) IBOutlet UILabel *freeRAMLabel;
@property (weak, nonatomic) IBOutlet UILabel *softwareLabel;

@end

@implementation VWWLogFileSummaryTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self updateControls];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark Private methods
-(void)updateControls{
    __weak VWWLogFileSummaryTableViewController *weakSelf = self;
    [AP2DataPlotController extractFileSummaryFromLogFileAtURL:self.logFile completionBlock:^(VWWLogFileSummary *summary) {
        weakSelf.filenameLabel.text = summary.filename;
        weakSelf.sizeLabel.text = summary.size;
        weakSelf.dateLabel.text = summary.date;
    }];
}

#pragma mark IBActions

- (IBAction)graphButtonTouchUpInside:(id)sender {
}
- (IBAction)googleEarthButtonTouchUpInside:(id)sender {
}


@end
