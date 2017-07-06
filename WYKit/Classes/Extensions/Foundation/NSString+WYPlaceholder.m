//
//  NSString+IPPlaceholder.m
//  WYKit
//
//  Created by yingwang on 2017/6/15.
//  Copyright © 2017年 yingwang. All rights reserved.
//
//  字符串分类
//

#import "NSString+WYPlaceholder.h"

@implementation NSString(WYPlaceholder)

- (NSString *(^)(NSString *))wy_placeholder {
    
    __weak NSString *weakSelf = self;
    
    return ^(NSString *placeholder) {
        return weakSelf.length ? weakSelf : placeholder;
    };
}

@end


NSString *NSStringNeverNil(NSString *string) {
    if ([string isKindOfClass:[NSNull class]]) return @"";
    return string ?: @"";
}

NSString *NSStringWithPlaceholder(NSString *string, NSString *placeholder) {
    if ([string isKindOfClass:[NSNull class]]) return placeholder;
    return string ?: placeholder;
}

NSString *NSStringFormatter(NSString *formatter, NSString *string, NSString *placeholder) {
    return string.length ? [NSString stringWithFormat:formatter, string] : placeholder;
}

NSString *NSStringTransformer(id obj, NSString *(^transform)(id string), NSString *placeholder) {
    
    if (obj) {
        return transform(obj);
    } else {
        return placeholder;
    }
}
