//
//  WYSparkHelper.m
//  SwiftToObjcDemo
//
//  Created by yingwang on 2016/10/20.
//  Copyright © 2016年 yingwang. All rights reserved.
//

#import "WYSparkHelper.h"

@implementation WYSparkHelper

+ (void)dictionary:(NSMutableDictionary *)dictionary safelyAddObject:(id)obj forKey:(NSString *)key {
    
    if (obj) {
        [dictionary setObject:obj forKey:key];
    }
}

@end
