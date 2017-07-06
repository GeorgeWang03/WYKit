//
//  WYSparkRingLayer.h
//  SwiftToObjcDemo
//
//  Created by yingwang on 2016/10/20.
//  Copyright © 2016年 yingwang. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

FOUNDATION_EXTERN NSString * const kWYSparkRingFromColor;
FOUNDATION_EXTERN NSString * const kWYSparkRingToColor;

@interface WYSparkRingLayer : CAShapeLayer
- (instancetype)initWithFrame:(CGRect)frame radius:(CGFloat)radius lineWidth:(CGFloat)lineWidth attributes:(NSDictionary *)attributes;

- (void)animationToRadiusWithDuration:(CGFloat)duration delay:(CGFloat)delay;
- (void)animationColapseWithDuration:(CGFloat)duration delay:(CGFloat)delay;

///////--------------------------------------- UNAVAILABLE ------------------------------------------///////

- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithLayer:(id)layer UNAVAILABLE_ATTRIBUTE;
@end
