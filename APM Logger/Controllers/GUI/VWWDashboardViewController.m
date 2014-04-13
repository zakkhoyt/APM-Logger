//
//  VWWDashboardViewController.m
//  APM Logger
//
//  Created by Zakk Hoyt on 4/12/14.
//  Copyright (c) 2014 Zakk Hoyt. All rights reserved.
//

#import "VWWDashboardViewController.h"
#import "VWWDashboardCollectionViewCell.h"

// View Controllers
#import "VWWLogsViewController.h"
#import "VWWTuningsViewController.h"
#import "VWWVideosViewController.h"
#import "VWWHelpViewController.h"
#import "VWWResourcesViewController.h"
#import "VWWAboutViewController.h"

typedef enum{
  VWWDashboardSectionMain = 0,
} VWWDashboardSection;

typedef enum {
    VWWDashboardItemLogs = 0,
    VWWDashboardItemTunings,
    VWWDashboardItemVideos,
    VWWDashboardItemHelp,
    VWWDashboardItemResources,
    VWWDashboardItemAbout,
} VWWDashboardItem;

@interface VWWDashboardViewController ()
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) VWWLogsViewController *logsViewController;
@property (nonatomic, strong) VWWTuningsViewController *tuningsViewController;
@property (nonatomic, strong) VWWVideosViewController *videosViewController;
@property (nonatomic, strong) VWWHelpViewController *helpViewController;
@property (nonatomic, strong) VWWResourcesViewController *resourcesViewController;
@property (nonatomic, strong) VWWAboutViewController *aboutViewController;
@property (nonatomic) NSUInteger selectedCellIndex;
@end

@implementation VWWDashboardViewController

#pragma mark UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.collectionView.contentInset = UIEdgeInsetsMake([UIApplication sharedApplication].statusBarFrame.size.height, 0, 0, 0);
    self.collectionView.alwaysBounceVertical = YES;
    
    // Default view controller
    self.logsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"VWWLogsViewController"];
    self.logsViewController.masterViewControllerDelegate = self;
    [self changeDetailView:self.logsViewController animated:NO];
    self.selectedCellIndex = 0;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
    
    [self.collectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] animated:NO scrollPosition:UICollectionViewScrollPositionNone];

}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
//}



#pragma mark Private methods


#pragma mark UICollectionViewDatasource

- (NSInteger)collectionView:(UICollectionView *)cv numberOfItemsInSection:(NSInteger)section {
    if(section == VWWDashboardSectionMain){
        return 6;
    }
    return 0;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)cv {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    VWWDashboardCollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"VWWDashboardCollectionViewCell" forIndexPath:indexPath];
    if(indexPath.section == VWWDashboardSectionMain){
        if(indexPath.item == VWWDashboardItemLogs){
            cell.titleLabel.text = @"APM Logs";
        } else if(indexPath.item == VWWDashboardItemTunings){
            cell.titleLabel.text = @"Motor/Prop Balancing";
        } else if(indexPath.item == VWWDashboardItemVideos){
            cell.titleLabel.text = @"Flight Videos";
        } else if(indexPath.item == VWWDashboardItemHelp){
            cell.titleLabel.text = @"Help";
        } else if(indexPath.item == VWWDashboardItemResources){
            cell.titleLabel.text = @"R.C. Resources";
        } else if(indexPath.item == VWWDashboardItemAbout){
            cell.titleLabel.text = @"About this App";
        }
    }
    
    // Selected
    if(indexPath.item == self.selectedCellIndex){
        cell.selected = YES;
    } else {
        cell.selected = NO;
    }
    return cell;
}



- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsZero;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return  CGSizeMake(320, 44);
}


#pragma mark UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)cv didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if(indexPath.section == 0){
        if(indexPath.item == VWWDashboardItemLogs){
            self.logsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"VWWLogsViewController"];
            self.logsViewController.masterViewControllerDelegate = self;
            [self changeDetailView:self.logsViewController animated:YES];
        } else if(indexPath.item == VWWDashboardItemTunings){
            self.tuningsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"VWWTuningsViewController"];
            self.tuningsViewController.masterViewControllerDelegate = self;
            [self changeDetailView:self.tuningsViewController animated:YES];
        } else if(indexPath.item == VWWDashboardItemVideos){
            self.videosViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"VWWVideosViewController"];
            self.videosViewController.masterViewControllerDelegate = self;
            [self changeDetailView:self.videosViewController animated:YES];
        } else if(indexPath.item == VWWDashboardItemHelp){
            self.helpViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"VWWHelpViewController"];
            self.helpViewController.masterViewControllerDelegate = self;
            [self changeDetailView:self.helpViewController animated:YES];
        } else if(indexPath.item == VWWDashboardItemResources){
            self.resourcesViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"VWWResourcesViewController"];
            self.resourcesViewController.masterViewControllerDelegate = self;
            [self changeDetailView:self.resourcesViewController animated:YES];
        } else if(indexPath.item == VWWDashboardItemAbout){
            self.aboutViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"VWWAboutViewController"];
            self.aboutViewController.masterViewControllerDelegate = self;
            [self changeDetailView:self.aboutViewController animated:YES];

        }
    }
}



@end
