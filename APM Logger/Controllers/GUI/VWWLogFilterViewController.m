//
//  VWWLogFilterViewController.m
//  APM Logger
//
//  Created by Zakk Hoyt on 4/14/14.
//  Copyright (c) 2014 Zakk Hoyt. All rights reserved.
//

#import "VWWLogFilterViewController.h"
#import "FMDB.h"

@interface VWWLogFilterViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation VWWLogFilterViewController

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
    // Do any additional setup after loading the view.
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



#pragma mark Private methods

#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.filters.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    NSDictionary *filter = self.filters[indexPath.row];
    NSString *title = filter[VWWLogFilterViewControllerFilterNameKey];
    cell.textLabel.text = title;
    
    NSNumber *activated = filter[VWWLogFilterViewControllerFilterActivatedKey];
    if(activated.integerValue){
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}



#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell setSelected:!cell.selected animated:NO];
    
    NSDictionary *filter = self.filters[indexPath.row];
    NSString *title = filter[VWWLogFilterViewControllerFilterNameKey];
    NSNumber *activated;
    
    if(cell.selected){
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        activated = @(1);
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
        activated = @(0);
    }
    NSDictionary *alteredFilter = @{VWWLogFilterViewControllerFilterNameKey : title,
                                    VWWLogFilterViewControllerFilterActivatedKey : activated};
    self.filters[indexPath.row] = alteredFilter;
}

@end
