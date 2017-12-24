//
//  WYTimerDelegate.m
//  WYKit
//
//  Created by yingwang on 2017/1/9.
//  Copyright © 2017年 GeorgeWang03. All rights reserved.
//

#import "WYTimerDelegate.h"

@interface WYTimerDelegate ()

@property (nonatomic, copy) void(^actionBlock)(NSTimer *timer);
@property (nonatomic, weak) NSTimer *timer;

@end

@implementation WYTimerDelegate

- (void)dealloc {
    [self stopTimer];
}

- (void)startTimerWithTimeInterval:(NSTimeInterval)interval block:(void (^)(NSTimer *timer))block userInfo:(id)userInfo repeats:(BOOL)repeats {
    
    [self stopTimer];
    
    self.actionBlock = block;
    
    NSTimer *timer = [NSTimer timerWithTimeInterval:interval
                                             target:self
                                           selector:@selector(handleTimerAction:)
                                           userInfo:userInfo
                                            repeats:repeats];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    self.timer = timer;
}

- (void)handleTimerAction:(NSTimer *)timer {
    
    if (self.actionBlock) {
        self.actionBlock(timer);
    }
}

- (void)stopTimer {
    if (self.timer) {
        [self.timer invalidate];
    }
}

@end
