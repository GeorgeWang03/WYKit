//
//  UINavigationBar+Gradient.m
//  Pods
//
//  Created by yingwang on 2017/4/5.
//
//
#import <objc/runtime.h>
#import "UINavigationBar+WYGradient.h"

@interface UINavigationBar ()

@property (nonatomic, strong) CAGradientLayer *gradientLayer;
@property (nonatomic, strong) UIView *gradientView;

@end

const char *kUINavigationBarWYGradienLayer = "kUINavigationBarWYGradienLayer";
const char *kUINavigationBarWYGradienView = "kUINavigationBarWYGradienView";
const char *kUINavigationBarWYTitleView = "kUINavigationBarWYTitleView";

@implementation UINavigationBar(WYGradient)

- (UIView *)titleView {
    UIView *titleView = objc_getAssociatedObject(self, kUINavigationBarWYTitleView);
    if (!titleView) {
        UIView *targetView = nil;
        for (UIView *subview in self.subviews) {
            if ([NSStringFromClass([subview class]) isEqualToString:@"UINavigationItemView"]) {
                targetView = subview;
                break;
            }
        }
        
        if (targetView) {
            titleView = targetView;
            //objc_setAssociatedObject(self, kUINavigationBarWYTitleView, titleView, OBJC_ASSOCIATION_ASSIGN);
        }
    }
    return titleView;
}

- (void)setGradientLayer:(CAGradientLayer *)gradientLayer {
    objc_setAssociatedObject(self, kUINavigationBarWYGradienLayer, gradientLayer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CAGradientLayer *)gradientLayer {
    return objc_getAssociatedObject(self, kUINavigationBarWYGradienLayer);
}

- (void)setGradientView:(UIView *)gradientView {
    objc_setAssociatedObject(self, kUINavigationBarWYGradienView, gradientView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIView *)gradientView {
    return objc_getAssociatedObject(self, kUINavigationBarWYGradienView);
}

/**
 设置渐变背景
 
 @param fromColor 起始颜色，位于上方
 @param toColor 终止颜色，位于下方
 */
- (void)wy_setGradientBackgroundFromColor:(UIColor *)fromColor toColor:(UIColor *)toColor {
    UIView *targetView = [self getRigionBackgroundView];
    
    if (targetView) {
        targetView.hidden = YES;
        
        UIView *backgroundView = self.gradientView;
        if (!backgroundView) {
            backgroundView = [[UIView alloc] init];
            backgroundView.userInteractionEnabled = NO;
            backgroundView.backgroundColor = [UIColor clearColor];
            [self setGradientView:backgroundView];
        }
        
        [self insertSubview:backgroundView atIndex:0];
        NSArray *subviews = self.subviews;
        
        CAGradientLayer *layer = self.gradientLayer;
        if (!layer) {
            layer = [CAGradientLayer layer];
            [self setGradientLayer:layer];
            
        }
        
        backgroundView.frame = targetView.frame;
        
        layer.frame = backgroundView.bounds;
        layer.colors = @[(id)fromColor.CGColor, (id)toColor.CGColor];
        layer.startPoint = CGPointMake(0, 0);
        layer.endPoint = CGPointMake(0, 1);
        layer.locations = @[@(0.1), @(0.9)];
        
        [backgroundView.layer addSublayer:layer];
    }
}

/**
 移除渐变背景，恢复到原来样式
 */
- (void)wy_removeGradient {
    
    UIView *targetView = [self getRigionBackgroundView];
    
    if (targetView) {
        targetView.hidden = NO;
        [self wy_setGradientProgress:0];
        
        UIView *gradientView = self.gradientView;
        [gradientView removeFromSuperview];
    }
}

/**
 设置渐变进度，与原有颜色交替显示
 
 @param progress 0~1, 1的时候为渐变色，0的时候为原来颜色
 */
- (void)wy_setGradientProgress:(CGFloat)progress {
    progress = (progress >= 0)? progress : 0;
    
    UIView *gradientView = self.gradientView;
    [self insertSubview:gradientView atIndex:0];
    
    UIView *targetView = [self getRigionBackgroundView];
    
    targetView.hidden = NO;
    targetView.alpha = 1-progress;
    
    CALayer *gradientLayer = self.gradientLayer;
    gradientLayer.opacity = progress;
}

- (UIView *)getRigionBackgroundView {
    UIView *targetView = nil;
    for (UIView *subview in self.subviews) {
        if ([subview isKindOfClass:NSClassFromString(@"_UIBarBackground")]) {
            targetView = subview;
            break;
        }
    }
    return targetView;
}


@end

void import_UINavigationBar_WYGradient(){}
