//
//  WYMorphingLabel.h
//  SwiftToObjcDemo
//
//  Created by yingwang on 2016/10/25.
//  Copyright © 2016年 yingwang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WYMorphingLabel : UILabel

@property (nonatomic, assign) BOOL repetable;

- (void)startAnimation;

- (void)stopAnimation;

@end
