//
//  WYModalPresentView.m
//  WYKit
//
//  Created by yingwang on 2017/5/16.
//  Copyright © 2017年 GeorgeWang03. All rights reserved.
//
//  模态展示视图
//

#import "WYModalPresentView.h"
#import <Masonry/Masonry.h>

@interface WYModalPresentView ()

@property (nonatomic, strong) UIView<WYModalPresentProtocal> *coreView;

@property (nonatomic, strong) UIView *backgroundShadowView; //背景遮罩层

@property (nonatomic) BOOL isShowing;

@property (nonatomic) WYModalPresentViewAnimationStyle currentAnimationStyle;

@end

@implementation WYModalPresentView
#pragma mark - Getter Setter

- (BOOL)showing {
    return _isShowing;
}

- (UIView *)backgroundShadowView {
    if (!_backgroundShadowView) {
        UIView *backgroundView = [[UIView alloc] init];
        backgroundView.backgroundColor = [UIColor blackColor];
        backgroundView.alpha = 0.0;
        _backgroundShadowView = backgroundView;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleShadowViewTapGestureRecognizer:)];
        [_backgroundShadowView addGestureRecognizer:tap];
    }
    return _backgroundShadowView;
}

#pragma mark - Intial
- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupSubviews];
    }
    return self;
}

- (instancetype)initWithCoreView:(UIView<WYModalPresentProtocal> *)coreView {
    self = [super init];
    if (self) {
        _coreView = coreView;
        [self setupSubviews];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame coreView:(UIView<WYModalPresentProtocal> *)coreView {
    self = [super initWithFrame:frame];
    if (self) {
        _coreView = coreView;
        [self setupSubviews];
    }
    return self;
}

#pragma mark - Event

- (void)handleShadowViewTapGestureRecognizer:(UIGestureRecognizer *)recognizer {
    if (self.hideWhenTapShadow) {
        [self hideWithAnimation:_currentAnimationStyle];
    }
}

#pragma mark - Layout
- (void)layoutSubviews {
    [super layoutSubviews];

}

- (void)setupSubviews {
    self.layer.masksToBounds = YES;
    
    [self addSubview:self.backgroundShadowView];
    [self addSubview:self.coreView];
    
    UIEdgeInsets padding = UIEdgeInsetsMake(0, 0, 0, 0);
    
    __weak typeof(self) weakSelf = self;
    [_backgroundShadowView mas_makeConstraints:^(MASConstraintMaker *make) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        make.left.equalTo(strongSelf.mas_left).with.offset(padding.left);
        make.right.equalTo(strongSelf.mas_right).with.offset(-padding.right);
        make.top.equalTo(strongSelf.mas_top).with.offset(padding.top);
        make.bottom.equalTo(strongSelf.mas_bottom).with.offset(-padding.bottom);
    }];
    
    self.hidden = YES;
    self.userInteractionEnabled = NO;
}

#pragma mark - Other

- (void)presentView:(UIView<WYModalPresentProtocal> *)view animation:(WYModalPresentViewAnimationStyle)style {
    self.coreView = view;
    [self addSubview:view];
    
    id<WYModalPresentProtocal> layoutDelegate = self.layoutDelegate ?: self.coreView;
    NSAssert([layoutDelegate respondsToSelector:@selector(presentViewWillLayoutSubviews:)], @"Core View or LayoutDelegate in WYModalPresentView must respond to selector : presentViewWillLayoutSubviews:");
    [layoutDelegate presentViewWillLayoutSubviews:self];
    [view layoutIfNeeded];
    
    self.hidden = NO;
    self.userInteractionEnabled = YES;
    CGFloat animationDuration = 0.6;
    
    self.currentAnimationStyle = style;
    self.coreView.transform = [self hidingTransformForAnimationStyle:style viewBounds:self.coreView.bounds progress:1];
    [UIView animateWithDuration:animationDuration
                     animations:^{
                         self.coreView.transform = CGAffineTransformIdentity;
                         //调整背景遮罩的透明度
                         self.backgroundShadowView.alpha = 0.3;
                     } completion:^(BOOL finished) {
                         self.isShowing = finished;
                     }];
}

- (void)hideWithAnimation:(WYModalPresentViewAnimationStyle)style {
    
    
    self.userInteractionEnabled = NO;
    CGFloat animationDuration = 0.6;
    
    self.coreView.transform = CGAffineTransformIdentity;
    [UIView animateWithDuration:animationDuration
                     animations:^{
                         self.coreView.transform = [self hidingTransformForAnimationStyle:style viewBounds:self.coreView.bounds progress:1];
                         //调整背景遮罩的透明度
                         self.backgroundShadowView.alpha = 0.0;
                     } completion:^(BOOL finished) {
                         if (finished) {
                             
                             [self.coreView removeFromSuperview];
                             self.hidden = YES;
                             self.isShowing = !finished;
                         }
                     }];
}

/**
 动画进度
 */
- (void)transformStyle:(WYModalPresentViewAnimationStyle)style
              progress:(CGFloat)progress
              animated:(BOOL)animated {
    
    CGFloat animationDuration = 0.6;

    if (animated) {
        [UIView animateWithDuration:animationDuration
                         animations:^{
                             self.coreView.transform = [self hidingTransformForAnimationStyle:style viewBounds:self.coreView.bounds progress:1-progress];
                             //调整背景遮罩的透明度
                             self.backgroundShadowView.alpha = 0.3*progress;
                         } completion:^(BOOL finished) {
                             if (finished) {
                                 
                                 self.isShowing = progress > 0;
                                 if (!self.isShowing) [self.coreView removeFromSuperview];
                                 self.hidden = !self.isShowing;
                             }
                         }];
    } else {
        self.coreView.transform = [self hidingTransformForAnimationStyle:style viewBounds:self.coreView.bounds progress:1-progress];
        //调整背景遮罩的透明度
        self.backgroundShadowView.alpha = 0.3*progress;
        self.isShowing = progress > 0;
        if (!self.isShowing) [self.coreView removeFromSuperview];
        self.hidden = !self.isShowing;
    }
}

- (CGAffineTransform)hidingTransformForAnimationStyle:(WYModalPresentViewAnimationStyle)style viewBounds:(CGRect)viewBounds progress:(CGFloat)progress {
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    switch (style) {
        case WYModalPresentViewAnimationStylePullDown:
            transform = CGAffineTransformTranslate(transform, 0, -CGRectGetHeight(viewBounds)*progress);
            break;
        case WYModalPresentViewAnimationStyleExpand:
            transform = CGAffineTransformScale(transform, 0.01, 0.01);
            break;
        case WYModalPresentViewAnimationStylePullLeft:
            transform = CGAffineTransformTranslate(transform, -CGRectGetWidth(viewBounds)*progress, 0);
            break;
        default:
            break;
    }
    return transform;
}

@end
