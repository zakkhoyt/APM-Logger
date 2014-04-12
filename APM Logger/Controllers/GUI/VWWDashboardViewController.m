//
//  VWWDashboardViewController.m
//  APM Logger
//
//  Created by Zakk Hoyt on 4/12/14.
//  Copyright (c) 2014 Zakk Hoyt. All rights reserved.
//

#import "VWWDashboardViewController.h"
#import "VWWDashboardCollectionViewCell.h"


typedef enum {
    VWWDashboardItemLogs = 0,
    VWWDashboardItemTunings,
    VWWDashboardItemVideos,
    VWWDashboardItemResources,
    VWWDashboardItemAbout,
} VWWDashboardItem;

@interface VWWDashboardViewController ()
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation VWWDashboardViewController

#pragma mark UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
    
    self.collectionView.contentInset = UIEdgeInsetsMake([UIApplication sharedApplication].statusBarFrame.size.height, 0, 0, 0);
    self.collectionView.alwaysBounceVertical = YES;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


#pragma mark UICollectionViewDatasource

- (NSInteger)collectionView:(UICollectionView *)cv numberOfItemsInSection:(NSInteger)section {
    if(section == 0){
        return 5;
    }
    return 0;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)cv {
    return 1;
}


//- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
//    UICollectionReusableView *view = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"View" forIndexPath:indexPath];
//    
//    if(indexPath.section == 0){
//    } else if(indexPath.section == 1){
//    }
//    
//    return view;
//}


- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    VWWDashboardCollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"VWWDashboardCollectionViewCell" forIndexPath:indexPath];
    
    if(indexPath.section == 0){
        if(indexPath.item == VWWDashboardItemLogs){
            cell.titleLabel.text = @"APM Logs";
        } else if(indexPath.item == VWWDashboardItemTunings){
            cell.titleLabel.text = @"Motor/Prop Balancing";
        } else if(indexPath.item == VWWDashboardItemVideos){
            cell.titleLabel.text = @"Videos";
        } else if(indexPath.item == VWWDashboardItemResources){
            cell.titleLabel.text = @"Resources";
        } else if(indexPath.item == VWWDashboardItemAbout){
            cell.titleLabel.text = @"About";
        }
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

}



@end
