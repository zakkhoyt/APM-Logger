//
//  SMDetailTableViewController.h
//  Radius-iOS
//
//  Created by Zakk Hoyt on 4/4/14.
//  Copyright (c) 2014 Zakk Hoyt. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VWWDetailTableViewController;

@protocol VWWDetailTableViewControllerDelegate <NSObject>
-(void)detailTableViewControllerMasterButtonTouchUpInside:(VWWDetailTableViewController*)sender;
@end

@interface VWWDetailTableViewController : UITableViewController
@property (nonatomic, strong) UINavigationController *navigationController;
@property (nonatomic, strong) UIImageView *blurredImageView;
-(void)updateBlurredImageView;

@property (nonatomic, weak) id <VWWDetailTableViewControllerDelegate> masterViewControllerDelegate;
@end
