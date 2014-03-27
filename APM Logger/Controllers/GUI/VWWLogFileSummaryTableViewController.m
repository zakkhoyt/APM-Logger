//
//  APM Logger
//
//  Created by Zakk Hoyt 2014
//  Copyright (c) 2014 Zakk Hoyt.
//


#import "VWWLogFileSummaryTableViewController.h"
#import "AP2DataPlotController.h"
#import "MBProgressHUD.h"

static NSString *VWWSegueLogFileSummaryToPlot = @"VWWSegueLogFileSummaryToPlot";


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
        weakSelf.versionLabel.text = summary.version;
        weakSelf.firmwareLabel.text = summary.firmware;
        weakSelf.freeRAMLabel.text = summary.freeRAM;
        weakSelf.softwareLabel.text = summary.software;
    }];
}

#pragma mark IBActions

- (IBAction)graphButtonTouchUpInside:(id)sender {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [AP2DataPlotController extractDataPlotFromLogFileAtURL:self.logFile completionBlock:^(AP2DataPlot *dataSet) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
}
- (IBAction)googleEarthButtonTouchUpInside:(id)sender {
}


@end
