//
//  UIButton+WYSpark.h
//  SwiftToObjcDemo
//
//  Created by yingwang on 2016/10/20.
//  Copyright © 2016年 yingwang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton(WYSpark)

- (void)wy_animationWithAttributes:(NSDictionary *)attributes;

- (void)wy_addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents animationAttributes:(NSDictionary *)attributes;

@end
