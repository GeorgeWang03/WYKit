//
//  WYSearchFuzzyViewController.m
//  WYKit
//
//  Created by yingwang on 2017/7/11.
//  Copyright © 2017年 GeorgeWang03. All rights reserved.
//

#import "Masonry.h"
#import "WYSearchFuzzyViewController.h"

/**
 *  弱引用
 */
#define WEAK_SELF __weak typeof(self) weakSelf = self;

/**
 *  强引用
 */
#define STRONG_SELF __strong typeof(weakSelf) strongSelf = weakSelf;

@implementation WYSearchFuzzyItem

@end

@interface WYSearchFuzzyTableViewCell : UITableViewCell<UITextFieldDelegate>

@property (nonatomic, strong) UIImageView *searchIconView;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UILabel *subtitleLabel;

@end

@implementation WYSearchFuzzyTableViewCell
#pragma mark - Getter
- (UIImageView *)searchIconView {
    if (!_searchIconView) {
        _searchIconView = [[UIImageView alloc] init];
        _searchIconView.image = [UIImage imageNamed:@"ic_basic_search_blue"];
        _searchIconView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _searchIconView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = [UIColor darkGrayColor];
        _titleLabel.font = [UIFont systemFontOfSize:14.f];
    }
    return _titleLabel;
}

- (UILabel *)subtitleLabel {
    if (!_subtitleLabel) {
        _subtitleLabel = [[UILabel alloc] init];
        _subtitleLabel.textColor = [UIColor lightGrayColor];
        _subtitleLabel.font = [UIFont systemFontOfSize:14.f];
        _subtitleLabel.textAlignment = NSTextAlignmentRight;
    }
    return _subtitleLabel;
}

#pragma mark - initializer
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupSubviews];
    }
    return self;
}

- (void)setupSubviews {
    [self addSubview:self.searchIconView];
    [self addSubview:self.titleLabel];
    [self addSubview:self.subtitleLabel];
    
    UIEdgeInsets padding = UIEdgeInsetsMake(0, 15, 0, 0);
    
    WEAK_SELF
    [self.searchIconView mas_makeConstraints:^(MASConstraintMaker *make) {
        STRONG_SELF
        make.left.equalTo(strongSelf.mas_left).with.offset(padding.left);
        make.centerY.equalTo(strongSelf);
        make.height.equalTo(@(20));
        make.width.equalTo(@(20));
    }];
    
    padding = UIEdgeInsetsMake(0, 0, 0, 15);
    [self.subtitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        STRONG_SELF
        make.right.equalTo(strongSelf.mas_right).with.offset(-padding.right);
        make.centerY.equalTo(strongSelf.searchIconView);
    }];
    
    padding = UIEdgeInsetsMake(0, 8, 0, 8);
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        STRONG_SELF
        make.left.equalTo(strongSelf.searchIconView.mas_right).with.offset(padding.left);
        make.right.equalTo(strongSelf.subtitleLabel.mas_left).with.offset(-padding.right);
        make.centerY.equalTo(strongSelf.searchIconView);
    }];
}

@end

@interface WYSearchFuzzyViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;

@property (nonatomic, strong) id<WYSearchFuzzyViewProtocol> viewModel;

@end

@implementation WYSearchFuzzyViewController

- (UIActivityIndicatorView *)indicatorView {
    if (!_indicatorView) {
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _indicatorView.hidesWhenStopped = YES;
    }
    return _indicatorView;
}

- (instancetype)initWithViewModel:(id<WYSearchFuzzyViewProtocol>)viewModel {
    self = [super init];
    if (self) {
        self.viewModel = viewModel;
    }
    return self;
}

- (void)loadView {
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.estimatedSectionFooterHeight = 0;
    _tableView.estimatedSectionHeaderHeight = 0;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    _tableView.tableFooterView = [[UIView alloc] init];
    [_tableView registerClass:[WYSearchFuzzyTableViewCell class]
     forCellReuseIdentifier:@"cell"];
    
    self.view = [[UIView alloc] init];
    [self.view addSubview:_tableView];
    [self.view addSubview:self.indicatorView];
    
    self.view.backgroundColor = _tableView.backgroundColor;
    
    UIEdgeInsets padding = UIEdgeInsetsMake(0, 0, 0, 0);
    
    WEAK_SELF
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        STRONG_SELF
        make.left.equalTo(strongSelf.view.mas_left).with.offset(padding.left);
        make.right.equalTo(strongSelf.view.mas_right).with.offset(-padding.right);
        make.top.equalTo(strongSelf.view.mas_top).with.offset(padding.top);
        make.bottom.equalTo(strongSelf.view.mas_bottom).with.offset(-padding.bottom);
    }];
    
    [self.indicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        STRONG_SELF
        make.centerX.equalTo(strongSelf.view);
        make.top.equalTo(strongSelf.view.mas_top).with.offset(100);
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)reloadData {
    
    self.tableView.hidden = YES;
    [self.indicatorView startAnimating];
    
    WEAK_SELF
    [self.viewModel reloadDataWithComplete:^(BOOL success, NSError *error) {
       STRONG_SELF
        [strongSelf.indicatorView stopAnimating];
        if (success) {
            if (strongSelf.viewModel.items.count) {
                strongSelf.tableView.hidden = NO;
                [strongSelf.tableView reloadData];
            } else {
                
            }
        } else {
            
        }
    }];
}

#pragma mark - WYSearchViewControllerTemprary Delegate
- (void)wy_searchController:(WYSearchViewController *)searchController changeKeyword:(NSString *)keyword {
    
    self.viewModel.keywork = keyword;
    [self reloadData];
}

#pragma mark - table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.internalHandleItemSelected) {
        NSString *text = self.viewModel.items[indexPath.section].title;
        self.internalHandleItemSelected(text);
    }
    
    if (self.handleItemSelected) {
        self.handleItemSelected(indexPath.section);
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.8;
}

#pragma mark - table view datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return self.viewModel.items.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WYSearchFuzzyTableViewCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    WYSearchFuzzyItem *item = self.viewModel.items[indexPath.section];
    
    cell.titleLabel.text = item.title;
    cell.subtitleLabel.text = item.subtitle;
    
    return cell;
    
}

@end
