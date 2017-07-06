//
//  UIView+WYBadge.m
//  WYKit
//
//  Created by yingwang on 2017/5/23.
//  Copyright © 2017年 yingwang. All rights reserved.
//
//  右上角badge
//

#import "UIView+WYBadge.h"
#import <objc/runtime.h>
#import <Masonry/Masonry.h>

@interface UIView()

@end

static char *kWYBageLableIdentify = "kWYBageLableIdentify";
static char *kWYBageLableHeightIdentify = "kWYBageLableHeightIdentify";

@implementation UIView(WYBadge)

- (UILabel *)wy_badge {
    UILabel *label = objc_getAssociatedObject(self, kWYBageLableIdentify);
    if (!label) {
        
        CGFloat height = MAX(self.wy_badgeHeight, 4);
        
        label = [[UILabel alloc] init];
        label.backgroundColor = [UIColor redColor];
        label.textColor = [UIColor whiteColor];
        label.layer.cornerRadius = height/2;
        label.layer.masksToBounds = YES;
        label.font = [UIFont systemFontOfSize:height-2];
        label.textAlignment = NSTextAlignmentCenter;
        
        objc_setAssociatedObject(self, kWYBageLableIdentify, label, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        [self addSubview:label];
        
        __weak typeof(self) weakSelf = self;
        UIEdgeInsets padding = UIEdgeInsetsMake(-height/2, 0, 0, -height/2);
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            make.right.equalTo(strongSelf.mas_right).with.offset(-padding.right);
            make.top.equalTo(strongSelf.mas_top).with.offset(padding.top);
            make.width.greaterThanOrEqualTo(@(height));
            make.height.equalTo(@(height));
        }];
    }
    
    return label;
}

- (CGFloat)wy_badgeHeight {
    NSNumber *height = objc_getAssociatedObject(self, kWYBageLableHeightIdentify);
    return height ? [height floatValue] : 0;
}

- (void)setWy_badgeHeight:(CGFloat)wy_badgeHeight {
    objc_setAssociatedObject(self, kWYBageLableHeightIdentify, @(wy_badgeHeight), OBJC_ASSOCIATION_RETAIN);
    
    CGFloat height = MIN(wy_badgeHeight, 4);
    UILabel *label = objc_getAssociatedObject(self, kWYBageLableIdentify);
    if (label) {
        label.layer.cornerRadius = height/2;
        label.font = [UIFont systemFontOfSize:height-2];
        
        __weak typeof(self) weakSelf = self;
        UIEdgeInsets padding = UIEdgeInsetsMake(-height/2, 0, 0, -height/2);
        [label mas_remakeConstraints:^(MASConstraintMaker *make) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            make.right.equalTo(strongSelf.mas_right).with.offset(-padding.right);
            make.top.equalTo(strongSelf.mas_top).with.offset(padding.top);
            make.width.greaterThanOrEqualTo(@(height));
            make.height.equalTo(@(height));
        }];
    }
}

@end
