//
//  APM Logger
//
//  Created by Zakk Hoyt 2014
//  Copyright (c) 2014 Zakk Hoyt.
//


#import "VWWAddOverlayViewController.h"

@interface VWWAddOverlayViewController ()
@property (weak, nonatomic) IBOutlet UISegmentedControl *frameSelectSegment;
@end

@implementation VWWAddOverlayViewController

- (IBAction)loadAsset:(id)sender {
    [self startMediaBrowserFromViewController:self usingDelegate:self];
}

- (IBAction)generateOutput:(id)sender {
  [self videoOutput];
}

- (void)applyVideoEffectsToComposition:(AVMutableVideoComposition *)composition size:(CGSize)size
{
    // 1 - set up the overlay
    CALayer *overlayLayer = [CALayer layer];
    UIImage *overlayImage = nil;
    if (_frameSelectSegment.selectedSegmentIndex == 0) {
        overlayImage = [UIImage imageNamed:@"Frame-1.png"];
    } else if(_frameSelectSegment.selectedSegmentIndex == 1) {
        overlayImage = [UIImage imageNamed:@"Frame-2.png"];
    } else if(_frameSelectSegment.selectedSegmentIndex == 2) {
        overlayImage = [UIImage imageNamed:@"Frame-3.png"];
    }
    
    [overlayLayer setContents:(id)[overlayImage CGImage]];
    overlayLayer.frame = CGRectMake(0, 0, size.width, size.height);
    [overlayLayer setMasksToBounds:YES];
    
    // 2 - set up the parent layer
    CALayer *parentLayer = [CALayer layer];
    CALayer *videoLayer = [CALayer layer];
    parentLayer.frame = CGRectMake(0, 0, size.width, size.height);
    videoLayer.frame = CGRectMake(0, 0, size.width, size.height);
    [parentLayer addSublayer:videoLayer];
    [parentLayer addSublayer:overlayLayer];
    
    // 3 - apply magic
    composition.animationTool = [AVVideoCompositionCoreAnimationTool
                                 videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
}

@end\
