//
//  WYCollectionPickerView.m
//  WYKit
//
//  Created by yingwang on 2016/12/26.
//  Copyright © 2016年 yingwang. All rights reserved.
//

#import "WYPodDefine.h"
#import "UIView+WYInitialize.h"
#import "WYCollectionPickerView.h"
#import "WYCollectionPickerViewCell.h"

@interface WYCollectionPickerView () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@end

@implementation WYCollectionPickerView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.collectionViewLayout = [[UICollectionViewFlowLayout alloc] init];
    [_collectionView registerNib:[WYCollectionPickerViewCell wy_loadGeneralNibByBundlePath:WYPodBundle]
      forCellWithReuseIdentifier:@"cell"];
}

#pragma mark - UICollectionView delegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([_delegate respondsToSelector:@selector(pickerView:didSelectedItemAtIndex:)]) {
        [_delegate pickerView:self didSelectedItemAtIndex:indexPath.row];
    }
}

#pragma mark - UICollectionView delegate flowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGSize size;
    size.height = (CGRectGetHeight(self.bounds)-CGRectGetWidth(self.bounds)*90.0/750-30)/2;
    size.width = CGRectGetWidth(self.bounds)/3;
    
    return size;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 15;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

#pragma mark - UICollectionView dataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_delegate numberOfItemInPickerView:self];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identify = @"cell";
    WYCollectionPickerViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identify forIndexPath:indexPath];
    cell.imageView.image = [_delegate pickerView:self imageForItemAtIndex:indexPath.row];
    cell.titleLabel.text = [_delegate pickerView:self titleForItemAtIndex:indexPath.row];
    
    return cell;
}


@end
