//
//  WYCheckinProgressView.h
//  WYKit
//
//  Created by yingwang on 2017/11/8.
//  Copyright © 2017年 yingwang. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, WYCheckinProgressViewState) {
    kWYCheckinProgressViewWaitCheckinState = 1,
    kWYCheckinProgressViewFinishState = 2
};

@interface WYCheckinProgressView : UIView

@property (nonatomic) NSUInteger day;

@property (nonatomic, copy) void(^handleButtonAction)();

- (void)reloadWithState:(WYCheckinProgressViewState)state;
- (void)reloadWithState:(WYCheckinProgressViewState)state progress:(CGFloat)progress;
- (void)reloadWithState:(WYCheckinProgressViewState)state numberOfDay:(NSUInteger)numberOfDay;

/**
 Reload view's appearence based on state.

 @param state A state the view to show
 @param numberOfDay The number of day to show on kWYCheckinProgressViewFinishState.
 @param progress The progress of the check-in activity.
 */
- (void)reloadWithState:(WYCheckinProgressViewState)state
            numberOfDay:(NSUInteger)numberOfDay progress:(CGFloat)progress;


/**
 Transit from kWYCheckinProgressViewWaitCheckinState to kWYCheckinProgressViewFinishState

 @param day Current number of day for check-in.
 */
- (void)startAnimationToDay:(NSUInteger)day;
- (void)startAnimationToDay:(NSUInteger)day progress:(CGFloat)progress;

@end
