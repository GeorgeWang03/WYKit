//
//  WYSegmentView.m
//  WYKit
//
//  Created by yingwang on 2017/6/28.
//  Copyright © 2017年 GeorgeWang03. All rights reserved.
//
//  按钮选择视图
//

#import "WYSegmentView.h"
#import <Masonry/Masonry.h>

/**
 *  弱引用
 */
#define WEAK_SELF __weak typeof(self) weakSelf = self;

/**
 *  强引用
 */
#define STRONG_SELF __strong typeof(weakSelf) strongSelf = weakSelf;

static CGFloat defaultSegmentorFontSize = 14;

@interface WYSegmentCollectionViewCell : UICollectionViewCell

@property (nonatomic) UILabel *titleLabel;

@end

@implementation WYSegmentCollectionViewCell

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.backgroundColor = [UIColor whiteColor];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont systemFontOfSize:defaultSegmentorFontSize];
    }
    return _titleLabel;
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
    
    UIEdgeInsets padding = UIEdgeInsetsMake(0, 0, 0, 0);
    
    WEAK_SELF
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        STRONG_SELF
        make.left.equalTo(strongSelf.mas_left).with.offset(padding.left);
        make.right.equalTo(strongSelf.mas_right).with.offset(-padding.right);
        make.top.equalTo(strongSelf.mas_top).with.offset(padding.top);
        make.bottom.equalTo(strongSelf.mas_bottom).with.offset(-padding.bottom);
    }];
}

@end

@interface WYSegmentView () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) UIView *decoratedLine;

@property (nonatomic) NSUInteger currentSelectedIndex;

@end

@implementation WYSegmentView
#pragma mark - Getter Setter
- (UIColor *)highlightedColor {
    if (!_highlightedColor) {
        _highlightedColor = [UIColor blackColor];
    }
    return _highlightedColor;
}

- (UIColor *)normalColor {
    if (!_normalColor) {
        _normalColor = [UIColor lightGrayColor];
    }
    return _normalColor;
}

- (UIView *)decoratedLine {
    if (!_decoratedLine) {
        _decoratedLine = [[UIView alloc] init];
    }
    return _decoratedLine;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
        
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        collectionView.delegate = self;
        collectionView.dataSource = self;
        collectionView.alwaysBounceHorizontal = YES;
        collectionView.showsVerticalScrollIndicator = NO;
        collectionView.showsHorizontalScrollIndicator = NO;
        
        [collectionView registerClass:[WYSegmentCollectionViewCell class]
           forCellWithReuseIdentifier:@"Cell"];
        
        _collectionView = collectionView;
    }
    return _collectionView;
}

#pragma mark - Intial
- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupSubviews];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubviews];
    }
    return self;
}

#pragma mark - Setup Subviews
- (void)setupSubviews {
    
    [self addSubview:self.collectionView];
    
    UIEdgeInsets padding = UIEdgeInsetsMake(0, 0, 0, 0);
    
    WEAK_SELF
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        STRONG_SELF
        make.left.equalTo(strongSelf.mas_left).with.offset(padding.left);
        make.right.equalTo(strongSelf.mas_right).with.offset(-padding.right);
        make.top.equalTo(strongSelf.mas_top).with.offset(padding.top);
        make.bottom.equalTo(strongSelf.mas_bottom).with.offset(-padding.bottom);
    }];
    
    [self.collectionView addSubview:self.decoratedLine];
    
//    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
//        STRONG_SELF
//        make.height.equalTo(@(2));
//        make.width.equalTo(@(width));
//        make.left.equalTo(@(centerY));
//        make.bottom.equalTo(strongSelf.collectionView.mas_bottom).with.offset(0);
//    }];
}

- (void)moveDecoratedLineToItemAtIndex:(NSUInteger)index animated:(BOOL)animated {
    
    if (index >= self.titles.count) return;
    self.currentSelectedIndex = index;
    
    __block CGFloat width = 10;
    __block CGFloat centerX = 0;
    [self.titles enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGFloat boundsWidth = 16 + obj.length*defaultSegmentorFontSize;
        boundsWidth = MAX(70, boundsWidth);
        if (idx < index) {
            centerX += boundsWidth;
        } else {
            width = boundsWidth;
//            centerX += boundsWidth/2;
            *stop = YES;
        }
    }];
    
    CGFloat boundsHeight = CGRectGetHeight(self.bounds) - 2;
    self.decoratedLine.hidden = (boundsHeight <= 0);
    
    if (boundsHeight > 0) {
        WEAK_SELF
        [self.decoratedLine mas_remakeConstraints:^(MASConstraintMaker *make) {
            STRONG_SELF
            make.height.equalTo(@(2));
            make.width.equalTo(@(width));
            make.left.equalTo(strongSelf.collectionView.mas_left).with.offset(centerX);
            make.top.equalTo(strongSelf.collectionView.mas_top).with.offset(boundsHeight);
        }];
    }
    
    if (CGRectGetWidth(self.decoratedLine.bounds) > 0) {
        [UIView animateWithDuration:0.6
                         animations:^{
                             //                         self.decoratedLine.frame = CGRectMake(centerX, centerY, width, 2);
                             [self.collectionView layoutIfNeeded];
                         }];
    } else {
        [self.collectionView layoutIfNeeded];
    }
    
}

#pragma mark - Event
- (void)reloadData {
    self.decoratedLine.backgroundColor = self.highlightedColor;
    self.collectionView.backgroundColor = self.backgroundColor;
    [self.collectionView reloadData];
}

#pragma mark - Layout
- (void)layoutSubviews {
    [super layoutSubviews];

    [self moveDecoratedLineToItemAtIndex:self.currentSelectedIndex animated:NO];
}

#pragma mark - UICollectionView Delegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.titles.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.item == self.currentSelectedIndex) return;
    [self moveDecoratedLineToItemAtIndex:indexPath.item animated:YES];
    [collectionView reloadData];
    
    if (self.handleSelectedItemAction) {
        self.handleSelectedItemAction(indexPath.item);
    }
}

#pragma mark - UICollectionView DelegateLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *title = self.titles[indexPath.item];
    
    CGSize size;
    CGFloat boundsHeight = CGRectGetHeight(self.bounds);
    CGFloat boundsWidth = 16 + title.length*defaultSegmentorFontSize;
    boundsWidth = MAX(70, boundsWidth);
    
    size = CGSizeMake(boundsWidth, boundsHeight);
    
    return size;
}
//
//- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
//    return 1;
//}
//
//- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
//    return 1;
//}

#pragma mark - UICollectionView DataSource
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    WYSegmentCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    
    cell.titleLabel.text = self.titles[indexPath.item];
    
    if (indexPath.item == self.currentSelectedIndex) {
        cell.titleLabel.textColor = self.highlightedColor;
    } else {
        cell.titleLabel.textColor = self.normalColor;
    }
    
    return cell;
}
#pragma mark - Other

@end
