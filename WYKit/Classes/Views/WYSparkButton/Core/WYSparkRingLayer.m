//
//  WYSparkRingLayer.m
//  SwiftToObjcDemo
//
//  Created by yingwang on 2016/10/20.
//  Copyright © 2016年 yingwang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WYSparkRingLayer.h"

#define DEFAULT_FROM_COLOR [UIColor colorWithRed:221.0/255.0 green:70.0/255.0 blue:136.0/255.0 alpha:1]
#define DEFAULT_TO_COLOR [UIColor colorWithRed:205.0/255.0 green:143.0/255.0 blue:246.0/255.0 alpha:1]

NSString * const kWYSparkRingFromColor = @"kWYSparkRingFromColor";
NSString * const kWYSparkRingToColor = @"kWYSparkRingToColor";

@interface WYSparkRingLayer ()

@property (nonatomic, assign) CGFloat radius;
@property (nonatomic, strong) NSDictionary *attributes;

@end

@implementation WYSparkRingLayer

- (instancetype)initWithFrame:(CGRect)frame radius:(CGFloat)radius lineWidth:(CGFloat)lineWidth attributes:(NSDictionary *)attributes {
    
    self = [super init];
    if (self) {
        _radius = radius;
        _attributes = attributes;
        self.lineWidth = lineWidth;
        self.frame = frame;
        
        [self setupLayer];
    }
    return self;
}

- (void)setupLayer {
    
    CGFloat boundsWidth = CGRectGetWidth(self.bounds);
    CGFloat boundsHeight = CGRectGetHeight(self.bounds);
    
    CGPoint boundsCenter = CGPointMake(boundsWidth/2, boundsHeight/2);
    
    CGFloat currentRadius = _radius;
    
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:boundsCenter
                                                        radius:currentRadius
                                                    startAngle:0 endAngle:2 * M_PI
                                                     clockwise:YES];
    self.path = path.CGPath;
    self.fillColor = [UIColor clearColor].CGColor;
    self.strokeColor = ((UIColor *)_attributes[kWYSparkRingFromColor]).CGColor ?: DEFAULT_FROM_COLOR.CGColor;
    self.hidden = YES;
}

- (void)animationToRadiusWithDuration:(CGFloat)duration delay:(CGFloat)delay {
    
    self.hidden = YES;
    
    CGFloat boundsWidth = CGRectGetWidth(self.bounds);
    CGFloat boundsHeight = CGRectGetHeight(self.bounds);
    
    CGPoint boundsCenter = CGPointMake(boundsWidth/2, boundsHeight/2);
    
    NSMutableArray *animations = [NSMutableArray array];
    CAAnimationGroup *group = [[CAAnimationGroup alloc] init];
    group.beginTime = CACurrentMediaTime() + delay;
    group.duration = duration;
    group.delegate = self;
    group.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    
    CABasicAnimation *animation;
    
    CGColorRef fromeColor = ((UIColor *)_attributes[kWYSparkRingFromColor]).CGColor ?: DEFAULT_FROM_COLOR.CGColor;
    CGColorRef toColor = ((UIColor *)_attributes[kWYSparkRingToColor]).CGColor ?: DEFAULT_TO_COLOR.CGColor;
    
    //* * * * * * * * * * * * * * * * * * * *//
    //          Fill Color Change            //
    //* * * * * * * * * * * * * * * * * * * *//
    animation = [CABasicAnimation animationWithKeyPath:@"fillColor"];
    animation.toValue = (__bridge id _Nullable)(toColor);
    [animations addObject:animation];
    
    //* * * * * * * * * * * * * * * * * * * *//
    //         Stroke Color Change           //
    //* * * * * * * * * * * * * * * * * * * *//
    animation = [CABasicAnimation animationWithKeyPath:@"strokeColor"];
    animation.toValue = (__bridge id _Nullable)(toColor);
    [animations addObject:animation];
    
    //* * * * * * * * * * * * * * * * * * * *//
    //               Path Change             //
    //* * * * * * * * * * * * * * * * * * * *//
    UIBezierPath *fromPath = [UIBezierPath bezierPathWithArcCenter:boundsCenter
                                                        radius:0.01 + self.lineWidth/2
                                                    startAngle:0 endAngle:2 * M_PI
                                                     clockwise:YES];
    UIBezierPath *toPath = [UIBezierPath bezierPathWithArcCenter:boundsCenter
                                                        radius:_radius
                                                    startAngle:0 endAngle:2 * M_PI
                                                     clockwise:YES];
    animation = [CABasicAnimation animationWithKeyPath:@"path"];
    animation.fromValue =(__bridge id _Nullable)(fromPath.CGPath);
    animation.toValue = (__bridge id _Nullable)(toPath.CGPath);
    [animations addObject:animation];
    
    group.animations = animations;
    [self addAnimation:group forKey:nil];
}

- (void)animationColapseWithDuration:(CGFloat)duration delay:(CGFloat)delay {
    
    CGFloat boundsWidth = CGRectGetWidth(self.bounds);
    CGFloat boundsHeight = CGRectGetHeight(self.bounds);
    
    CGPoint boundsCenter = CGPointMake(boundsWidth/2, boundsHeight/2);
    
    NSMutableArray *animations = [NSMutableArray array];
    CAAnimationGroup *group = [[CAAnimationGroup alloc] init];
    group.beginTime = CACurrentMediaTime() + delay;
    group.duration = duration;
    group.delegate = self;
    group.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    
    CABasicAnimation *animation;
    
    //* * * * * * * * * * * * * * * * * * * *//
    //          Line Width Change            //
    //* * * * * * * * * * * * * * * * * * * *//
    animation = [CABasicAnimation animationWithKeyPath:@"lineWidth"];
    animation.toValue = @0;
    [animations addObject:animation];
    
    //* * * * * * * * * * * * * * * * * * * *//
    //               Path Change             //
    //* * * * * * * * * * * * * * * * * * * *//
    UIBezierPath *fromPath = [UIBezierPath bezierPathWithArcCenter:boundsCenter
                                                        radius:0.01 + self.lineWidth/2
                                                    startAngle:0 endAngle:2 * M_PI
                                                     clockwise:YES];
    UIBezierPath *toPath = [UIBezierPath bezierPathWithArcCenter:boundsCenter
                                                          radius:_radius
                                                      startAngle:0 endAngle:2 * M_PI
                                                       clockwise:YES];
    animation = [CABasicAnimation animationWithKeyPath:@"path"];
    animation.fromValue = (__bridge id _Nullable)(fromPath.CGPath);
    animation.toValue = (__bridge id _Nullable)(toPath.CGPath);
    [animations addObject:animation];
    
    group.animations = animations;
    [self addAnimation:group forKey:nil];
}

- (void)animationDidStart:(CAAnimation *)anim {
    self.hidden = NO;
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if (flag) {
        self.hidden = YES;
    }
}

@end
