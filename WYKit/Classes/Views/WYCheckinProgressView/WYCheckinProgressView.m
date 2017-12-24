//
//  WYCheckinProgressView.m
//  WYKit
//
//  Created by yingwang on 2017/11/8.
//  Copyright © 2017年 GeorgeWang03. All rights reserved.
//

#import "WYCheckinProgressView.h"

#define OUTTER_BLUE_COLOR [UIColor colorWithRed:145.0/255.0 green:180.0/255.0 blue:253.0/255.0 alpha:1]
#define OUTTER_PURPLE_COLOR [UIColor colorWithRed:201.0/255.0 green:143.0/255.0 blue:234.0/255.0 alpha:1]

#define INNER_PURPLE_COLOR [UIColor colorWithRed:94.0/255.0 green:193.0/255.0 blue:254.0/255.0 alpha:1]
#define INNER_BLUE_COLOR [UIColor colorWithRed:44.0/255.0 green:94.0/255.0 blue:217.0/255.0 alpha:1]

#define DIVERGED_LINE_COLOR [UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:255.0/255.0 alpha:1]

#define CIRCLE_BEAD_COLOR [UIColor colorWithRed:102.0/255.0 green:204.0/255.0 blue:255.0/255.0 alpha:1]

#define DEFAULT_DAY_TEXT_FONT_SIZE 40

#define DEFAULT_ANIMATION_DURATION .8

#define OUTTER_LINE_WIDTH 1
#define BEAD_LINE_WIDTH 1

#define SCREEN_PROPORTION CGRectGetWidth(self.bounds)/110.0

@interface WYCheckinProgressView() <CAAnimationDelegate>

@property (nonatomic) CGFloat currentProgress;
@property (nonatomic) WYCheckinProgressViewState currentState;

@property (nonatomic, strong) CALayer *signLayer;

@property (nonatomic, strong) CALayer *outterRingLayer;
@property (nonatomic, strong) CAShapeLayer *outterRingShadowLayer;

@property (nonatomic, strong) CALayer *divergedLayer;
@property (nonatomic, strong) NSArray *diverges;

@property (nonatomic, strong) CALayer *beadLayer;

@property (nonatomic, strong) CALayer *dayLayer;
@property (nonatomic, strong) CATextLayer *dayTextLayer;

@property (nonatomic, strong) UIButton *button;

@end

@implementation WYCheckinProgressView

- (UIButton *)button {
    if (!_button) {
        _button = [[UIButton alloc] init];
        _button.backgroundColor = [UIColor clearColor];
        
        [_button addTarget:self action:@selector(handleButtonAction:)
          forControlEvents:UIControlEventTouchUpInside];
        
        NSDictionary *metric = @{@"top" : @0,
                                 @"left" : @0,
                                 @"bottom" : @0,
                                 @"right" : @0};
        NSDictionary *views = NSDictionaryOfVariableBindings(_button);
        
        _button.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_button];
        
        NSLayoutFormatOptions opt = NSLayoutFormatAlignAllTop | NSLayoutFormatAlignAllBottom;
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-top-[_button]-bottom-|"
                                                                     options:opt
                                                                     metrics:metric
                                                                       views:views]];
        opt = NSLayoutFormatAlignAllLeft | NSLayoutFormatAlignAllRight;
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-left-[_button]-right-|"
                                                                     options:opt
                                                                     metrics:metric
                                                                       views:views]];
    }
    return _button;
}

- (CALayer *)signLayer {
    if (!_signLayer) {
        _signLayer = [CALayer layer];
        
        // Inner
        
        CAGradientLayer *gradientLayer = [[CAGradientLayer alloc] init];
        gradientLayer.frame = CGRectInset(self.bounds, 14, 14);
        gradientLayer.startPoint = CGPointMake(0, 0);
        gradientLayer.endPoint = CGPointMake(1, 0);
        gradientLayer.colors = @[(__bridge id)INNER_BLUE_COLOR.CGColor, (__bridge id)INNER_PURPLE_COLOR.CGColor];
        
        [_signLayer addSublayer:gradientLayer];
        
        CAShapeLayer *shapeLayer = [[CAShapeLayer alloc] init];
        shapeLayer.frame = gradientLayer.bounds;
        shapeLayer.path = [UIBezierPath bezierPathWithOvalInRect:CGRectInset(gradientLayer.bounds, 2, 2)].CGPath;
        shapeLayer.lineWidth = 4;
        shapeLayer.fillColor = [[UIColor whiteColor] colorWithAlphaComponent:0].CGColor;
        shapeLayer.strokeColor = [UIColor blackColor].CGColor;
        
        gradientLayer.mask = shapeLayer;
        
        // Label
        
        CGFloat fontsize = 22*SCREEN_PROPORTION;
        
        gradientLayer = [[CAGradientLayer alloc] init];
        gradientLayer.frame = CGRectMake(CGRectGetMidX(self.bounds)-25, CGRectGetMidY(self.bounds)-(fontsize+4)/2, 50, fontsize+4);
        gradientLayer.startPoint = CGPointMake(1, 1);
        gradientLayer.endPoint = CGPointMake(0, 0);
        gradientLayer.colors = @[(__bridge id)INNER_BLUE_COLOR.CGColor, (__bridge id)INNER_PURPLE_COLOR.CGColor];
        
        [_signLayer addSublayer:gradientLayer];
        
        NSDictionary *attributes = @{NSFontAttributeName : [UIFont systemFontOfSize:fontsize weight:UIFontWeightBlack],
                                     NSForegroundColorAttributeName : [UIColor blackColor]
                                     };
        NSAttributedString *attributeText = [[NSAttributedString alloc] initWithString:@"签到"
                                                                            attributes:attributes];
        
        CATextLayer *textLayer = [[CATextLayer alloc] init];
        textLayer.alignmentMode = kCAAlignmentCenter;
        textLayer.string = attributeText;
        textLayer.frame = gradientLayer.bounds;
        textLayer.contentsScale = [UIScreen mainScreen].scale;
        
        gradientLayer.mask = textLayer;
    }
    return _signLayer;
}

- (CAShapeLayer *)outterRingShadowLayer {
    if (!_outterRingShadowLayer) {
        CGFloat lineWidth = OUTTER_LINE_WIDTH;
        CAShapeLayer *shapeLayer = [[CAShapeLayer alloc] init];
        shapeLayer.lineWidth = lineWidth;
        shapeLayer.fillColor = [[UIColor whiteColor] colorWithAlphaComponent:0].CGColor;
        shapeLayer.strokeColor = [UIColor blackColor].CGColor;
        
        _outterRingShadowLayer = shapeLayer;
    }
    return _outterRingShadowLayer;
}

- (CALayer *)outterRingLayer {
    if (!_outterRingLayer) {
        
        // Outter
        CAGradientLayer *gradientLayer = [[CAGradientLayer alloc] init];
        gradientLayer.frame = CGRectInset(self.bounds, 8, 8);
        gradientLayer.startPoint = CGPointMake(0, 1);
        gradientLayer.endPoint = CGPointMake(1, 0);
        gradientLayer.colors = @[(__bridge id)OUTTER_PURPLE_COLOR.CGColor, (__bridge id)OUTTER_BLUE_COLOR.CGColor];

        CGFloat lineWidth = OUTTER_LINE_WIDTH;
        self.outterRingShadowLayer.frame = gradientLayer.bounds;
        self.outterRingShadowLayer.path = [UIBezierPath bezierPathWithOvalInRect:CGRectInset(gradientLayer.bounds, lineWidth, lineWidth)].CGPath;
        gradientLayer.mask = self.outterRingShadowLayer;
        
        _outterRingLayer = gradientLayer;
    }
    return _outterRingLayer;
}

- (CALayer *)divergedLayer {
    if (!_divergedLayer) {
        _divergedLayer = [CALayer layer];
        
        // diverged line
        
        NSUInteger numberOfLine = 24;
        CGFloat arcSpacing = 2*M_PI/numberOfLine;
        CGFloat cur_arc = 0;
        CGFloat lenOfLine = 4;
        CGFloat endRadius = CGRectGetWidth(self.bounds)/2;
        CGFloat startRadius = endRadius-lenOfLine;
        CGFloat sx, sy, ex, ey;
        CGPoint center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
        
        CAShapeLayer *layer;
        UIBezierPath *path;
        NSMutableArray *diverges = [NSMutableArray array];
        
        for (NSUInteger idx = 0; idx < numberOfLine; ++idx) {
            path = [UIBezierPath bezierPath];
            
            // start point
            sx = center.x + startRadius*cosf(cur_arc);
            sy = center.y + startRadius*sinf(cur_arc);
            
            // end point
            ex = center.x + endRadius*cosf(cur_arc);
            ey = center.y + endRadius*sinf(cur_arc);
            
            [path moveToPoint:CGPointMake(sx, sy)];
            [path addLineToPoint:CGPointMake(ex, ey)];
            
            layer = [CAShapeLayer layer];
            layer.strokeColor = DIVERGED_LINE_COLOR.CGColor;
            layer.lineWidth = 1;
            layer.path = path.CGPath;
            layer.frame = self.bounds;
            
            [_divergedLayer addSublayer:layer];
            [diverges addObject:layer];
            
            cur_arc += arcSpacing;
        }
        
        self.diverges = diverges;
//
//        CAShapeLayer *shadowLayer = [CAShapeLayer layer];
//        shadowLayer.fillColor = [UIColor whiteColor].CGColor;
//        shadowLayer.path = [UIBezierPath bezierPathWithOvalInRect:CGRectInset(self.bounds, lenOfLine, lenOfLine)].CGPath;
//        shadowLayer.lineWidth = .5;
//        _divergedShadowLayer = shadowLayer;
        
//        [_divergedLayer addSublayer:shadowLayer];
    }
    return _divergedLayer;
}

- (CALayer *)beadLayer {
    if (!_beadLayer) {
        // bead
        
        CAShapeLayer *beadLayer = [CAShapeLayer layer];
        beadLayer.lineWidth = BEAD_LINE_WIDTH;
        beadLayer.fillColor = [UIColor whiteColor].CGColor;
        beadLayer.strokeColor = CIRCLE_BEAD_COLOR.CGColor;
        beadLayer.frame = CGRectMake(CGRectGetWidth(self.bounds)/2+CGRectGetWidth(self.bounds)/2-10.5, CGRectGetWidth(self.bounds)/2, 4, 4);
        beadLayer.path = [UIBezierPath bezierPathWithOvalInRect:beadLayer.bounds].CGPath;
        
        _beadLayer = beadLayer;
    }
    return _beadLayer;
}

- (CALayer *)dayLayer {
    if (!_dayLayer) {
        _dayLayer = [CALayer layer];
        
        // Label
        
        CGFloat fontsize = DEFAULT_DAY_TEXT_FONT_SIZE;
        
        CAGradientLayer *gradientLayer = [[CAGradientLayer alloc] init];
        gradientLayer.frame = CGRectMake(CGRectGetMidX(self.bounds)-25, CGRectGetMidY(self.bounds)-(fontsize+4)/2, 50, fontsize+4);
        gradientLayer.startPoint = CGPointMake(0, 1);
        gradientLayer.endPoint = CGPointMake(0, 0);
        gradientLayer.colors = @[(__bridge id)INNER_BLUE_COLOR.CGColor, (__bridge id)INNER_PURPLE_COLOR.CGColor];
        
        [_dayLayer addSublayer:gradientLayer];
        self.dayTextLayer.frame = gradientLayer.bounds;
        
        gradientLayer.mask = self.dayTextLayer;
    }
    return _dayLayer;
}

- (CATextLayer *)dayTextLayer {
    if (!_dayTextLayer) {
        NSDictionary *attributes = @{NSFontAttributeName : [UIFont systemFontOfSize:DEFAULT_DAY_TEXT_FONT_SIZE*SCREEN_PROPORTION weight:UIFontWeightBlack],
                                     NSForegroundColorAttributeName : [UIColor blackColor]
                                     };
        NSAttributedString *attributeText = [[NSAttributedString alloc] initWithString:@"3"
                                                                            attributes:attributes];
        
        CATextLayer *textLayer = [[CATextLayer alloc] init];
        textLayer.alignmentMode = kCAAlignmentCenter;
        textLayer.string = attributeText;
        textLayer.contentsScale = [UIScreen mainScreen].scale;
        
        _dayTextLayer = textLayer;
    }
    return _dayTextLayer;
}

- (void)reloadWithState:(WYCheckinProgressViewState)state {
    [self reloadWithState:state numberOfDay:self.day];
}

- (void)reloadWithState:(WYCheckinProgressViewState)state progress:(CGFloat)progress {
    [self reloadWithState:state numberOfDay:self.day progress:progress];
}

- (void)reloadWithState:(WYCheckinProgressViewState)state numberOfDay:(NSUInteger)numberOfDay {
    [self reloadWithState:state numberOfDay:numberOfDay progress:self.currentProgress];
}

- (void)reloadWithState:(WYCheckinProgressViewState)state numberOfDay:(NSUInteger)numberOfDay progress:(CGFloat)progress {
    if (state == self.currentState) return;
    
    // 1.remove all sublayer
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.layer.sublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    
    // 2.update layers
    self.currentState = state;
    [self addSubview:self.button];
    
    switch (state) {
        case kWYCheckinProgressViewFinishState:
            [self updateDayLayerWithNumber:numberOfDay];
            [self updateOutterRingForState:state];
            [self.layer addSublayer:self.outterRingLayer];
            [self.layer addSublayer:self.dayLayer];
            break;
        case kWYCheckinProgressViewWaitCheckinState:
            [self.layer addSublayer:self.divergedLayer];
            
            [self updateOutterRingForState:state];
            [self.layer addSublayer:self.outterRingLayer];
            
            self.signLayer.frame = self.bounds;
            [self.layer addSublayer:self.signLayer];
            
            [self updateBeadLocationWithProgress:progress];
            [self.layer addSublayer:self.beadLayer];
            break;
        default:
            break;
    }
}

- (void)updateDayLayerWithNumber:(NSUInteger)number {
    
    self.day = number;
    
    NSDictionary *attributes = @{NSFontAttributeName : [UIFont systemFontOfSize:DEFAULT_DAY_TEXT_FONT_SIZE*SCREEN_PROPORTION
                                                                         weight:UIFontWeightBlack],
                                 NSForegroundColorAttributeName : [UIColor blackColor]
                                 };
    NSAttributedString *attributeText = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%lu", number]
                                                                        attributes:attributes];
    self.dayTextLayer.string = attributeText;
}

- (void)updateOutterRingForState:(WYCheckinProgressViewState)state {
    CGFloat lineWidth = OUTTER_LINE_WIDTH;
    CGFloat inset = 6;
    
    if (state == kWYCheckinProgressViewWaitCheckinState) {
        self.outterRingShadowLayer.path = [UIBezierPath bezierPathWithOvalInRect:CGRectInset(self.outterRingLayer.bounds, lineWidth, lineWidth)].CGPath;
    } else if (state == kWYCheckinProgressViewFinishState) {
        self.outterRingShadowLayer.path = [UIBezierPath bezierPathWithOvalInRect:CGRectInset(self.outterRingLayer.bounds, inset, inset)].CGPath;
    }
}

- (void)updateBeadLocationWithProgress:(CGFloat)progress {
    CGPoint cur_loc = [self beadLocationWithProgress:progress];
    self.currentProgress = progress;
    self.beadLayer.position = CGPointMake(cur_loc.x, cur_loc.y);
//    self.beadLayer.frame = CGRectMake(cur_loc.x-CGRectGetWidth(self.layer.bounds)/2, cur_loc.y-CGRectGetHeight(self.layer.bounds)/2, CGRectGetWidth(self.layer.bounds), CGRectGetHeight(self.layer.bounds));
}

- (CGPoint)beadLocationWithProgress:(CGFloat)progress {
    progress = fmin(progress, 1.0);
    
    CGFloat target_arc = -M_PI_2+2*M_PI*progress;
    CGPoint center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    
    CGFloat radius = CGRectGetWidth(self.outterRingLayer.bounds) / 2 - OUTTER_LINE_WIDTH/2;
    return CGPointMake(center.x+radius*cos(target_arc), center.x+radius*sin(target_arc));
}

- (void)startAnimationToDay:(NSUInteger)day {
    [self startAnimationToDay:day progress:self.currentProgress];
}

- (void)startAnimationToDay:(NSUInteger)day progress:(CGFloat)progress {
    
    if (self.currentState == kWYCheckinProgressViewFinishState) {
        return;
    }
    
    //    self.currentState = kIPDailySignAnimatorViewFinishState;
    [self updateDayLayerWithNumber:day];
    
    if (progress != self.currentProgress) {
        
        UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds))
                                                            radius:CGRectGetWidth(self.outterRingLayer.bounds)/2-OUTTER_LINE_WIDTH/2
                                                        startAngle:-M_PI_2+2*M_PI*self.currentProgress
                                                          endAngle:-M_PI_2+2*M_PI*progress
                                                         clockwise:YES];
        self.currentProgress = progress;
        
        CAKeyframeAnimation *beadAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
        beadAnimation.duration = DEFAULT_ANIMATION_DURATION/3;
        beadAnimation.path = path.CGPath;
        beadAnimation.delegate = self;
        beadAnimation.removedOnCompletion = NO;
        beadAnimation.fillMode = kCAFillModeForwards;
        [beadAnimation setValue:self.beadLayer forKey:@"beadAnimation"];
        
        [self.beadLayer addAnimation:beadAnimation forKey:@"beadAnimation"];
    }
    
    CABasicAnimation *signAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    signAnimation.duration = DEFAULT_ANIMATION_DURATION*2/3;
    signAnimation.fromValue = @1.0;
    signAnimation.toValue = @0;
    signAnimation.fillMode = kCAFillModeForwards;
    signAnimation.removedOnCompletion = NO;
    signAnimation.delegate = self;
    [signAnimation setValue:self.signLayer forKey:@"signLayerAnimation"];
    
    [self.signLayer addAnimation:signAnimation forKey:@"signLayerAnimation"];
    
    [self.diverges enumerateObjectsUsingBlock:^(CAShapeLayer *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CABasicAnimation *divergedAnimation = [CABasicAnimation animationWithKeyPath:@"strokeStart"];
        divergedAnimation.fromValue = @0;
        divergedAnimation.toValue = @1;
        divergedAnimation.duration = DEFAULT_ANIMATION_DURATION*2/3;
        divergedAnimation.delegate = self;
        divergedAnimation.fillMode = kCAFillModeForwards;
        divergedAnimation.removedOnCompletion = NO;
        
        [divergedAnimation setValue:obj forKey:@"divergedAnimation"];
        [obj addAnimation:divergedAnimation forKey:@"divergedAnimation"];
    }];
    
    CABasicAnimation *outrerLayerAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
    outrerLayerAnimation.fromValue = (__bridge id _Nullable)self.outterRingShadowLayer.path;
    outrerLayerAnimation.toValue = (__bridge id _Nullable)[UIBezierPath bezierPathWithOvalInRect:CGRectInset(self.outterRingLayer.bounds, 6, 6)].CGPath;
    outrerLayerAnimation.fillMode = kCAFillModeForwards;
    outrerLayerAnimation.removedOnCompletion = NO;
    outrerLayerAnimation.beginTime = CACurrentMediaTime() + DEFAULT_ANIMATION_DURATION/3;
    outrerLayerAnimation.duration = DEFAULT_ANIMATION_DURATION*2/3;
    outrerLayerAnimation.delegate = self;
    
    [outrerLayerAnimation setValue:self.outterRingShadowLayer forKey:@"outrerLayerAnimation"];
    [self.outterRingShadowLayer addAnimation:outrerLayerAnimation forKey:@"outrerLayerAnimation"];
    
    self.dayLayer.frame = self.bounds;
    [self.layer addSublayer:self.dayLayer];
    self.dayLayer.opacity = 0;
    
    CABasicAnimation *dayAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    dayAnimation.fromValue = @.7;
    dayAnimation.toValue = @1.0;
    
    CABasicAnimation *alphaAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    alphaAnimation.fromValue = @0;
    alphaAnimation.toValue = @1.0;
    
    CAAnimationGroup *group = [[CAAnimationGroup alloc] init];
    group.beginTime = CACurrentMediaTime() + DEFAULT_ANIMATION_DURATION/3;
    group.duration = DEFAULT_ANIMATION_DURATION*2/3;
    group.delegate = self;
    group.removedOnCompletion = NO;
    group.fillMode = kCAFillModeForwards;
    group.animations = @[dayAnimation, alphaAnimation];
    
    [group setValue:self.dayLayer forKey:@"dayAnimation"];
    
    [self.dayLayer addAnimation:group forKey:@"dayAnimation"];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    
    CALayer *layer = [anim valueForKey:@"signLayerAnimation"];
    if (layer && flag) {
        [self.signLayer setValue:@0 forKeyPath:@"transform.scale"];
//        self.signLayer.transform = CATransform3DScale(CATransform3DIdentity, 0, 0, 1);
    }
    
    CAShapeLayer *divergeLayer = [anim valueForKey:@"divergedAnimation"];
    if (divergeLayer && flag) {
        self.divergedLayer.hidden = YES;
    }
    
    layer = [anim valueForKey:@"outrerLayerAnimation"];
    if (layer && flag) {
        self.outterRingShadowLayer.path = [UIBezierPath bezierPathWithOvalInRect:CGRectInset(self.outterRingLayer.bounds, 6, 6)].CGPath;
    }
    
    layer = [anim valueForKey:@"dayAnimation"];
    if (layer && flag) {
        self.dayLayer.opacity = 1;
    }
    
    layer = [anim valueForKey:@"beadAnimation"];
    if (layer && flag) {
//        self.beadLayer.position = [self beadLocationWithProgress:self.currentProgress];
        [self.beadLayer removeFromSuperlayer];
    }
    
    [CATransaction commit];
}

- (void)handleButtonAction:(UIButton *)sender {
    if (self.handleButtonAction) {
        self.handleButtonAction();
    }
}

@end
