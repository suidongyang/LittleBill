//
//  SUDateTool.m
//  Little Bill
//
//  Created by SU on 2017/11/21.
//  Copyright © 2017年 SU. All rights reserved.
//

#import "SUDateTool.h"

@interface SUDateTool ()

@property (assign, nonatomic) NSInteger weekOfMonth;
@property (strong, nonatomic) NSCalendar *calendar;

@end


@implementation SUDateTool


static SUDateTool *_dateTool;
+ (SUDateTool *)dateTool {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _dateTool = [[SUDateTool alloc] init];
        _dateTool.calendar = [NSCalendar currentCalendar];
        _dateTool.currentWeek = [_dateTool getFirstAndLastDayOfThisWeek];
        _dateTool.currentMonth = [NSDate date];
        _dateTool.currentYear = [NSDate date];
    });
    return _dateTool;
}


#pragma mark - 获取指定日期 待优化


// 获取本周的首末两天
- (NSArray *)getFirstAndLastDayOfThisWeek {
    
    NSDateComponents *dateComponents = [self.calendar components:NSCalendarUnitWeekday | NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
    NSInteger weekday = [dateComponents weekday];   //第几天(从sunday开始)
    NSInteger firstDiff,lastDiff;
    if (weekday == 1) { // 周日
        firstDiff = -6;
        lastDiff = 0;
    }else {
        firstDiff =  - weekday + 2;
        lastDiff = 8 - weekday;
    }
    NSInteger day = [dateComponents day];
    NSDateComponents *firstComponents = [self.calendar components:NSCalendarUnitWeekday | NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitWeekOfMonth fromDate:[NSDate date]];
    [firstComponents setDay:day+firstDiff];
    NSDate *firstDay = [self.calendar dateFromComponents:firstComponents];
    
    self.weekOfMonth = [firstComponents weekOfMonth];
    
    NSDateComponents *lastComponents = [self.calendar components:NSCalendarUnitWeekday | NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitWeekOfMonth fromDate:[NSDate date]];
    [lastComponents setDay:day+lastDiff];
    NSDate *lastDay = [self.calendar dateFromComponents:lastComponents];
    
    return [NSArray arrayWithObjects:firstDay,lastDay, nil];
    
}

//  获取某一周的首末两天
- (NSArray *)getFirstAndLastDayOfSomeWeek:(NSDate *)date {
    
    NSDateComponents *dateComponents = [self.calendar components:NSCalendarUnitWeekday | NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:date];
    NSInteger weekday = [dateComponents weekday];   //第几天(从sunday开始)
    NSInteger firstDiff,lastDiff;
    if (weekday == 1) { // 周日
        firstDiff = -6;
        lastDiff = 0;
    }else {
        firstDiff =  - weekday + 2;
        lastDiff = 8 - weekday;
    }
    NSInteger day = [dateComponents day];
    NSDateComponents *firstComponents = [self.calendar components:NSCalendarUnitWeekday | NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitWeekOfMonth fromDate:date];
    [firstComponents setDay:day+firstDiff];
    NSDate *firstDay = [self.calendar dateFromComponents:firstComponents];
    
    //    self.weekOfMonth = [firstComponents weekOfMonth];
    
    NSDateComponents *lastComponents = [self.calendar components:NSCalendarUnitWeekday | NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitWeekOfMonth fromDate:date];
    [lastComponents setDay:day+lastDiff];
    NSDate *lastDay = [self.calendar dateFromComponents:lastComponents];
    
    return [NSArray arrayWithObjects:firstDay,lastDay, nil];
    
}

// 获取前后周或本周的第一天，不更新current
- (NSDate *)firstDayOfNextWeek:(NSInteger)next {
    
    if (next == 1) { // 下一周
        
        NSDateComponents *dateComponents = [self.calendar components:NSCalendarUnitWeekday | NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitWeekOfMonth fromDate:self.currentWeek.lastObject];
        
        NSInteger day = [dateComponents day];
        
        [dateComponents setDay:day + 1];
        NSDate *firstDay = [self.calendar dateFromComponents:dateComponents];
        
        return firstDay;
       
    }
    
    else if (next == -1) { // 上一周
        
        NSDateComponents *dateComponents = [self.calendar components:NSCalendarUnitWeekday | NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitWeekOfMonth fromDate:self.currentWeek.firstObject];
        
        NSInteger day = [dateComponents day];
        
        [dateComponents setDay:day - 7];
        NSDate *firstDay = [self.calendar dateFromComponents:dateComponents];
        
        return firstDay;
    }
    
    else { // 0 本周
        return self.currentWeek.firstObject;
    }
}

// 获取前后周的首末两天
- (NSArray *)getFirstAndLastDayOfNextWeek:(NSInteger)next {
    
    if (next) {
        
        NSDateComponents *dateComponents = [self.calendar components:NSCalendarUnitWeekday | NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitWeekOfMonth fromDate:self.currentWeek.lastObject];
        
        NSInteger day = [dateComponents day];
        
        [dateComponents setDay:day + 1];
        NSDate *firstDay = [self.calendar dateFromComponents:dateComponents];
        
        self.weekOfMonth = [dateComponents weekOfMonth];
        
        [dateComponents setDay:day + 7];
        NSDate *lastDay = [self.calendar dateFromComponents:dateComponents];
        
        self.currentWeek = @[firstDay, lastDay];
        self.currentMonth = firstDay;
        self.currentYear = firstDay;
        
        
        return self.currentWeek;
    }
    
    else {
        
        NSDateComponents *dateComponents = [self.calendar components:NSCalendarUnitWeekday | NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitWeekOfMonth fromDate:self.currentWeek.firstObject];
        
        NSInteger day = [dateComponents day];
        
        [dateComponents setDay:day - 1];
        NSDate *lastDay = [self.calendar dateFromComponents:dateComponents];
        
        [dateComponents setDay:day - 7];
        NSDate *firstDay = [self.calendar dateFromComponents:dateComponents];
        
        self.currentWeek = @[firstDay, lastDay];
        self.currentMonth = firstDay;
        self.currentYear = firstDay;
        self.weekOfMonth = [dateComponents weekOfMonth];
        
        return self.currentWeek;
        
    }
    
}

// 获取前后月，不更新current
- (NSDate *)nextMonth:(NSInteger)next {
    
    NSDateComponents *dateComponents = [self.calendar components:NSCalendarUnitWeekday | NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:self.currentMonth];
    
    NSInteger month = [dateComponents month];
    [dateComponents setMonth: month + next];
    
    NSDate *date = [self.calendar dateFromComponents:dateComponents];
    
    return date;
}

// 获取前后月
- (NSDate *)getNextMonth:(NSInteger)next {
    
    NSDateComponents *dateComponents = [self.calendar components:NSCalendarUnitWeekday | NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:self.currentMonth];
    
    NSInteger month = [dateComponents month];
    [dateComponents setMonth: month + (next ? 1 : -1)];
    
    NSDate *date = [self.calendar dateFromComponents:dateComponents];
    
    self.currentMonth = date;
    [self updateCurrentWeek];
    self.currentYear = date;
    
    return self.currentMonth;
    
}

// 获取前后年，不更新current
- (NSDate *)nextYear:(NSInteger)next {
    
    NSDateComponents *dateComponents = [self.calendar components:NSCalendarUnitWeekday | NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:self.currentYear];
    
    NSInteger year = [dateComponents year];
    [dateComponents setYear: year + next];
    
    NSDate *date = [self.calendar dateFromComponents:dateComponents];
    
    return date;
    
}

// 获取前后年
- (NSDate *)getNextYear:(NSInteger)next {
    
    NSDateComponents *dateComponents = [self.calendar components:NSCalendarUnitWeekday | NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:self.currentYear];
    
    NSInteger year = [dateComponents year];
    [dateComponents setYear: year + (next ? 1 : -1)];
    
    NSDate *date = [self.calendar dateFromComponents:dateComponents];
    
    self.currentYear = date;
    self.currentMonth = date;
    [self updateCurrentWeek];
    
    return self.currentYear;
}


#pragma mark - 根据当前周是某个月的第几周，更新当前星期日期范围


- (void)updateCurrentWeek {
    
    NSDate *firstDay;
    [self.calendar rangeOfUnit:NSCalendarUnitMonth startDate:&firstDay interval:nil forDate:self.currentMonth];
    
    NSUInteger dayNumberOfMonth = [self.calendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate: self.currentMonth].length;
    
    NSDateComponents *comp = [self.calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekOfMonth fromDate:firstDay];
    
    NSInteger day = [comp day];
    
    NSDateComponents *newComp;
    
    for (int i = 0; i < dayNumberOfMonth; i++) {
        
        [comp setDay:day + i];
        NSDate *date = [self.calendar dateFromComponents:comp];
        newComp = [self.calendar components: NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekOfMonth | NSCalendarUnitWeekday fromDate:date];
        NSInteger weekIndex = [newComp weekOfMonth];

        if (weekIndex == self.weekOfMonth) {
            break;
        }
        
    }
    
    NSDate *date = [self.calendar dateFromComponents:newComp];

    
    NSDateComponents *firstDayComp = [self.calendar components:NSCalendarUnitWeekday fromDate:firstDay];
    
    
    
    if ([firstDayComp weekday] != 1 && [newComp weekday] == 1) {
        
        NSInteger day = [newComp day];
        [newComp setDay:day + 1];
        date = [self.calendar dateFromComponents:newComp];
    }
    
    self.currentWeek = [self getFirstAndLastDayOfSomeWeek:date];
    
}


#pragma mark - 计算某一天是全年第几周，返回 "2017-35"


- (NSString *)weekOfYearForDate:(NSDate *)date {
    
    /**
     1号是周日，周日对应的不变，其他+1
     1号不是周日，周日对应的-1，其他不变
     */
    
    NSDate *firstDay;
    [self.calendar rangeOfUnit:NSCalendarUnitYear startDate:&firstDay interval:nil forDate:date];
    
    NSDateComponents *firstDayComps = [self.calendar components:NSCalendarUnitWeekOfYear | NSCalendarUnitWeekday fromDate:firstDay];
    
    NSDateComponents *dateComps = [self.calendar components:NSCalendarUnitWeekOfYear | NSCalendarUnitWeekday | NSCalendarUnitYear fromDate:date];
    
    long weekOfYear = [dateComps weekOfYear];
    
    if ([firstDayComps weekday] != 1 && [dateComps weekday] == 1) {
        weekOfYear -= 1;
    }
    
    else if ([firstDayComps weekday] == 1 && [dateComps weekday] != 1) {
        weekOfYear += 1;
    }
    
    // 临时解决，2017最后一周，canlender获取到year == 2017，weekOfYear == 1
    if ([dateComps year] == 2017 && [dateComps weekOfYear] == 1) {
        weekOfYear = 53;
    }
    
    return [NSString stringWithFormat:@"%ld-%ld", [dateComps year], weekOfYear];
}

#pragma mark - 将星期的首末日期转成字符串

- (NSString *)stringFromWeekDates:(NSArray<NSDate *> *)dates {
    
    NSDateFormatter *formatter = [SUDateTool dateFormatterYMD];
    formatter.dateFormat = @"MM月dd日";
    
    NSString *firstString = [formatter stringFromDate:[dates firstObject]];
    NSString *lastString = [formatter stringFromDate:[dates lastObject]];
    
    NSString *prefix = [firstString substringToIndex:3];
    
    if ([lastString hasPrefix:prefix]) {
        lastString = [lastString substringFromIndex:3];
    }
    
    NSString *dateString = [NSString stringWithFormat:@"%@-%@", firstString, lastString];
    
    return dateString;
    
}


#pragma mark - 参考方法


- (NSArray *)getFirstAndLastDayOfThisMonth {

    NSDate *firstDay;
    [self.calendar rangeOfUnit:NSCalendarUnitMonth startDate:&firstDay interval:nil forDate:[NSDate date]];
    NSDateComponents *lastDateComponents = [self.calendar components:NSCalendarUnitMonth | NSCalendarUnitYear |NSCalendarUnitDay fromDate:firstDay];
    NSUInteger dayNumberOfMonth = [self.calendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:[NSDate date]].length;
    NSInteger day = [lastDateComponents day];
    [lastDateComponents setDay:day+dayNumberOfMonth-1];
    NSDate *lastDay = [self.calendar dateFromComponents:lastDateComponents];
    return [NSArray arrayWithObjects:firstDay,lastDay, nil];

}

- (NSArray *)getFirstAndLastDayOfThisYear {

    //通过2月天数的改变，来确定全年天数
    NSDateFormatter *formatter = [SUDateTool dateFormatterYMD];
    [formatter setTimeZone:[NSTimeZone systemTimeZone]];
    [formatter setDateFormat:@"yyyy"];
    NSString *dateStr = [formatter stringFromDate:[NSDate date]];
    dateStr = [dateStr stringByAppendingString:@"-02-14"];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *aDayOfFebruary = [formatter dateFromString:dateStr];

    NSDate *firstDay;
    [self.calendar rangeOfUnit:NSCalendarUnitYear startDate:&firstDay interval:nil forDate:[NSDate date]];
    NSDateComponents *lastDateComponents = [self.calendar components:NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitDay fromDate:firstDay];
    NSUInteger dayNumberOfFebruary = [self.calendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:aDayOfFebruary].length;
    NSInteger day = [lastDateComponents day];
    [lastDateComponents setDay:day+337+dayNumberOfFebruary-1];
    NSDate *lastDay = [self.calendar dateFromComponents:lastDateComponents];

    return [NSArray arrayWithObjects:firstDay,lastDay, nil];

}

#pragma mark -

static NSDateFormatter *_formatterYMD;
static NSDateFormatter *_formatterMD;

+ (NSString *)stringForDate:(NSDate *)date {
    
    NSDateFormatter *formatter = [self dateFormatterYMD];
    formatter.dateFormat = @"yyyy-MM-dd";
    return [formatter stringFromDate:date];
}


+ (NSString *)stringForDateMD:(NSDate *)date {
    
    NSDateFormatter *formatter = [self dateFormatterMD];
    return [formatter stringFromDate:date];
}


+ (NSDateFormatter *)dateFormatterYMD {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _formatterYMD = [[NSDateFormatter alloc] init];
        _formatterYMD.dateFormat = @"yyyy-MM-dd";
    });
    return _formatterYMD;
}


+ (NSDateFormatter *)dateFormatterMD {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _formatterMD = [[NSDateFormatter alloc] init];
        _formatterMD.dateFormat = @"MM-dd";
    });
    return _formatterMD;
}


@end
