//  MasterDetailview
//  Created by Zakk Hoyt
//  Copyright (c) 2014 Threefold photos. All rights reserved.




#import "VWWMasterViewController.h"
#import <QuartzCore/QuartzCore.h>

const CGFloat SMMasterViewControllerMasterWidth = 265;

@interface VWWMasterViewController () 
@property BOOL masterVisible;
@property (nonatomic, retain) UIView *masterView;
@property (nonatomic, retain) UIView *detailView;
@property (nonatomic, assign) UIViewController *masterController;
@property (nonatomic, assign) VWWDetailViewController *detailController;
@property (nonatomic, strong) UINavigationController *detailNavigationController;
@property (nonatomic) CGFloat firstX;
@property (nonatomic) CGFloat firstY;
@end

@implementation VWWMasterViewController


#pragma mark UIViewController
-(void)viewDidLoad{
    [super viewDidLoad];
    self.masterVisible = YES;
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
//    [self.view setSmileFonts];
    [self.view layoutSubviews];
}


#pragma mark Public methods

- (void)changeDetailView:(VWWDetailViewController*)detailViewController animated:(BOOL)animated{
    if([detailViewController isKindOfClass:self.detailController.class]){
        [self hideMaster:YES];
        return;
    }
    
    // Remove current detail view
    if(self.detailController){
        [self.detailController.view removeFromSuperview];
        [self.detailController removeFromParentViewController];
        self.detailController = nil;
    }
    if(self.detailNavigationController){
        [self.detailNavigationController.view removeFromSuperview];
        [self.detailNavigationController removeFromParentViewController];
        self.detailNavigationController = nil;
    }


    // Embed VC in a navigation controller. Also replace the back button with a toggle button.
    self.detailController = detailViewController;
    self.detailNavigationController = [[UINavigationController alloc]initWithRootViewController:self.detailController];
    self.detailController.navigationController = self.detailNavigationController;
    self.detailController.navigationItem.hidesBackButton = NO;

//    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"dash-icon"] style:UIBarButtonItemStylePlain target:self action:@selector(toggleButtonTouchUpInside:)];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks target:self action:@selector(toggleButtonTouchUpInside:)];
    [self.detailController.navigationItem setLeftBarButtonItem:doneButton animated:YES];

    // Setup view frame
    CGRect frameForView = self.view.frame;
    frameForView.origin.y = 0;
    UIView *view = self.detailController.view;
    CGRect offscreenLeftFrame = frameForView;
    offscreenLeftFrame.origin.x = offscreenLeftFrame.size.width;
    view.frame = offscreenLeftFrame;
    view.hidden = NO;
    view.alpha = 1.0;
    
    
    // Shadow
    self.detailNavigationController.view.layer.shadowOffset = CGSizeMake(-1, 1);
    self.detailNavigationController.view.layer.shadowRadius = 5;
    self.detailNavigationController.view.layer.shadowOpacity = 0.3;
    self.detailNavigationController.view.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.detailNavigationController.view.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.detailNavigationController.view.bounds].CGPath;
    
    
    
    
    // Add child view and animate in
    [self addChildViewController:self.detailNavigationController];
    [self.view addSubview:self.detailNavigationController.view];
    [self.detailNavigationController didMoveToParentViewController:self];
    
    [UIView animateWithDuration:0.5 delay:0.0 usingSpringWithDamping:0.7 initialSpringVelocity:1.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        view.frame = frameForView;
    } completion:^(BOOL finished) {
        self.masterVisible = NO;
        
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panGestureHandler:)];
        [self.detailNavigationController.view addGestureRecognizer:panGesture];
    }];

}

#pragma mark IBActions
-(void)toggleButtonTouchUpInside:(id)sender{
    [self hideMaster:self.masterVisible];
}


#pragma mark Private methods


-(void)panGestureHandler:(UIPanGestureRecognizer*)sender{
    
    [self.view bringSubviewToFront:[(UIPanGestureRecognizer*)sender view]];
    CGPoint translatedCenterPoint = [(UIPanGestureRecognizer*)sender translationInView:self.view];

    
    if ([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateBegan) {
        self.firstX = [[sender view] center].x;
        self.firstY = [[sender view] center].y;
        [self.detailController updateBlurredImageView];
    }
    
    translatedCenterPoint = CGPointMake(self.firstX+translatedCenterPoint.x, self.firstY);
    
    [[sender view] setCenter:translatedCenterPoint];

    CGFloat finalX = translatedCenterPoint.x;
    CGFloat finalY = self.firstY;

    // Stop panning off the left or right of the screen
    CGFloat leftLimit = self.view.center.x;
    CGFloat rightLimit = self.view.center.x + SMMasterViewControllerMasterWidth;
    CGFloat threshold = (leftLimit + rightLimit) / 2.0;
    float blurAlpha = (finalX - leftLimit) / threshold;
    self.detailController.blurredImageView.alpha = blurAlpha;


    if(finalX < leftLimit){
        finalX = leftLimit;
    } else if(finalX > rightLimit){
        finalX = rightLimit;
    }
    
    [[sender view] setCenter:CGPointMake(finalX, finalY)];
    
    if ([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateEnded) {

        if(finalX <= threshold){
            [self hideMaster:YES];
        } else if(finalX > threshold){
            [self hideMaster:NO];
        }
    }
}

-(void)hideMaster:(BOOL)shouldShow{
    if(shouldShow == NO){
        // Show master
        [self.detailController updateBlurredImageView];
        
        self.masterVisible = YES;
        CGRect masterShowingRect = self.view.frame;
        masterShowingRect.origin.x += SMMasterViewControllerMasterWidth;
        [UIView animateWithDuration:0.5 delay:0.0 usingSpringWithDamping:0.7 initialSpringVelocity:1.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.detailNavigationController.view.frame = masterShowingRect;
//            self.detailNavigationController.view.tintAdjustmentMode = UIViewTintAdjustmentModeDimmed;
            self.detailController.blurredImageView.alpha = 1.0;
        } completion:^(BOOL finished) {
            
        }];
    } else {
        // Hide Master
        self.masterVisible = NO;
        CGRect masterShowingRect = self.view.frame;
        [UIView animateWithDuration:0.5 delay:0.0 usingSpringWithDamping:0.7 initialSpringVelocity:1.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.detailNavigationController.view.frame = masterShowingRect;
//            self.detailNavigationController.view.tintAdjustmentMode = UIViewTintAdjustmentModeNormal;
            self.detailController.blurredImageView.alpha = 0;
        } completion:^(BOOL finished) {
            
        }];
    }
}

#pragma mark SMDetailViewControllerDelegate
-(void)detailViewControllerMasterButtonTouchUpInside:(VWWDetailViewController*)sender{
    [self hideMaster:self.masterVisible];
}


#pragma mark SMDetailTableViewControllerDelegate
-(void)detailTableViewControllerMasterButtonTouchUpInside:(VWWDetailTableViewController*)sender{
    [self hideMaster:self.masterVisible];
}

@end
