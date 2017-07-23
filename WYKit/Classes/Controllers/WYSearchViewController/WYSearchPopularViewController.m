//
//  WYSearchPopularViewController.m
//  CPCS
//
//  Created by yingwang on 2017/6/24.
//  Copyright © 2017年 全国邮政电子商务运营中心. All rights reserved.
//
//  搜索控制器-热门搜索／历史搜索子控制器
//

//View

//Model

//Controller
#import "WYSearchViewController.h"
#import "WYSearchPopularViewController.h"

//Other
#import <Masonry/Masonry.h>

@interface WYSearchPopularCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UIImageView *iconImageView;

@end

@implementation WYSearchPopularCollectionViewCell

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupSubviews];
        [self setupObserver];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubviews];
        [self setupObserver];
    }
    return self;
}

- (void)dealloc {
    [self.iconImageView removeObserver:self forKeyPath:@"image"];
}

#pragma mark - Observer
- (void)setupObserver {
    [self.iconImageView addObserver:self
                         forKeyPath:@"image"
                            options:NSKeyValueObservingOptionNew
                            context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)context {
    
    if (object == self.iconImageView) {
        if ([keyPath isEqualToString:@"image"]) {
            if (self.iconImageView.image) {
                __weak WYSearchPopularCollectionViewCell *weakSelf = self;
                [self.iconImageView mas_updateConstraints:^(MASConstraintMaker *make) {
                    __strong WYSearchPopularCollectionViewCell *strongSelf = weakSelf;
                    make.width.equalTo(strongSelf.iconImageView.mas_height);
                }];
            } else {
                [self.iconImageView mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.width.equalTo(@(0.01));
                }];
            }
        }
    }
}

#pragma mark - Setup Subviews
- (void)setupSubviews {
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.font = [UIFont systemFontOfSize:12];
    titleLabel.textColor = [UIColor darkGrayColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    self.iconImageView = imageView;
    self.titleLabel = titleLabel;
    
    [self addSubview:titleLabel];
    [self addSubview:imageView];
    
    UIEdgeInsets padding = UIEdgeInsetsMake(5, 5, 5, 0);
    
    __weak WYSearchPopularCollectionViewCell *weakSelf = self;
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        __strong WYSearchPopularCollectionViewCell *strongSelf = weakSelf;
        make.left.equalTo(strongSelf.contentView.mas_left).with.offset(padding.left);
        make.top.equalTo(strongSelf.contentView.mas_top).with.offset(padding.top);
        make.bottom.equalTo(strongSelf.contentView.mas_bottom).with.offset(-padding.bottom);
//        make.width.equalTo(strongSelf.iconImageView.mas_height);
        make.width.equalTo(@(0.01));
    }];
    
    padding = UIEdgeInsetsMake(5, 5, 5, 5);
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        __strong WYSearchPopularCollectionViewCell *strongSelf = weakSelf;
        make.left.equalTo(strongSelf.contentView.mas_left).with.offset(padding.left);
        make.right.equalTo(strongSelf.contentView.mas_right).with.offset(-padding.right);
        make.top.equalTo(strongSelf.contentView.mas_top).with.offset(padding.top);
        make.bottom.equalTo(strongSelf.contentView.mas_bottom).with.offset(-padding.bottom);
    }];
    
}

@end

@interface WYSearchPopularViewCollectionHeaderView : UICollectionReusableView

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UIButton *cleanButton;

@end

@implementation WYSearchPopularViewCollectionHeaderView

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:14];
    }
    return _titleLabel;
}

- (UIButton *)cleanButton {
    if (!_cleanButton) {
        _cleanButton = [[UIButton alloc] init];
        _cleanButton.hidden = YES;
        [_cleanButton setImage:[UIImage imageNamed:@"ic_basic_delete"]
                      forState:UIControlStateNormal];
    }
    return _cleanButton;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubviews];
    }
    return self;
}

- (void)setupSubviews {
    
    [self addSubview:self.titleLabel];
    [self addSubview:self.cleanButton];
    self.backgroundColor = [UIColor whiteColor];
    
    UIEdgeInsets padding = UIEdgeInsetsMake(0, 0, 0, 5);
    
    __weak WYSearchPopularViewCollectionHeaderView *weakSelf = self;
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        __strong WYSearchPopularViewCollectionHeaderView *strongSelf = weakSelf;
        make.left.equalTo(strongSelf.mas_left).with.offset(padding.left);
        make.right.equalTo(strongSelf.cleanButton.mas_right).with.offset(-padding.right);
        make.top.equalTo(strongSelf.mas_top).with.offset(padding.top);
        make.bottom.equalTo(strongSelf.mas_bottom).with.offset(-padding.bottom);
    }];
    
    padding = UIEdgeInsetsMake(0, 0, 0, 0);
    [self.cleanButton mas_makeConstraints:^(MASConstraintMaker *make) {
        __strong UIView *strongSelf = weakSelf;
        make.width.equalTo(strongSelf.mas_height);
        make.right.equalTo(strongSelf.mas_right).with.offset(-padding.right);
        make.top.equalTo(strongSelf.mas_top).with.offset(padding.top);
        make.bottom.equalTo(strongSelf.mas_bottom).with.offset(-padding.bottom);
    }];
}

@end


@interface WYSearchPopularViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, copy) NSString *historySearchKey;
@property (nonatomic) WYSearchPopularComponentOption componentOption;

@property (nonatomic, strong) NSMutableArray *sectionOptions;

@property (nonatomic, strong) NSMutableArray *hotSearchKeywords;
@property (nonatomic, strong) NSMutableArray *historyKeywords;

@end

static NSUInteger kMaxHistoryKeywordCount = 10;
static NSUInteger kMaxKeywordLength = 10;

static NSString *WYSearchPopularViewControllerDefaultHistoryKey = @"WYSearchPopularViewControllerDefaultHistoryKey";

@implementation WYSearchPopularViewController
#pragma mark - Getter Setter
- (NSMutableArray *)historyKeywords {
    if (!_historyKeywords) {
        @synchronized (self) {
            _historyKeywords = [[NSUserDefaults standardUserDefaults] objectForKey:self.historySearchKey];
            _historyKeywords = [NSMutableArray arrayWithArray:_historyKeywords];
            
            if (!_historyKeywords) {
                _historyKeywords = [NSMutableArray array];
                [[NSUserDefaults standardUserDefaults] setObject:_historyKeywords
                                                          forKey:self.historySearchKey];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
        }
    }
    return _historyKeywords;
}

- (void)addHistoryKeyword:(NSString *)keyword {
    @synchronized (self) {
//        NSMutableArray *record = [[NSUserDefaults standardUserDefaults] objectForKey:self.historySearchKey];
        // delete equal keyword from records
        __block NSInteger index = -1;
        [self.historyKeywords enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isEqualToString:keyword]) {
                index = idx;
            }
        }];
        
        if (index > -1)
            [self.historyKeywords removeObjectAtIndex:index];
        // add new keyword
        [self.historyKeywords insertObject:keyword atIndex:0];
        
        if (self.historyKeywords.count > kMaxHistoryKeywordCount) {
            [self.historyKeywords removeObjectsInRange:NSMakeRange(kMaxHistoryKeywordCount, self.historyKeywords.count-kMaxHistoryKeywordCount)];
        }
        
//        [[NSUserDefaults standardUserDefaults] setObject:self.historyKeywords
//                                                  forKey:self.historySearchKey];
//        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

#pragma mark - Intial
- (instancetype)init {
    return [self initWithOption:WYSearchPopularComponentOptionHistory];
}

- (instancetype)initWithOption:(WYSearchPopularComponentOption)option {
    return [self initWithHistoryIdentifier:WYSearchPopularViewControllerDefaultHistoryKey
                             option:option];
}

- (instancetype)initWithHistoryIdentifier:(NSString *)historyIdentifier
                                   option:(WYSearchPopularComponentOption)option {
    self = [super init];
    if (self) {
        self.historySearchKey = historyIdentifier;
        self.componentOption = option;
        
        self.sectionOptions = [NSMutableArray array];
        if (option & WYSearchPopularComponentOptionHot)
            [self.sectionOptions addObject:@(WYSearchPopularComponentOptionHot)];
        if (option & WYSearchPopularComponentOptionHistory)
            [self.sectionOptions addObject:@(WYSearchPopularComponentOptionHistory)];
    }
    return self;
}

#pragma mark - Lifecyle
- (void)loadView {
    self.view = [[UIView alloc] init];
    self.view.backgroundColor = [UIColor whiteColor];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing = 1;
    layout.minimumInteritemSpacing = 1;
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.backgroundColor = [UIColor whiteColor];
    
    self.collectionView = collectionView;
    
    [collectionView registerClass:[WYSearchPopularCollectionViewCell class]
       forCellWithReuseIdentifier:@"Cell"];
    [collectionView registerClass:[WYSearchPopularViewCollectionHeaderView class]
       forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
              withReuseIdentifier:@"HeaderView"];
    [collectionView registerClass:[UICollectionReusableView class]
       forSupplementaryViewOfKind:UICollectionElementKindSectionFooter
              withReuseIdentifier:@"FooterView"];
    
    [self.view addSubview:collectionView];
    
    UIEdgeInsets padding = UIEdgeInsetsMake(15, 25, 15, 25);
    
    __weak UIViewController *weakSelf = self;
    [collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        __strong UIViewController *strongSelf = weakSelf;
        make.left.equalTo(strongSelf.view.mas_left).with.offset(padding.left);
        make.right.equalTo(strongSelf.view.mas_right).with.offset(-padding.right);
        make.top.equalTo(strongSelf.view.mas_top).with.offset(padding.top);
        make.bottom.equalTo(strongSelf.view.mas_bottom).with.offset(-padding.bottom);
    }];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
    [[NSUserDefaults standardUserDefaults] setObject:self.historyKeywords
                                              forKey:self.historySearchKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Event
- (void)handleCleanButtonAction:(UIButton *)sender {
    [self.historyKeywords removeAllObjects];
    [[NSUserDefaults standardUserDefaults] setObject:self.historyKeywords
                                              forKey:self.historySearchKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self.collectionView reloadData];
}

#pragma mark - Notification

#pragma mark - WYSearchViewControllerPopular Delegate
- (void)wy_searchControllerWillShowPopularView:(WYSearchViewController *)searchController {
    [self.collectionView reloadData];
}

- (void)wy_searchController:(WYSearchViewController *)searchController
  didStartSearchWithKeyword:(NSString *)keyword {
    [self addHistoryKeyword:keyword];
}

#pragma mark - UICollectionView Delegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSUInteger itemCount = 0;
    
    WYSearchPopularComponentOption option;
    option = [self.sectionOptions[section] unsignedIntegerValue];
    switch (option) {
        case WYSearchPopularComponentOptionHot:
            itemCount = self.hotSearchKeywords.count;
            break;
        case WYSearchPopularComponentOptionHistory:
            itemCount = self.historyKeywords.count;
            break;
        default:
            break;
    }
    
    return itemCount;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.sectionOptions.count;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    WYSearchPopularComponentOption option;
    option = [self.sectionOptions[indexPath.section] unsignedIntegerValue];
    
    if (option == WYSearchPopularComponentOptionHistory) {
        if (self.quickSearchForKeyword) {
            NSString *keyword = self.historyKeywords[indexPath.row];
            [self addHistoryKeyword:keyword];
            self.quickSearchForKeyword(keyword);
        }
    }
}

#pragma mark - UICollectionView DelegateLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *keyword;
    WYSearchPopularComponentOption option;
    option = [self.sectionOptions[indexPath.section] unsignedIntegerValue];
    switch (option) {
        case WYSearchPopularComponentOptionHot:
            keyword = @"";
            break;
        case WYSearchPopularComponentOptionHistory:
            keyword = self.historyKeywords[indexPath.row];
            break;
        default:
            break;
    }
    
    CGSize size;
    CGFloat width = 12*MIN(kMaxKeywordLength, keyword.length)+12;
    size = CGSizeMake(width, 30);
    
    return size;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    
    CGFloat boundsWidth = CGRectGetWidth(self.view.bounds);
    return CGSizeMake(boundsWidth, 30);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    CGFloat boundsWidth = CGRectGetWidth(self.view.bounds);
    return CGSizeMake(boundsWidth, 8);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 8;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 8;
}

#pragma mark - UICollectionView DataSource
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    WYSearchPopularCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    
    NSString *keyword;
    WYSearchPopularComponentOption option;
    option = [self.sectionOptions[indexPath.section] unsignedIntegerValue];
    switch (option) {
        case WYSearchPopularComponentOptionHot:
            keyword = @"";
            break;
        case WYSearchPopularComponentOptionHistory:
            keyword = self.historyKeywords[indexPath.row];
            break;
        default:
            break;
    }
    
    cell.iconImageView.image = indexPath.item%2 ? [UIImage imageNamed:@"ic_basic_search_blue"] : nil;
    cell.titleLabel.text = keyword.length <= kMaxKeywordLength ? keyword : [keyword substringWithRange:NSMakeRange(0, kMaxKeywordLength)];
    
    cell.layer.cornerRadius = 4;
    cell.layer.masksToBounds = YES;
    cell.contentView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:0.8];
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        WYSearchPopularViewCollectionHeaderView *headerView =
        [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                           withReuseIdentifier:@"HeaderView"
                                                  forIndexPath:indexPath];
        
        WYSearchPopularComponentOption option;
        option = [self.sectionOptions[indexPath.section] unsignedIntegerValue];
        switch (option) {
            case WYSearchPopularComponentOptionHot:
                headerView.titleLabel.text = @"热门搜索";
                headerView.cleanButton.hidden = YES;
                break;
            case WYSearchPopularComponentOptionHistory:
                headerView.titleLabel.text = @"历史搜索";
                headerView.cleanButton.hidden = NO;
                [headerView.cleanButton addTarget:self
                                           action:@selector(handleCleanButtonAction:)
                                 forControlEvents:UIControlEventTouchUpInside];
                break;
            default:
                break;
        }
        return headerView;
    }
    
    UICollectionReusableView *view = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                                                                        withReuseIdentifier:@"FooterView"
                                                                               forIndexPath:indexPath];
    return view;
}

#pragma mark - Other

@end
