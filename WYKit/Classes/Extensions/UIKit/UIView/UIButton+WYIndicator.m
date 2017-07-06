//
//  UIButton+WYIndicator.m
//  CPCS
//
//  Created by yingwang on 2017/6/24.
//  Copyright © 2017年 yingwang. All rights reserved.
//
//  UIButton扩展
//

#import "UIButton+WYIndicator.h"
#import <objc/runtime.h>

@interface UIButton ()

/**
 开始执行加载动画
 */
@property (nonatomic, copy) void(^startIndicatorAnimation)();

/**
 停止加载动画
 */
@property (nonatomic, copy) void(^stopIndicatorAnimation)();

@property (nonatomic, strong) UIActivityIndicatorView *indicator;

@end

static char *kActivicatorIndicatorKey = "kActivicatorIndicatorKey";
static char *kStartAnimationKey = "kStartAnimationKey";
static char *kStopAnimationKey = "kStopAnimationKey";

@implementation UIButton(Indicator)

- (void)setWy_indicatorStyle:(UIActivityIndicatorViewStyle)wy_indicatorStyle {
    self.indicator.activityIndicatorViewStyle = wy_indicatorStyle;
}

- (UIActivityIndicatorViewStyle)wy_indicatorStyle {
    return self.indicator.activityIndicatorViewStyle;
}

- (UIActivityIndicatorView *)indicator {
    UIActivityIndicatorView *indicator = objc_getAssociatedObject(self, kActivicatorIndicatorKey);
    
    if (!indicator) {
        indicator = [[UIActivityIndicatorView alloc] init];
        objc_setAssociatedObject(self, kActivicatorIndicatorKey,
                                 indicator, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        [self addSubview:indicator];
    }
    
    return indicator;
}

- (void (^)())startIndicatorAnimation {
    id block = objc_getAssociatedObject(self, kStartAnimationKey);
    
    if (!block) {
        __weak UIButton *weakSelf = self;
        block = ^{
            weakSelf.imageView.layer.transform = CATransform3DMakeScale(0, 0, 0);
            weakSelf.userInteractionEnabled = NO;
            weakSelf.indicator.center = weakSelf.imageView.center;
            [weakSelf.indicator startAnimating];
        };
        
        objc_setAssociatedObject(self, kStartAnimationKey, block, OBJC_ASSOCIATION_COPY_NONATOMIC);
    }
    
    return block;
}

- (void (^)())stopIndicatorAnimation {
    id block = objc_getAssociatedObject(self, kStopAnimationKey);
    
    if (!block) {
        __weak UIButton *weakSelf = self;
        block = ^{
            weakSelf.imageView.layer.transform = CATransform3DIdentity;
            weakSelf.userInteractionEnabled = YES;
            [weakSelf.indicator stopAnimating];
        };
        
        objc_setAssociatedObject(self, kStopAnimationKey, block, OBJC_ASSOCIATION_COPY_NONATOMIC);
    }
    
    return block;
}

- (void (^)())wy_startIndicatorAnimation {
    return self.startIndicatorAnimation;
}

- (void (^)())wy_stopIndicatorAnimation {
    return self.stopIndicatorAnimation;
}

@end
