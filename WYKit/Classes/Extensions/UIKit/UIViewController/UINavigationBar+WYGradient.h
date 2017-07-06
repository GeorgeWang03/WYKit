//
//  UINavigationBar+Gradient.h
//  Pods
//
//  Created by yingwang on 2017/4/5.
//
//

#import <UIKit/UIKit.h>

@interface UINavigationBar(WYGradient)

/**
 导航栏标题视图
 */
@property (nonatomic, readonly) UIView *titleView;

/**
 设置渐变背景

 @param fromColor 起始颜色，位于上方
 @param toColor 终止颜色，位于下方
 */
- (void)wy_setGradientBackgroundFromColor:(UIColor *)fromColor toColor:(UIColor *)toColor;

/**
 移除渐变背景，恢复到原来样式
 */
- (void)wy_removeGradient;

/**
 设置渐变进度，与原有颜色交替显示
 必需先调用wy_setGradientBackgroundFromColor:toColor: 才有效

 @param progress 0~1, 1的时候为渐变色，0的时候为原来颜色
 */
- (void)wy_setGradientProgress:(CGFloat)progress;


@end

void import_UINavigationBar_WYGradient();
