//
//  VWWLogViewController.m
//  APM Logger
//
//  Created by Zakk Hoyt on 4/12/14.
//  Copyright (c) 2014 Zakk Hoyt. All rights reserved.
//

#import "VWWLogViewController.h"
#import "VWWAP2LogController.h"
#import "VWWLogPlotViewController.h"


static NSString *VWWSegueLogToPlot = @"VWWSegueLogToPlot";


@interface VWWLogViewController ()
@property (weak, nonatomic) IBOutlet UILabel *filenameLabel;
@property (weak, nonatomic) IBOutlet UILabel *sizeLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property (weak, nonatomic) IBOutlet UILabel *firmwareLabel;
@property (weak, nonatomic) IBOutlet UILabel *freeRAMLabel;
@property (weak, nonatomic) IBOutlet UILabel *softwareLabel;

@end

@implementation VWWLogViewController

#pragma mark UIViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    self.navigationItem.title = @"Summary";
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

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:VWWSegueLogToPlot]){
        VWWLogPlotViewController *vc = segue.destinationViewController;
        vc.dataPlot = sender;
    }
}

#pragma mark Private methods
-(void)updateControls{
    __weak VWWLogViewController *weakSelf = self;
    [VWWAP2LogController extractFileSummaryFromLogFileAtURL:self.logFile completionBlock:^(VWWLogFileSummary *summary) {
        weakSelf.filenameLabel.text = summary.filename;
        weakSelf.sizeLabel.text = summary.size;
        weakSelf.dateLabel.text = summary.date;
        weakSelf.versionLabel.text = summary.version;
        weakSelf.firmwareLabel.text = summary.firmware;
        weakSelf.freeRAMLabel.text = summary.freeRAM;
        weakSelf.softwareLabel.text = summary.software;
    }];
}

#pragma mark IBActions

- (IBAction)graphButtonTouchUpInside:(id)sender {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    __weak VWWLogViewController *weakSelf = self;
    [VWWAP2LogController extractDataPlotFromLogFileAtURL:self.logFile completionBlock:^(AP2DataPlot *dataSet) {
        
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        [weakSelf performSegueWithIdentifier:VWWSegueLogToPlot sender:dataSet];
    }];
}
- (IBAction)googleEarthButtonTouchUpInside:(id)sender {
}

@end
