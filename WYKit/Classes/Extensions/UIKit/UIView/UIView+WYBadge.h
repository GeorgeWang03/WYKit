//
//  UIView+WYBadge.h
//  WYKit
//
//  Created by yingwang on 2017/5/23.
//  Copyright © 2017年 GeorgeWang03. All rights reserved.
//
//  右上角badge
//

#import <UIKit/UIKit.h>

@interface UIView(WYBadge)

@property (nonatomic, readonly) UILabel *wy_badge;

@property (nonatomic) CGPoint wy_badgeOffset;

@property (nonatomic) CGFloat wy_badgeHeight;

@end
