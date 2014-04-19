//
//  VWWTuningOptionsViewController.m
//  APM Logger
//
//  Created by Zakk Hoyt on 4/12/14.
//  Copyright (c) 2014 Zakk Hoyt. All rights reserved.
//

#import "VWWTuningOptionsViewController.h"


typedef enum {
    VWWTuningOptionsSectionGeneral = 0,
    VWWTuningOptionsSectionSensor,
    VWWTuningOptionsSectionFilter,
    VWWTuningOptionsSectionColor,
    VWWTuningOptionsSectionDone3,
} VWWTuningOptionsSection;

typedef enum {
    VWWTuningOptionsSensorAccelerometers = 0,
    VWWTuningOptionsSensorGyroscopes = 1,
    VWWTuningOptionsSensorMagnetometers = 2,
} VWWTuningOptionsSensor;

typedef enum {
    VWWTuningOptionsFilterButterworth = 0,
    VWWTuningOptionsFilterBessel,
    VWWTuningOptionsFilterChebyshev,
} VWWTuningOptionsFilter;

typedef enum {
    VWWTuningOptionsColorDark = 0,
    VWWTuningOptionsColorLight = 1,
} VWWTuningOptionsColor;
@interface VWWTuningOptionsViewController ()
@property (weak, nonatomic) IBOutlet UISegmentedControl *sensorSegment;
@property (weak, nonatomic) IBOutlet UISegmentedControl *colorSegment;
@property (weak, nonatomic) IBOutlet UISlider *frequencySlider;
@property (weak, nonatomic) IBOutlet UILabel *frequencyLabel;
@end

@implementation VWWTuningOptionsViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.contentInset = UIEdgeInsetsMake([UIApplication sharedApplication].statusBarFrame.size.height, 0, 0, 0);
    
    
    self.frequencySlider.minimumValue = 30;
    self.frequencySlider.maximumValue = 500;
    self.frequencySlider.value = [VWWUserDefaults tuningUpdateFrequency];
    self.frequencyLabel.text = [NSString stringWithFormat:@"%ld Hz", [VWWUserDefaults tuningUpdateFrequency]];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    NSIndexPath *sensorIndexPath = [NSIndexPath indexPathForRow:[VWWUserDefaults tuningSensor] inSection:VWWTuningOptionsSectionSensor];
    UITableViewCell *sensorCell = [self.tableView cellForRowAtIndexPath:sensorIndexPath];
    sensorCell.accessoryType = UITableViewCellAccessoryCheckmark;

    NSIndexPath *filterIndexPath = [NSIndexPath indexPathForRow:[VWWUserDefaults tuningFilter] inSection:VWWTuningOptionsSectionFilter];
    UITableViewCell *filterCell = [self.tableView cellForRowAtIndexPath:filterIndexPath];
    filterCell.accessoryType = UITableViewCellAccessoryCheckmark;

    
    NSIndexPath *colorIndexPath = [NSIndexPath indexPathForRow:[VWWUserDefaults tuningColorScheme] inSection:VWWTuningOptionsSectionColor];
    UITableViewCell *colorCell = [self.tableView cellForRowAtIndexPath:colorIndexPath];
    colorCell.accessoryType = UITableViewCellAccessoryCheckmark;

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

- (IBAction)doneButtonTouchUpInside:(id)sender {
    [VWWUserDefaults setTuningUpdateFrequency:(NSUInteger)self.frequencySlider.value];
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}
- (IBAction)updateFrequencySliderValueChanged:(UISlider*)sender {
    self.frequencyLabel.text = [NSString stringWithFormat:@"%ld Hz", (long)sender.value];
}

//- (IBAction)updateFrequencySliderEditingDidEnd:(UISlider*)sender {
//    [VWWUserDefaults setTuningUpdateFrequency:sender.value];
//}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(indexPath.section == VWWTuningOptionsSectionSensor){
        UITableViewCell *accCell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:VWWTuningOptionsSensorAccelerometers inSection:VWWTuningOptionsSectionSensor]];
        accCell.accessoryType = UITableViewCellAccessoryNone;
        
        UITableViewCell *gyroCell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:VWWTuningOptionsSensorGyroscopes inSection:VWWTuningOptionsSectionSensor]];
        gyroCell.accessoryType = UITableViewCellAccessoryNone;
        
        UITableViewCell *magCell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:VWWTuningOptionsSensorMagnetometers inSection:VWWTuningOptionsSectionSensor]];
        magCell.accessoryType = UITableViewCellAccessoryNone;
        
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        
        [VWWUserDefaults setTuningSensor:indexPath.row];
    } else if(indexPath.section == VWWTuningOptionsSectionFilter){
        UITableViewCell *butterworthCell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:VWWTuningOptionsFilterButterworth inSection:VWWTuningOptionsSectionFilter]];
        butterworthCell.accessoryType = UITableViewCellAccessoryNone;
        
        UITableViewCell *besselCell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:VWWTuningOptionsFilterBessel inSection:VWWTuningOptionsSectionFilter]];
        besselCell.accessoryType = UITableViewCellAccessoryNone;
        
        UITableViewCell *chebyshevCell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:VWWTuningOptionsFilterChebyshev inSection:VWWTuningOptionsSectionFilter]];
        chebyshevCell.accessoryType = UITableViewCellAccessoryNone;

        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        
        [VWWUserDefaults setTuningFilter:indexPath.row];
        
    } else if(indexPath.section == VWWTuningOptionsSectionColor){
        UITableViewCell *darkCell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:VWWTuningOptionsColorDark inSection:VWWTuningOptionsSectionColor]];
        darkCell.accessoryType = UITableViewCellAccessoryNone;
        
        UITableViewCell *lightCell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:VWWTuningOptionsColorLight inSection:VWWTuningOptionsSectionColor]];
        lightCell.accessoryType = UITableViewCellAccessoryNone;

        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [VWWUserDefaults setTuningColorScheme:indexPath.row];
    }
}



@end
