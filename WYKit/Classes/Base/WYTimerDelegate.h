//
//  WYTimerDelegate.h
//  WYKit
//
//  Created by yingwang on 2017/1/9.
//  Copyright © 2017年 GeorgeWang03. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WYTimerDelegate : NSObject

- (void)startTimerWithTimeInterval:(NSTimeInterval)interval block:(void(^)(NSTimer *timer))block userInfo:(id)userInfo repeats:(BOOL)repeats;

- (void)stopTimer;

@end
