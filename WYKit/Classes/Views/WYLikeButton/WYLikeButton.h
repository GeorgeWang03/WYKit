//
//  WYLikeButton.h
//  WYKit
//
//  Created by yingwang on 2017/12/5.
//  Copyright © 2017年 yingwang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WYLikeButton : UIButton

/**
 The max number of like to show,
 for example, the max number is 10,000, so 1,1000 will be 10000+.
 */
@property (nonatomic) NSInteger maxNumberOfLike;

@property (nonatomic, readonly) NSInteger numberOfLike;

- (instancetype)init __attribute__((unavailable("use buttonWithType: instead, and type should be Custom")));

- (void)setTitle:(NSString *)title forState:(UIControlState)state __attribute__((unavailable("use changeNumberOfLike:animated: instead")));

- (void)changeNumberOfLike:(NSInteger)numberOfLike animated:(BOOL)animated;

@end
