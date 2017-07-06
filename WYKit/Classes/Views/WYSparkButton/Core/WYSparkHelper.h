//
//  WYSparkHelper.h
//  SwiftToObjcDemo
//
//  Created by yingwang on 2016/10/20.
//  Copyright © 2016年 yingwang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WYSparkHelper : NSObject

+ (void)dictionary:(NSMutableDictionary *)dictionary safelyAddObject:(id)obj forKey:(NSString *)key;

@end
