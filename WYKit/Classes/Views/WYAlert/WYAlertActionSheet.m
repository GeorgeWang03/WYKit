//
//  WYAlertActionSheet.m
//  WYostApp
//
//  Created by yingwang on 2016/12/11.
//  Copyright © 2016年 yingwang. All rights reserved.
//

#import "WYAlertAction.h"
#import <objc/runtime.h>
#import "WYAlertActionSheet.h"

const char *WYAlertActionSheetPrivateTagKey = "WYAlertActionSheetPrivate";

@interface WYAlertAction (WYAlertActionSheetPrivate)
@property (nonatomic) NSInteger tag;
@property (nonatomic, strong) UIColor *titleColor;
@end

@implementation WYAlertAction(WYAlertActionSheetPrivate)

- (void)setTag:(NSInteger)tag {
    objc_setAssociatedObject(self, WYAlertActionSheetPrivateTagKey, @(tag), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSInteger)tag {
    return [objc_getAssociatedObject(self, WYAlertActionSheetPrivateTagKey) integerValue];
}

- (UIColor *)titleColor {
    
    UIColor *color;
    
    switch (self.style) {
        case WYAlertActionCancel:
            color = [UIColor redColor];
            break;
        case WYAlertActionDefault:
            color = [UIColor colorWithRed:0/255.0 green:153.f/255.0 blue:0/255.0 alpha:1.f];
            break;
        case WYAlertActionGray:
            color = [UIColor grayColor];
            break;
        default:
            break;
    }
    return color;
}

@end

@interface WYAlertActionSheet ()
{
    BOOL _hasCancelAction;
}

@property (nonatomic, strong) UIWindow *privateWindow;//私有window窗口
@property (nonatomic, strong) UIView *backgroundShadowView;//被禁遮罩层

@property (nonatomic, strong) UIView *actionView;

@property (nonatomic, strong) NSMutableArray *privateActionsArray;

@end

@implementation WYAlertActionSheet

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupSubviews];
    }
    return self;
}

+ (instancetype)actionSheet {
    return [[self alloc] init];
}

#pragma mark - setup subviews
- (void)setupSubviews {
    [self initializeSubviews];
}

- (void)initializeSubviews {
    
    CGRect screenbBounds = [UIScreen mainScreen].bounds;
    
//    self.frame = CGRectMake(0, 0.4*CGRectGetHeight(screenbBounds), CGRectGetWidth(screenbBounds), 0.6*CGRectGetHeight(screenbBounds));
//    self.backgroundColor = [UIColor colorWithRed:230.0/255 green:230.0/255 blue:230.0/255 alpha:1.0];
    
    _privateWindow  = [[UIWindow alloc] initWithFrame:screenbBounds];
    _privateWindow.windowLevel = UIWindowLevelStatusBar;
    _privateWindow.backgroundColor = [UIColor clearColor];
    
    UIView *backgroundView = [[UIView alloc] initWithFrame:_privateWindow.frame];
    backgroundView.backgroundColor = [UIColor darkGrayColor];
    backgroundView.alpha = 0.0;
    [_privateWindow addSubview:backgroundView];
    _backgroundShadowView = backgroundView;
    
    UITapGestureRecognizer *recognize = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                action:@selector(hide)];
    [_backgroundShadowView addGestureRecognizer:recognize];
}

- (void)setupActionView {
    
    CGFloat boundsMargin = 10;
    CGFloat screenWidth = CGRectGetWidth([UIScreen mainScreen].bounds);
    CGFloat actionViewWidth = screenWidth - 2*boundsMargin;
    CGFloat defaultActionHeight = actionViewWidth * 108/750;
    CGFloat seperatorLineHeight = 1;
    CGFloat actionViewHeight = 0;
    
    UIView *actionView = [[UIView alloc] init];
    actionView.backgroundColor = [UIColor clearColor];
    [_privateWindow addSubview:actionView];
    
    NSLayoutConstraint *constraintTop;
    NSLayoutConstraint *constraintLeft;
    NSLayoutConstraint *constraintRight;
    NSLayoutConstraint *constraintHeight;
    
    UIView *topView = actionView;
    
    NSInteger idx = 0;
    for (WYAlertAction *action in _privateActionsArray) {
        
        action.tag = actionViewHeight;
        
        UIButton *button = [[UIButton alloc] init];
        button.tag = action.tag;
        button.backgroundColor = [UIColor whiteColor];
        [button setTitleColor:action.titleColor forState:UIControlStateNormal];
        [button setTitle:action.title forState:UIControlStateNormal];
        [button addTarget:self action:@selector(handleButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [actionView addSubview:button];
        
        button.translatesAutoresizingMaskIntoConstraints = NO;
        
        seperatorLineHeight = (action.style == WYAlertActionCancel) ? 10 : 1;
        constraintTop = [NSLayoutConstraint constraintWithItem:button
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:topView
                                                     attribute:(topView == actionView) ? NSLayoutAttributeTop : NSLayoutAttributeBottom
                                                    multiplier:1.0 constant:seperatorLineHeight];
        constraintLeft = [NSLayoutConstraint constraintWithItem:button
                                                      attribute:NSLayoutAttributeLeft
                                                      relatedBy:NSLayoutRelationEqual
                                                         toItem:actionView
                                                      attribute:NSLayoutAttributeLeft
                                                     multiplier:1.0 constant:0];
        constraintRight = [NSLayoutConstraint constraintWithItem:button
                                                       attribute:NSLayoutAttributeRight
                                                       relatedBy:NSLayoutRelationEqual
                                                          toItem:actionView
                                                       attribute:NSLayoutAttributeRight
                                                      multiplier:1.0 constant:0];
        constraintHeight = [NSLayoutConstraint constraintWithItem:button
                                                        attribute:NSLayoutAttributeHeight
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:nil
                                                        attribute:NSLayoutAttributeHeight
                                                       multiplier:1.f constant:defaultActionHeight];
        [actionView addConstraints:@[constraintTop, constraintLeft, constraintRight, constraintHeight]];
        
        if (idx < _privateActionsArray.count - 2) {
            UIView *seperatorLine = [[UIView alloc] init];
            seperatorLine.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
            [actionView addSubview:seperatorLine];
            
            seperatorLine.translatesAutoresizingMaskIntoConstraints = NO;
            constraintTop = [NSLayoutConstraint constraintWithItem:seperatorLine
                                                         attribute:NSLayoutAttributeTop
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:button
                                                         attribute:NSLayoutAttributeBottom
                                                        multiplier:1.0 constant:0];
            constraintLeft = [NSLayoutConstraint constraintWithItem:seperatorLine
                                                          attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:actionView
                                                          attribute:NSLayoutAttributeLeft
                                                         multiplier:1.0 constant:0];
            constraintRight = [NSLayoutConstraint constraintWithItem:seperatorLine
                                                           attribute:NSLayoutAttributeRight
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:actionView
                                                           attribute:NSLayoutAttributeRight
                                                          multiplier:1.0 constant:0];
            constraintHeight = [NSLayoutConstraint constraintWithItem:seperatorLine
                                                            attribute:NSLayoutAttributeHeight
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:nil
                                                            attribute:NSLayoutAttributeHeight
                                                           multiplier:1.f constant:1];
            [actionView addConstraints:@[constraintTop, constraintLeft, constraintRight, constraintHeight]];
        }
        
        ++ idx;
        topView = button;
        actionViewHeight += (defaultActionHeight + seperatorLineHeight);
    }
    
    actionView.frame = CGRectMake(boundsMargin, CGRectGetHeight(_privateWindow.bounds), actionViewWidth, actionViewHeight);
    _actionView = actionView;
}

- (void)viewWillShowAnimated:(BOOL)animated {
    [self setupActionView];
}

#pragma mark - Respond Method

- (void)addAction:(WYAlertAction *)action {
    
    NSAssert(!(_hasCancelAction && (action.style == WYAlertActionCancel)), @"WYAlertActionSheet can have only one cancel style action!");
    _hasCancelAction |= (action.style == WYAlertActionCancel);
    
    if (!_privateActionsArray) _privateActionsArray = [NSMutableArray array];
    
    if ([(WYAlertAction *)[_privateActionsArray lastObject] style] == WYAlertActionCancel) {
        [_privateActionsArray insertObject:action atIndex:_privateActionsArray.count-1];
    } else {
        [_privateActionsArray addObject:action];
    }
}

- (void)show {
    [self viewWillShowAnimated:YES];
    
    CGFloat animationDuration = .5;
    CGFloat boundsMargin = 10;
    CGFloat translateDistance;
    CGAffineTransform toTransform;
    
    translateDistance = -(CGRectGetHeight(_actionView.frame) + boundsMargin);
    toTransform = CGAffineTransformMakeTranslation(0, translateDistance);
    
//    [self.privateWindow addSubview:self];
    [self.privateWindow setHidden:NO];
    [self.privateWindow makeKeyAndVisible];
    
    [UIView animateWithDuration:animationDuration
                     animations:^{
                         //调整背景遮罩的透明度
                         self.backgroundShadowView.alpha = 0.6;
                         _actionView.transform = toTransform;
                     }];
}

- (void)hide {
    
    CGFloat animationDuration = .5;
    CGAffineTransform toTransform;
    
    toTransform = CGAffineTransformIdentity;
    
    [UIView animateWithDuration:animationDuration
                     animations:^{
                         _actionView.transform = toTransform;
                         //恢复背景遮罩的透明度为0
                         self.backgroundShadowView.alpha = 0.0;
                     } completion:^(BOOL finished) {
                         self.privateWindow.hidden = YES;
                         [[[[UIApplication sharedApplication] delegate] window] makeKeyAndVisible];
                     }];
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

@end
