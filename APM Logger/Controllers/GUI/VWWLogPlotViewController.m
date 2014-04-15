//
//  VWWLogPlotViewController.m
//  APM Logger
//
//  Created by Zakk Hoyt on 4/12/14.
//  Copyright (c) 2014 Zakk Hoyt. All rights reserved.
//

#import "VWWLogPlotViewController.h"
#import "AP2DataPlot.h"
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
    
    //    [self.navigationController setNavigationBarHidden:NO];
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
//    [self performSegueWithIdentifier:VWWSeguePlotToFilter sender:self];
    
    
    
    [self.dataPlot getDataForTable:@"ATT" completionBlock:^(NSArray *array) {
        // Convert our arrays to x/y plot
        dispatch_async(dispatch_get_main_queue(), ^{
            // Add some initial data
//            NSMutableArray *contentArray = [NSMutableArray arrayWithCapacity:100];
//            for ( NSUInteger i = 0; i < 60; i++ ) {
//                NSNumber *x = @(1.0 + i * 0.05);
//                NSNumber *y = @(1.2 * rand() / (double)RAND_MAX + 1.2);
//                [contentArray addObject:@{ @"x": x,
//                                           @"y": y }
//                 ];
//            }
//            self.dataForPlot = contentArray;
            self.dataForPlot = [array mutableCopy];
            
            //            dataForPlot = [array mutableCopy];
            
            
            [self.dataSourceLinePlot reloadData];
            [self.graph reloadData];
        });

        
    }];

}



#pragma mark Private methods


-(void)buildGraph{
    
    

    
    self.graph = [[CPTXYGraph alloc] initWithFrame:self.view.bounds] ;
    
    CPTGraphHostingView *hostingView = (CPTGraphHostingView *)self.view;
    hostingView.collapsesLayers = NO; // Setting to YES reduces GPU memory usage, but can slow drawing/scrolling
    hostingView.hostedGraph     = self.graph;
    
    
    //    [self addGraph:graph toHostingView:layerHostingView];
    //    [self applyTheme:theme toGraph:graph withDefault:[CPTTheme themeNamed:kCPTSlateTheme]];
    
    //    [self setTitleDefaultsForGraph:graph withBounds:bounds];
    //    [self setPaddingDefaultsForGraph:graph withBounds:bounds];
    //
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
    
    
    
    
////    graph = [[CPTXYGraph alloc] initWithFrame:self.view.bounds] ;
////    
////    CPTGraphHostingView *hostingView = (CPTGraphHostingView *)self.view;
////    hostingView.collapsesLayers = NO; // Setting to YES reduces GPU memory usage, but can slow drawing/scrolling
////    hostingView.hostedGraph     = graph;
////    
////    
////    //    [self addGraph:graph toHostingView:layerHostingView];
////    //    [self applyTheme:theme toGraph:graph withDefault:[CPTTheme themeNamed:kCPTSlateTheme]];
////    
////    //    [self setTitleDefaultsForGraph:graph withBounds:bounds];
////    //    [self setPaddingDefaultsForGraph:graph withBounds:bounds];
////    //
////    CPTScatterPlot *dataSourceLinePlot = [[CPTScatterPlot alloc] init];
////    dataSourceLinePlot.cachePrecision = CPTPlotCachePrecisionDouble;
////    
////    CPTMutableLineStyle *lineStyle = [dataSourceLinePlot.dataLineStyle mutableCopy];
////    lineStyle.lineWidth              = 1.0;
////    lineStyle.lineColor              = [CPTColor greenColor];
////    dataSourceLinePlot.dataLineStyle = lineStyle;
////    
////    dataSourceLinePlot.dataSource = self;
////    dataSourceLinePlot.delegate   = self;
////    
////    CPTMutableTextStyle *whiteTextStyle = [CPTMutableTextStyle textStyle];
////    whiteTextStyle.color              = [CPTColor whiteColor];
////    dataSourceLinePlot.labelTextStyle = whiteTextStyle;
////    dataSourceLinePlot.labelOffset    = 5.0;
////    dataSourceLinePlot.labelRotation  = M_PI_4;
////    dataSourceLinePlot.identifier     = @"Stepped Plot";
////    [graph addPlot:dataSourceLinePlot];
////    
////    // Make the data source line use stepped interpolation
////    dataSourceLinePlot.interpolation = CPTScatterPlotInterpolationStepped;
////    
////    // Put an area gradient under the plot above
////    CPTColor *areaColor       = [CPTColor colorWithComponentRed:0.3 green:1.0 blue:0.3 alpha:0.8];
////    CPTGradient *areaGradient = [CPTGradient gradientWithBeginningColor:areaColor endingColor:[CPTColor clearColor]];
////    areaGradient.angle = -90.0;
////    CPTFill *areaGradientFill = [CPTFill fillWithGradient:areaGradient];
////    dataSourceLinePlot.areaFill      = areaGradientFill;
////    dataSourceLinePlot.areaBaseValue = CPTDecimalFromDouble(1.75);
////    
////    // Auto scale the plot space to fit the plot data
////    // Extend the y range by 10% for neatness
////    CPTXYPlotSpace *plotSpace = (id)graph.defaultPlotSpace;
////    plotSpace.allowsUserInteraction = YES;
////    [plotSpace scaleToFitPlots:@[dataSourceLinePlot]];
////    CPTMutablePlotRange *yRange = [plotSpace.yRange mutableCopy];
////    [yRange expandRangeByFactor:CPTDecimalFromDouble(1.1)];
////    plotSpace.yRange = yRange;
////    
////    // Restrict y range to a global range
////    CPTPlotRange *globalYRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0.0f) length:CPTDecimalFromFloat(6.0f)];
////    plotSpace.globalYRange = globalYRange;
//    
//    
//    // Add some initial data
//    NSMutableArray *contentArray = [NSMutableArray arrayWithCapacity:100];
//    for ( NSUInteger i = 0; i < 60; i++ ) {
//        NSNumber *x = @(1.0 + i * 0.05);
//        NSNumber *y = @(1.2 * rand() / (double)RAND_MAX + 1.2);
//        [contentArray addObject:@{ @"x": x,
//                                   @"y": y }
//         ];
//    }
//    dataForPlot = contentArray;
    
//    // Create graph from theme
//    graph = [[CPTXYGraph alloc] initWithFrame:CGRectZero];
//    CPTTheme *theme = [CPTTheme themeNamed:kCPTDarkGradientTheme];
//    [graph applyTheme:theme];
//    CPTGraphHostingView *hostingView = (CPTGraphHostingView *)self.view;
//    hostingView.collapsesLayers = NO; // Setting to YES reduces GPU memory usage, but can slow drawing/scrolling
//    hostingView.hostedGraph     = graph;
//
//    graph.paddingLeft   = 10.0;
//    graph.paddingTop    = self.navigationController.view.bounds.size.height + [UIApplication sharedApplication].statusBarFrame.size.height;
//    graph.paddingRight  = 10.0;
//    graph.paddingBottom = 10.0;
//
//    // Setup plot space
//    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
//    plotSpace.allowsUserInteraction = YES;
//    plotSpace.xRange                = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(1.0) length:CPTDecimalFromDouble(2.0)];
//    plotSpace.yRange                = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(1.0) length:CPTDecimalFromDouble(3.0)];
//
//    // Axes
//    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)graph.axisSet;
//    CPTXYAxis *x          = axisSet.xAxis;
//    x.majorIntervalLength         = CPTDecimalFromDouble(0.5);
//    x.orthogonalCoordinateDecimal = CPTDecimalFromDouble(2.0);
//    x.minorTicksPerInterval       = 2;
//    NSArray *exclusionRanges = @[[CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(1.99) length:CPTDecimalFromDouble(0.02)],
//                                 [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(0.99) length:CPTDecimalFromDouble(0.02)],
//                                 [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(2.99) length:CPTDecimalFromDouble(0.02)]];
//    x.labelExclusionRanges = exclusionRanges;
//
//    CPTXYAxis *y = axisSet.yAxis;
//    y.majorIntervalLength         = CPTDecimalFromDouble(0.5);
//    y.minorTicksPerInterval       = 5;
//    y.orthogonalCoordinateDecimal = CPTDecimalFromDouble(2.0);
//    exclusionRanges               = @[[CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(1.99) length:CPTDecimalFromDouble(0.02)],
//                                      [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(0.99) length:CPTDecimalFromDouble(0.02)],
//                                      [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(3.99) length:CPTDecimalFromDouble(0.02)]];
//    y.labelExclusionRanges = exclusionRanges;
//    y.delegate             = self;
//
//    // Create a blue plot area
//    CPTScatterPlot *boundLinePlot  = [[CPTScatterPlot alloc] init];
//    CPTMutableLineStyle *lineStyle = [CPTMutableLineStyle lineStyle];
//    lineStyle.miterLimit        = 1.0;
//    lineStyle.lineWidth         = 3.0;
//    lineStyle.lineColor         = [CPTColor blueColor];
//    boundLinePlot.dataLineStyle = lineStyle;
//    boundLinePlot.identifier    = @"Blue Plot";
//    boundLinePlot.dataSource    = self;
//    [graph addPlot:boundLinePlot];
//
////    CPTImage *fillImage = [CPTImage imageNamed:@"BlueTexture"];
////    fillImage.tiled = YES;
////    CPTFill *areaImageFill = [CPTFill fillWithImage:fillImage];
////    boundLinePlot.areaFill      = areaImageFill;
////    boundLinePlot.areaBaseValue = [[NSDecimalNumber zero] decimalValue];
//
//    // Add plot symbols
//    CPTMutableLineStyle *symbolLineStyle = [CPTMutableLineStyle lineStyle];
//    symbolLineStyle.lineColor = [CPTColor blackColor];
//    CPTPlotSymbol *plotSymbol = [CPTPlotSymbol ellipsePlotSymbol];
//    plotSymbol.fill          = [CPTFill fillWithColor:[CPTColor blueColor]];
//    plotSymbol.lineStyle     = symbolLineStyle;
//    plotSymbol.size          = CGSizeMake(10.0, 10.0);
//    boundLinePlot.plotSymbol = plotSymbol;
//
//    // Create a green plot area
//    CPTScatterPlot *dataSourceLinePlot = [[CPTScatterPlot alloc] init];
//    lineStyle                        = [CPTMutableLineStyle lineStyle];
//    lineStyle.lineWidth              = 3.0;
//    lineStyle.lineColor              = [CPTColor greenColor];
//    lineStyle.dashPattern            = @[@5.0, @5.0];
//    dataSourceLinePlot.dataLineStyle = lineStyle;
//    dataSourceLinePlot.identifier    = @"Green Plot";
//    dataSourceLinePlot.dataSource    = self;
//
//    // Put an area gradient under the plot above
//    CPTColor *areaColor       = [CPTColor colorWithComponentRed:0.3 green:1.0 blue:0.3 alpha:0.8];
//    CPTGradient *areaGradient = [CPTGradient gradientWithBeginningColor:areaColor endingColor:[CPTColor clearColor]];
//    areaGradient.angle = -90.0;
//    CPTFill *areaGradientFill = [CPTFill fillWithGradient:areaGradient];
//    dataSourceLinePlot.areaFill      = areaGradientFill;
//    dataSourceLinePlot.areaBaseValue = CPTDecimalFromDouble(1.75);
//
//    // Animate in the new plot, as an example
//    dataSourceLinePlot.opacity = 0.0;
//    [graph addPlot:dataSourceLinePlot];
//
//    CABasicAnimation *fadeInAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
//    fadeInAnimation.duration            = 5.0;
//    fadeInAnimation.removedOnCompletion = NO;
//    fadeInAnimation.fillMode            = kCAFillModeForwards;
//    fadeInAnimation.toValue             = @1.0;
//    [dataSourceLinePlot addAnimation:fadeInAnimation forKey:@"animateOpacity"];
//
//
//
//#ifdef PERFORMANCE_TEST
//    [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(changePlotRange) userInfo:nil repeats:YES];
//#endif
}


-(void)buildFilters{
    if(self.filters == nil){
        self.filters = [@[]mutableCopy];
    } else {
        [self.filters removeAllObjects];
    }
    
    [self.dataPlot getParamsWithCompletionBlock:^(NSArray *tables) {
        dispatch_async(dispatch_get_main_queue(), ^{
            for(NSString *table in tables){
                // Set default filters
                // 0 is off, non-zero is on
                NSNumber *activated = @(0);
                if([table isEqualToString:@"GPS"]){
                    activated = @(1);
                }
                
                NSDictionary *filter = @{VWWLogFilterViewControllerFilterNameKey : table,
                                         VWWLogFilterViewControllerFilterActivatedKey : activated};
                [self.filters addObject:filter];
            }
            
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

#pragma mark -
#pragma mark Plot Data Source Methods

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

#pragma mark -
#pragma mark Axis Delegate Methods

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
