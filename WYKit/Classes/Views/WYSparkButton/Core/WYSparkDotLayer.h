//
//  WYSparkDotLayer.h
//  SwiftToObjcDemo
//
//  Created by yingwang on 2016/10/20.
//  Copyright © 2016年 yingwang. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

FOUNDATION_EXTERN NSString * const kWYSparkDotFirstColors;
FOUNDATION_EXTERN NSString * const kWYSparkDotSecondColors;

@interface WYSparkDotLayer : CALayer

- (instancetype)initWithFrame:(CGRect)frame radius:(CGFloat)radius attributes:(NSDictionary *)attributes;

- (void)animationWithDuration:(CGFloat)duration delay:(CGFloat)delay;

///////--------------------------------------- UNAVAILABLE ------------------------------------------///////

- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithLayer:(id)layer UNAVAILABLE_ATTRIBUTE;

@end
