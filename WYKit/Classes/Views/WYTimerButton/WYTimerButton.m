//
//  WYTimerButton.m
//  WYKit
//
//  Created by yingwang on 2016/12/16.
//  Copyright © 2016年 yingwang. All rights reserved.
//

#import "WYTimerButton.h"
#import "WYTimerDelegate.h"

@interface WYTimerButton ()

@property (nonatomic) NSString *primaryTitle;
@property (nonatomic, strong) UIColor *primaryTitleColor;
@property (nonatomic, strong) UIColor *primaryBorderColor;

@property (nonatomic) NSTimeInterval timerInterval;

@property (nonatomic) BOOL timing;

@property (nonatomic, strong) WYTimerDelegate *timerDelegate;

@property (nonatomic, copy) void(^completeBlock)(BOOL finish);

@end

@implementation WYTimerButton

- (void)dealloc {
    [self.timerDelegate stopTimer];
}

- (void)startTimerWithTimerInterval:(NSTimeInterval)interval completion:(void (^)(BOOL))block {
    
    if (_timing) return;
    
    _primaryTitleColor = self.titleLabel.textColor;
    _primaryBorderColor = [UIColor colorWithCGColor:self.layer.borderColor];
    _primaryTitle = self.titleLabel.text;
    _completeBlock = block;
    _timerInterval = interval;
    
    _timing = YES;
    self.userInteractionEnabled = _touchableWhenTiming;
    
    self.timerDelegate = [[WYTimerDelegate alloc] init];
    
    __weak typeof(self) weakSelf = self;
    [self.timerDelegate startTimerWithTimeInterval:1.0
                                             block:^(NSTimer *timer) {
                                                 __strong typeof(weakSelf) strongSelf = weakSelf;
                                                 --strongSelf.timerInterval;
                                                 
                                                 if (strongSelf.timerInterval == 0) {
                                                     strongSelf.timing = NO;
                                                     [strongSelf.timerDelegate stopTimer];
                                                     strongSelf.userInteractionEnabled = YES;
                                                     
                                                     if (strongSelf.completeBlock) strongSelf.completeBlock(YES);
                                                 }
                                                 
                                                 [strongSelf updateButtonAppearence];
                                             } userInfo:nil repeats:YES];
}

- (void)stop {
    
    
    [self.timerDelegate stopTimer];
    self.timerInterval = 0;
    self.timing = NO;
    self.userInteractionEnabled = YES;
    [self updateButtonAppearence];
    
    if (self.completeBlock) self.completeBlock(NO);
}

- (void)updateButtonAppearence {
    
    if (_timing) {
        UIColor *titleColor;
        CGColorRef borderColor;
        titleColor = _timingStateColor ?: [UIColor lightGrayColor];
        borderColor = _timingStateColor ? _timingStateColor.CGColor : [UIColor lightGrayColor].CGColor;
        [self setTitle:[NSString stringWithFormat:@"%.0f秒", _timerInterval] forState:UIControlStateNormal];
        [self setTitleColor:titleColor forState:UIControlStateNormal];
        self.layer.borderColor = borderColor;
    } else {
        [self setTitle:_primaryTitle forState:UIControlStateNormal];
        [self setTitleColor:_primaryTitleColor forState:UIControlStateNormal];
        self.layer.borderColor = _primaryBorderColor.CGColor;
    }
}

@end
