//
//  NSCalendar+WYExtension.m
//  WYKit
//
//  Created by yingwang on 2017/6/7.
//  Copyright © 2017年 yingwang. All rights reserved.
//
//  日历扩展
//

#import "NSCalendar+WYExtension.h"

@implementation NSCalendar(WYExtension)

- (NSDate *)wy_firstDateOfMonthFromDate:(NSDate *)date {
    NSDateComponents *components = [self components:(NSCalendarUnitYear | NSCalendarUnitWeekOfMonth | NSCalendarUnitDay | NSCalendarUnitMonth) fromDate:date];
    [components setDay:1];
    return [self dateFromComponents:components];
}

- (NSDate *)wy_lastDateOfMonthFromDate:(NSDate *)date {
    NSDateComponents *components = [self components:(NSCalendarUnitYear | NSCalendarUnitWeekOfMonth | NSCalendarUnitDay | NSCalendarUnitMonth) fromDate:date];
    [components setMonth:components.month+1];
    [components setDay:0];
    return [self dateFromComponents:components];
}

- (NSDate *)wy_firstDateOfYearFromDate:(NSDate *)date {
    NSDateComponents *components = [self components:(NSCalendarUnitYear | NSCalendarUnitWeekOfMonth | NSCalendarUnitDay | NSCalendarUnitMonth) fromDate:date];
    [components setDay:1];
    [components setMonth:1];
    return [self dateFromComponents:components];
}

- (NSDate *)wy_lastDateOfYearFromDate:(NSDate *)date {
    NSDateComponents *components = [self components:(NSCalendarUnitYear | NSCalendarUnitWeekOfMonth | NSCalendarUnitDay | NSCalendarUnitMonth) fromDate:date];
    [components setMonth:12];
    [components setDay:31];
    return [self dateFromComponents:components];
}

- (NSString *)wy_weekDayStringWithFormatter:(NSString *)formatter type:(NSUInteger)type date:(NSDate *)date {
    NSDateComponents *components = [self components:NSCalendarUnitWeekday fromDate:date];
    NSUInteger day = components.weekday;
    
    if (day < 1 || day > 7) return nil;
    
    NSArray *dayNames;
    NSString *dayName;
    switch (type) {
        case 0:
            dayNames = @[@"7", @"1", @"2", @"3", @"4", @"5", @"6"];
            dayName = dayNames[day-1];
            break;
        case 1:
            dayNames = @[@"日", @"一", @"二", @"三", @"四", @"五", @"六"];
            dayName = dayNames[day-1];
            break;
        default:
            dayName = @"";
            break;
    }
    
    return [NSString stringWithFormat:formatter, dayName];
}

@end
