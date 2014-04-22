//
//  VWWPRVideosViewController.m
//  RCTools
//
//  Created by Zakk Hoyt on 4/21/14.
//  Copyright (c) 2014 Zakk Hoyt. All rights reserved.
//

#import "VWWPRVideosViewController.h"

@implementation VWWPRVideosViewController



#pragma mark UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"VIDEO (Post Render)";
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addButtonTouchUpInside:)];
    [self.navigationItem setRightBarButtonItem:addButton animated:NO];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
//}


@end
