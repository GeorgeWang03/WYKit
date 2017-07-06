//
//  WYTimerButton.h
//  WYKit
//
//  Created by yingwang on 2016/12/16.
//  Copyright © 2016年 yingwang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WYTimerButton : UIButton

@property (nonatomic) UIColor *timingStateColor;
@property (nonatomic) BOOL touchableWhenTiming;

- (void)startTimerWithTimerInterval:(NSTimeInterval)interval completion:(void(^)(BOOL finish))block;

- (void)stop;

@end
