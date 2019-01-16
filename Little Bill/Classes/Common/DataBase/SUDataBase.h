//
//  SUDataBase.h
//  Little Bill
//
//  Created by SU on 2017/10/9.
//  Copyright © 2017年 SU. All rights reserved.
//

#import <Foundation/Foundation.h>


#warning 封装FMDB

typedef NS_ENUM(NSUInteger, BudgetValueType) {
    BudgetValueTypeExpense = 0,
    BudgetValueTypeTotal = 1,
};



@class SUDailyCostModel;
@class SUBudgetItem;

@interface SUDataBase : NSObject

+ (SUDataBase *)sharedInstance;

- (void)insert:(SUDailyCostModel *)payoutModel;
- (void)update:(SUDailyCostModel *)payoutModel;
// id, date, category, remark, cost, weekofyear, inbudget
- (void)update:(SUDailyCostModel *)payoutModel forColumn:(NSInteger)column;
- (BOOL)deleteItem:(SUDailyCostModel *)item;

- (int)maxId;

- (NSArray *)queryDailyExpensesList:(NSString *)dayString;
- (CGFloat)queryDailySumExpense:(NSString *)dayString;
- (NSArray *)queryWeeklyExpenseList:(NSString *)weekOfYear;
- (NSArray *)queryMonthlyExpenseList:(NSString *)monthString;
- (NSArray *)queryYearlyExpenseList:(NSString *)yearString;


- (NSInteger)queryCategoryForId:(int)uniqueId;

// 类别按周期统计 减 inBudget == 0
- (CGFloat)querySumExpenseForCategory:(int)category date:(NSString *)dateString cycleType:(int)cycleType;
// 周期总支出，不包括不计入预算的
- (CGFloat)querySumExpenseForDate:(NSString *)dateString cycleType:(int)cycleType;

// 查询所有记录，用于导出CSV
- (NSArray<NSDictionary *> *)queryAllExpenses;


#pragma mark - 预算

// 插入时需要统计本周期开始以来的开销总额，计入预算
- (void)insertBudget:(SUBudgetItem *)item;

- (void)updateBudget:(SUBudgetItem *)item type:(BudgetValueType)type;

// 待修改 删除时判断是否需要更新子预算是否超支的状态 红黄绿
- (void)deleteBudget:(SUBudgetItem *)item;

- (int)maxBudgetUniqueId;
- (int)maxCycleId;

// 查询当期预算
- (NSArray *)queryCurrentBudget;

// 查询某条指定预算(包括子预算)   0-周预算  1-月预算
- (NSArray *)queryHistoryBudgetWithDate:(NSString *)date cycleType:(int)cycleType;
- (NSArray *)querySubBudgetsWithCycleId:(int)cycleId;

// 查询10条历史预算（仅总预算）
- (NSArray *)queryHistoryBudgetsFromIndex:(int)index;

// 插入新预算 启动和新增记录时，判断当前日期是否包含在最新的预算周期里
//- (void)


// 批量方法 开启事务 dataBaseQueue的使用



@end
