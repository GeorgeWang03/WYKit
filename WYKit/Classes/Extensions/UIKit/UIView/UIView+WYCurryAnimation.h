//
//  UIView+WYCurryAnimation.h
//  BezierCuryTest
//
//  Created by yingwang on 2017/1/13.
//  Copyright © 2017年 yingwang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (WYCurryAnimation)

/**
 add curry reaction
 添加粘性交互
 */
- (void)wy_addCurry;


/**
 add curry reaction
 添加粘性交互

 @param completedBlock 松手时回调block
 */
- (void)wy_addCurryWithCompleted:(void(^)(UIView *sender, BOOL dismiss))completedBlock;


/**
 remove curry reaction
 移除粘性交互
 */
- (void)wy_removeCurry;

@end

void import_UIView_WYCurryAnimation();
