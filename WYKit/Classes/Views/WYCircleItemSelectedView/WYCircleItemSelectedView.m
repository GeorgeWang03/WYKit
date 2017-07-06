//
//  WYCircleItemSelectedView.m
//  WYKit
//
//  Created by yingwang on 2016/11/24.
//  Copyright © 2016年 yingwang. All rights reserved.
//

#import "WYMarco.h"
#import "Masonry.h"
#import "WYCircleItemSelectedView.h"

NSString * const kWYCircleItemSelectedViewCellSelectedNotificationName = @"kWYCircleItemSelectedViewCellSelectedNotificationName";
NSString * const kWYCircleItemSelectedViewCellNotifyInfoIndexPathKey = @"kWYCircleItemSelectedViewCellNotifyInfoIndexPathKey";

@interface WYCircleItemSelectedCell : UICollectionViewCell

@property (nonatomic, assign) CGFloat fontSize;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UIImageView *icon;

@property (nonatomic, strong) NSString *selectedImageName;
@property (nonatomic, strong) NSString *deselectedImageName;

@end

@implementation WYCircleItemSelectedCell

- (UILabel *)label {
    if (!_label) {
        
        _icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"exp_ic_budget_cir_u"]];
        _icon.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_icon];
        
        WEAK_SELF
        UIEdgeInsets padding = UIEdgeInsetsMake(6, 0, 6, 0);
        [_icon mas_makeConstraints:^(MASConstraintMaker *make) {
            STRONG_SELF
            make.left.equalTo(strongSelf.mas_left).with.offset(padding.left);
            make.centerY.equalTo(strongSelf);
            make.height.equalTo(@(strongSelf.fontSize+1));
            make.width.equalTo(strongSelf.icon.mas_height);
        }];
        
        _label = [[UILabel alloc] init];
        _label.font = [UIFont systemFontOfSize:_fontSize];
        _label.textAlignment = NSTextAlignmentCenter;
        _label.textColor = [UIColor darkGrayColor];
        [self addSubview:_label];
        
        padding = UIEdgeInsetsMake(0, 5, 0, 0);
        [_label mas_makeConstraints:^(MASConstraintMaker *make) {
            STRONG_SELF
            make.top.equalTo(strongSelf.mas_top).with.offset(padding.top);
            make.left.equalTo(strongSelf.icon.mas_right).with.offset(padding.left);
            make.bottom.equalTo(strongSelf.mas_bottom).with.offset(-padding.bottom);
            make.right.equalTo(strongSelf.mas_right).with.offset(-padding.right);
        }];
    }
    return _label;
}

- (void)setFontSize:(CGFloat)fontSize {
    _fontSize = fontSize;
    
    if (_label) {
        _label.font = [UIFont systemFontOfSize:_fontSize];
        WEAK_SELF
        [_icon mas_updateConstraints:^(MASConstraintMaker *make) {
            STRONG_SELF
            make.height.equalTo(@(strongSelf.fontSize));
        }];
        [self layoutIfNeeded];
    }
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    if (selected) {
        _icon.image = _selectedImageName ? [UIImage imageNamed:_selectedImageName] : [UIImage imageNamed:@"exp_ic_budget_cir_h"];
    } else {
        _icon.image = _deselectedImageName ? [UIImage imageNamed:_deselectedImageName] : [UIImage imageNamed:@"exp_ic_budget_cir_u"];
    }
}

@end

@interface WYCircleItemSelectedCollectionFlowlayout : UICollectionViewFlowLayout
@property (nonatomic, assign) CGFloat exactItemSpacing;
@property (nonatomic, assign) CGFloat exactLineSpacing;
@end
@implementation WYCircleItemSelectedCollectionFlowlayout

- (NSArray *) layoutAttributesForElementsInRect:(CGRect)rect {
    NSArray *answer = [super layoutAttributesForElementsInRect:rect];
    
    CGFloat currentY;
    CGFloat startX;
    
    for(int i = 1; i < [answer count]; ++i) {
        if (i == 1) {
            startX = CGRectGetMinX(((UICollectionViewLayoutAttributes *)answer[0]).frame);
            currentY = CGRectGetMinY(((UICollectionViewLayoutAttributes *)answer[0]).frame);
        }
        
        UICollectionViewLayoutAttributes *currentLayoutAttributes = answer[i];
        UICollectionViewLayoutAttributes *prevLayoutAttributes = answer[i - 1];
        CGFloat maximumSpacing = _exactItemSpacing;
        CGFloat origin = CGRectGetMaxX(prevLayoutAttributes.frame);
        
        if(origin + maximumSpacing + currentLayoutAttributes.frame.size.width < self.collectionViewContentSize.width) {
            CGRect frame = currentLayoutAttributes.frame;
            frame.origin.x = origin + maximumSpacing;
            frame.origin.y = currentY;
            currentLayoutAttributes.frame = frame;
            
        } else {
            currentY += (_exactLineSpacing + CGRectGetHeight(prevLayoutAttributes.frame));
            CGRect frame = currentLayoutAttributes.frame;
            frame.origin.x = startX;
            frame.origin.y = currentY;
            currentLayoutAttributes.frame = frame;
        }
    }
    return answer;
}

@end

@interface WYCircleItemSelectedView () <UICollectionViewDelegate,
                                        UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, assign) NSUInteger selectedIndex;

@end

@implementation WYCircleItemSelectedView

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (!_collectionView) {
        [self setupCollectionView];
    }
}

- (void)setItemsTitle:(NSArray *)itemsTitle {
    
    _itemsTitle = itemsTitle;
    
    _selectionIndex = (BOOL *)malloc(sizeof(BOOL)*_itemsTitle.count);
    memset(_selectionIndex, 0, sizeof(BOOL)*_itemsTitle.count);
    
    BOOL i = _selectionIndex[0];
    i = _selectionIndex[1];
    i = _selectionIndex[2];
    i = _selectionIndex[3];
    
    [_collectionView reloadData];
}

- (CGFloat)fontSize {
    return _fontSize > 0 ? _fontSize : 15;
}

- (UICollectionView *)contentCollectionView {
    return _collectionView;
}

- (void)setupCollectionView {
    [self layoutIfNeeded];
    
    WYCircleItemSelectedCollectionFlowlayout *flowLayout = [[WYCircleItemSelectedCollectionFlowlayout alloc] init];
    flowLayout.exactLineSpacing = _exactLineSpacing;
    flowLayout.exactItemSpacing = _exactItemSpacing;
    
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.backgroundColor = [UIColor clearColor];
    _collectionView.scrollEnabled = NO;
    [_collectionView registerClass:[WYCircleItemSelectedCell class]
        forCellWithReuseIdentifier:@"cell"];
    
    [self addSubview:_collectionView];
    _collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[collectionView]-0-|"
                                                                   options:0
                                                                   metrics:nil
                                                                     views:@{@"collectionView" : _collectionView}]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[collectionView]-0-|"
                                                                   options:0
                                                                   metrics:nil
                                                                     views:@{@"collectionView" : _collectionView}]
                           ];
}

#pragma mark - UICollectionView layout delegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGSize size;
    size.height = self.fontSize+11;
    size.width = [_itemsTitle[indexPath.row] length]*(self.fontSize+1) + 5 + (self.fontSize+1);
    
    return size;
}

#pragma mark - UICollectionView layout delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return _itemsTitle.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    _selectedIndex = indexPath.row;
    [collectionView reloadData];
    
    _selectionIndex[indexPath.row] = !_selectionIndex[indexPath.row];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kWYCircleItemSelectedViewCellSelectedNotificationName
                                                        object:self
                                                      userInfo:@{kWYCircleItemSelectedViewCellNotifyInfoIndexPathKey:@(indexPath.row)}];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    WYCircleItemSelectedCell *cell;
    static NSString *identify = @"cell";
    cell = [collectionView dequeueReusableCellWithReuseIdentifier:identify
                                                     forIndexPath:indexPath];
    cell.label.text = _itemsTitle[indexPath.row];
    cell.selected = _mutableSelection ? (_selectionIndex[indexPath.row]) : (_selectedIndex == indexPath.row);
    cell.fontSize = self.fontSize;
    
    cell.selectedImageName = _selectedImageName;
    cell.deselectedImageName = _deselectedImageName;
    
    return cell;
}

@end
