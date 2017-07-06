//
//  WYCircleProgressBar.m
//  WYKit
//
//  Created by yingwang on 2016/10/28.
//  Copyright © 2016年 yingwang. All rights reserved.
//

#import "WYCircleProgressBar.h"

#define DEFAULT_ANIMATION_DURATION 0.5
#define DEFAULT_ANIMTAION_INTERVAL 1.0

@interface WYCPCircleLayer ()

@property (nonatomic, assign) WYCPCircleLayerType type;
@property (nonatomic, assign) CGFloat radius;
@property (nonatomic, strong) UIColor *color;

@property (nonatomic, strong) CAShapeLayer *topLayer;

@property (nonatomic, assign) NSInteger progress;
@property (nonatomic, assign) BOOL animating;
@property (nonatomic, assign) NSInteger totalFrame;
@property (nonatomic, assign) NSInteger totalIntervalFrame;
@property (nonatomic, strong) CADisplayLink *displayLink;
@end

@implementation WYCPCircleLayer

- (instancetype)initWithFrame:(CGRect)frame type:(WYCPCircleLayerType)type radius:(CGFloat)radius color:(UIColor *)color {
    self = [super init];
    if (self) {
        self.frame = frame;
        _type = type;
        _radius = radius;
        _color = color;
        
        if(_type == kWYCPCircleLayerTypeHighlighted) {
            [self drawHighlightedCircle];
        } else {
            [self drawNormalCircleSolid:(_type == kWYCPCircleLayerTypeNormalSolid)];
        }
    }
    return self;
}

- (void)drawNormalCircleSolid:(BOOL)isSolid {
    
    CGRect rect = CGRectMake(0, 0, 2*_radius, 2*_radius);
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:rect];
    
    self.path = path.CGPath;
    
    if (isSolid) {
        self.fillColor = _color.CGColor;
        self.strokeColor = _color.CGColor;
    } else {
        self.strokeColor = _color.CGColor;
        self.fillColor = [UIColor clearColor].CGColor;
        self.lineWidth = 1.0;
    }
}

- (void)drawHighlightedCircle {
    
    _topLayer = [CAShapeLayer layer];
    _topLayer.frame = CGRectMake(self.bounds.size.width/2-2.0*_radius, self.bounds.size.height/2-2.0*_radius, 4.0*_radius, 4.0*_radius);
    [self addSublayer:_topLayer];
    
    CGFloat radius = 1.5 + _radius + 0.5;
    CGRect ovalRect = CGRectMake(CGRectGetWidth(_topLayer.bounds)/2-radius, CGRectGetHeight(_topLayer.bounds)/2-radius, 2*radius, 2*radius);
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:ovalRect];
    _topLayer.path = path.CGPath;
    _topLayer.fillColor = [UIColor clearColor].CGColor;
    _topLayer.strokeColor = _color.CGColor;
    _topLayer.lineWidth = 1;
    
    radius = _radius - 0.5;
    ovalRect = CGRectMake(CGRectGetWidth(self.bounds)/2-radius, CGRectGetHeight(self.bounds)/2-radius, 2*radius, 2*radius);
    path = [UIBezierPath bezierPathWithOvalInRect:ovalRect];
    self.path = path.CGPath;
    self.lineWidth = 1;
    self.fillColor = _color.CGColor;
    self.strokeColor = _color.CGColor;
    
    _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(handleScreenUpdate)];
    _displayLink.frameInterval = 1;
    
    _totalFrame = DEFAULT_ANIMATION_DURATION * 60 / _displayLink.frameInterval;
    _totalIntervalFrame = DEFAULT_ANIMTAION_INTERVAL * 60 / _displayLink.frameInterval;
    _progress = 0;
    
    [_displayLink addToRunLoop:[NSRunLoop currentRunLoop]
                       forMode:NSRunLoopCommonModes];
    _displayLink.paused = YES;
}

- (void)setAnimatable:(BOOL)animatable {
    _animatable = animatable;
    
    if (_animatable) {
        _displayLink.paused = NO;
        [self starAnimation];
    } else {
        _displayLink.paused = YES;
        [self stopAnimation];
    }
}

- (void)starAnimation {
    _progress = 0;
    _animating = YES;
}

- (void)stopAnimation {
    _progress = 0;
    _animating = NO;
}

- (void)handleScreenUpdate {
    
    ++ _progress;
    
    if (!_animating) {
        if (_progress > _totalIntervalFrame) {
            [self starAnimation];
        }
        return;
    }
    
    if (_progress > _totalFrame) {
        [self stopAnimation];
        return;
    }
    
    CGFloat radius;
    CGFloat lineWidth;
    CGRect ovalRect;
    UIBezierPath *path;
    
    if (!_topLayer) {
        _topLayer = [CAShapeLayer layer];
        _topLayer.frame = CGRectMake(self.bounds.size.width/2-2.0*_radius, self.bounds.size.height/2-2.0*_radius, 4.0*_radius, 4.0*_radius);
        [self addSublayer:_topLayer];
    }
    
    if (_progress < _totalFrame / 3) {
        radius = 2.5 + _radius * _progress / (_totalFrame / 3);
        ovalRect = CGRectMake(CGRectGetWidth(_topLayer.bounds)/2-radius, CGRectGetHeight(_topLayer.bounds)/2-radius, 2*radius, 2*radius);
        path = [UIBezierPath bezierPathWithOvalInRect:ovalRect];
        _topLayer.path = path.CGPath;
        _topLayer.fillColor = [_color colorWithAlphaComponent:0.3].CGColor;
        _topLayer.strokeColor = [_color colorWithAlphaComponent:0.5].CGColor;
    }
    
    if (_progress >= _totalFrame/3 && _progress < _totalFrame * 4/5) {
        lineWidth = 1;
        radius = 1.5 + _radius * (_progress-_totalFrame/3) / (_totalFrame * 4/5 - _totalFrame/3) + lineWidth/2;
        ovalRect = CGRectMake(CGRectGetWidth(_topLayer.bounds)/2-radius, CGRectGetHeight(_topLayer.bounds)/2-radius, 2*radius, 2*radius);
        path = [UIBezierPath bezierPathWithOvalInRect:ovalRect];
        _topLayer.path = path.CGPath;
        _topLayer.fillColor = [UIColor clearColor].CGColor;
        _topLayer.strokeColor = _color.CGColor;
        _topLayer.lineWidth = lineWidth;
    }
    
    if (_progress >= _totalFrame * 2/3) {
        lineWidth = 1;
        radius = _radius * (_progress-_totalFrame * 2/3)*3/_totalFrame - lineWidth/2;
        ovalRect = CGRectMake(CGRectGetWidth(self.bounds)/2-radius, CGRectGetHeight(self.bounds)/2-radius, 2*radius, 2*radius);
        path = [UIBezierPath bezierPathWithOvalInRect:ovalRect];
        self.path = path.CGPath;
        self.lineWidth = lineWidth;
        self.fillColor = _color.CGColor;
        self.strokeColor = _color.CGColor;
    } else {
        self.path = [UIBezierPath bezierPath].CGPath;
    }
}

@end

@interface WYCircleProgressBar ()
{
    UIColor *_highlightedColor;
    UIColor *_normalColor;
}

@property (nonatomic, assign) CGFloat radius;
@property (nonatomic, assign) NSInteger circleCount;

@property (nonatomic, strong) NSMutableArray *dotLayers;

@property (nonatomic, strong) WYCPCircleLayer *animationDot;

@end

@implementation WYCircleProgressBar

- (instancetype)initWithFrame:(CGRect)frame radius:(CGFloat)radius circlesCount:(NSInteger)circlesCount {
    self = [super initWithFrame:frame];
    if (self) {
        _radius = MAX(1, radius);
        _circleCount = circlesCount;
        self.backgroundColor = [UIColor clearColor];
        [self setupDots];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self setupDots];
}

- (UIColor *)highlightedColor {
    if (!_highlightedColor) {
        _highlightedColor = [UIColor orangeColor];
    }
    return _highlightedColor;
}

- (UIColor *)normalColor {
    if (!_normalColor) {
        _normalColor = [UIColor colorWithRed:195.0/255.0 green:195.0/255.0 blue:195.0/255.0 alpha:0.8];
    }
    return _normalColor;
}

- (void)setProgress:(NSInteger)progress {
    _progress = progress;
    [self setupDots];
}

- (void)setHighlightedColor:(UIColor *)highlightedColor {
    _highlightedColor = highlightedColor;
    [self setupDots];
}

- (void)setNormalColor:(UIColor *)normalColor {
    _normalColor = normalColor;
    [self setupDots];
}

- (void)setAnimatable:(BOOL)animatable {
    _animatable = animatable;
    _animationDot.animatable = _animatable;
}

- (CGPoint)currentPosition {
    
    CGFloat margin = self.bounds.size.width/(_circleCount);
    CGFloat currentX = margin/2 + _progress*margin;
    CGFloat currentY = self.frame.size.height/2 - _radius;
    return CGPointMake(currentX, currentY);
}


- (void)setupDots {
    
    for (CALayer *layer in _dotLayers) {
        [layer removeFromSuperlayer];
    }
    
    _dotLayers = [NSMutableArray array];
    
    CGRect frame;
    UIColor *color;
    WYCPCircleLayer *layer;
    WYCPCircleLayerType type;
    CGFloat posX, posY = 0;
    CGFloat margin;
    
    posY = self.frame.size.height/2 - _radius;
    margin = self.bounds.size.width/(_circleCount);
    posX = margin / 2 - _radius;
    
    for (NSInteger idx = 0; idx < _circleCount ; ++idx) {
        frame = CGRectMake(posX, posY, 2*_radius, 2*_radius);
        
        if (idx < _progress) {
            color = self.highlightedColor;
            type = kWYCPCircleLayerTypeNormalSolid;
        } else if(idx == _progress) {
            color = self.highlightedColor;
            type = kWYCPCircleLayerTypeHighlighted;
        } else {
            color = self.normalColor;
            type = kWYCPCircleLayerTypeNormalHollow;
        }
        
        layer = [[WYCPCircleLayer alloc] initWithFrame:frame type:type radius:_radius color:color];
        if(type == kWYCPCircleLayerTypeHighlighted) _animationDot = layer;
        [self.layer addSublayer:layer];
        [_dotLayers addObject:layer];
        layer.animatable = YES;
        posX = posX + margin;
    }
}

@end
