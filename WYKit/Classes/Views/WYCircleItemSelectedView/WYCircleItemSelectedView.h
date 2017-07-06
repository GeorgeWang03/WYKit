//
//  WYCircleItemSelectedView.h
//  WYKit
//
//  Created by yingwang on 2016/11/24.
//  Copyright © 2016年 yingwang. All rights reserved.
//

#import <UIKit/UIKit.h>

FOUNDATION_EXTERN NSString * const kWYCircleItemSelectedViewCellSelectedNotificationName;
FOUNDATION_EXTERN NSString * const kWYCircleItemSelectedViewCellNotifyInfoIndexPathKey;


@interface WYCircleItemSelectedView : UIView

// 必需是NSString类型
@property (nonatomic, strong) NSArray<NSString *> *itemsTitle;

@property (nonatomic, readonly) UICollectionView *contentCollectionView;

@property (nonatomic, assign) CGFloat exactItemSpacing;
@property (nonatomic, assign) CGFloat exactLineSpacing;
@property (nonatomic, assign) CGFloat fontSize;

@property (nonatomic) BOOL mutableSelection;
@property (nonatomic) BOOL *selectionIndex;

@property (nonatomic, strong) NSString *selectedImageName;
@property (nonatomic, strong) NSString *deselectedImageName;

@end
