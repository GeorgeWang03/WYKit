//
//  WYModalPresentView.h
//  WYKit
//
//  Created by yingwang on 2017/5/16.
//  Copyright © 2017年 GeorgeWang03. All rights reserved.
//
//  模态展示视图
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, WYModalPresentViewAnimationStyle) {
    WYModalPresentViewAnimationStylePullDown,
    WYModalPresentViewAnimationStylePullLeft,
    WYModalPresentViewAnimationStyleExpand
};

@class WYModalPresentView;
@protocol WYModalPresentProtocal <NSObject>
@required
- (void)presentViewWillLayoutSubviews:(WYModalPresentView *)presentView;

@end

@interface WYModalPresentView : UIView

@property (nonatomic, readonly) BOOL showing;

@property (nonatomic, weak) id<WYModalPresentProtocal> layoutDelegate;

@property (nonatomic) BOOL hideWhenTapShadow;

- (void)presentView:(UIView<WYModalPresentProtocal> *)view animation:(WYModalPresentViewAnimationStyle)style;

- (void)hideWithAnimation:(WYModalPresentViewAnimationStyle)style;

/**
 动画进度
 */
- (void)transformStyle:(WYModalPresentViewAnimationStyle)style progress:(CGFloat)progress animated:(BOOL)animated;

@end
