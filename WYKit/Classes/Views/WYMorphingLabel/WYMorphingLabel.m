//
//  WYMorphingLabel.m
//  SwiftToObjcDemo
//
//  Created by yingwang on 2016/10/25.
//  Copyright © 2016年 yingwang. All rights reserved.
//

#import "WYPodDefine.h"
#import "WYMorphingLabel.h"

#define DEFAULT_ANIMATION_DURATION 1.0

@interface WYMorphingChar : NSObject

@property (nonatomic, assign) CGRect frame;
@property (nonatomic, strong) NSString *character;
@property (nonatomic, assign) CGFloat alpha;
@property (nonatomic, assign) CGFloat fontSize;

@property (nonatomic, assign) CGRect maskedFrame;
@property (nonatomic, strong) UIImage *maskedImage;

@end

@implementation WYMorphingChar

@end

@interface WYMorphingLabel ()

@property (nonatomic, assign) NSInteger currentFrameIndex;
@property (nonatomic, assign) NSInteger totalFrames;

@property (nonatomic, strong) NSArray *previousCharRects;
@property (nonatomic, strong) NSArray *charRects;
@property (nonatomic, strong) NSMutableArray *emitters;

@property (nonatomic, strong) CADisplayLink *displayLink;

@property (nonatomic, assign) BOOL animatable;

@end

@implementation WYMorphingLabel

- (void)setText:(NSString *)text {
   
    [super setText:text];
    
    [self initializeNormalState];
}

- (NSMutableArray *)emitters {
    
    if (!_emitters) {
        _emitters = [NSMutableArray array];
    }
    return _emitters;
}

- (CADisplayLink *)displayLink {
    
    if (!_displayLink) {
        _displayLink = [CADisplayLink displayLinkWithTarget:self
                                                   selector:@selector(handleFramesUpdate)];
        [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [_displayLink setPaused:YES];
    }
    
    return _displayLink;
}

- (void)initializeNormalState {
    _totalFrames = 1;
    _currentFrameIndex = 1;
    
    // recalculate chars` rect
    _previousCharRects = nil;
    _charRects = [self rectsOfString:self.text
                                font:self.font];
}

- (void)initializeAnimationState {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    _totalFrames = DEFAULT_ANIMATION_DURATION * 60 / self.displayLink.frameInterval;
#pragma clang diagnostic pop
    _currentFrameIndex = 0;
    
    // recalculate chars` rect
    _previousCharRects = nil;
    _charRects = [self rectsOfString:self.text
                                font:self.font];
}

- (void)handleFramesUpdate {

    if (_currentFrameIndex > _totalFrames) {
        _currentFrameIndex = 0;
        // 不循环播放
        if (!_repetable) {
            [self stopAnimation];
            return;
        }
    }
    
//    NSLog(@"current frame %lu", _currentFrameIndex);
    [self setNeedsDisplay];
    _currentFrameIndex += 1;
}

- (void)drawTextInRect:(CGRect)rect {
    
//    if (!_animatable) {
//        [super drawTextInRect:rect];
//        return;
//    }
    
    CGFloat progress = fmin((float)(_currentFrameIndex) / (float)_totalFrames, 1.0);
//    NSLog(@"progress %f", progress);
    if (progress <= 0 || progress > 1) {
        _previousCharRects = _charRects;
        return;
    }
    
    NSInteger index = 0;
    CAEmitterLayer *emitter;
    NSArray *characters = [self currentCharacters];

    for (WYMorphingChar *character in characters) {
        [self setupMaskedImageWithCharacter:character progress:progress];
        [character.maskedImage drawInRect:character.maskedFrame];
        
        emitter = [self getEmitterAtIndex:index++];
        
        if (progress < 0.65) {
            emitter.emitterSize = CGSizeMake(character.frame.size.width, 1.0);
            emitter.position = CGPointMake(CGRectGetMidX(character.frame), CGRectGetMaxY(character.maskedFrame));
            [self.layer addSublayer:emitter];
        } else {
            emitter.position = CGPointMake(CGRectGetMidX(character.frame), CGRectGetMinY(character.maskedFrame));
            [emitter removeFromSuperlayer];
        }
    }
    
    if (progress < 0.2 && _previousCharRects.count) {
        characters = [self currentPreviousCharactersWithProgress:progress / 0.2];
        for (WYMorphingChar *character in characters) {
            [character.character drawInRect:character.frame
                             withAttributes:@{NSFontAttributeName:self.font,
                                              NSForegroundColorAttributeName:
                                                  [self.textColor colorWithAlphaComponent:character.alpha]
                                              }];
        }
    }
}

- (void)startAnimation {
    
    _animatable = YES;
    [self initializeAnimationState]; //初始化所有状态
    self.displayLink.paused = NO;
}

- (void)stopAnimation {
    
    _animatable = NO;
    self.displayLink.paused = YES;
    
    [self initializeNormalState];
    [self stopEmitting]; // 停止粒子效果
    [self setNeedsDisplay]; //重绘
}

- (void)stopEmitting {
    
    if(!self.emitters.count) return;
    
    for (CAEmitterLayer *emitter in self.emitters) {
        [emitter removeFromSuperlayer];
    }
}

- (NSArray *)currentCharacters {
    
    NSMutableArray *characters = [NSMutableArray array];
    
    WYMorphingChar *currentMorhingChar;
    
    for(NSInteger idx = 0; idx < self.text.length; ++ idx) {
        
        currentMorhingChar = [[WYMorphingChar alloc] init];
        currentMorhingChar.character = [self.text substringWithRange:NSMakeRange(idx, 1)];
        currentMorhingChar.frame = [_charRects[idx] CGRectValue];
        currentMorhingChar.alpha = 1.0;
        currentMorhingChar.fontSize = self.font.pointSize;
        
        [characters addObject:currentMorhingChar];
    }
    
    return characters;
}

- (NSArray *)currentPreviousCharactersWithProgress:(CGFloat)progress {
    
    NSMutableArray *characters = [NSMutableArray array];
    
    WYMorphingChar *currentMorhingChar;
    
    for(NSInteger idx = 0; idx < self.text.length; ++ idx) {
        
        currentMorhingChar = [[WYMorphingChar alloc] init];
        currentMorhingChar.character = [self.text substringWithRange:NSMakeRange(idx, 1)];
        currentMorhingChar.frame = [_previousCharRects[idx] CGRectValue];
        currentMorhingChar.alpha = fmax(0.01, 1.0 - progress);
        currentMorhingChar.fontSize = self.font.pointSize;
        
        [characters addObject:currentMorhingChar];
    }
    
    return characters;
}

- (void)setupMaskedImageWithCharacter:(WYMorphingChar *)character progress:(CGFloat)progress {
    
    CGRect currentRect;
    CGSize currentSize;
    CGFloat maskedHeight;
    
    maskedHeight = fmax(0.01, progress) * character.frame.size.height;
    currentSize = CGSizeMake(character.frame.size.width, maskedHeight);
    currentRect = CGRectMake(0, 0, currentSize.width, currentSize.height);
    
    UIGraphicsBeginImageContextWithOptions(currentSize, NO, [UIScreen mainScreen].scale);
    [character.character drawInRect:currentRect
                     withAttributes:@{NSFontAttributeName:self.font,
                                      NSForegroundColorAttributeName:self.textColor}];
    character.maskedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    character.maskedFrame = CGRectMake(character.frame.origin.x, character.frame.origin.y, currentSize.width, currentSize.height);
}

- (NSArray *)rectsOfString:(NSString *)string font:(UIFont *)font{
    
    if (!string || string.length == 0) {
        return nil;
    }
    
    CGRect bounds = self.bounds;
    CGFloat boundsWidth = CGRectGetWidth(bounds);
    CGFloat boundsHeight = CGRectGetHeight(bounds);
    NSMutableArray *tempRects = [NSMutableArray array];
    NSMutableArray *resultRects = [NSMutableArray array];
    
    CGFloat charHeight = [@"Leg" sizeWithAttributes:@{NSFontAttributeName:font}].height;
    
    CGFloat leftOffset = 0.0;
    CGFloat topOffset = (boundsHeight - charHeight)/2;
    
    CGSize charSize;
    CGRect charRect;
    CGFloat totalWidth, totalLeftOffset;
    
    for(NSInteger idx = 0; idx < string.length; ++ idx) {
        
        charSize = [[string substringWithRange:NSMakeRange(idx, 1)]
                    sizeWithAttributes:@{NSFontAttributeName:font}];
        charRect = CGRectMake(leftOffset, topOffset, charSize.width, charSize.height);
        [tempRects addObject:[NSValue valueWithCGRect:charRect]];
        
        leftOffset += charSize.width;
    }
    
    totalWidth = leftOffset;
    switch (self.textAlignment) {
        case NSTextAlignmentRight:
            totalLeftOffset = boundsWidth - totalWidth;
            break;
        case NSTextAlignmentCenter:
            totalLeftOffset = (boundsWidth - totalWidth) / 2;
            break;
        default:
            totalLeftOffset = 0.0;
            break;
    }
    
    for (NSValue *val in tempRects) {
        charRect = [val CGRectValue];
        charRect = CGRectOffset(charRect, totalLeftOffset, 0.0);
        [resultRects addObject:[NSValue valueWithCGRect:charRect]];
    }
    
    return resultRects;
}

- (CAEmitterLayer *)getEmitterAtIndex:(NSInteger)index {
    
    CAEmitterLayer *emitter;
    
    if (index < self.emitters.count) {
        emitter = self.emitters[index];
    } else {
        emitter = [self createEmitter];
        [self.emitters addObject:emitter];
    }
    
    return emitter;
}

- (CAEmitterLayer *)createEmitter {
    
    CAEmitterLayer *emitter = [CAEmitterLayer layer];
    emitter.renderMode = kCAEmitterLayerOutline;
    emitter.emitterShape = kCAEmitterLayerLine;
    
    UIImage *image = WYPodImageNamed(@"ic_basic_sparkle");
    
    CAEmitterCell *cell = [CAEmitterCell emitterCell];
    cell.contents = (__nonnull id)image.CGImage;
    cell.birthRate = self.font.pointSize * (CGFloat)(arc4random_uniform(7) + 3);
    cell.velocity = 50;
    cell.velocityRange = -80.0;
    cell.lifetime = 0.16;
    cell.lifetimeRange = 0.1;
    cell.emissionLongitude = (CGFloat)(M_PI / 2.0);
    cell.emissionRange = (CGFloat)(M_PI_2 * 2.0);
    cell.scale = self.font.pointSize / 300.0;
    cell.yAcceleration = 100;
    cell.scaleSpeed = self.font.pointSize / 300.0 * -1.5;
    cell.scaleRange = 0.1;
    cell.color = [UIColor darkGrayColor].CGColor;
    
    emitter.emitterCells = @[cell];
    
    return emitter;
}

@end
