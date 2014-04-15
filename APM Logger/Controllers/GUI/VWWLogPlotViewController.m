//
//  VWWLogPlotViewController.m
//  APM Logger
//
//  Created by Zakk Hoyt on 4/12/14.
//  Copyright (c) 2014 Zakk Hoyt. All rights reserved.
//

#import "VWWLogPlotViewController.h"
#import "AP2Data.h"
#import "CorePlot-CocoaTouch.h"
#import "VWWLogFilterViewController.h"


static NSString *VWWSeguePlotToFilter = @"VWWSeguePlotToFilter";

@interface VWWLogPlotViewController () <CPTPlotDataSource, CPTAxisDelegate>
@property (nonatomic, strong) CPTXYGraph *graph;
@property (nonatomic, strong) NSMutableArray *dataForPlot;
@property (nonatomic, strong) NSMutableArray *filters;
@property (nonatomic) BOOL hasLoaded;
@property (nonatomic, strong) CPTScatterPlot *dataSourceLinePlot;
@end

@implementation VWWLogPlotViewController


#pragma mark UIViewController
-(void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"APM Log";
    
    
    UIBarButtonItem *filterButton = [[UIBarButtonItem alloc]initWithTitle:@"Filter" style:UIBarButtonItemStylePlain target:self action:@selector(filterButtonTouchUpInside:)];
    [self.navigationItem setRightBarButtonItem:filterButton animated:NO];

}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    if(self.hasLoaded == NO){
        self.hasLoaded = YES;
        [self buildFilters];
        [self buildData];
        [self buildGraph];
    }

}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:VWWSeguePlotToFilter]){
        VWWLogFilterViewController *vc = segue.destinationViewController;
        vc.filters = self.filters;
    }
}

#pragma mark IBActions
-(void)filterButtonTouchUpInside:(UIBarButtonItem*)sender{
    [self performSegueWithIdentifier:VWWSeguePlotToFilter sender:self];
}



#pragma mark Private methods


-(void)buildGraph{
    
    

    
    self.graph = [[CPTXYGraph alloc] initWithFrame:self.view.bounds] ;
    
    CPTGraphHostingView *hostingView = (CPTGraphHostingView *)self.view;
    hostingView.collapsesLayers = NO; // Setting to YES reduces GPU memory usage, but can slow drawing/scrolling
    hostingView.hostedGraph     = self.graph;
    
    self.dataSourceLinePlot = [[CPTScatterPlot alloc] init];
    self.dataSourceLinePlot.cachePrecision = CPTPlotCachePrecisionDouble;
    
    CPTMutableLineStyle *lineStyle = [self.dataSourceLinePlot.dataLineStyle mutableCopy];
    lineStyle.lineWidth              = 1.0;
    lineStyle.lineColor              = [CPTColor greenColor];
    self.dataSourceLinePlot.dataLineStyle = lineStyle;
    
    self.dataSourceLinePlot.dataSource = self;
    self.dataSourceLinePlot.delegate   = self;
    

    
    CPTMutableTextStyle *whiteTextStyle = [CPTMutableTextStyle textStyle];
    whiteTextStyle.color              = [CPTColor whiteColor];
    self.dataSourceLinePlot.labelTextStyle = whiteTextStyle;
    self.dataSourceLinePlot.labelOffset    = 5.0;
    self.dataSourceLinePlot.labelRotation  = M_PI_4;
    self.dataSourceLinePlot.identifier     = @"Stepped Plot";
    [self.graph addPlot:self.dataSourceLinePlot];
    
    // Make the data source line use stepped interpolation
    self.dataSourceLinePlot.interpolation = CPTScatterPlotInterpolationStepped;
    
    // Put an area gradient under the plot above
    CPTColor *areaColor       = [CPTColor colorWithComponentRed:0.3 green:1.0 blue:0.3 alpha:0.8];
    CPTGradient *areaGradient = [CPTGradient gradientWithBeginningColor:areaColor endingColor:[CPTColor clearColor]];
    areaGradient.angle = -90.0;
    CPTFill *areaGradientFill = [CPTFill fillWithGradient:areaGradient];
    self.dataSourceLinePlot.areaFill      = areaGradientFill;
    self.dataSourceLinePlot.areaBaseValue = CPTDecimalFromDouble(1.75);
    
    // Auto scale the plot space to fit the plot data
    // Extend the y range by 10% for neatness
    CPTXYPlotSpace *plotSpace = (id)self.graph.defaultPlotSpace;
    plotSpace.allowsUserInteraction = YES;
    [plotSpace scaleToFitPlots:@[self.dataSourceLinePlot]];
    CPTMutablePlotRange *yRange = [plotSpace.yRange mutableCopy];
    [yRange expandRangeByFactor:CPTDecimalFromDouble(1.1)];
    plotSpace.yRange = yRange;
    
    // Restrict y range to a global range
    CPTPlotRange *globalYRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0.0f) length:CPTDecimalFromFloat(10.0f)];
    plotSpace.globalYRange = globalYRange;
    
 }


-(void)buildFilters{
    if(self.filters == nil){
        self.filters = [@[]mutableCopy];
    } else {
        [self.filters removeAllObjects];
    }
    
    [self.dataPlot getParamsWithCompletionBlock:^(NSArray *filters) {
        dispatch_async(dispatch_get_main_queue(), ^{
//            for(NSString *table in tables){
//                // Set default filters
//                // 0 is off, non-zero is on
//                NSNumber *activated = @(0);
//                if([table isEqualToString:@"GPS"]){
//                    activated = @(1);
//                }
//                
//                NSDictionary *filter = @{VWWLogFilterViewControllerFilterNameKey : table,
//                                         VWWLogFilterViewControllerFilterActivatedKey : activated};
//                [self.filters addObject:filter];
//            }
            self.filters = [filters mutableCopy];
        });
    }];

}


-(void)buildData{

//    // Add some initial data
    NSMutableArray *contentArray = [NSMutableArray arrayWithCapacity:100];
    for ( NSUInteger i = 0; i < 60; i++ ) {
        NSNumber *x = @(1.0 + i * 0.05);
        NSNumber *y = @(1.2 * rand() / (double)RAND_MAX + 1.2);
        [contentArray addObject:@{ @"x": x,
                                   @"y": y }
         ];
    }
    self.dataForPlot = contentArray;

//    [self.dataPlot getDataForTable:@"ATT" completionBlock:^(NSArray *array) {
//        // Convert our arrays to x/y plot
//        dispatch_async(dispatch_get_main_queue(), ^{
//            // Add some initial data
//            NSMutableArray *contentArray = [NSMutableArray arrayWithCapacity:100];
//            for ( NSUInteger i = 0; i < 60; i++ ) {
//                NSNumber *x = @(1.0 + i * 0.05);
//                NSNumber *y = @(1.2 * rand() / (double)RAND_MAX + 1.2);
//                [contentArray addObject:@{ @"x": x,
//                                           @"y": y }
//                 ];
//            }
//            self.dataForPlot = contentArray;
//
////            dataForPlot = [array mutableCopy];
//
//            [self.graph reloadData];
//        });
//        
//        
//    }];
}


-(void)changePlotRange
{
    // Setup plot space
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)self.graph.defaultPlotSpace;
    
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0.0) length:CPTDecimalFromFloat(3.0 + 2.0 * rand() / RAND_MAX)];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0.0) length:CPTDecimalFromFloat(3.0 + 2.0 * rand() / RAND_MAX)];
}

#pragma mark CPTPlotDataSource

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    return [self.dataForPlot count];
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    NSString *key = (fieldEnum == CPTScatterPlotFieldX ? @"x" : @"y");
    NSNumber *num = [self.dataForPlot[index] valueForKey:key];
    
    // Green plot gets shifted above the blue
    if ( [(NSString *)plot.identifier isEqualToString : @"Green Plot"] ) {
        if ( fieldEnum == CPTScatterPlotFieldY ) {
            num = @([num doubleValue] + 1.0);
        }
    }
    return num;
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

@end
