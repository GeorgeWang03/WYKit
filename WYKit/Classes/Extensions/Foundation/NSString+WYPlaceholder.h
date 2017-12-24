//
//  NSString+IPPlaceholder.h
//  WYKit
//
//  Created by yingwang on 2017/6/15.
//  Copyright © 2017年 GeorgeWang03. All rights reserved.
//
//  字符串分类
//

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT NSString *NSStringNeverNil(NSString *string);
FOUNDATION_EXPORT NSString *NSStringWithPlaceholder(NSString *string, NSString *placeholder);
FOUNDATION_EXPORT NSString *NSStringFormatter(NSString *formatter, NSString *string, NSString *placeholder);
FOUNDATION_EXPORT NSString *NSStringTransformer(id obj, NSString *(^)(id string), NSString *placeholder);

@interface NSString(WYPlaceholder)

@property (nonatomic, readonly) NSString *(^wy_placeholder)(NSString *placeholder);

@end
