//
//  VWWScatterViewController.m
//  RCTools
//
//  Created by Zakk Hoyt on 4/15/14.
//  Copyright (c) 2014 Zakk Hoyt. All rights reserved.
//

#import "VWWScatterViewController.h"
#import "CorePlot-CocoaTouch.h"
#import "TestXYTheme.h"
#import "VWWMotionController.h"

#define NUM_POINTS 50
#define kAlpha 0.5;
@interface VWWScatterViewController ()<CPTPlotDataSource, VWWMotionControllerDelegate>
@property (nonatomic, strong) NSMutableArray *dataForPlot;
@property (weak, nonatomic) IBOutlet CPTGraphHostingView *graphView;
@property (nonatomic, strong) CPTXYGraph *graph;
@property (nonatomic, strong) VWWMotionController *motionController;
@end

@implementation VWWScatterViewController

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

#pragma mark -
#pragma mark Initialization and teardown

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.motionController = [VWWMotionController sharedInstance];
    self.motionController.delegate = self;
    self.motionController.updateInterval = 1/30.0;
    [self.motionController startAccelerometer];
    [self setupData];
    [self setupgraph];
}


-(void)setupData{
    self.dataForPlot = [@[]mutableCopy];
    //    // Add some initial data
//    NSMutableArray *contentArray = [NSMutableArray arrayWithCapacity:NUM_POINTS];
//    for ( NSUInteger i = 0; i < NUM_POINTS; i++ ) {
//        NSNumber *x = @(i);
//        float randomNum = ((float)rand() / RAND_MAX) * 10;
//        randomNum -= 5.0;
//        NSNumber *y = @(randomNum);
//        [contentArray addObject:@{ @"x": x,
//                                   @"y": y }
//         ];
//    }
//    self.dataForPlot = contentArray;
}
-(void)setupgraph{
    
    //#define VWW_SCATTER
    
#if defined(VWW_SCATTER)
    // Create self.graph from a custom theme
    self.graph = [[CPTXYGraph alloc] initWithFrame:CGRectZero];
    CPTTheme *theme = [[TestXYTheme alloc] init];
    [self.graph applyTheme:theme];
    
    CPTGraphHostingView *hostingView = (CPTGraphHostingView *)self.graphView;
    // Flip about x axis
    self.graphView.transform = CGAffineTransformMakeScale(1.0, -1.0);
    hostingView.hostedGraph = self.graph;
    
    self.graph.plotAreaFrame.masksToBorder = NO;
    
    // Setup plot space
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)self.graph.defaultPlotSpace;
    plotSpace.allowsUserInteraction = NO;
    plotSpace.xRange                = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0.0) length:CPTDecimalFromFloat(NUM_POINTS)];
    plotSpace.yRange                = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(-5.0) length:CPTDecimalFromFloat(10)];
    
    
    // Create a blue plot area
    CPTScatterPlot *boundLinePlot = [[CPTScatterPlot alloc] init];
    boundLinePlot.identifier = @"Blue Plot";
    
    CPTMutableLineStyle *lineStyle = [boundLinePlot.dataLineStyle mutableCopy];
    lineStyle.lineWidth         = 1.0;
    lineStyle.lineColor         = [CPTColor blueColor];
    boundLinePlot.dataLineStyle = lineStyle;
    
    boundLinePlot.dataSource = self;
    [self.graph addPlot:boundLinePlot];
    
    // Create a green plot area
    CPTScatterPlot *dataSourceLinePlot = [[CPTScatterPlot alloc] init];
    dataSourceLinePlot.identifier = @"Green Plot";
    
    lineStyle                        = [dataSourceLinePlot.dataLineStyle mutableCopy];
    lineStyle.lineWidth              = 1.0;
    lineStyle.lineColor              = [CPTColor greenColor];
    dataSourceLinePlot.dataLineStyle = lineStyle;
    
    dataSourceLinePlot.dataSource = self;
    [self.graph addPlot:dataSourceLinePlot];
    
#else
    
    
    // Create self.graph from a custom theme
    self.graph = [[CPTXYGraph alloc] initWithFrame:CGRectZero];
    //    CPTTheme *theme = [[TestXYTheme alloc] init];
    //    CPTTheme *theme = [CPTTheme themeNamed:kCPTDarkGradientTheme];
    CPTTheme *theme = [CPTTheme themeNamed:kCPTPlainBlackTheme];
    //    CPTTheme *theme = [CPTTheme themeNamed:kCPTPlainWhiteTheme];
    //    CPTTheme *theme = [CPTTheme themeNamed:kCPTSlateTheme];
    //    CPTTheme *theme = [CPTTheme themeNamed:kCPTStocksTheme];
    [self.graph applyTheme:theme];
    
    CPTGraphHostingView *hostingView = (CPTGraphHostingView *)self.graphView;
    // Flip about x axis
    self.graphView.transform = CGAffineTransformMakeScale(1.0, -1.0);
    hostingView.hostedGraph = self.graph;
    

    //    self.graph = [[CPTXYGraph alloc] initWithFrame:self.view.bounds] ;
    
//    self.graph.plotAreaFrame.paddingTop    = 15.0;
//    self.graph.plotAreaFrame.paddingRight  = 15.0;
//    self.graph.plotAreaFrame.paddingBottom = 55.0;
//    self.graph.plotAreaFrame.paddingLeft   = 55.0;
//    self.graph.plotAreaFrame.masksToBorder = NO;
    
    // Grid line styles
    CPTMutableLineStyle *majorGridLineStyle = [CPTMutableLineStyle lineStyle];
    majorGridLineStyle.lineWidth = 0.75;
    majorGridLineStyle.lineColor = [[CPTColor colorWithGenericGray:0.2] colorWithAlphaComponent:0.75];
    
    CPTMutableLineStyle *minorGridLineStyle = [CPTMutableLineStyle lineStyle];
    minorGridLineStyle.lineWidth = 0.25;
    minorGridLineStyle.lineColor = [[CPTColor whiteColor] colorWithAlphaComponent:0.1];
    
    // Axes
    // X axis
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)self.graph.axisSet;
    CPTXYAxis *x          = axisSet.xAxis;
    x.labelingPolicy              = CPTAxisLabelingPolicyAutomatic;
    x.orthogonalCoordinateDecimal = CPTDecimalFromUnsignedInteger(0);
    x.majorGridLineStyle          = majorGridLineStyle;
    x.minorGridLineStyle          = minorGridLineStyle;
    x.minorTicksPerInterval       = 9;
    x.title                       = @"X Axis";
    x.titleOffset                 = 35.0;
    NSNumberFormatter *labelFormatter = [[NSNumberFormatter alloc] init];
    labelFormatter.numberStyle = NSNumberFormatterNoStyle;
    x.labelFormatter           = labelFormatter;
    
    
    // Y axis
    CPTXYAxis *y = axisSet.yAxis;
    y.labelingPolicy              = CPTAxisLabelingPolicyAutomatic;
    y.orthogonalCoordinateDecimal = CPTDecimalFromUnsignedInteger(0);
    y.majorGridLineStyle          = majorGridLineStyle;
    y.minorGridLineStyle          = minorGridLineStyle;
    y.minorTicksPerInterval       = 3;
    y.labelOffset                 = 5.0;
    y.title                       = @"Y Axis";
    y.titleOffset                 = 30.0;
    y.axisConstraints             = [CPTConstraints constraintWithLowerOffset:0.0];
    
    // Rotate the labels by 45 degrees, just to show it can be done.
    x.labelRotation = M_PI_4;
    
    // Create the plot
    CPTScatterPlot *dataSourceLinePlot = [[CPTScatterPlot alloc] init];
    dataSourceLinePlot.identifier     = @"Blue Plot";
    dataSourceLinePlot.cachePrecision = CPTPlotCachePrecisionDouble;
    
    CPTMutableLineStyle *lineStyle = [dataSourceLinePlot.dataLineStyle mutableCopy];
    lineStyle.lineWidth              = 3.0;
    lineStyle.lineColor              = [CPTColor greenColor];
    dataSourceLinePlot.dataLineStyle = lineStyle;
    
    dataSourceLinePlot.dataSource = self;
    [self.graph addPlot:dataSourceLinePlot];
    
    // Plot space
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)self.graph.defaultPlotSpace;
    plotSpace.xRange                = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0.0) length:CPTDecimalFromFloat(NUM_POINTS)];
    plotSpace.yRange                = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(-5.0) length:CPTDecimalFromFloat(10)];
    
    
#endif
    
    
    ////#define PERFORMANCE_TEST1
    //#ifdef PERFORMANCE_TEST1
    //    [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(changePlotRange) userInfo:nil repeats:YES];
    //#endif
    //
    //#define PERFORMANCE_TEST2
    //#ifdef PERFORMANCE_TEST2
    //    [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(cycleData) userInfo:nil repeats:YES];
    //#endif
    
}

-(void)changePlotRange{
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)self.graph.defaultPlotSpace;
    float ylen                = NUM_POINTS * (rand() / (double)RAND_MAX);
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0.0) length:CPTDecimalFromFloat(NUM_POINTS)];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0.0) length:CPTDecimalFromFloat(ylen)];
}

-(void)cycleData{
    [self setupData];
    [self.graph reloadData];
    
}

#pragma mark CPTPlotDataSource

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot{
    return [self.dataForPlot count];
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    @synchronized(self.dataForPlot){
        NSString *key = (fieldEnum == CPTScatterPlotFieldX ? @"x" : @"y");
        NSNumber *num = [self.dataForPlot[index] valueForKey:key];
        
        // Green plot gets shifted above the blue
        if ( [(NSString *)plot.identifier isEqualToString : @"Green Plot"] ) {
            if ( fieldEnum == CPTScatterPlotFieldY ) {
                num = @([num doubleValue] + 1/5.0 + 2.0);
            }
        }
        return num;
    }
}

#pragma mark CPTAxisDelegate

-(BOOL)axis:(CPTAxis *)axis shouldUpdateAxisLabelsAtLocations:(NSSet *)locations
{
    static CPTTextStyle *positiveStyle = nil;
    static CPTTextStyle *negativeStyle = nil;
    
    NSFormatter *formatter = axis.labelFormatter;
    CGFloat labelOffset    = axis.labelOffset;
    NSDecimalNumber *zero  = [NSDecimalNumber zero];
    
    NSMutableSet *newLabels = [NSMutableSet set];
    
    for ( NSDecimalNumber *tickLocation in locations ) {
        CPTTextStyle *theLabelTextStyle;
        
        if ( [tickLocation isGreaterThanOrEqualTo:zero] ) {
            if ( !positiveStyle ) {
                CPTMutableTextStyle *newStyle = [axis.labelTextStyle mutableCopy];
                newStyle.color = [CPTColor greenColor];
                positiveStyle  = newStyle;
            }
            theLabelTextStyle = positiveStyle;
        }
        else {
            if ( !negativeStyle ) {
                CPTMutableTextStyle *newStyle = [axis.labelTextStyle mutableCopy];
                newStyle.color = [CPTColor redColor];
                negativeStyle  = newStyle;
            }
            theLabelTextStyle = negativeStyle;
        }
        
        NSString *labelString       = [formatter stringForObjectValue:tickLocation];
        CPTTextLayer *newLabelLayer = [[CPTTextLayer alloc] initWithText:labelString style:theLabelTextStyle];
        
        CPTAxisLabel *newLabel = [[CPTAxisLabel alloc] initWithContentLayer:newLabelLayer];
        newLabel.tickLocation = tickLocation.decimalValue;
        newLabel.offset       = labelOffset;
        
        [newLabels addObject:newLabel];
    }
    
    axis.axisLabels = newLabels;
    
    return NO;
}


-(void)motionController:(VWWMotionController*)sender didUpdateAcceleremeters:(CMAccelerometerData*)accelerometers limits:(VWWDeviceLimits *)limits{
    @synchronized(self.dataForPlot){
        static NSInteger counter = 0;
        
        CPTGraph *theGraph = self.graph;
        CPTPlot *thePlot   = [theGraph plotWithIdentifier:@"Blue Plot"];
        
        if ( thePlot ) {
            
            if ( self.dataForPlot.count >= NUM_POINTS ) {
                [self.dataForPlot removeObjectAtIndex:0];
                [thePlot deleteDataInIndexRange:NSMakeRange(0, 1)];
            }
            
            CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)theGraph.defaultPlotSpace;
            NSUInteger location       = (counter >= NUM_POINTS ? counter - NUM_POINTS + 2 : 0);
            
            CPTPlotRange *oldRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromUnsignedInteger( (location > 0) ? (location - 1) : 0 )
                                                                  length:CPTDecimalFromUnsignedInteger(NUM_POINTS - 2)];
            CPTPlotRange *newRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromUnsignedInteger(location)
                                                                  length:CPTDecimalFromUnsignedInteger(NUM_POINTS - 2)];
            
            [CPTAnimation animate:plotSpace
                         property:@"xRange"
                    fromPlotRange:oldRange
                      toPlotRange:newRange
                         duration:CPTFloat(1/30.0)];
            
            
            NSNumber *x = @(counter);
            NSNumber *y = @(accelerometers.acceleration.x);
            [self.dataForPlot addObject:@{ @"x": x,
                                           @"y": y }];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [thePlot insertDataAtIndex:self.dataForPlot.count - 1 numberOfRecords:1];
            });
            
            
            counter++;
            
        }
    }
}
@end
