//
//  WYSparkMainLayer.h
//  SwiftToObjcDemo
//
//  Created by yingwang on 2016/10/20.
//  Copyright © 2016年 yingwang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WYSparkIconLayer.h"
#import "WYSparkDotLayer.h"
#import "WYSparkHelper.h"
#import "WYSparkRingLayer.h"

@interface WYSparkMainLayer : CALayer

- (instancetype)initWithButton:(UIButton *)button attributes:(NSDictionary *)attributes;

- (void)animationWithSelected:(BOOL)isSelected;

///////--------------------------------------- UNAVAILABLE ------------------------------------------///////

- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithLayer:(id)layer UNAVAILABLE_ATTRIBUTE;

@end
