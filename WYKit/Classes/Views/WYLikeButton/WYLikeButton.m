//
//  WYLikeButton.m
//  WYKit
//
//  Created by yingwang on 2017/12/5.
//  Copyright © 2017年 yingwang. All rights reserved.
//

#import "WYLikeButton.h"

@interface UILabel(LetterRect)
@end

@implementation UILabel(LetterRect)

- (CGRect)boundingRectForCharacterRange:(NSRange)range
{
    NSTextStorage *textStorage = [[NSTextStorage alloc] initWithAttributedString:self.attributedText];
    NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
    [textStorage addLayoutManager:layoutManager];
    NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize:[self bounds].size];
    textContainer.lineFragmentPadding = 0;
    [layoutManager addTextContainer:textContainer];
    
    NSRange glyphRange;
    
    // Convert the range for glyphs.
    [layoutManager characterRangeForGlyphRange:range actualGlyphRange:&glyphRange];
    
    return [layoutManager boundingRectForGlyphRange:glyphRange inTextContainer:textContainer];
}

@end

#define DEFAULT_ANIMATION_DURATION 0.3
#define DEFAULT_BEGIN_INTERVAL 0.05

@interface WYLikeButton() <CAAnimationDelegate>

@property (nonatomic, copy) NSString *currentTitleText;
@property (nonatomic, strong) CALayer *animationLayer;
@property (nonatomic, strong) CALayer *staticTextLayer;

@property (nonatomic, getter=isAnimating) BOOL animating;

@end

@implementation WYLikeButton
@synthesize numberOfLike = _numberOfLike;

- (NSInteger)maxNumberOfLike {
    return (_maxNumberOfLike > 9999) ? _maxNumberOfLike : 10000;
}

- (void)changeNumberOfLike:(NSInteger)numberOfLike animated:(BOOL)animated {
    
    BOOL isIncreased;
    NSString *targetString;
    NSString *targetPlaceholderString;
    NSInteger diff = numberOfLike - _numberOfLike;
    
    if (diff > 0) {
        isIncreased = YES;
        
        if (numberOfLike > self.maxNumberOfLike) {
            numberOfLike = self.maxNumberOfLike;
            targetString = [NSString stringWithFormat:@"%lu+", self.maxNumberOfLike];
        } else {
            targetString = [@(numberOfLike) stringValue];
        }
        
    } else if (diff < 0) {
        isIncreased = NO;
        
        if (-numberOfLike > self.maxNumberOfLike) {
            numberOfLike = -self.maxNumberOfLike;
            targetString = [NSString stringWithFormat:@"-%lu+", self.maxNumberOfLike];
        } else {
            targetString = [@(numberOfLike) stringValue];
        }
        
    } else if (numberOfLike == 0) {
        targetString = @"0";
    } else  {
        return;
    }
    
    for (NSUInteger i=0; i < targetString.length; ++i) {
        targetPlaceholderString = targetPlaceholderString ? [targetPlaceholderString stringByAppendingString:@"-"] : @"-";
    }
    
    self.titleLabel.alpha = 0;
    [self.animationLayer removeFromSuperlayer];
    [self.staticTextLayer removeFromSuperlayer];
    [super setTitle:targetPlaceholderString forState:UIControlStateNormal];
    [super layoutIfNeeded];
    
    CGFloat layerWidth = CGRectGetWidth(self.bounds)-CGRectGetMinX(self.titleLabel.frame);
    CGRect layerRect = CGRectMake(CGRectGetMinX(self.titleLabel.frame),
                                  CGRectGetMinY(self.titleLabel.frame),
                                  layerWidth, CGRectGetHeight(self.titleLabel.frame));
    
    if (!animated) {
        self.staticTextLayer = [self textLayerFromString:targetString
                                                    font:self.titleLabel.font
                                               textColor:self.titleLabel.textColor
                                               layerRect:layerRect];
        [self.layer addSublayer:self.staticTextLayer];
    } else {
        CAAnimation *animation = [self animationForIconWithDuration:DEFAULT_ANIMATION_DURATION*2];
        [self.imageView.layer addAnimation:animation forKey:@"animation"];
        
        NSString *rigionText = self.currentTitleText;
        self.animationLayer = [self transiteFromText:rigionText
                                     targetText:targetString
                                                font:self.titleLabel.font
                                           textColor:self.titleLabel.textColor
                                      layerRect:layerRect
                              animationDuration:DEFAULT_ANIMATION_DURATION
                                        animatedDown:!isIncreased
                                     animationFinish:^(CALayer *layer){
                                         // if layer is the current one,
                                         // that means it has not been interrupt when animating
                                         // and no another animation perform currently
                                         if (layer == self.animationLayer) {
                                             
                                         } else {
                                             [layer removeFromSuperlayer];
                                         }
                                        }];
        
        [self.layer addSublayer:self.animationLayer];
    }
    
    self.currentTitleText = targetString;
    _numberOfLike = numberOfLike;
}

- (CAAnimation *)animationForIconWithDuration:(NSTimeInterval)animationDuration {
    CAKeyframeAnimation *kAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    kAnimation.keyTimes = @[@(animationDuration/6), @(animationDuration*3/6), @(animationDuration*5/6), @1];
    
    kAnimation.values = @[@0.8, @1.8, @0.8, @1];
    kAnimation.beginTime = CACurrentMediaTime();
    return kAnimation;
}

- (NSArray<CATextLayer *> *)textLayersFromString:(NSString *)string
                             font:(UIFont *)font textColor:(UIColor *)textColor opacity:(CGFloat)opacity
                        layerRect:(CGRect)layerRect
                   verticalOffset:(CGFloat)verticalOffset {
    
    UILabel *tempLabel = [[UILabel alloc] init];
    //    tempLabel.textAlignment = NSTextAlignmentCenter;
    tempLabel.font = font;
    tempLabel.frame = layerRect;
    tempLabel.text = string;
    
    CGRect letterFrame;
    CATextLayer *textLayer;
    NSMutableArray<CATextLayer *> *textLayers = [NSMutableArray array];
    
    for (NSInteger i = 0; i < string.length; ++i) {
        textLayer = [[CATextLayer alloc] init];
        textLayer.opacity = opacity;
        textLayer.alignmentMode = kCAAlignmentCenter;
        textLayer.string = [[NSAttributedString alloc] initWithString:[string substringWithRange:NSMakeRange(i, 1)]
                                                           attributes:@{NSFontAttributeName:font,
                                                                        NSForegroundColorAttributeName:textColor}];
        textLayer.contentsScale = [UIScreen mainScreen].scale;
        
        letterFrame = [tempLabel boundingRectForCharacterRange:NSMakeRange(i, 1)];
        letterFrame.origin.y += verticalOffset;
        textLayer.frame = letterFrame;
        
        [textLayers addObject:textLayer];
    }
    
    return [textLayers copy];
}

- (CALayer *)textLayerFromString:(NSString *)string
                            font:(UIFont *)font
                       textColor:(UIColor *)textColor
                       layerRect:(CGRect)layerRect {
    
    CALayer *targetLayer = [CALayer layer];
    targetLayer.frame = layerRect;
    
    NSArray<CALayer *> *layers = [self textLayersFromString:string font:font
                                       textColor:textColor opacity:1
                                       layerRect:layerRect
                                  verticalOffset:0];
    
    [layers enumerateObjectsUsingBlock:^(CALayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [targetLayer addSublayer:obj];
    }];
    
    return targetLayer;
}

- (CALayer *)transiteFromText:(NSString *)rigionText
                   targetText:(NSString *)targetText
                         font:(UIFont *)font
                    textColor:(UIColor *)textColor
                    layerRect:(CGRect)layerRect
            animationDuration:(CGFloat)animationDuration
                 animatedDown:(BOOL)animatedDown animationFinish:(void(^)(CALayer *))animationFinish {
    
    CALayer *animationLayer;
    CGFloat boundsHeight;
    
    boundsHeight = CGRectGetHeight(layerRect);
    
    animationLayer = [CALayer layer];
    animationLayer.frame = layerRect;
    
    NSArray *rigionTextLayers = [self textLayersFromString:rigionText
                                                      font:font
                                                 textColor:textColor opacity:1
                                                 layerRect:layerRect
                                            verticalOffset:0];
    NSArray *targetTextLayers = [self textLayersFromString:targetText
                                                      font:font
                                                 textColor:textColor opacity:0
                                                 layerRect:layerRect
                                            verticalOffset:(animatedDown ? -boundsHeight : boundsHeight)];
    
    void(^layerAnimator)(CATextLayer *, CGPoint, CGFloat, CFTimeInterval) = ^(CATextLayer *layer, CGPoint targetPoint, CGFloat alpha, CFTimeInterval beginTime) {
        
        CABasicAnimation *positionAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
        positionAnimation.toValue = [NSValue valueWithCGPoint:targetPoint];
        
        CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        opacityAnimation.toValue = @(alpha);
        
        CAAnimationGroup *group = [[CAAnimationGroup alloc] init];
        group.duration = animationDuration;
        group.fillMode = kCAFillModeForwards;
        group.removedOnCompletion = NO;
        group.beginTime = beginTime;
        group.delegate = self;
        group.animations = @[positionAnimation, opacityAnimation];
        
        [group setValue:@[layer, [NSValue valueWithCGPoint:targetPoint], @(alpha)]
                     forKey:@"userInfo"];
        [layer addAnimation:group forKey:@"layerAnimation"];
    };
    
    __block CGFloat beginTime, finistTime;
    CGPoint targetPoint;
    CATextLayer *rTextLayer, *cTextLayer;
    
    beginTime = CACurrentMediaTime();
    finistTime = 0;
    
    if (rigionText.length == targetText.length) {
        for (NSInteger i = 0; i < rigionText.length; ++i) {
            rTextLayer = rigionTextLayers[i];
            cTextLayer = targetTextLayers[i];
            // same letter
            if ([[rTextLayer.string string] isEqualToString:[cTextLayer.string string]]) {
                
                [animationLayer addSublayer:rTextLayer];
                targetPoint = CGPointMake(cTextLayer.position.x, rTextLayer.position.y);
                layerAnimator(rTextLayer, targetPoint, 1, beginTime);
                beginTime += DEFAULT_BEGIN_INTERVAL;
                finistTime += DEFAULT_BEGIN_INTERVAL;
            } else {
                // rigion layer
                [animationLayer addSublayer:rTextLayer];
                targetPoint = CGPointMake(rTextLayer.position.x, rTextLayer.position.y-pow(-1, animatedDown)*boundsHeight);
                layerAnimator(rTextLayer, targetPoint, 0, beginTime);
                beginTime += DEFAULT_BEGIN_INTERVAL;
                finistTime += DEFAULT_BEGIN_INTERVAL;
                
                [animationLayer addSublayer:cTextLayer];
                targetPoint = CGPointMake(cTextLayer.position.x, cTextLayer.position.y-pow(-1, animatedDown)*boundsHeight);
                layerAnimator(cTextLayer, targetPoint, 1, beginTime);
                beginTime += DEFAULT_BEGIN_INTERVAL;
                finistTime += DEFAULT_BEGIN_INTERVAL;
            }
        }
    } else {
        [rigionTextLayers enumerateObjectsUsingBlock:^(CATextLayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [animationLayer addSublayer:obj];
            CGPoint targetPoint = CGPointMake(obj.position.x, obj.position.y-pow(-1, animatedDown)*boundsHeight);
            layerAnimator(obj, targetPoint, 0, beginTime);
            beginTime += DEFAULT_BEGIN_INTERVAL;
            finistTime += DEFAULT_BEGIN_INTERVAL;
        }];
        
        [targetTextLayers enumerateObjectsUsingBlock:^(CATextLayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [animationLayer addSublayer:obj];
            CGPoint targetPoint = CGPointMake(obj.position.x, obj.position.y-pow(-1, animatedDown)*boundsHeight);
            layerAnimator(obj, targetPoint, 1, beginTime);
            beginTime += DEFAULT_BEGIN_INTERVAL;
            finistTime += DEFAULT_BEGIN_INTERVAL;
        }];
    }
    
    finistTime = (finistTime-DEFAULT_BEGIN_INTERVAL+DEFAULT_ANIMATION_DURATION);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(finistTime * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
        if (animationFinish) {
            animationFinish(animationLayer);
        }
    });
    
    return animationLayer;
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    
    NSArray *userInfos = [anim valueForKey:@"userInfo"];
    
    if (userInfos) {
        CALayer *layer = [userInfos firstObject];
        CGPoint position = [[userInfos objectAtIndex:1] CGPointValue];
        CGFloat opacity = [[userInfos objectAtIndex:2] floatValue];
        
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        
        layer.opacity = opacity;
        layer.position = position;
        
        if (opacity == 0) [layer removeFromSuperlayer];
        
        [CATransaction commit];
    }
}

@end







