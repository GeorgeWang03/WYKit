//
//  WYSegmentView.h
//  WYKit
//
//  Created by yingwang on 2017/6/28.
//  Copyright © 2017年 GeorgeWang03. All rights reserved.
//
//  按钮选择视图
//

#import <UIKit/UIKit.h>

@interface WYSegmentView : UIView

@property (nonatomic, strong) UIColor *highlightedColor;
@property (nonatomic, strong) UIColor *normalColor;

@property (nonatomic, strong) NSArray<NSString *> *titles;

@property (nonatomic, copy) void(^handleSelectedItemAction)(NSUInteger idx);

- (void)reloadData;

@end
