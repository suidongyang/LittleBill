//
//  SUBudgetItem.h
//  Little Bill
//
//  Created by SU on 2017/12/10.
//  Copyright © 2017年 SU. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SUBudgetItem : NSObject

// 主键
@property (assign, nonatomic) int uniqueId;

// 周期id   同一个周期的预算和子预算 此id相同，相邻周期单调递增
@property (assign, nonatomic) int cycleId;

// 总支出   计算时排除不计入预算的条目
@property (assign, nonatomic) CGFloat sumExpense;

// 总预算
@property (assign, nonatomic) CGFloat total;

// 时间   月：“2017-12” or 周次：“2017-35”
@property (copy, nonatomic) NSString *date;

// 具体时间 用于预算详情页获取某一周的首末两天
@property (copy, nonatomic) NSString *dateString;

// 周期类型   0-周预算  1-月预算
@property (assign, nonatomic) int cycleType;

// 类别   0-总预算  categoryKey-某个类别的子预算
@property (assign, nonatomic) int category;

// 是否超支 1-超支  0-正常
@property (assign, nonatomic) int exceed;


@end
