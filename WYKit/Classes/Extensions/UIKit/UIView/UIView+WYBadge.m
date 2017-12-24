//
//  UIView+WYBadge.m
//  WYKit
//
//  Created by yingwang on 2017/5/23.
//  Copyright © 2017年 GeorgeWang03. All rights reserved.
//
//  右上角badge
//

#import "UIView+WYBadge.h"
#import <objc/runtime.h>
#import <Masonry/Masonry.h>
#import "WYKVOOBserver.h"

@interface UIView()

@property (nonatomic, strong) UIView *backgroundView;

@end

static char *kWYBageLabelBackgroundViewIdentify = "kWYBageLabelBackgroundViewIdentify";
static char *kWYBageLableIdentify = "kWYBageLableIdentify";
static char *kWYBageLableHeightIdentify = "kWYBageLableHeightIdentify";
static char *kWYBageLableOffsetIdentify = "kWYBageLableOffsetIdentify";

@implementation UIView(WYBadge)
@dynamic wy_badgeOffset;
@dynamic wy_badgeHeight;

- (UIView *)wy_badgeBackgroundView {
    return self.backgroundView;
}

- (UIView *)backgroundView {
    UIView *backView = objc_getAssociatedObject(self, kWYBageLabelBackgroundViewIdentify);
    
    if (!backView) {
        CGFloat height = MAX(self.wy_badgeHeight, 4);
        CGPoint offset = self.wy_badgeOffset;
        
        backView = [[UIView alloc] init];
        backView.backgroundColor = [UIColor redColor];
        backView.layer.cornerRadius = height/2;
        
        objc_setAssociatedObject(self, kWYBageLabelBackgroundViewIdentify, backView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        [self addSubview:backView];
        
        __weak typeof(self) weakSelf = self;
        UIEdgeInsets padding = UIEdgeInsetsMake(-height/2+offset.y, 0, 0, height/2-offset.x);
        [backView mas_makeConstraints:^(MASConstraintMaker *make) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            make.left.equalTo(strongSelf.mas_right).with.offset(-padding.right);
            make.top.equalTo(strongSelf.mas_top).with.offset(padding.top);
            make.width.greaterThanOrEqualTo(@(height));
            make.height.equalTo(@(height));
        }];
    }
    
    return backView;
}

- (UILabel *)wy_badge {
    UILabel *label = objc_getAssociatedObject(self, kWYBageLableIdentify);
    if (!label) {
        CGFloat height = MAX(self.wy_badgeHeight, 4);
        CGPoint offset = self.wy_badgeOffset;
        
        label = [[UILabel alloc] init];
        label.textColor = [UIColor whiteColor];
        label.layer.masksToBounds = YES;
        label.textAlignment = NSTextAlignmentCenter;
        
        objc_setAssociatedObject(self, kWYBageLableIdentify, label, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        [self addSubview:label];
        
//        __weak UIView *weakView = self.backgroundView;
        __weak typeof(self) weakSelf = self;
        UIEdgeInsets padding = UIEdgeInsetsMake(-height/2+offset.y, 0, 0, height/2-offset.x);
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            make.left.equalTo(strongSelf.mas_right).with.offset(-padding.right);
            make.top.equalTo(strongSelf.mas_top).with.offset(padding.top);
            make.width.greaterThanOrEqualTo(@(height));
            make.height.equalTo(@(height));
        }];
        
        
        static BOOL ignore = NO;
        [self.kvoObserver wy_observe:label keyPath:@"text" options:NSKeyValueObservingOptionNew
                             context:nil
                              action:^(UILabel *target, UIView *observer, NSDictionary<NSKeyValueChangeKey,id> *change, void *context) {
                                  if (ignore) return;
                                  ignore = YES;
                                  CGRect rect = [target textRectForBounds:CGRectMake(0, 0, 100, 100) limitedToNumberOfLines:1];
                                  [target mas_updateConstraints:^(MASConstraintMaker *make) {
                                      make.width.greaterThanOrEqualTo(@(fmaxf(CGRectGetWidth(rect)+6, MAX(weakSelf.wy_badgeHeight, 4))));
                                  }];
                                  [target layoutIfNeeded];
                                  ignore = NO;
                              }];
        [self.kvoObserver wy_observe:label keyPath:@"font" options:NSKeyValueObservingOptionNew
                             context:nil
                              action:^(UILabel *target, UIView *observer, NSDictionary<NSKeyValueChangeKey,id> *change, void *context) {
                                  CGRect rect = [target textRectForBounds:CGRectMake(0, 0, 100, 100) limitedToNumberOfLines:1];
                                  [target mas_updateConstraints:^(MASConstraintMaker *make) {
                                      make.width.greaterThanOrEqualTo(@(fmaxf(CGRectGetWidth(rect)+6, MAX(weakSelf.wy_badgeHeight, 4))));
                                  }];
                                  [target layoutIfNeeded];
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
    
    CGFloat height = MAX(wy_badgeHeight, 4);
    CGPoint offset = self.wy_badgeOffset;
    UIView *backView = self.wy_badge;
    if (backView) {
        CGRect rect = [self.wy_badge textRectForBounds:CGRectMake(0, 0, 100, 100) limitedToNumberOfLines:1];
        
        __weak typeof(self) weakSelf = self;
        UIEdgeInsets padding = UIEdgeInsetsMake(-height/2+offset.y, 0, 0, height/2-offset.x);
        [backView mas_updateConstraints:^(MASConstraintMaker *make) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            make.left.equalTo(strongSelf.mas_right).with.offset(-padding.right);
            make.top.equalTo(strongSelf.mas_top).with.offset(padding.top);
            make.width.greaterThanOrEqualTo(@(fmaxf(CGRectGetWidth(rect)+6, MAX(weakSelf.wy_badgeHeight, 4))));
            make.height.equalTo(@(height));
        }];
    }
}

- (CGPoint)wy_badgeOffset {
    NSValue *offsetValue = objc_getAssociatedObject(self, kWYBageLableOffsetIdentify);
    CGPoint offset = [offsetValue CGPointValue];
    return offset;
}

- (void)setWy_badgeOffset:(CGPoint)wy_badgeOffset {
    NSValue *offsetValue = [NSValue valueWithCGPoint:wy_badgeOffset];
    objc_setAssociatedObject(self, kWYBageLableOffsetIdentify, offsetValue, OBJC_ASSOCIATION_RETAIN);
    
    CGFloat height = fmax(self.wy_badgeHeight, 4);
    UIView *backView = self.wy_badge;
    if (backView) {
        
        __weak typeof(self) weakSelf = self;
        UIEdgeInsets padding = UIEdgeInsetsMake(-height/2+wy_badgeOffset.y, 0, 0, height/2-wy_badgeOffset.x);
        [backView mas_updateConstraints:^(MASConstraintMaker *make) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            make.left.equalTo(strongSelf.mas_right).with.offset(-padding.right);
            make.top.equalTo(strongSelf.mas_top).with.offset(padding.top);
        }];
    }
}

@end

