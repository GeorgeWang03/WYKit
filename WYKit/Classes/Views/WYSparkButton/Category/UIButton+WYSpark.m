//
//  UIButton+WYSpark.m
//  SwiftToObjcDemo
//
//  Created by yingwang on 2016/10/20.
//  Copyright © 2016年 yingwang. All rights reserved.
//

#import "UIButton+WYSpark.h"
#import "WYSparkMainLayer.h"
#import <objc/runtime.h>


static char WYSparkMainLayerKey;

@implementation UIButton(WYSpark)

- (void)wy_animationWithAttributes:(NSDictionary *)attributes {
    
    WYSparkMainLayer *layer = [[WYSparkMainLayer alloc] initWithButton:self
                                                            attributes:nil];
    objc_setAssociatedObject(self, &WYSparkMainLayerKey, layer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self.layer addSublayer:layer];
}

- (void)wy_addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents animationAttributes:(NSDictionary *)attributes {
    
    WYSparkMainLayer *layer = objc_getAssociatedObject(self, &WYSparkMainLayerKey);
    
    if (!layer) {
        [self wy_animationWithAttributes:attributes];
    }
    
    [self addTarget:target action:action forControlEvents:controlEvents];
    [self addTarget:self action:@selector(handleAction:) forControlEvents:controlEvents];
}

- (void)handleAction:(id)sender {
    WYSparkMainLayer *layer = objc_getAssociatedObject(self, &WYSparkMainLayerKey);
    self.selected = !self.selected;
    [layer animationWithSelected:self.selected];
}

@end
