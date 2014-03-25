//
//  APM Logger
//
//  Created by Zakk Hoyt 2014
//  Copyright (c) 2014 Zakk Hoyt.
//

#import "VWWAddAnimationViewController.h"

@interface VWWAddAnimationViewController ()
@property (weak, nonatomic) IBOutlet UISegmentedControl *animationSelectSegment;
@end

@implementation VWWAddAnimationViewController

- (IBAction)loadAsset:(id)sender {
    [self startMediaBrowserFromViewController:self usingDelegate:self];
}

- (IBAction)generateOutput:(id)sender {
  [self videoOutput];
}

- (void)applyVideoEffectsToComposition:(AVMutableVideoComposition *)composition size:(CGSize)size
{
    UIImage *animationImage = [UIImage imageNamed:@"star.png"];;
    CALayer *overlayLayer1 = [CALayer layer];
    [overlayLayer1 setContents:(id)[animationImage CGImage]];
    overlayLayer1.frame = CGRectMake(size.width/2-64, size.height/2 + 200, 128, 128);
    [overlayLayer1 setMasksToBounds:YES];
    
    CALayer *overlayLayer2 = [CALayer layer];
    [overlayLayer2 setContents:(id)[animationImage CGImage]];
    overlayLayer2.frame = CGRectMake(size.width/2-64, size.height/2 - 200, 128, 128);
    [overlayLayer2 setMasksToBounds:YES];
    
    // Rotate
    if (_animationSelectSegment.selectedSegmentIndex == 0) {
        CABasicAnimation *animation =
        [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
        animation.duration=2.0;
        animation.repeatCount=5;
        animation.autoreverses=YES;
        // rotate from 0 to 360
        animation.fromValue=[NSNumber numberWithFloat:0.0];
        animation.toValue=[NSNumber numberWithFloat:(2.0 * M_PI)];
        animation.beginTime = AVCoreAnimationBeginTimeAtZero;
        [overlayLayer1 addAnimation:animation forKey:@"rotation"];
        
        animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
        animation.duration=2.0;
        animation.repeatCount=5;
        animation.autoreverses=YES;
        // rotate from 0 to 360
        animation.fromValue=[NSNumber numberWithFloat:0.0];
        animation.toValue=[NSNumber numberWithFloat:(2.0 * M_PI)];
        animation.beginTime = AVCoreAnimationBeginTimeAtZero;
        [overlayLayer2 addAnimation:animation forKey:@"rotation"];
        
        // Fade
    } else if(_animationSelectSegment.selectedSegmentIndex == 1) {
        CABasicAnimation *animation
        =[CABasicAnimation animationWithKeyPath:@"opacity"];
        animation.duration=3.0;
        animation.repeatCount=5;
        animation.autoreverses=YES;
        // animate from fully visible to invisible
        animation.fromValue=[NSNumber numberWithFloat:1.0];
        animation.toValue=[NSNumber numberWithFloat:0.0];
        animation.beginTime = AVCoreAnimationBeginTimeAtZero;
        [overlayLayer1 addAnimation:animation forKey:@"animateOpacity"];
        
        animation=[CABasicAnimation animationWithKeyPath:@"opacity"];
        animation.duration=3.0;
        animation.repeatCount=5;
        animation.autoreverses=YES;
        // animate from invisible to fully visible
        animation.fromValue=[NSNumber numberWithFloat:1.0];
        animation.toValue=[NSNumber numberWithFloat:0.0];
        animation.beginTime = AVCoreAnimationBeginTimeAtZero;
        [overlayLayer2 addAnimation:animation forKey:@"animateOpacity"];
        
        // Twinkle
    } else if(_animationSelectSegment.selectedSegmentIndex == 2) {
        CABasicAnimation *animation =
        [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        animation.duration=0.5;
        animation.repeatCount=10;
        animation.autoreverses=YES;
        // animate from half size to full size
        animation.fromValue=[NSNumber numberWithFloat:0.5];
        animation.toValue=[NSNumber numberWithFloat:1.0];
        animation.beginTime = AVCoreAnimationBeginTimeAtZero;
        [overlayLayer1 addAnimation:animation forKey:@"scale"];
        
        animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        animation.duration=1.0;
        animation.repeatCount=5;
        animation.autoreverses=YES;
        // animate from half size to full size
        animation.fromValue=[NSNumber numberWithFloat:0.5];
        animation.toValue=[NSNumber numberWithFloat:1.0];
        animation.beginTime = AVCoreAnimationBeginTimeAtZero;
        [overlayLayer2 addAnimation:animation forKey:@"scale"];
    }
    
    CALayer *parentLayer = [CALayer layer];
    CALayer *videoLayer = [CALayer layer];
    parentLayer.frame = CGRectMake(0, 0, size.width, size.height);
    videoLayer.frame = CGRectMake(0, 0, size.width, size.height);
    [parentLayer addSublayer:videoLayer];
    [parentLayer addSublayer:overlayLayer1];
    [parentLayer addSublayer:overlayLayer2];
    
    composition.animationTool = [AVVideoCompositionCoreAnimationTool
                                 videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];

}

@end
