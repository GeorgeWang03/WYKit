//
//  WYSparkIconLayer.m
//  SwiftToObjcDemo
//
//  Created by yingwang on 2016/10/20.
//  Copyright © 2016年 yingwang. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "WYSparkIconLayer.h"

NSString * const kWYSparkIconNormalColor = @"kWYSparkIconNormalColor";
NSString * const kWYSparkIconSelectedColor = @"kWYSparkIconSelectedColor";
NSString * const kWYSparkIconImage = @"kWYSparkIconImage";

#define NORMAL_COLOR [UIColor colorWithRed:137.0/255.0 green:156.0/255.0 blue:167.0/255.0 alpha:1]
#define SELECTED_COLOR [UIColor colorWithRed:226.0/255.0 green:38.0/255.0 blue:77.0/255.0 alpha:1]

@interface WYSparkIconLayer ()

@property (nonatomic, strong) NSDictionary *attributes;

@property (nonatomic, strong) CAShapeLayer *backgroundLayer;

@end

@implementation WYSparkIconLayer

- (instancetype)initWithFrame:(CGRect)frame attributes:(NSDictionary *)attributes {
    
    self = [super init];
    if (self) {
        _attributes = attributes;
        
        self.frame = frame;
        
        [self setBackgroundColor:[UIColor clearColor].CGColor];
        
        [self setupLayer];
    }
    return self;
}

- (UIColor *)normalColor {
    if (_attributes[kWYSparkIconNormalColor]) {
        return _attributes[kWYSparkIconNormalColor];
    } else {
        return NORMAL_COLOR;
    }
}

- (UIColor *)selectedColor {
    if (_attributes[kWYSparkIconSelectedColor]) {
        return _attributes[kWYSparkIconSelectedColor];
    } else {
        return SELECTED_COLOR;
    }
}

- (void)setupLayer {
    
    CGRect rigionBounds = self.bounds;
    CGFloat boundsWidth = CGRectGetWidth(self.bounds);
    CGFloat boundsHeight = CGRectGetHeight(self.bounds);
    
    CGPoint boundsCenter = CGPointMake(boundsWidth/2, boundsHeight/2);
    
    UIImage *iconImage = _attributes[kWYSparkIconImage];
    
//    NSAssert(iconImage == nil, @"icon image cannot be nil!");
    
    CGColorRef normalColor;
    normalColor = [self normalColor].CGColor;
    
    CALayer *maskLayer = [CALayer layer];
    maskLayer.contents = (__bridge id _Nullable)(iconImage.CGImage);
    maskLayer.contentsScale = [UIScreen mainScreen].scale;
    maskLayer.frame = rigionBounds;
    
    CAShapeLayer *backgroundLayer = [CAShapeLayer layer];
    backgroundLayer.path = [UIBezierPath bezierPathWithRect:rigionBounds].CGPath;
    backgroundLayer.mask = maskLayer;
    backgroundLayer.fillColor = normalColor;
    backgroundLayer.frame = rigionBounds;
    
    _backgroundLayer = backgroundLayer;
    
    [self addSublayer:backgroundLayer];
}

- (void)animationForColorsWithDuration:(CGFloat)duration delay:(CGFloat)delay {
    [self animatiedColorfully:YES duration:duration delay:delay];
}

- (void)animationForNormalWithDuration:(CGFloat)duration delay:(CGFloat)delay {
    [self animatiedColorfully:NO duration:duration delay:delay];
}

- (void)animatiedColorfully:(BOOL)isColorful duration:(CGFloat)duration delay:(CGFloat)delay {
    
    CGColorRef fillColor;
    
    if (isColorful) {
        fillColor = [self selectedColor].CGColor;
    } else {
        fillColor = [self normalColor].CGColor;
    }
    
    [CATransaction begin];
    _backgroundLayer.fillColor = fillColor;
    [CATransaction commit];
    
    CAKeyframeAnimation *keyframeAniamtion = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    keyframeAniamtion.keyTimes = @[@0.05, @0.2, @0.4, @0.6, @0.8, @0.98];
    keyframeAniamtion.values = @[@0.2, @1.3, @0.5, @1.1, @0.8, @1.0];
    keyframeAniamtion.duration = duration;
    keyframeAniamtion.beginTime = CACurrentMediaTime() + delay;
    keyframeAniamtion.delegate = self;
    
    [_backgroundLayer addAnimation:keyframeAniamtion forKey:@"transform.scale"];
    _backgroundLayer.hidden = YES;
}

- (void)animationDidStart:(CAAnimation *)anim {
    _backgroundLayer.hidden = NO;
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
}

@end
