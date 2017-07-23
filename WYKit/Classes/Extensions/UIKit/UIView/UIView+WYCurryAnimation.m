//
//  UIView+WYCurryAnimation.m
//  BezierCuryTest
//
//  Created by yingwang on 2017/1/13.
//  Copyright © 2017年 yingwang. All rights reserved.
//

#import "UIView+WYCurryAnimation.h"
#import <objc/runtime.h>

@interface UIView ()

@property (nonatomic, strong) UIView *wy_newCircle;
@property (nonatomic, strong) CAShapeLayer *wy_shapeLayer;

@property (nonatomic, strong) UIView *wy_springer;
@property (nonatomic, strong) CADisplayLink *wy_displayLink;

@property (nonatomic) CGFloat wy_originCircleRadius;
@property (nonatomic) CGFloat wy_newCircleRadius;
@property (nonatomic) CGFloat wy_circleDistance;

@property (nonatomic) CGFloat wy_sin;
@property (nonatomic) CGFloat wy_cos;

@property (nonatomic) CGPoint wy_pointA;
@property (nonatomic) CGPoint wy_pointB;
@property (nonatomic) CGPoint wy_pointC;
@property (nonatomic) CGPoint wy_pointD;

@property (nonatomic) CGPoint wy_pointC1;
@property (nonatomic) CGPoint wy_pointC2;

@property (nonatomic) CGPoint wy_originCenter;

@property (nonatomic, readonly) UIBezierPath *wy_curryPath;

@property (nonatomic, strong) UIPanGestureRecognizer *wy_pan;

@property (nonatomic, copy) void(^wy_completedBlock)(UIView *sender, BOOL dismiss);

@end

const char *UIViewCurryAnimationNewCircleKey = "UIViewCurryAnimationNewCircleKey";
const char *UIViewCurryAnimationCurryShapeKey = "UIViewCurryAnimationCurryShapeKey";
const char *UIViewCurryAnimationPanGestureKey = "UIViewCurryAnimationPanGestureKey";
const char *UIViewCurryAnimationSpringerKey = "UIViewCurryAnimationSpringerKey";
const char *UIViewCurryAnimationOriginCenterKey = "UIViewCurryAnimationOriginCenterKey";
const char *UIViewCurryAnimationCompletedBlockKey = "UIViewCurryAnimationCompletedBlockKey";

const static CGFloat minCoe = 0.2;

@implementation UIView (WYCurryAnimation)

// component

- (UIView *)wy_newCircle {
    
    UIView *circle = objc_getAssociatedObject(self, UIViewCurryAnimationNewCircleKey);
    
    if (!circle) {
        
        CGFloat radius = [self wy_originCircleRadius];
        circle = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 2*radius, 2*radius)];
        circle.center = self.center;
        circle.backgroundColor = self.backgroundColor;
        circle.layer.cornerRadius = radius;
        circle.layer.masksToBounds = YES;
        [self.superview insertSubview:circle belowSubview:self];
        
        objc_setAssociatedObject(self, UIViewCurryAnimationNewCircleKey, circle, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    return circle;
}

- (CAShapeLayer *)wy_shapeLayer {
    
    CAShapeLayer *layer = objc_getAssociatedObject(self, UIViewCurryAnimationCurryShapeKey);
    
    if (!layer) {
        
        layer = [CAShapeLayer layer];
        layer.fillColor = self.backgroundColor.CGColor;
        
        [self.superview.layer addSublayer:layer];
        [self.superview.layer insertSublayer:layer below:self.layer];
        
        objc_setAssociatedObject(self, UIViewCurryAnimationCurryShapeKey, layer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    return layer;
}

- (UIView *)wy_springer {
    
    UIView *springer = objc_getAssociatedObject(self, UIViewCurryAnimationSpringerKey);
    
    if (!springer) {
        springer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 5)];
        springer.backgroundColor = [UIColor clearColor];
        springer.center = self.center;
        
        [self.superview addSubview:springer];
        
        objc_setAssociatedObject(self, UIViewCurryAnimationSpringerKey, springer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    return springer;
}

- (void)setWy_originCenter:(CGPoint)wy_originCenter {
    objc_setAssociatedObject(self, UIViewCurryAnimationOriginCenterKey, [NSValue valueWithCGPoint:wy_originCenter], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGPoint)wy_originCenter {
    
    NSValue *point = objc_getAssociatedObject(self, UIViewCurryAnimationOriginCenterKey);
    return [point CGPointValue];
}

- (void)setWy_completedBlock:(void (^)(UIView *, BOOL))wy_completedBlock {
    
    id block = [wy_completedBlock copy];
    
    objc_setAssociatedObject(self, UIViewCurryAnimationCompletedBlockKey, block, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void (^)(UIView *, BOOL))wy_completedBlock {
    return objc_getAssociatedObject(self, UIViewCurryAnimationCompletedBlockKey);
}

#pragma mark - calculate
- (CGFloat)wy_originCircleRadius {
    return MIN(CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds))/2;
}

- (CGFloat)wy_newCircleRadius {
    return self.wy_originCircleRadius - self.wy_circleDistance / 8;
}

- (CGFloat)wy_circleDistance {
    
    CGPoint p1 = self.wy_originCenter;
    CGPoint p2 = self.center;
    
    return sqrtf(pow(p1.x-p2.x, 2.0)+pow(p1.y-p2.y, 2.0));
}

- (CGFloat)wy_sin {
    return (self.center.x - self.wy_originCenter.x) / self.wy_circleDistance;
}

- (CGFloat)wy_cos {
    return (self.center.y - self.wy_originCenter.y) / self.wy_circleDistance;
}

- (CGPoint)wy_pointA {
    
    CGPoint pointA;
    pointA.x = self.wy_originCenter.x - self.wy_newCircleRadius * self.wy_cos;
    pointA.y = self.wy_originCenter.y + self.wy_newCircleRadius * self.wy_sin;
    
    return pointA;
}

- (CGPoint)wy_pointB {
    
    CGPoint pointB;
    pointB.x = self.wy_originCenter.x + self.wy_newCircleRadius * self.wy_cos;
    pointB.y = self.wy_originCenter.y - self.wy_newCircleRadius * self.wy_sin;
    
    return pointB;
}

- (CGPoint)wy_pointC {
    
    CGPoint pointC;
    pointC.x = self.center.x + self.wy_originCircleRadius * self.wy_cos;
    pointC.y = self.center.y - self.wy_originCircleRadius * self.wy_sin;
    
    return pointC;
}

- (CGPoint)wy_pointD {
    
    CGPoint pointD;
    pointD.x = self.center.x - self.wy_originCircleRadius * self.wy_cos;
    pointD.y = self.center.y + self.wy_originCircleRadius * self.wy_sin;
    
    return pointD;
}

- (CGPoint)wy_pointC1 {
    
    CGPoint pointC1;
    pointC1.x = self.wy_pointA.x + self.wy_circleDistance/2 * self.wy_sin;
    pointC1.y = self.wy_pointA.y + self.wy_circleDistance/2 * self.wy_cos;
    
    return pointC1;
}

- (CGPoint)wy_pointC2 {
    
    CGPoint pointC2;
    pointC2.x = self.wy_pointB.x + self.wy_circleDistance/2 * self.wy_sin;
    pointC2.y = self.wy_pointB.y + self.wy_circleDistance/2 * self.wy_cos;
    
    return pointC2;
}

- (UIBezierPath *)wy_curryPath {
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:self.wy_pointA];
    [path addLineToPoint:self.wy_pointB];
    [path addQuadCurveToPoint:self.wy_pointC controlPoint:self.wy_pointC2];
    [path addLineToPoint:self.wy_pointD];
    [path addQuadCurveToPoint:self.wy_pointA controlPoint:self.wy_pointC1];
//    [path closePath];
    
    return path;
}

#pragma mark - setup

- (void)wy_addCurry {
    [self wy_addCurryWithCompleted:nil];
}

- (void)wy_addCurryWithCompleted:(void (^)(UIView *, BOOL))completedBlock {
    
    NSAssert(self.superview, @"View must add to a superview before curry reaction!");
    
    [self.superview layoutIfNeeded];
    
    if (completedBlock) self.wy_completedBlock = completedBlock;
    
    self.wy_originCenter = self.center;
    
    [self addGestureRecognizer:self.wy_pan];
    self.wy_pan.enabled = YES;
    self.userInteractionEnabled = YES;
}

- (void)wy_removeCurry {
    
    self.wy_pan.enabled = NO;
}

#pragma mark - reaction

- (UIPanGestureRecognizer *)wy_pan {
    UIPanGestureRecognizer *gesture = objc_getAssociatedObject(self, UIViewCurryAnimationPanGestureKey);
    
    if (!gesture) {
        gesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(wy_handlePanGestureRecognizer:)];
        objc_setAssociatedObject(self, UIViewCurryAnimationPanGestureKey, gesture, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    return gesture;
}

- (void)wy_handlePanGestureRecognizer:(UIPanGestureRecognizer *)pan {
    
    // update self center
    
    CGPoint transPoint = [pan translationInView:self];
    CGPoint center = self.center;
    center.x += transPoint.x;
    center.y += transPoint.y;
    self.center = center;
    [pan setTranslation:CGPointZero inView:self];
    
    // configure new circle
    
    self.wy_newCircle.layer.cornerRadius = self.wy_newCircleRadius;
    self.wy_newCircle.frame = CGRectMake(self.wy_newCircle.frame.origin.x,
                                         self.wy_newCircle.frame.origin.y,
                                         2*self.wy_newCircleRadius,
                                         2*self.wy_newCircleRadius);
    self.wy_newCircle.center = self.wy_originCenter;
    
    if (self.wy_newCircleRadius > self.wy_originCircleRadius*minCoe) {
        
        // configure shape layer
        
        self.wy_shapeLayer.path = self.wy_curryPath.CGPath;
        
        if (pan.state == UIGestureRecognizerStateBegan) {
            [self.wy_newCircle setHidden:NO];
            [self.superview.layer insertSublayer:self.wy_shapeLayer below:self.layer];
        }
        
        if (pan.state == UIGestureRecognizerStateEnded) {
            [self.wy_newCircle setHidden:YES];
            [self.wy_shapeLayer removeFromSuperlayer];
            //
            [UIView animateWithDuration:0.5
                                  delay:0
                 usingSpringWithDamping:0.2
                  initialSpringVelocity:0
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^{
                                 self.center = self.wy_originCenter;
                             } completion:^(BOOL finished) {
                             }];
            
            if (self.wy_completedBlock) self.wy_completedBlock(self, NO);
        }
    } else {
        
        [self.wy_newCircle setHidden:YES];
        [self.wy_shapeLayer removeFromSuperlayer];
        
        if (pan.state == UIGestureRecognizerStateEnded) {

            self.hidden = YES;
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.frame];
            
            NSMutableArray *images = [NSMutableArray arrayWithCapacity:9];
            for (NSInteger idx = 0; idx < 9; ++idx) {
                CGFloat radius = idx%2 ? 2.5:3.5;
                radius = radius * self.wy_originCircleRadius / 10.0;
                CGFloat x = (CGRectGetWidth(self.bounds) - 7*self.wy_originCircleRadius / 10.0)/2 * (idx%3);
                CGFloat y = (CGRectGetHeight(self.bounds) - 7*self.wy_originCircleRadius / 10.0)/2 * floor(idx/3.0);
                UIImage *image = [self wy_imageFromColor:self.backgroundColor bounds:self.frame rect:CGRectMake(x, y, 2*radius, 2*radius)];
                [images addObject:image];
            }
            
            imageView.animationImages = [images sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                return arc4random_uniform(2);
            }];
            imageView.animationDuration = 0.5;
            imageView.animationRepeatCount = 1;
            
            [self.superview addSubview:imageView];
            [imageView startAnimating];
            
            self.center = self.wy_originCenter;
            
            if (self.wy_completedBlock) self.wy_completedBlock(self, YES);
        }
    }
}

#pragma mark - Util

- (UIImage *)wy_imageFromColor:(UIColor *)color bounds:(CGRect)bounds rect:(CGRect)rect {
    
    UIGraphicsBeginImageContext(CGSizeMake(bounds.size.width*3, bounds.size.height*3));
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
//    CGContextFillRect(context, rect);
    CGContextFillEllipseInRect(context, CGRectMake(rect.origin.x*3, rect.origin.y*3, rect.size.width*3, rect.size.height*3));
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end

void import_UIView_WYCurryAnimation(){}

