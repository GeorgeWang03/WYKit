//
//  WYTagView.h
//  WYKit
//
//  Created by yingwang on 2017/5/24.
//  Copyright © 2017年 GeorgeWang03. All rights reserved.
//
//  标签视图
//

#import <UIKit/UIKit.h>

@interface WYTagView : UIView

@property (nonatomic, strong) UIFont *font;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) UIColor *borderColor;

@property (nonatomic) CGFloat lineSpacing;
@property (nonatomic) CGFloat itemSpacing;

@property (nonatomic) CGFloat itemCornerRadius;

@property (nonatomic) UIEdgeInsets contentInset;
@property (nonatomic) UIEdgeInsets tagContentInset;

////////////////
@property (nonatomic, strong) NSArray *titles;

- (void)reloadData;

@end
