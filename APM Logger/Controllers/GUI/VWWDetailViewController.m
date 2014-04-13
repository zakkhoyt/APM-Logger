//
//  DetailViewController.m
//  MasterDetailview
//
//  Created by Rasmus Styrk on 8/26/12.
//  Copyright (c) 2012 Styrk-IT. All rights reserved.
//

#import "VWWDetailViewController.h"
#import "VWWMasterViewController.h"
#import "GPUImage.h"

@interface VWWDetailViewController ()
//@property (nonatomic, strong) GPUImageiOSBlurFilter *blurFilter;
//@property (nonatomic, strong) GPUImageSketchFilter *sketchFilter;
@property (nonatomic, strong) GPUImageGrayscaleFilter *grayscaleFilter;
@end



@implementation VWWDetailViewController

-(void)viewDidLoad{
    [super viewDidLoad];
//    self.blurFilter = [[GPUImageiOSBlurFilter alloc]init];
//    self.sketchFilter = [[GPUImageSketchFilter alloc] init];
    self.grayscaleFilter = [[GPUImageGrayscaleFilter alloc]init];
//    self.blurredImageView = [[UIImageView alloc]initWithFrame:self.view.bounds];
    self.blurredImageView.alpha = 0.0;

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
        self.blurredImageView.image = [self.grayscaleFilter imageByFilteringImage:image];
//    }
    
}



@end

