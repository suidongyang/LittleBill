//
//  SUDateTool.h
//  Little Bill
//
//  Created by SU on 2017/11/21.
//  Copyright © 2017年 SU. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SUDateTool : NSObject

@property (strong, nonatomic) NSArray<NSDate *> *currentWeek;
@property (strong, nonatomic) NSDate *currentMonth;
@property (strong, nonatomic) NSDate *currentYear;



+ (SUDateTool *)dateTool;

/**
 获取前后周的首末两天
 0：前一周期  1：后一周期
 */
- (NSArray *)getFirstAndLastDayOfThisWeek;
- (NSArray *)getFirstAndLastDayOfSomeWeek:(NSDate *)date;
- (NSArray *)getFirstAndLastDayOfNextWeek:(NSInteger)next;
- (NSDate *)getNextMonth:(NSInteger)next;
- (NSDate *)getNextYear:(NSInteger)next;

/**
 获取前后周期或本周期第一天，不更新current周期
 -1：上一周期  1：下一周期  0：本周期
 */
- (NSDate *)firstDayOfNextWeek:(NSInteger)next;
- (NSDate *)nextMonth:(NSInteger)next;
- (NSDate *)nextYear:(NSInteger)next;

// 计算某一天是全年第几周，每周从周一开始 返回 "2017-25"
- (NSString *)weekOfYearForDate:(NSDate *)date;

// 将星期的首末日期转成字符串
- (NSString *)stringFromWeekDates:(NSArray<NSDate *> *)dates;


#pragma mark -

+ (NSDateFormatter *)dateFormatterYMD;
+ (NSDateFormatter *)dateFormatterMD;

+ (NSString *)stringForDate:(NSDate *)date;
+ (NSString *)stringForDateMD:(NSDate *)date;



@end

