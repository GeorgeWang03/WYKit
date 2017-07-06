//
//  UIView+WYInitialize.h
//  WYostApp
//
//  Created by yingwang on 2016/10/26.
//  Copyright © 2016年 yingwang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (WYInitialize)

/**
 *  加载通用版的view
 *
 */
+ (id)wy_loadFromNibGeneral;

/**
 在pod中加载通用版的view
 */
+ (id)wy_loadFromNibGeneralForPods;

/**
 通过bundle路径加载通用版的view
 */
+ (id)wy_loadFromNibByBundlePath:(NSString *)bundlePath;

/**
 *  加载通用版的nib
 *
 */
+ (id)wy_loadGeneralNibFromClassName;

/**
 *  在pod中加载通用版的nib
 *
 */
+ (id)wy_loadGeneralNibFromClassNameInPods;

/**
 *  通过bundle路径加载通用版的nib
 *
 */
+ (id)wy_loadGeneralNibByBundlePath:(NSString *)bundlePath;

@end

void import_UIView_WYInitialize();
