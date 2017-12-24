//
//  UIColor+WYExtension.m
//  WYKit
//
//  Created by yingwang on 2017/6/13.
//  Copyright © 2017年 GeorgeWang03. All rights reserved.
//
//  UIColor Extension
//

#import "UIColor+WYExtension.h"

@implementation UIColor(WYExtension)

+ (UIColor *)wy_colorWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue {
    [self wy_colorWithRed:red green:green blue:blue alpha:1.0];
}

+ (UIColor *)wy_colorWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha {
    return [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:alpha];
}

@end
