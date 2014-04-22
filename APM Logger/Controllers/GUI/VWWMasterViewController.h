//
//  ViewController.h
//  MasterDetailview
//
//  Created by Rasmus Styrk on 8/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VWWDetailViewController.h"
#import "VWWDetailTableViewController.h"

@interface VWWMasterViewController : UIViewController <VWWDetailViewControllerDelegate, VWWDetailTableViewControllerDelegate>
-(void)changeDetailView:(UIViewController*)detailController animated:(BOOL)animated;
-(void)hideMaster:(BOOL)shouldShow;
@end
