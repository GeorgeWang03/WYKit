//
//  UIImage+WYExtension.m
//  WYKit
//
//  Created by yingwang on 2017/6/13.
//  Copyright © 2017年 GeorgeWang03. All rights reserved.
//
//  UIImage Extension
//

#import "UIImage+WYExtension.h"

@implementation UIImage(WYExtension)

+ (UIImage *)wy_imageFromColor:(UIColor *)color {
    return [self wy_imageFromColor:color frame:CGRectMake(0, 0, 1, 1)];
}

+ (UIImage *)wy_imageFromColor:(UIColor *)color frame:(CGRect)frame {
    CGRect rect = frame;
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (UIImage *)wy_gradientImageFromColors:(NSArray *)colors frame:(CGRect)frame startPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint {
    
    if (colors.count == 0)  {
        return nil;
    }
    
    if (colors.count == 1) {
        return [self wy_imageFromColor:[colors firstObject] frame:frame];
    }
    
    CGRect rect = frame;
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    size_t gradientNum = colors.count;
    //    CGFloat *gradientLocation = malloc(colors.count*sizeof(CGFloat));
    //    for (int idx = 0; idx < colors.count; ++idx) {
    //        gradientLocation[idx] = idx * 1.0/(colors.count-1);
    //    }
    
    CGFloat *gradientColors = malloc(4*sizeof(CGFloat)*colors.count);
    for (int idx = 0; idx < colors.count; ++idx) {
        const CGFloat *currentColors = CGColorGetComponents(((UIColor *)colors[idx]).CGColor);//CGColorGetComponents(((UIColor *)colors[idx]).CGColor);
        size_t componentNum = CGColorGetNumberOfComponents(((UIColor *)colors[idx]).CGColor);
        gradientColors[idx*4+0] = currentColors[0];
        gradientColors[idx*4+1] = componentNum == 4 ? currentColors[1] : currentColors[0];
        gradientColors[idx*4+2] = componentNum == 4 ? currentColors[2] : currentColors[0];
        gradientColors[idx*4+3] = componentNum == 4 ? currentColors[3] : currentColors[1];//[alphas[idx] floatValue];
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, gradientColors, NULL, gradientNum);
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, kCGGradientDrawsAfterEndLocation);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}


@end
