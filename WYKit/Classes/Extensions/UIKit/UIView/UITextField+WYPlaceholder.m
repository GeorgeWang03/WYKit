//
//  UITextField+WYPlaceholder.m
//  WYostApp
//
//  Created by yingwang on 2016/12/12.
//  Copyright © 2016年 yingwang. All rights reserved.
//

#import "UITextField+WYPlaceholder.h"

@implementation UITextField(WYPlaceholder)

- (void)wy_setPlaceholderColor:(UIColor *)placeholderColor {
    if ([self respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        self.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.placeholder?:@"" attributes:@{NSForegroundColorAttributeName: placeholderColor}];
    } else {
        NSLog(@"Cannot set placeholder text's color, because deployment target is earlier than iOS 6.0");
        // TODO: Add fall-back code to set placeholder color.
    }
}

@end

void import_UITextField_WYPlaceholder() {}
