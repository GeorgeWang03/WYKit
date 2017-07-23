//
//  WYSearchListViewController.m
//  WYKit_Example
//
//  Created by yingwang on 2017/7/23.
//  Copyright © 2017年 GeorgeWang03. All rights reserved.
//


#import "WYSearchListViewController.h"

@interface WYSearchListViewController ()

@end

@implementation WYSearchListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor lightGrayColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - WYSearchViewControllerResultDelegate
- (void)wy_searchController:(WYSearchViewController *)searchController
  didStartSearchWithKeyword:(NSString *)keyword {
    
}

@end
