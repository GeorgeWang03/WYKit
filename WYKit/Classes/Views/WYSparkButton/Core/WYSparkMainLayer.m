//
//  WYSparkMainLayer.m
//  SwiftToObjcDemo
//
//  Created by yingwang on 2016/10/20.
//  Copyright © 2016年 yingwang. All rights reserved.
//

#import "WYSparkMainLayer.h"
#import "WYSparkIconLayer.h"
#import "WYSparkDotLayer.h"
#import "WYSparkHelper.h"
#import "WYSparkRingLayer.h"

#define ICON_ANIMATION_DURATION 1

#define DOT_RANG_RADIUS_COEFFICENCY 1.5
#define DEFAULT_RING_LINEWIDTH 3.0

@interface WYSparkMainLayer ()

@property (nonatomic, weak) UIButton *button;
@property (nonatomic, strong) NSDictionary *attributes;

@property (nonatomic, strong) WYSparkIconLayer *iconLayer;
@property (nonatomic, strong) WYSparkDotLayer *dotsLayer;
@property (nonatomic, strong) WYSparkRingLayer *ringLayer;

@end

@implementation WYSparkMainLayer

- (instancetype)initWithButton:(UIButton *)button attributes:(NSDictionary *)attributes {
    
    self = [super init];
    if (self) {
        _button = button;
        _attributes = attributes;
        
        self.frame = _button.bounds;
        [self setBackgroundColor:[UIColor clearColor].CGColor];
        
        [self setupDotLayer];
        [self setupIconLayer];
        [self setupRingLayer];
        
//        self.borderColor = [UIColor blackColor].CGColor;
//        self.borderWidth = 2;
        
        [_button setImage:[[UIImage alloc] init] forState:UIControlStateNormal];
        [_button setImage:[[UIImage alloc] init] forState:UIControlStateSelected];
        
        [_button setTitle:nil forState:UIControlStateNormal];
        [_button setTitle:nil forState:UIControlStateSelected];
    }
    return self;
}

- (void)setupIconLayer {
    
    UIImage *iconImage = [_button imageForState:UIControlStateNormal];
    
    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
    [WYSparkHelper dictionary:attributes safelyAddObject:_attributes[kWYSparkIconNormalColor]
                       forKey:kWYSparkIconNormalColor];
    [WYSparkHelper dictionary:attributes safelyAddObject:_attributes[kWYSparkIconSelectedColor]
                       forKey:kWYSparkIconSelectedColor];
    [WYSparkHelper dictionary:attributes safelyAddObject:iconImage
                       forKey:kWYSparkIconImage];
    
    WYSparkIconLayer *iconLayer = [[WYSparkIconLayer alloc] initWithFrame:self.bounds
                                                               attributes:attributes];
    _iconLayer = iconLayer;
    [self addSublayer:iconLayer];
}

- (void)setupDotLayer {
    
    CGFloat radius = [self radius] / 2 * DOT_RANG_RADIUS_COEFFICENCY;
    
    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
    if(_attributes[kWYSparkDotFirstColors]) attributes[kWYSparkDotFirstColors] = _attributes[kWYSparkDotFirstColors];
    if (_attributes[kWYSparkDotSecondColors]) attributes[kWYSparkDotSecondColors] = _attributes[kWYSparkDotSecondColors];
    
    _dotsLayer = [[WYSparkDotLayer alloc] initWithFrame:self.bounds radius:radius attributes:attributes];
    [self addSublayer:_dotsLayer];
}

- (void)setupRingLayer {
    CGFloat radius = [self radius] / 2 * DOT_RANG_RADIUS_COEFFICENCY;
    
    WYSparkRingLayer *ringLayer = [[WYSparkRingLayer alloc] initWithFrame:self.bounds
                                                                   radius:radius
                                                                lineWidth:DEFAULT_RING_LINEWIDTH
                                                               attributes:_attributes];
    _ringLayer = ringLayer;
    [self addSublayer:_ringLayer];
}

- (CGFloat)radius {
    return MAX(CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
}

- (void)animationWithSelected:(BOOL)isSelected {
    
    if (isSelected) {
        [_ringLayer animationToRadiusWithDuration:0.1298 delay:0];
        [_ringLayer animationColapseWithDuration:0.1098 delay:0.1298];
        [_dotsLayer animationWithDuration:1.1 delay:0.18];
        [_iconLayer animationForColorsWithDuration:ICON_ANIMATION_DURATION delay:0.2];
    } else {
        [_iconLayer animationForNormalWithDuration:ICON_ANIMATION_DURATION delay:0];
    }
}

@end
