//
//  UIScrollView+WYLayout.m
//  WYostApp
//
//  Created by yingwang on 2016/11/30.
//  Copyright © 2016年 yingwang. All rights reserved.
//

#import "UIScrollView+WYLayout.h"

@implementation UIScrollView (WYLayout)

- (void)wy_adjustContentSize {
    CGRect contentRect = CGRectZero;
    for (UIView *view in self.subviews) {
        contentRect = CGRectUnion(contentRect, view.frame);
    }
    self.contentSize = contentRect.size;
}

@end

void import_UIScrollView_WYLayout(){}
