//
//  VWWGraphViewController.m
//  RCTools
//
//  Created by Zakk Hoyt on 4/15/14.
//  Copyright (c) 2014 Zakk Hoyt. All rights reserved.
//

#import "VWWGraphViewController.h"
#import "VWWGraphView.h"
#import "VWWMotionController.h"

#define NUM_POINTS 320


@interface VWWGraphViewController () <VWWMotionControllerDelegate>
@property (weak, nonatomic) IBOutlet VWWGraphView *xGraphView;
@property (nonatomic, strong) VWWMotionController *motionController;
@property (nonatomic, strong) NSMutableArray *dataForPlot;
@end

@implementation VWWGraphViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController setNavigationBarHidden:YES];
    self.dataForPlot = [[NSMutableArray alloc]initWithCapacity:NUM_POINTS];
    self.motionController = [VWWMotionController sharedInstance];
    self.motionController.delegate = self;
    self.motionController.updateInterval = 1/200.0;
    [self.motionController startAccelerometer];
    
    
    for(int x = 0; x < 320; x++){
        NSDictionary *d = @{@"x" : @(0),
                            @"y" : @(0),
                            @"z" : @(0)};
        [self.dataForPlot addObject:d];
    }

    self.xGraphView.dataSource = self.dataForPlot;
    
    CADisplayLink *link = [CADisplayLink displayLinkWithTarget:self selector:@selector(renderGraph)];
    [link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];

}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

//    [NSTimer scheduledTimerWithTimeInterval:1/30.0 target:self selector:@selector(drawGraphs) userInfo:nil repeats:YES];

}

-(void)renderGraph{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.xGraphView setNeedsDisplay];
    });
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


-(void)motionController:(VWWMotionController*)sender didUpdateAcceleremeters:(CMAccelerometerData*)accelerometers{
    @synchronized(self.dataForPlot){
        static NSInteger counter = 0;
        
        if ( self.dataForPlot.count >= NUM_POINTS ) {
            
        }
        
        
        NSDictionary *d = @{@"x" : @(accelerometers.acceleration.x),
                            @"y" : @(accelerometers.acceleration.y),
                            @"z" : @(accelerometers.acceleration.z)};
        [self.dataForPlot addObject:d];
        [self.dataForPlot removeObjectAtIndex:0];
        counter++;
    }

}

@end
