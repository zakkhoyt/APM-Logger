//
//  SMDetailTableViewController.m
//  Radius-iOS
//
//  Created by Zakk Hoyt on 4/4/14.
//  Copyright (c) 2014 Zakk Hoyt. All rights reserved.
//

#import "VWWDetailTableViewController.h"
#import "VWWMasterViewController.h"
//#import "GPUImage.h"


@interface VWWDetailTableViewController ()
//@property (nonatomic, strong) GPUImageiOSBlurFilter *blurFilter;
//@property (nonatomic, strong) GPUImageSketchFilter *sketchFilter;
//@property (nonatomic, strong) GPUImageGrayscaleFilter *grayscaleFilter;

@end

@implementation VWWDetailTableViewController

-(void)viewDidLoad{
    [super viewDidLoad];
//    self.blurFilter = [[GPUImageiOSBlurFilter alloc]init];
//    self.sketchFilter = [[GPUImageSketchFilter alloc] init];
//    self.grayscaleFilter = [[GPUImageGrayscaleFilter alloc]init];
//    self.blurredImageView = [[UIImageView alloc]initWithFrame:self.view.bounds];
//    self.blurredImageView.backgroundColor = [UIColor radiusGreenColor];
//    self.blurredImageView.alpha = 0.0;
    
    [self.view addSubview:self.blurredImageView];
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
//    [self.view setSmileFonts];
    [self.view layoutSubviews];
}

-(void)updateBlurredImageView{
    UIGraphicsBeginImageContext(self.view.bounds.size);
    [self.view drawViewHierarchyInRect:self.view.bounds afterScreenUpdates:YES];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.blurredImageView.image = image;
//    if([SMUserDefaults detailViewEffectType] == 0){
//        self.blurredImageView.image = [self.blurFilter imageByFilteringImage:image];
//    } else if([SMUserDefaults detailViewEffectType] == 1){
//        self.blurredImageView.image = [self.sketchFilter imageByFilteringImage:image];
//    } else if([SMUserDefaults detailViewEffectType] == 2){
//        self.blurredImageView.image = [self.grayscaleFilter imageByFilteringImage:image];
//    }
}

@end
