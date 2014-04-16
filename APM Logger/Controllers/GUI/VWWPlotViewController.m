//
//  VWWPlotViewController.m
//  RCTools
//
//  Created by Zakk Hoyt on 4/15/14.
//  Copyright (c) 2014 Zakk Hoyt. All rights reserved.
//

#import "VWWPlotViewController.h"
#import "CorePlot-CocoaTouch.h"

static NSString *const kPlotIdentifier = @"Data Source Plot";
static const NSUInteger kMaxDataPoints = 52;
static const double kFrameRate = 5.0;  // frames per second
static const double kAlpha     = 0.25; // smoothing constant


@interface VWWPlotViewController () <CPTPlotDataSource>
@property (nonatomic, strong) CPTXYGraph *graph;
@property (nonatomic, strong) NSTimer *dataTimer;
@property (nonatomic, strong) NSMutableArray *plotData;
@property (nonatomic) NSUInteger currentIndex;
@property (weak, nonatomic) IBOutlet CPTGraphHostingView *graphView;

@end

@implementation VWWPlotViewController


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
    [self newData:nil];
    self.plotData = [@[]mutableCopy];
    //    [self.plotData removeAllObjects];
    self.currentIndex = 0;
    
    [self setupGraph];
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

-(void)setupGraph{
    
    self.graph = [[CPTXYGraph alloc] initWithFrame:self.view.bounds] ;
    //    [self addGraph:graph toHostingView:layerHostingView];
    //    [self applyTheme:theme toGraph:graph withDefault:[CPTTheme themeNamed:kCPTDarkGradientTheme]];
    
    //    [self setTitleDefaultsForGraph:graph withBounds:bounds];
    //    [self setPaddingDefaultsForGraph:graph withBounds:bounds];
    
    self.graph.plotAreaFrame.paddingTop    = 15.0;
    self.graph.plotAreaFrame.paddingRight  = 15.0;
    self.graph.plotAreaFrame.paddingBottom = 55.0;
    self.graph.plotAreaFrame.paddingLeft   = 55.0;
    self.graph.plotAreaFrame.masksToBorder = NO;
    
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
    dataSourceLinePlot.identifier     = kPlotIdentifier;
    dataSourceLinePlot.cachePrecision = CPTPlotCachePrecisionDouble;
    
    CPTMutableLineStyle *lineStyle = [dataSourceLinePlot.dataLineStyle mutableCopy];
    lineStyle.lineWidth              = 3.0;
    lineStyle.lineColor              = [CPTColor greenColor];
    dataSourceLinePlot.dataLineStyle = lineStyle;
    
    dataSourceLinePlot.dataSource = self;
    [self.graph addPlot:dataSourceLinePlot];
    
    // Plot space
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)self.graph.defaultPlotSpace;
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromUnsignedInteger(0) length:CPTDecimalFromUnsignedInteger(kMaxDataPoints - 2)];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromUnsignedInteger(0) length:CPTDecimalFromUnsignedInteger(1)];
    
    [self.dataTimer invalidate];
    
    
    //    if ( animated ) {
    if(YES){
        self.dataTimer = [NSTimer timerWithTimeInterval:1.0 / kFrameRate
                                                 target:self
                                               selector:@selector(newData:)
                                               userInfo:nil
                                                repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:self.dataTimer forMode:NSRunLoopCommonModes];
    }
    else {
        self.dataTimer = nil;
    }
}



#pragma mark -
#pragma mark Timer callback

-(void)newData:(NSTimer *)theTimer
{
    //CPTGraph *theGraph = (self.graphs)[0];
    CPTGraph *theGraph = self.graph;
    CPTPlot *thePlot   = [theGraph plotWithIdentifier:kPlotIdentifier];
    
    if ( thePlot ) {
        if (self.plotData.count >= kMaxDataPoints ) {
            [self.plotData removeObjectAtIndex:0];
            [thePlot deleteDataInIndexRange:NSMakeRange(0, 1)];
        }
        
        CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)theGraph.defaultPlotSpace;
        NSUInteger location       = (self.currentIndex >= kMaxDataPoints ? self.currentIndex - kMaxDataPoints + 2 : 0);
        
        CPTPlotRange *oldRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromUnsignedInteger( (location > 0) ? (location - 1) : 0 )
                                                              length:CPTDecimalFromUnsignedInteger(kMaxDataPoints - 2)];
        CPTPlotRange *newRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromUnsignedInteger(location)
                                                              length:CPTDecimalFromUnsignedInteger(kMaxDataPoints - 2)];
        
        [CPTAnimation animate:plotSpace
                     property:@"xRange"
                fromPlotRange:oldRange
                  toPlotRange:newRange
                     duration:CPTFloat(1.0 / kFrameRate)];
        
        self.currentIndex++;
        [self.plotData addObject:@( (1.0 - kAlpha) * [[self.plotData lastObject] doubleValue] + kAlpha * rand() / (double)RAND_MAX )];
        [thePlot insertDataAtIndex:self.plotData.count - 1 numberOfRecords:1];
    }
}

#pragma mark -
#pragma mark Plot Data Source Methods

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    return [self.plotData count];
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    NSNumber *num = nil;
    
    switch ( fieldEnum ) {
        case CPTScatterPlotFieldX:
            num = @(index + self.currentIndex - self.plotData.count);
            break;
            
        case CPTScatterPlotFieldY:
            num = self.plotData[index];
            break;
            
        default:
            break;
    }
    
    return num;
}

@end
