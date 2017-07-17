//
//  WYCollectionPicker.m
//  WYKit
//
//  Created by yingwang on 2016/12/26.
//  Copyright © 2016年 yingwang. All rights reserved.
//

#import "WYPodDefine.h"
#import "UIView+WYInitialize.h"
#import "WYCollectionPicker.h"
#import "WYCollectionPickerView.h"

@interface WYCollectionPicker () <WYCollectionPickerViewDelegate>

@property (nonatomic, strong) UIWindow *privateWindow;//私有window窗口
@property (nonatomic, strong) UIView *backgroundShadowView;//被禁遮罩层

@property (nonatomic, strong) WYCollectionPickerView *pickView;

@end

@implementation WYCollectionPicker

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupSubviews];
    }
    return self;
}

- (void)setTitle:(NSString *)title {
    _title = title;
    
    _pickView.titleLabel.text = title;
}

- (void)show {
    
    [self.privateWindow addSubview:_pickView];
    [self.privateWindow setHidden:NO];
//    [self.privateWindow makeKeyAndVisible];
    
    _pickView.transform = CGAffineTransformMakeTranslation(0, CGRectGetHeight(_pickView.bounds));
    
//    [self reloadData];
    
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options:0
                     animations:^{
                         //调整背景遮罩的透明度
                         self.backgroundShadowView.alpha = 0.6;
                         _pickView.transform = CGAffineTransformIdentity;
                     }
                     completion:^(BOOL finished) {}];
}

- (void)hide {
    
    if ([_delegate respondsToSelector:@selector(pickerWillDismiss:)]) {
        [_delegate pickerWillDismiss:self];
    }
    
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options:0
                     animations:^{
                         //恢复背景遮罩的透明度为0
                         self.backgroundShadowView.alpha = 0.0;
                         _pickView.transform = CGAffineTransformMakeTranslation(0, CGRectGetHeight(_pickView.bounds));
                     } completion:^(BOOL finished) {
                         self.privateWindow.hidden = YES;
                         [_pickView removeFromSuperview];
                         [[[[UIApplication sharedApplication] delegate] window] makeKeyAndVisible];
                     }];
}

#pragma mark - setup subviews
- (void)setupSubviews {
    CGRect screenbBounds = [UIScreen mainScreen].bounds;
    
    _pickView = [WYCollectionPickerView wy_loadFromNibByBundlePath:WYPodBundlePath];
    _pickView.delegate = self;
    _pickView.titleLabel.text = _title;
    [_pickView.cancelButton addTarget:self action:@selector(hide) forControlEvents:UIControlEventTouchUpInside];
    
    _pickView.frame = CGRectMake(0, CGRectGetHeight(screenbBounds) - 270, CGRectGetWidth(screenbBounds), 270);
    
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

#pragma mark - WYCollectionPickerView Delegate
- (NSInteger)numberOfItemInPickerView:(WYCollectionPickerView *)pickerView {
    return [_delegate numberOfItemInPicker:self];
}

- (UIImage *)pickerView:(WYCollectionPickerView *)pickerView imageForItemAtIndex:(NSInteger)index {
    return [_delegate picker:self imageForItemAtIndex:index];
}

- (NSString *)pickerView:(WYCollectionPickerView *)pickerView titleForItemAtIndex:(NSInteger)index {
    return [_delegate picker:self titleForItemAtIndex:index];
}

- (void)pickerView:(WYCollectionPickerView *)pickerView didSelectedItemAtIndex:(NSInteger)index {
    if ([_delegate respondsToSelector:@selector(picker:didSelectedItemAtIndex:)]) {
        [_delegate picker:self didSelectedItemAtIndex:index];
    }
}


@end
