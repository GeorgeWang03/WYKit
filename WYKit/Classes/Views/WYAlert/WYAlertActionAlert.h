//
//  WYAlertActionAlert.h
//  WYKit
//
//  Created by yingwang on 2016/12/27.
//  Copyright © 2016年 yingwang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WYAlertAction;
@interface WYAlertActionAlert : NSObject

@property (nonatomic, readonly) UILabel *titleLabel;
@property (nonatomic, readonly) UILabel *contentLabel;

- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message;
- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message icon:(UIImage *)icon;

- (void)addAction:(WYAlertAction *)action;

- (void)show;
- (void)hide;

- (void)showWithOrientation:(UIInterfaceOrientation)orientation;
- (void)showWithOrientation:(UIInterfaceOrientation)orientation window:(UIWindow *)window;

@end
