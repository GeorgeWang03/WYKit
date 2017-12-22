//
//  WYRootViewController.m
//  WYKit
//
//  Created by yingwang on 2017/6/13.
//  Copyright © 2017年 全国邮政电子商务运营中心. All rights reserved.
//
//

//View

//Model

//Controller
#import "WYRootViewController.h"
#import "WYVCExampleViewController.h"
#import "WYViewsExampleViewController.h"

//Other
#import "WYMarco.h"
#import "Masonry.h"

@interface WYRootViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray<NSString *> *titles;

@end

@implementation WYRootViewController
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
    self.titles = @[@"ViewsExample", @"ControllerExample"];
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
    
    UIViewController *vc;
    switch (indexPath.row) {
        case 0:
            vc = [[WYViewsExampleViewController alloc] init];
            break;
        case 1:
            vc = [[WYVCExampleViewController alloc] init];
            break;
            
        default:
            vc = [[UIViewController alloc] init];
            break;
    }
    
    [self.navigationController pushViewController:vc animated:YES];
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
