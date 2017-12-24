//
//  UIImage+WYExtension.h
//  WYKit
//
//  Created by yingwang on 2017/6/13.
//  Copyright © 2017年 GeorgeWang03. All rights reserved.
//
//  UIImage Extension
//

#import <UIKit/UIKit.h>

@interface UIImage(WYExtension)

/**
 *	创建纯色图像
 *
 *	@param color	指定颜色
 *
 *	@return 生成图像
 */
+ (UIImage *)wy_imageFromColor:(UIColor *)color;

/**
 *	创建渐变图像
 *
 *	@param colors	指定颜色
 *
 *	@return 生成图像
 */
+ (UIImage *)wy_gradientImageFromColors:(NSArray *)colors
                                  frame:(CGRect)frame
                             startPoint:(CGPoint)startPoint
                               endPoint:(CGPoint)endPoint;

@end
