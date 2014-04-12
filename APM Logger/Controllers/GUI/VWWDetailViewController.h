//
//  DetailViewController.h
//  MasterDetailview
//
//  Created by Rasmus Styrk on 8/26/12.
//  Copyright (c) 2012 Styrk-IT. All rights reserved.
//

#import "VWWViewController.h"

@class VWWDetailViewController;


@protocol VWWDetailViewControllerDelegate <NSObject>
-(void)detailViewControllerMasterButtonTouchUpInside:(VWWDetailViewController*)sender;
@end

@interface VWWDetailViewController : VWWViewController
@property (nonatomic, strong) UINavigationController *navigationController;
@property (nonatomic, strong) UIImageView *blurredImageView;
-(void)updateBlurredImageView;
@property (nonatomic, weak) id <VWWDetailViewControllerDelegate> masterViewControllerDelegate;
@end
