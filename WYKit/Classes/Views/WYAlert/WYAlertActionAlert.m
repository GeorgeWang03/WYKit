//
//  WYAlertActionAlert.m
//  WYKit
//
//  Created by yingwang on 2016/12/27.
//  Copyright © 2016年 yingwang. All rights reserved.
//

#import "WYAlertAction.h"
#import <objc/runtime.h>
#import "WYAlertActionAlert.h"
#import "Masonry.h"

const char *WYAlertActionAlertPrivateTagKey = "WYAlertActionSheetPrivate";

@interface WYAlertAction (WYAlertActionAlertPrivate)
@property (nonatomic) NSInteger tag;
@end

@implementation WYAlertAction(WYAlertActionSheetPrivate)

- (void)setTag:(NSInteger)tag {
    objc_setAssociatedObject(self, WYAlertActionAlertPrivateTagKey, @(tag), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSInteger)tag {
    return [objc_getAssociatedObject(self, WYAlertActionAlertPrivateTagKey) integerValue];
}

@end

@interface WYAlertActionAlert ()

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) UIImage *icon;

@property (nonatomic, strong) UIWindow *privateWindow;//私有window窗口
@property (nonatomic, strong) UIView *backgroundShadowView;//被禁遮罩层

@property (nonatomic, strong) UIView *alertView;
@property (nonatomic, strong) UILabel *privateTitleLabel;
@property (nonatomic, strong) UILabel *messageLabel;
@property (nonatomic, strong) UIImageView *privateIconView;


@property (nonatomic, strong) UIView *alertButtonBackgroundView;

@property (nonatomic, strong) NSMutableArray *privateActionsArray;

@property (nonatomic, strong) UIView *mainView;

@property (nonatomic, strong) UIView *backgroundView;

@end

#define ALERT_MARGIN 30
#define ICON_WIDTH 60
#define ICON_HEIGHT 60

@implementation WYAlertActionAlert

- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message {
    return [self initWithTitle:title message:message icon:nil];
}

- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message icon:(UIImage *)icon {
    self = [super init];
    if (self) {
        _title = title;
        _message = message;
        _icon = icon;
    }
    return self;
}

- (UILabel *)titleLabel {
    return self.privateTitleLabel;
}

- (UILabel *)privateTitleLabel {
    if (!_privateTitleLabel) {
        _privateTitleLabel = [[UILabel alloc] init];
        _privateTitleLabel.textAlignment = NSTextAlignmentCenter;
        _privateTitleLabel.textColor = [UIColor colorWithRed:0 green:153.0/255.0 blue:0 alpha:1];
        _privateTitleLabel.font = [UIFont systemFontOfSize:14.0];
    }
    return _privateTitleLabel;
}

- (UILabel *)messageLabel {
    if (!_messageLabel) {
        _messageLabel = [[UILabel alloc] init];
        _messageLabel.numberOfLines = 0;
        _messageLabel.lineBreakMode = NSLineBreakByCharWrapping;
        _messageLabel.textAlignment = NSTextAlignmentCenter;
        _messageLabel.textColor = [UIColor grayColor];
        _messageLabel.font = [UIFont systemFontOfSize:12.0];
    }
    return _messageLabel;
}

- (UIImageView *)privateIconView {
    if (!_privateIconView) {
        _privateIconView = [[UIImageView alloc] init];
        _privateIconView.contentMode = UIViewContentModeCenter;
    }
    return _privateIconView;
}

- (UILabel *)contentLabel {
    return self.messageLabel;
}

- (UIView *)backgroundShadowView {
    if (!_backgroundShadowView) {
        UIView *backgroundView = [[UIView alloc] init];
        backgroundView.backgroundColor = [UIColor blackColor];
        backgroundView.alpha = 0.0;
        _backgroundShadowView = backgroundView;
    }
    return _backgroundShadowView;
}

- (UIWindow *)privateWindow {
    if (!_privateWindow) {
        _privateWindow  = [[UIWindow alloc] init];
        _privateWindow.windowLevel = UIWindowLevelStatusBar;
        _privateWindow.backgroundColor = [UIColor clearColor];
    }
    return _privateWindow;
}

- (UIView *)alertView {
    if (!_alertView) {
        _alertView = [[UIView alloc] init];
        _alertView.layer.cornerRadius = 5;
        _alertView.clipsToBounds = YES;
        _alertView.layer.masksToBounds = YES;
        
        
        _alertButtonBackgroundView = [[UIView alloc] init];
        _alertView.backgroundColor = [UIColor whiteColor];
        
        self.privateTitleLabel.text = _title;
        self.messageLabel.text = _message;
        self.privateIconView.image = self.icon;
        
        [_alertView addSubview:_privateTitleLabel];
        [_alertView addSubview:_messageLabel];
        [_alertView addSubview:_privateIconView];
        [_alertView addSubview:_alertButtonBackgroundView];
        
        UIEdgeInsets padding = UIEdgeInsetsMake(0, 0, 0, 0);
        __weak typeof(self) weakSelf = self;
        [_privateTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            make.left.equalTo(strongSelf.alertView.mas_left).with.offset(padding.left);
            make.right.equalTo(strongSelf.alertView.mas_right).with.offset(-padding.right);
            make.top.equalTo(strongSelf.privateIconView.mas_bottom).with.offset(padding.top);
            make.height.equalTo(@(20));
        }];
        
        padding = UIEdgeInsetsMake(0, 0, 0, 0);
        [_alertButtonBackgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            make.left.equalTo(strongSelf.alertView.mas_left).with.offset(padding.left);
            make.right.equalTo(strongSelf.alertView.mas_right).with.offset(-padding.right);
            make.bottom.equalTo(strongSelf.alertView.mas_bottom).with.offset(-padding.bottom);
            make.height.equalTo(@(40));
        }];
        
        padding = UIEdgeInsetsMake(15, 0, 0, 0);
        [_privateIconView mas_makeConstraints:^(MASConstraintMaker *make) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            make.centerX.equalTo(strongSelf.alertView);
            make.top.equalTo(strongSelf.alertView.mas_top).with.offset(padding.top);
            make.width.equalTo(@(ICON_WIDTH));
        }];
        
        padding = UIEdgeInsetsMake(0, 0, 0, 0);
        [_messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            make.left.equalTo(strongSelf.alertView.mas_left).with.offset(padding.left);
            make.right.equalTo(strongSelf.alertView.mas_right).with.offset(-padding.right);
            make.bottom.equalTo(strongSelf.alertButtonBackgroundView.mas_top).with.offset(-padding.bottom);
            make.top.equalTo(strongSelf.privateTitleLabel.mas_bottom).with.offset(padding.top);
            make.height.equalTo(@(45));
        }];
    }
    return _alertView;
}

#pragma mark - setup subviews

- (void)layoutInWindow:(UIWindow *)window {
    
    [window addSubview:self.backgroundShadowView];
    [window addSubview:self.alertView];
    
    CGFloat alertViewHeight;
    alertViewHeight = self.icon ? 120 + ICON_HEIGHT : 120;
    
    __weak typeof(self) weakSelf = self;
    UIEdgeInsets padding = UIEdgeInsetsMake(0, ALERT_MARGIN, 0, ALERT_MARGIN);
    [self.alertView mas_makeConstraints:^(MASConstraintMaker *make) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        make.centerY.equalTo(window);
        make.centerX.equalTo(window);
        make.height.equalTo(@(alertViewHeight));
        make.width.equalTo(@(280));
    }];
    
    padding = UIEdgeInsetsMake(0, 0, 0, 0);
    [_backgroundShadowView mas_makeConstraints:^(MASConstraintMaker *make) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        make.left.equalTo(window.mas_left).with.offset(padding.left);
        make.right.equalTo(window.mas_right).with.offset(-padding.right);
        make.top.equalTo(window.mas_top).with.offset(padding.top);
        make.bottom.equalTo(window.mas_bottom).with.offset(-padding.bottom);
    }];
}

- (void)updateAlertButtonBeforeShowing {
    
    CGFloat buttonWidth = (280.0) / _privateActionsArray.count;
   
    UIButton *button;
    UIView *leftView;
    
    [_alertButtonBackgroundView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    NSInteger idx = 0;
    for (WYAlertAction *action in _privateActionsArray) {
        button = [self buttonWithAction:action];
        
        button.tag = idx;
        action.tag = idx;
        [button setTitle:action.title forState:UIControlStateNormal];
        [button addTarget:self action:@selector(handleButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        
        [_alertButtonBackgroundView addSubview:button];
        
        __weak typeof(self) weakSelf = self;
        UIEdgeInsets padding = UIEdgeInsetsMake(0, 0, 0, 0);
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            make.left.equalTo(leftView.mas_right ?: strongSelf.alertButtonBackgroundView.mas_left).with.offset(padding.left);
            make.bottom.equalTo(strongSelf.alertButtonBackgroundView.mas_bottom).with.offset(-padding.bottom);
            make.top.equalTo(strongSelf.alertButtonBackgroundView.mas_top).with.offset(padding.top);
            make.width.equalTo(@(buttonWidth));
        }];
        
        ++ idx;
        leftView = button;
    }
}

- (UIButton *)buttonWithAction:(WYAlertAction *)action {
    
    UIColor *backgroundColor;
    UIColor *textColor;
    UIColor *borderColor;
    
    switch (action.style) {
        case WYAlertActionGray:
        case WYAlertActionDefault:
            backgroundColor = [UIColor whiteColor];
            textColor = [UIColor lightGrayColor];
            borderColor = [UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:1];
            break;
        case WYAlertActionCancel:
            backgroundColor = [UIColor whiteColor];
            textColor = [UIColor redColor];
            borderColor = [UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:1];
            break;
        case WYAlertActionHighlight:
            backgroundColor = [UIColor orangeColor];
            textColor = [UIColor whiteColor];
            borderColor = [UIColor clearColor];
            break;
        case WYAlertActionCustom:
            backgroundColor = action.backgroundColor;
            textColor = action.textColor;
            borderColor = [UIColor clearColor];
            break;
        default:
            break;
    }
    
    UIButton *button = [[UIButton alloc] init];
    [button setTitleColor:textColor forState:UIControlStateNormal];
    [button setBackgroundColor:backgroundColor];
    button.layer.borderWidth = 0.5;
    button.layer.borderColor = borderColor.CGColor;
    button.titleLabel.font = [UIFont systemFontOfSize:14.0];
    
    return button;
}

#pragma mark - Respond Method

- (void)addAction:(WYAlertAction *)action {
    
    if (!_privateActionsArray) _privateActionsArray = [NSMutableArray array];
    
    if ([(WYAlertAction *)[_privateActionsArray lastObject] style] == WYAlertActionCancel) {
        [_privateActionsArray insertObject:action atIndex:_privateActionsArray.count-1];
    } else {
        [_privateActionsArray addObject:action];
    }
}

- (void)handleButtonAction:(UIButton *)sender {
    
    WYAlertAction *action;
    for (action in _privateActionsArray) {
        if (action.tag == sender.tag) {
            break;
        }
    }
    
    if (action && action.handler) {
        action.handler(action);
    }
}

- (void)show {
    [self showWithOrientation:UIInterfaceOrientationPortrait];
}

- (void)showWithOrientation:(UIInterfaceOrientation)orientation {
    [self showWithOrientation:orientation window:self.privateWindow];
}

- (void)showWithOrientation:(UIInterfaceOrientation)orientation window:(UIWindow *)window {
    
    if (window == self.privateWindow) {
        CGRect screenbBounds = [UIScreen mainScreen].bounds;
        if (screenbBounds.size.width > screenbBounds.size.height) screenbBounds.size = CGSizeMake(screenbBounds.size.height, screenbBounds.size.width);
        self.privateWindow.frame = screenbBounds;
        
        [self.privateWindow setHidden:NO];
        [self.privateWindow makeKeyAndVisible];
    }
    
    [self layoutInWindow:window];
    [self updateAlertButtonBeforeShowing];
    
    CGFloat animationDuration = .5;
    
    CGFloat rotation;
    switch (orientation) {
        case UIInterfaceOrientationPortrait:
            rotation = 0;
            break;
        case UIInterfaceOrientationLandscapeLeft:
            rotation = -M_PI_2;
            break;
        case UIInterfaceOrientationLandscapeRight:
            rotation = M_PI_2;
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            rotation = M_PI;
            break;
        default:
            break;
    }
    
    self.alertView.hidden = NO;
    self.alertView.transform = CGAffineTransformMakeScale(0.01, 0.01);
    self.alertView.transform = CGAffineTransformRotate(_alertView.transform, rotation);
    
    [UIView animateWithDuration:animationDuration
                     animations:^{
                         self.alertView.transform = CGAffineTransformMakeScale(1, 1);
                         self.alertView.transform = CGAffineTransformRotate(self.alertView.transform, rotation);
                         //调整背景遮罩的透明度
                         self.backgroundShadowView.alpha = 0.3;
                     }];
}

- (void)hide {
    
    CGFloat animationDuration = .5;
    [UIView animateWithDuration:animationDuration
                     animations:^{
                         self.alertView.transform = CGAffineTransformScale(self.alertView.transform, 0.01, 0.01);
                         //恢复背景遮罩的透明度为0
                         self.backgroundShadowView.alpha = 0.0;
                     } completion:^(BOOL finished) {
                         self.alertView.transform = CGAffineTransformIdentity;
                         self.alertView.hidden = YES;
                         if (self.privateWindow.isKeyWindow) {
                             self.privateWindow.hidden = YES;
                             [[[[UIApplication sharedApplication] delegate] window] makeKeyAndVisible];
                         }
                     }];
}

@end
