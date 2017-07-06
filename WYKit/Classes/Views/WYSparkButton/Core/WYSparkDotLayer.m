//
//  WYSparkDotLayer.m
//  SwiftToObjcDemo
//
//  Created by yingwang on 2016/10/20.
//  Copyright © 2016年 yingwang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WYSparkDotLayer.h"

#define BIGGER_DOT_DIVIATION_COEFFICENCY 0
#define SMALLER_DOT_DIVIATION_COEFFICENCY 0

#define BIGGER_DOT_RADIUS_COEFFICENCY 0.1
#define SMALLER_DOT_RADIUS_COEFFICENCY 0.07

#define DOT_PAIR_ANGLE_MARGIN M_PI_2/6
#define DOT_PAIR_COUNT 8

#define BIG_ANIMATION_DISTANCE_COEFFICENCY 0.7
#define SMALL_ANIMATION_DISTANCE_COEFFICENCY 0.5

#define DEFAULT_FIRST_COLOR [UIColor colorWithRed:247.0/255.0 green:188.0/255.0 blue:48.0/255.0 alpha:1]
#define DEFAULT_SECOND_COLOR [UIColor colorWithRed:152.0/255.0 green:219.0/255.0 blue:236.0/255.0 alpha:1]

NSString * const kWYSparkDotFirstColors = @"kWYSparkDotFirstColors";
NSString * const kWYSparkDotSecondColors = @"kWYSparkDotSecondColors";

@interface WYSparkDot : CAShapeLayer

@property (nonatomic, assign) CGFloat diviation;
@property (nonatomic, assign) CGFloat radius;

@property (nonatomic, assign) CGPoint beginAnimationPosition;

- (instancetype)initWithFrame:(CGRect)frame radius:(CGFloat)radius;

@end

@implementation WYSparkDot

- (instancetype)initWithFrame:(CGRect)frame radius:(CGFloat)radius {
    
    self = [super init];
    if (self) {
        self.frame = frame;
        _radius = radius;
        [self setupLayer];
        self.position = CGPointMake(frame.origin.x,
                                    frame.origin.y);
    }
    return self;
}

- (void)setupLayer {
    
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, 2*_radius, 2*_radius)];
    self.path = path.CGPath;
}

@end

@interface WYSparkDotLayer ()

@property (nonatomic, assign) CGFloat radius;
@property (nonatomic, strong) NSDictionary *attributes;

@property (nonatomic, strong) NSArray *dots;

@end

@implementation WYSparkDotLayer

- (instancetype)initWithFrame:(CGRect)frame radius:(CGFloat)radius attributes:(NSDictionary *)attributes {
    
    self = [super init];
    if (self) {
        _radius = radius;
        _attributes = attributes;
        
        self.frame = frame;
        [self setupLayer];
        self.hidden = YES;
    }
    return self;
}

- (void)setupLayer {
    
    CGFloat boundsWidth = CGRectGetWidth(self.bounds);
    CGFloat boundsHeight = CGRectGetHeight(self.bounds);

    CGPoint boundsCenter = CGPointMake(boundsWidth/2, boundsHeight/2);
    
    CGFloat startAngle = - M_PI_2;
    CGFloat angleDiviation = 2 * M_PI / DOT_PAIR_COUNT;
    
    CGFloat smallDotDistance = _radius * (1 + SMALLER_DOT_DIVIATION_COEFFICENCY);
    CGFloat bigDotDistance = _radius * (1 + BIGGER_DOT_DIVIATION_COEFFICENCY);
    
    CGFloat smallDotRadius = _radius * SMALLER_DOT_RADIUS_COEFFICENCY;
    CGFloat bigDotRadius = _radius * BIGGER_DOT_RADIUS_COEFFICENCY;
    
    CGRect currentFrame;
    CGFloat currentAngle;
    
    CGFloat x, y;
    
    NSMutableArray *dots = [NSMutableArray array];
    
    for (NSInteger idx = 0; idx < DOT_PAIR_COUNT; ++idx) {
        
        currentAngle = startAngle + idx * angleDiviation;
        
        x = boundsCenter.x + (bigDotDistance + _radius*BIG_ANIMATION_DISTANCE_COEFFICENCY) * cosf(currentAngle);
        y = boundsCenter.y + (bigDotDistance + _radius*BIG_ANIMATION_DISTANCE_COEFFICENCY) * sinf(currentAngle);
        currentFrame = CGRectMake(x, y, 2*bigDotRadius, 2*bigDotRadius);
        NSLog(@"%@", NSStringFromCGRect(currentFrame));
        
        WYSparkDot *bigDot = [[WYSparkDot alloc] initWithFrame:currentFrame radius:bigDotRadius];
        bigDot.beginAnimationPosition = CGPointMake(boundsCenter.x + bigDotDistance * cosf(currentAngle),
                                                  boundsCenter.y + bigDotDistance * sinf(currentAngle));
        [bigDot setValue:@0.01 forKeyPath:@"transform.scale"];
        [self addSublayer:bigDot];
        
        currentAngle = startAngle + idx * angleDiviation + DOT_PAIR_ANGLE_MARGIN;
        
        x = boundsCenter.x + (smallDotDistance + _radius*SMALL_ANIMATION_DISTANCE_COEFFICENCY) * cosf(currentAngle);
        y = boundsCenter.y + (smallDotDistance + _radius*SMALL_ANIMATION_DISTANCE_COEFFICENCY) * sinf(currentAngle);
        currentFrame = CGRectMake(x, y, 2*smallDotRadius, 2*smallDotRadius);
        
        WYSparkDot *smallDot = [[WYSparkDot alloc] initWithFrame:currentFrame radius:smallDotRadius];
        smallDot.beginAnimationPosition = CGPointMake(boundsCenter.x + smallDotDistance * cosf(currentAngle),
                                                    boundsCenter.y + smallDotDistance * sinf(currentAngle));
        [smallDot setValue:@0.01 forKeyPath:@"transform.scale"];
        [self addSublayer:smallDot];
        
        [dots addObjectsFromArray:@[bigDot, smallDot]];
        bigDot.fillColor = [UIColor clearColor].CGColor;
        smallDot.fillColor = [UIColor clearColor].CGColor;
    }
    
    _dots = [NSArray arrayWithArray:dots];
}

- (void)animationWithDuration:(CGFloat)duration delay:(CGFloat)delay {
    
    self.hidden = YES;
    
    CGColorRef firstColor, secondColor;
    
    for (NSInteger i = 0; i < _dots.count; i += 2) {
        
        firstColor = [self getColorAtSection:1 index:i/2];
        secondColor = [self getColorAtSection:2 index:i/2];
        
        WYSparkDot *bigDot = _dots[i];
        WYSparkDot *smallDot = _dots[i+1];
        
        CAAnimationGroup *firstGroup = [[CAAnimationGroup alloc] init];
        firstGroup.beginTime = CACurrentMediaTime() + delay;
        firstGroup.duration = duration;
        firstGroup.removedOnCompletion = NO;
//        firstGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        firstGroup.delegate = self;
        
        CAAnimationGroup *secondGroup = [[CAAnimationGroup alloc] init];
        secondGroup.beginTime = CACurrentMediaTime() + delay;
        secondGroup.duration = duration;
        secondGroup.removedOnCompletion = NO;
//        secondGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        
        NSMutableArray *bigDotanimations = [NSMutableArray array];
        NSMutableArray *smallDotanimations = [NSMutableArray array];
        
        //* * * * * * * * * * * * * * * * * * * *//
        //              Position Translate       //
        //* * * * * * * * * * * * * * * * * * * *//
        CAKeyframeAnimation *keyframeAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
        keyframeAnimation.values = @[[NSValue valueWithCGPoint:bigDot.beginAnimationPosition],
                                     [NSValue valueWithCGPoint:bigDot.beginAnimationPosition],
                                     [NSValue valueWithCGPoint:bigDot.position]];
        keyframeAnimation.keyTimes = @[@0.01, @(7/11), @0.99];
        keyframeAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        [bigDotanimations addObject:keyframeAnimation];
        
        keyframeAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
        keyframeAnimation.values = @[[NSValue valueWithCGPoint:smallDot.beginAnimationPosition],
                                     [NSValue valueWithCGPoint:smallDot.beginAnimationPosition],
                                     [NSValue valueWithCGPoint:smallDot.position]];
        keyframeAnimation.keyTimes = @[@0.01, @(7/11), @0.99];
        keyframeAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        [smallDotanimations addObject:keyframeAnimation];
        
        //* * * * * * * * * * * * * * * * * * * *//
        //             Color Change              //
        //* * * * * * * * * * * * * * * * * * * *//
        bigDot.fillColor = firstColor;
        smallDot.fillColor = secondColor;
        
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"fillColor"];
        animation.fromValue = (__bridge id _Nullable)(firstColor);
        animation.toValue = (__bridge id _Nullable)(secondColor);
        animation.beginTime =  duration*4/11;
        animation.duration = duration*7/11;
        [bigDotanimations addObject:animation];
        
        animation = [CABasicAnimation animationWithKeyPath:@"fillColor"];
        animation.fromValue = (__bridge id _Nullable)(secondColor);
        animation.toValue = (__bridge id _Nullable)(firstColor);
        animation.beginTime =  duration*4/11;
        animation.duration = duration*7/11;
        [smallDotanimations addObject:animation];

        //* * * * * * * * * * * * * * * * * * * *//
        //             Scale Change              //
        //* * * * * * * * * * * * * * * * * * * *//
        
        keyframeAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
        keyframeAnimation.values = @[@1.0, @1.0, @0.01];
        keyframeAnimation.keyTimes = @[@0.01, @(7/11), @(0.99)];
        keyframeAnimation.beginTime =  CACurrentMediaTime() + delay;
        keyframeAnimation.duration = duration;
        [bigDot addAnimation:keyframeAnimation forKey:nil];
        [smallDot addAnimation:keyframeAnimation forKey:nil];
//        [bigDotanimations addObject:animation];
//        [smallDotanimations addObject:animation];
        
        firstGroup.animations = bigDotanimations;
        secondGroup.animations = smallDotanimations;
        [bigDot addAnimation:firstGroup forKey:nil];
        [smallDot addAnimation:secondGroup forKey:nil];
    }
}

- (CGColorRef)getColorAtSection:(NSInteger)section index:(NSInteger)idx {
    
    NSArray *colors = section == 1 ? _attributes[kWYSparkDotFirstColors] : _attributes[kWYSparkDotSecondColors];
    
    if (colors.count == 0 || idx >= colors.count) {
        return section == 1 ? DEFAULT_FIRST_COLOR.CGColor : DEFAULT_SECOND_COLOR.CGColor;
    } else {
        return ((UIColor *)colors[idx]).CGColor;
    }
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
