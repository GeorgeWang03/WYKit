//
//  UIView+WYInitialize.m
//  WYostApp
//
//  Created by yingwang on 2016/10/26.
//  Copyright © 2016年 yingwang. All rights reserved.
//

#import "UIView+WYInitialize.h"

@implementation UIView (WYInitialize)

+ (id)wy_loadFromNibGeneral {
    
    NSString *className = NSStringFromClass([self class]);
    return [[[NSBundle mainBundle] loadNibNamed:className
                                          owner:nil
                                        options:nil] firstObject];
}

+ (id)wy_loadFromNibGeneralForPods {
    
    NSString *className = NSStringFromClass([self class]);
    NSLog(@"path %@", [NSBundle bundleForClass:[self class]].bundlePath);
    return [[[NSBundle bundleForClass:[self class]] loadNibNamed:className
                                                           owner:nil
                                                         options:nil] firstObject];
}

+ (id)wy_loadFromNibByBundlePath:(NSString *)bundlePath {
    NSString *className = NSStringFromClass([self class]);
    
    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
    
    if (bundle) {
        return [[bundle loadNibNamed:className
                               owner:nil
                             options:nil] firstObject];
    }
    
    return nil;
}

+ (id)wy_loadGeneralNibFromClassName {
    NSString *className = NSStringFromClass([self class]);
    return [UINib nibWithNibName:className bundle:nil];
}

+ (id)wy_loadGeneralNibFromClassNameInPods {
    NSString *className = NSStringFromClass([self class]);
    return [UINib nibWithNibName:className bundle:[NSBundle bundleForClass:[self class]]];
}

+ (id)wy_loadGeneralNibByBundlePath:(NSString *)bundlePath {
    NSString *className = NSStringFromClass([self class]);
    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
    
    if (bundle) {
        return [UINib nibWithNibName:className bundle:bundle];
    }
    
    return nil;
}

@end

void import_UIView_WYInitialize(){}
