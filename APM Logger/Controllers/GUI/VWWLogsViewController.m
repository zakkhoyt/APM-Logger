//
//  VWWLogsViewController.m
//  APM Logger
//
//  Created by Zakk Hoyt on 4/12/14.
//  Copyright (c) 2014 Zakk Hoyt. All rights reserved.
//

#import "VWWLogsViewController.h"
#import "VWWFileController.h"
#import "VWWLogViewController.h"

static NSString *VWWSegueLogsToLog = @"VWWSegueLogsToLog";

@interface VWWLogsViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation VWWLogsViewController

#pragma mark UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"APM LOGS";
    
    // Add pull to refresh controller
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.attributedTitle = [[NSAttributedString alloc]initWithString:@"Loading log files..."];
    [refreshControl addTarget:self action:@selector(refreshTable:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
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


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:VWWSegueLogsToLog]){
        VWWLogViewController *vc = segue.destinationViewController;
        vc.logFile = sender;
    }
}

#pragma mark Private methods
- (void)refreshTable:(UIRefreshControl *)refreshControl {
    VWW_LOG_INFO(@"Refreshing log files");
    [self.tableView reloadData];
    [refreshControl endRefreshing];
}


#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSArray *logFiles = [VWWFileController urlsForLogs];
    return logFiles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    NSArray *logFiles = [VWWFileController urlsForLogs];
    NSURL *logFile = logFiles[indexPath.row];
    NSString *shortName = [NSString stringWithFormat:@"%@", [logFile lastPathComponent]];
    cell.textLabel.text = shortName;
    return cell;
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSArray *logFiles = [VWWFileController urlsForLogs];
    NSURL *logFile = logFiles[indexPath.row];
    [self performSegueWithIdentifier:VWWSegueLogsToLog sender:logFile];
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSArray *logFiles = [VWWFileController urlsForLogs];
        NSURL *logFileURL = logFiles[indexPath.row];
        
        if([VWWFileController deleteLogAtURL:logFileURL]){
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}


@end
