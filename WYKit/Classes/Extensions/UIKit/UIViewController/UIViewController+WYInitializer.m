//
//  UIViewController+WYInitializer.m
//  Pods
//
//  Created by yingwang on 2017/4/24.
//  Copyright © 2017年 yingwang. All rights reserved.
//
//  UIViewController初始化
//

//View

//Model

//Controller
#import "UIViewController+WYInitializer.h"


@implementation UIViewController(WYInitializer)

/**
 *  加载通用版的viewController
 *
 */
+ (id)wy_loadFromNibGeneral {
    NSString *className = NSStringFromClass([self class]);
    
    return [[self alloc] initWithNibName:className bundle:nil];
}

/**
 通过bundle路径加载通用版的viewController
 */
+ (id)wy_loadFromNibByBundlePath:(NSString *)bundlePath {
    NSString *className = NSStringFromClass([self class]);
    
    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
    return [[self alloc] initWithNibName:className bundle:bundle];
}

@end

void import_UIViewController_WYInitializer() {}
