//
//  UIViewController+WYInitializer.h
//  WYKit
//
//  Created by yingwang on 2017/4/24.
//  Copyright © 2017年 GeorgeWang03. All rights reserved.
//
//  UIViewController初始化
//

#import <UIKit/UIKit.h>

@interface UIViewController(WYInitializer)

/**
 *  加载通用版的viewController
 *
 */
+ (id)wy_loadFromNibGeneral;

/**
 通过bundle路径加载通用版的viewController
 */
+ (id)wy_loadFromNibByBundlePath:(NSString *)bundlePath;

@end

void import_UIViewController_WYInitializer();
