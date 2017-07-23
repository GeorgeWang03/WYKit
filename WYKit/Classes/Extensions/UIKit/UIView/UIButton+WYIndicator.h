//
//  UIButton+WYIndicator.h
//  CPCS
//
//  Created by yingwang on 2017/6/24.
//  Copyright © 2017年 yingwang. All rights reserved.
//
//  UIButton扩展
//

#import <UIKit/UIKit.h>

typedef NS_OPTIONS(NSUInteger, WYButtonIndicatorOption) {
    kWYButtonIndicatorInsteadImage,
    kWYButtonIndicatorInsteadTitle,
    kWYButtonIndicatorCenter
};

@interface UIButton(Indicator)

@property (nonatomic) UIActivityIndicatorViewStyle wy_indicatorStyle;
@property (nonatomic, readonly) BOOL wy_indicatorAnimating;

/**
 开始执行加载动画
 */
@property (nonatomic, readonly) void(^wy_startIndicatorAnimation)(WYButtonIndicatorOption option);

/**
 停止加载动画
 */
@property (nonatomic, readonly) void(^wy_stopIndicatorAnimation)();

@end
