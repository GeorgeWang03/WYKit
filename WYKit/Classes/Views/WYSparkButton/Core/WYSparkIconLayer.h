//
//  WYSparkIconLayer.h
//  SwiftToObjcDemo
//
//  Created by yingwang on 2016/10/20.
//  Copyright © 2016年 yingwang. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

FOUNDATION_EXTERN NSString * const kWYSparkIconNormalColor;
FOUNDATION_EXTERN NSString * const kWYSparkIconSelectedColor;
FOUNDATION_EXTERN NSString * const kWYSparkIconImage;

@interface WYSparkIconLayer : CALayer

- (instancetype)initWithFrame:(CGRect)frame attributes:(NSDictionary *)attributes;

- (void)animationForColorsWithDuration:(CGFloat)duration delay:(CGFloat)delay;

- (void)animationForNormalWithDuration:(CGFloat)duration delay:(CGFloat)delay;

///////--------------------------------------- UNAVAILABLE ------------------------------------------///////

- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithLayer:(id)layer UNAVAILABLE_ATTRIBUTE;

@end
