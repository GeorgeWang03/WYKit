//
//  NSCalendar+WYExtension.h
//  WYKit
//
//  Created by yingwang on 2017/6/7.
//  Copyright © 2017年 yingwang. All rights reserved.
//
//  日历扩展
//

#import <Foundation/Foundation.h>

@interface NSCalendar(WYExtension)

- (NSDate *)wy_firstDateOfMonthFromDate:(NSDate *)date;

- (NSDate *)wy_lastDateOfMonthFromDate:(NSDate *)date;

- (NSDate *)wy_firstDateOfYearFromDate:(NSDate *)date;

- (NSDate *)wy_lastDateOfYearFromDate:(NSDate *)date;

- (NSString *)wy_weekDayStringWithFormatter:(NSString *)formatter
                                    type:(NSUInteger)type
                                    date:(NSDate *)date;

@end

