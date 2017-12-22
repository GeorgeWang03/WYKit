//
//  WYVCExampleViewController.m
//  WYKit
//
//  Created by yingwang on 2017/6/13.
//  Copyright © 2017年 GeorgeWang03. All rights reserved.
//

//View

//Model

//ViewMode
#import "WYSearchFuzzyViewModel.h"

//Controller
#import "WYVCExampleViewController.h"
#import "WYImageSliderViewController.h"
#import "WYSearchListViewController.h"

//Other
#import "WYMarco.h"
#import "Masonry.h"

@interface WYVCExampleViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray<NSString *> *titles;

@end

@implementation WYVCExampleViewController
#pragma mark - Getter Setter

#pragma mark - Intial

#pragma mark - Lifecyle
- (void)loadView {
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    _tableView.tableFooterView = [[UIView alloc] init];
    [_tableView registerClass:[UITableViewCell class]
       forCellReuseIdentifier:@"cell"];
    
    self.view = [[UIView alloc] init];
    [self.view addSubview:_tableView];
    
    UIEdgeInsets padding = UIEdgeInsetsMake(0, 0, 0, 0);
    
    WEAK_SELF
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        STRONG_SELF
        make.left.equalTo(strongSelf.view.mas_left).with.offset(padding.left);
        make.right.equalTo(strongSelf.view.mas_right).with.offset(-padding.right);
        make.top.equalTo(strongSelf.view.mas_top).with.offset(padding.top);
        make.bottom.equalTo(strongSelf.view.mas_bottom).with.offset(-padding.bottom);
    }];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.titles = @[@"WYImageSliderViewController", @"WYSearchViewController"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)dealloc {
}

#pragma mark - table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.row) {
        case 0:
        {
            WYImageSliderViewController *vc = [[WYImageSliderViewController alloc] init];
            vc.imageURLs = @[@"http://p3.music.126.net/J9xewS5h-mZ63a3E-G7Jpw==/3287539774465863.jpg",
                             @"http://img4.duitang.com/uploads/item/201309/22/20130922233443_ws4H4.thumb.700_0.jpeg",
                             @"http://cn.toluna.com/dpolls_images/2016/07/18/3105ff14-c15b-4e84-91be-37a21f16ab3c_x400.jpg"];
            vc.titles = @[@"mickey_001", @"mickey_002", @"mickey_003"];
            vc.initialImageIndex = 0;
            
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 1:
        {
            WYSearchListViewController *lvc = [[WYSearchListViewController alloc] init];
            
            WYSearchPopularViewController *pvc = [[WYSearchPopularViewController alloc] initWithHistoryIdentifier:@"WYDemoSearchHistoryIdentifier"
                                                                                                           option:WYSearchPopularComponentOptionHistory];
            
            WYSearchFuzzyViewModel *fvm = [[WYSearchFuzzyViewModel alloc] init];
            WYSearchFuzzyViewController *fvc = [[WYSearchFuzzyViewController alloc] initWithViewModel:fvm];
            
            
            WYSearchViewController *svc = [[WYSearchViewController alloc] initWithChildViewController:lvc
                                                                                popularViewController:pvc
                                                                               tempraryViewController:fvc];
            svc.searchBar.style = WYSearchBarStyleWhite;
            
            [self.navigationController pushViewController:svc animated:YES];
        }
            break;
        default:
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}

#pragma mark - table view datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.titles.count;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    cell.textLabel.text = self.titles[indexPath.row];
    
    return cell;
    
}

@end
