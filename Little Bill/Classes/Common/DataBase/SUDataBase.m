//
//  SUDataBase.m
//  Little Bill
//
//  Created by SU on 2017/10/9.
//  Copyright © 2017年 SU. All rights reserved.
//

#import "SUDataBase.h"
#import <FMDB/FMDB.h>

#import "SUDailyCostModel.h"
#import "SUCategoryManager.h"

#import "SUBudgetItem.h"


@interface SUDataBase ()

@property (strong, nonatomic) FMDatabase *dataBase;
@property (strong, nonatomic) FMDatabaseQueue *dataBaseQueue;

@end


@implementation SUDataBase

static SUDataBase *_database;
static NSString * const kDataBaseName = @"little_bill.db";
static NSString * const kPayoutTable = @"table_payout";
static NSString * const kBudgetTable = @"table_budget";


+ (SUDataBase *)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _database = [[self alloc] init];
    });
    return _database;
}

#pragma mark - 初始化

- (instancetype)init {
    if (self = [super init]) {
        [self initDataBase];
        [self initTable];
    }
    return self;
}

// 创建数据库
- (void)initDataBase {
    
    NSString *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *dbPath = [documentPath stringByAppendingPathComponent:kDataBaseName];
    NSLog(@"\n%@", dbPath);
    
    self.dataBase = [FMDatabase databaseWithPath: dbPath];
    self.dataBaseQueue = [FMDatabaseQueue databaseQueueWithPath:dbPath];
    
}

// 创建收支表
- (void)initTable {
    
    if ([self.dataBase open]) {
        [self createExpenseTable];
    }
    [self.dataBase close];
    
    [self createBudgetTable];
    
}

- (void)createExpenseTable {
    
    NSString *createTableSql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS '%@' (id INTEGER , date TEXT, category INTEGER, remark TEXT, cost REAL, weekofyear TEXT, inbudget INTEGER)", kPayoutTable];
    
    if ([self.dataBase executeUpdate:createTableSql]) {
        NSLog(@"创建成功：收支表");
    }
    else {
        NSLog(@"创建失败：收支表");
    }
    
    // 添加测试数据

//    [self.dataBase executeUpdate:@"delete from table_payout"];
//
//    int iddd = 1;
//
//    for (int i = 0; i < 50; i++) {
//
//        for (int j = 0; j < 7; j++) {
//
//            SUDailyCostModel *model = [[SUDailyCostModel alloc] init];
//            model.category = arc4random_uniform(20) + 1;
//            model.remarks = [NSString stringWithFormat:@"%@-%d", [[SUCategoryManager manager] titleForKey:model.category], i * 10 + j];
//            model.cost = arc4random_uniform(100);
//            if (i < 30) {
//                model.dateString = [NSString stringWithFormat:@"2017-11-%d", i + 1];
//                if (i + 1 < 10) {
//                    model.dateString = [NSString stringWithFormat:@"2017-11-0%d", i + 1];
//                }
//            }else {
//                model.dateString = [NSString stringWithFormat:@"2017-10-%d", i - 30 + 12];
//            }
//
//            model.weekOfYear = [NSString stringWithFormat:@"2017-%d", 40 + i / 10];
//            model.inBudget = YES;
//            model.recordId = iddd;
//            ++iddd;
//
//            [self insert:model];
//        }
//
//
//    }
    
}

#pragma mark - 增

- (void)insert:(SUDailyCostModel *)payoutModel {
    
    if ([self.dataBase open]) {

        NSString *insert_sql = [NSString stringWithFormat:@"INSERT INTO '%@' (id, date, category, remark, cost, weekofyear, inbudget) VALUES (%d, '%@', %d, '%@', %f, '%@', %d)", kPayoutTable, payoutModel.recordId, payoutModel.dateString, (int)payoutModel.category, payoutModel.remarks, payoutModel.cost, payoutModel.weekOfYear, payoutModel.inBudget];

        if ([self.dataBase executeUpdate:insert_sql]) {
            NSLog(@"插入成功");
        }else {
            NSLog(@"插入失败");
        }
        
        [self.dataBase close];
    }
    
}

#pragma mark - 删

- (BOOL)deleteItem:(SUDailyCostModel *)item {
    
    BOOL result = NO;
    
    if ([self.dataBase open]) {
        
        NSString *deleteSql = [NSString stringWithFormat:@"DELETE FROM '%@' WHERE id = %d", kPayoutTable, item.recordId];
        
        result = [self.dataBase executeUpdate:deleteSql];
        
        NSLog(result ? @"删除成功" : @"删除失败");
        
        [self.dataBase close];
    }
    
    
    return result;
}

#pragma mark - 改

- (void)update:(SUDailyCostModel *)payoutModel {
    
    if ([self.dataBase open]) {
        
        NSString *updateSql = [NSString stringWithFormat:@"UPDATE '%@' SET date = '%@', category = %d, remark = '%@', cost = %f, inbudget = %d WHERE id = %d", kPayoutTable, payoutModel.dateString, (int)payoutModel.category, payoutModel.remarks, payoutModel.cost, payoutModel.inBudget, payoutModel.recordId];
        
        if ([self.dataBase executeUpdate:updateSql]) {
            NSLog(@"更新成功");
        }else {
             NSLog(@"更新失败");
        }
     
        [self.dataBase close];
    }
    
}

#warning 优化  抽取所有方法的公共部分，封装fmdb 将所有字段改为宏定义，

// id, date, category, remark, cost, weekofyear, inbudget

// 设置 inbudget

- (void)update:(SUDailyCostModel *)payoutModel forColumn:(NSInteger)column {
    
    if ([self.dataBase open]) {
        
        NSString *updateSql = [NSString stringWithFormat:@"UPDATE '%@' SET inbudget = %d WHERE id = %d", kPayoutTable, payoutModel.inBudget, payoutModel.recordId];
        
        if ([self.dataBase executeUpdate:updateSql]) {
            NSLog(@"更新成功 -- inbudget");
        }else {
            NSLog(@"更新失败 -- inbudget");
        }
        
        [self.dataBase close];
    }
    
}

#pragma mark - 查

#pragma mark - 主键

- (int)maxId {
    
    int maxId = -1;
    if ([self.dataBase open]) {
        maxId = [self.dataBase intForQuery:@"SELECT max(id) from table_payout"];
        [self.dataBase close];
    }
    
    return maxId;
}

#pragma mark - 每日收支列表

- (NSArray *)queryDailyExpensesList:(NSString *)dayString {
    
    NSMutableArray *costarray = [NSMutableArray array];
    
    NSString *selectSql = [NSString stringWithFormat:@"SELECT * FROM '%@' WHERE date = '%@' ORDER BY id DESC", kPayoutTable, dayString];
    
    if ([self.dataBase open]) {
        
        FMResultSet *resultSet = [self.dataBase executeQuery:selectSql];
        
        while ([resultSet next]) {
            
            SUDailyCostModel *model = [[SUDailyCostModel alloc] init];
            model.recordId = [resultSet intForColumn:@"id"];
            model.dateString = [resultSet stringForColumn:@"date"];
            model.category = [resultSet intForColumn:@"category"];
            model.remarks = [resultSet stringForColumn:@"remark"];
            model.cost = [resultSet doubleForColumn:@"cost"];
            model.weekOfYear = [resultSet stringForColumn:@"weekofyear"];
            model.inBudget = [resultSet intForColumn:@"inbudget"];
            
            [costarray addObject:model];
            
        }
        
        [self.dataBase close];
    }
    
    
    return costarray;
}

#pragma mark - 每日支出总额

- (CGFloat)queryDailySumExpense:(NSString *)dayString {
    
    NSString *dailySumSql = [NSString stringWithFormat:@"SELECT sum(cost) FROM table_payout WHERE date = '%@' and category < 31", dayString];
    
    CGFloat sumExpense = 0;
    
    if ([self.dataBase open]) {
        sumExpense = [self.dataBase doubleForQuery:dailySumSql];
    }
    
    [self.dataBase close];
    
    return sumExpense;
}


#pragma mark - 周度统计

- (NSArray *)queryWeeklyExpenseList:(NSString *)weekOfYear {
    
    NSString *selectSql = [NSString stringWithFormat:@"SELECT * FROM '%@' WHERE weekofyear = '%@'", kPayoutTable, weekOfYear];
    return [self query:selectSql];
}


#pragma mark - 月度统计

- (NSArray *)queryMonthlyExpenseList:(NSString *)monthString {
    
    NSString *selectSql = [NSString stringWithFormat:@"SELECT * FROM '%@' WHERE date LIKE '%@%%'", kPayoutTable, monthString];
    return [self query:selectSql];
}


#pragma mark - 年度统计

- (NSArray *)queryYearlyExpenseList:(NSString *)yearString {
    return [self queryMonthlyExpenseList:yearString];
}

#pragma mark -

- (NSArray *)query:(NSString *)sqlString {
    
    NSString *selectSql = sqlString;
    NSMutableArray *queryResults = [NSMutableArray array];
    
    if ([self.dataBase open]) {
        
        FMResultSet *resultSet = [self.dataBase executeQuery:selectSql];
        
        while ([resultSet next]) {
            
            SUDailyCostModel *model = [[SUDailyCostModel alloc] init];
            model.category = [resultSet intForColumn:@"category"];
            model.cost = [resultSet doubleForColumn:@"cost"];
            
            [queryResults addObject:model];
        }
    }
    
    [self.dataBase close];
    
    if (queryResults.count == 0) {
        return @[@[], @[]];
    }
    
    // 转换成cycleCost需要的数据结构
    // [ [{categoryKey:sum}, ... ] , [{}, ... ] ]
    
    // sum        array[0] array[1] ... array[34]
    // category   key1     key2     ... key35
    
    //#warning 暂不支持自定义类别，先写死 支出类别30个，收入类别5个
    
    float sumArray[35] = {0.0f};
    for (SUDailyCostModel *item in queryResults) {
        sumArray[item.category - 1] += item.cost;
    }
    
    NSMutableArray *key_sum_array = [NSMutableArray arrayWithCapacity:30];
    NSMutableArray *income_key_sum_array = [NSMutableArray arrayWithCapacity:5];
    
    for (int i = 0; i < 35; i++) {
        if (sumArray[i] != 0.0f) {
            NSDictionary *keySumDict = @{@(i + 1) : @(sumArray[i])};
            
            if (i < 30) {
                [key_sum_array addObject:keySumDict];
            }else {
                [income_key_sum_array addObject:keySumDict];
            }
        }
    }
    
    // 降序排序
    
    typedef NSDictionary<NSNumber *, NSNumber *> * ObjType;
    
    if (key_sum_array.count > 0) {
        [key_sum_array sortUsingComparator:^NSComparisonResult(ObjType _Nonnull obj1, ObjType _Nonnull obj2) {
            return [obj2.allValues.firstObject compare: obj1.allValues.firstObject];
        }];
    }
    
    if (income_key_sum_array.count > 0) {
        [income_key_sum_array sortUsingComparator:^NSComparisonResult(ObjType _Nonnull obj1, ObjType _Nonnull obj2) {
            return [obj2.allValues.firstObject compare: obj1.allValues.firstObject];
        }];
    }
    
    return @[key_sum_array, income_key_sum_array];
}


- (NSInteger)queryCategoryForId:(int)uniqueId {
    
    NSInteger category = -1;
    
    if ([self.dataBase open]) {
        
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM '%@' WHERE id = %d", kPayoutTable, uniqueId];
        
        FMResultSet *resultSet = [self.dataBase executeQuery:sql];
        
        while ([resultSet next]) {
            category = [resultSet intForColumn:@"category"];
        }
        
        [self.dataBase close];
    }
    
    return category;
    
}


#pragma mark - 按 类别和日期和计入预算标记 查询总支出


- (CGFloat)querySumExpenseForCategory:(int)category date:(NSString *)dateString cycleType:(int)cycleType {
    
    NSString *querySql;
    
    if (cycleType == 0) { // 周预算
        querySql = [NSString stringWithFormat:@"SELECT sum(cost) FROM table_payout WHERE weekofyear = '%@' AND inbudget = 1 AND category = %d", dateString, category];
    }else {
        querySql = [NSString stringWithFormat:@"SELECT sum(cost) FROM table_payout WHERE date LIKE '%@%%' AND inbudget = 1 AND category = %d", dateString, category];
    }
    
    CGFloat sumExpense = 0;
    
    if ([self.dataBase open]) {
        
        sumExpense = [self.dataBase doubleForQuery:querySql];
        
        [self.dataBase close];
    }

    return sumExpense;
}


#pragma mark - 预算使用 周期总支出，不包含不计入预算的

- (CGFloat)querySumExpenseForDate:(NSString *)dateString cycleType:(int)cycleType {
    
    NSString *querySql;
    
    if (cycleType == 0) {
        querySql = [NSString stringWithFormat:@"SELECT sum(cost) FROM table_payout WHERE weekofyear = '%@' AND inbudget = 1 AND category < 31", dateString];
    }else {
        querySql = [NSString stringWithFormat:@"SELECT sum(cost) FROM table_payout WHERE date LIKE '%@%%' AND inbudget = 1 AND category < 31", dateString];
    }
    
    CGFloat sumExpense = 0;
    
    if ([self.dataBase open]) {
        
        sumExpense = [self.dataBase doubleForQuery:querySql];
        
        [self.dataBase close];
    }
    
    return sumExpense;
}



- (NSArray<NSDictionary *> *)queryAllExpenses {
    
    NSString *querySql = @"SELECT * FROM table_payout";
    
    NSMutableArray<NSMutableDictionary *> *results = [NSMutableArray<NSMutableDictionary *> array];
    
    if ([self.dataBase open]) {
        
        SUCategoryManager *catMan = [SUCategoryManager manager];
        
        FMResultSet *resultSet = [self.dataBase executeQuery:querySql];
        
        while ([resultSet next]) {
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            dict[@"日期"] = [resultSet stringForColumn:@"date"];
            dict[@"类别"] = [catMan titleForKey: [resultSet intForColumn:@"category"]];
            dict[@"类型"] = [resultSet intForColumn:@"category"] > 30 ? @"收入" : @"支出";
            dict[@"金额"] = [NSString stringWithFormat:@"%.1f", [resultSet doubleForColumn:@"cost"]];
            dict[@"备注"] = [resultSet stringForColumn:@"remark"];
            
            [results addObject:dict];
            
        }
        
        [self.dataBase close];
    }
    
    return results;
}




#pragma mark -
#pragma mark - 预算


#pragma mark - 创建预算表

- (void)createBudgetTable {
    
    /*
     主键
     周期id   同一个周期的预算和子预算 此id相同，相邻周期单调递增
     总支出   计算时排除不计入预算的条目
     总预算
     时间    月：“2017-12” or 周次：“2017-35”
     周期类型
     类别    0-总预算  categoryKey-某个类别的子预算
     */
    
    
    /**
     一个预算会有多条记录，分别是总预算和各个子预算，读取某个预算时需要读取多条记录
     添加子预算时，自动包含该类别本周期已支出的总额
     
     
     */
    
    if ([self.dataBase open]) {
        
        NSString *createTableSql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS '%@' (id INTEGER, cycleid INTEGER, sumexpense REAL, total REAL, date TEXT, datestring TEXT, cycletype INTEGER, category INTEGER, exceed INTEGER)", kBudgetTable];
        
        if ([self.dataBase executeUpdate:createTableSql]) {
            NSLog(@"创建成功：预算表");
        }
        else {
            NSLog(@"创建失败：预算表");
        }
        

        #warning 需要注释掉 测试
        
//        [self.dataBase executeUpdate:@"delete from table_budget"];
//        [self addTestData];
    
        [self.dataBase close];
    }
    
    
}


#pragma mark - 添加预算

- (void)insertBudget:(SUBudgetItem *)item {
    
    item.exceed = item.sumExpense > item.total;
    item.uniqueId = [self maxBudgetUniqueId] + 1;
    
    if ([self.dataBase open]) {
        
        NSString *insert_sql = [NSString stringWithFormat:@"INSERT INTO '%@' (id, cycleid, sumexpense, total, date, datestring, cycletype, category, exceed) VALUES (%d, %d, %f, %f, '%@', '%@', %d, %d, %d)", kBudgetTable,item.uniqueId, item.cycleId, item.sumExpense, item.total, item.date, item.dateString, item.cycleType, item.category, item.exceed];
        
        if ([self.dataBase executeUpdate:insert_sql]) {
            NSLog(@"预算 插入成功");
        }else {
            NSLog(@"预算 插入失败");
        }
        
        
        // 统计本周期开始以来的各类别及总开销总额
        // 另外在设置中增加子预算时可能会用到
        
        
    }
    
    [self.dataBase close];
}


#pragma mark - 更新预算

/*
 当前预算：查询条件：maxCycleId
         更新条件：cycleId category
 
 历史预算：查询条件：date cycleType
         更新条件：cycleId category
 
 */
- (void)updateBudget:(SUBudgetItem *)item type:(BudgetValueType)type {
    
    item.exceed = item.sumExpense > item.total;
    
    if ([self.dataBase open]) {
        
        NSString *key = type == BudgetValueTypeTotal ? @"total" : @"sumexpense";
        CGFloat value = type == BudgetValueTypeTotal ? item.total : item.sumExpense;
        
        NSString *updateSql = [NSString stringWithFormat:@"UPDATE '%@' SET '%@' = %f, exceed = %d WHERE cycleid = %d AND category = %d", kBudgetTable, key, value, item.exceed, item.cycleId, item.category];
        
        if ([self.dataBase executeUpdate:updateSql]) {
            NSLog(@"预算 更新成功 -- date: %@, 类别：%d", item.date, item.category);
        }else {
            NSLog(@"预算 更新失败 -- date: %@, 类别：%d", item.date, item.category);
        }
        
    }
    
    [self.dataBase close];
}

#pragma mark - 删除预算

// 删除时判断是否需要更新子预算是否超支的状态 红黄绿
// 总预算只能修改总额

- (void)deleteBudget:(SUBudgetItem *)item {
    
    if ([self.dataBase open]) {
        
        NSString *deleteSql = [NSString stringWithFormat:@"DELETE FROM '%@' WHERE id = %d", kBudgetTable, item.uniqueId];
        
        if ([self.dataBase executeUpdate:deleteSql]) {
            NSLog(@"预算 删除成功");
        }else {
            NSLog(@"预算 删除失败");
        }
        
    }
    
    [self.dataBase close];
    
}

#pragma mark - id 和 cycleId 的最新值

- (int)maxBudgetUniqueId {
    
    int maxId = -1;
    if ([self.dataBase open]) {
        maxId = [self.dataBase intForQuery:@"SELECT max(id) from table_budget"];
    }
    [self.dataBase close];
    
    return maxId;
    
}


// 周期id，总预算和子预算的cycleId相同，不同周期单调递增
- (int)maxCycleId {
    
    int maxId = -1;
    if ([self.dataBase open]) {
        maxId = [self.dataBase intForQuery:@"SELECT max(cycleid) from table_budget"];
    }
    [self.dataBase close];
    
    return maxId;
    
}


#pragma mark - 查询当期预算

// [总预算, 子预算, ...]

- (NSArray *)queryCurrentBudget {
    
    int cycleId = [self maxCycleId];
    
    NSMutableArray<SUBudgetItem *> *budgetArray = [NSMutableArray array];
    
    NSString *selectSql = [NSString stringWithFormat:@"SELECT * FROM '%@' WHERE cycleid = %d ORDER BY id ASC", kBudgetTable, cycleId];
    
    if ([self.dataBase open]) {
        
        FMResultSet *resultSet = [self.dataBase executeQuery:selectSql];
        
        while ([resultSet next]) {
            // (cycleid, sumexpense, total, date, cycletype, category)
            SUBudgetItem *item = [[SUBudgetItem alloc] init];
            item.uniqueId = [resultSet intForColumn:@"id"];
            item.cycleId = [resultSet intForColumn:@"cycleid"];
            item.sumExpense = [resultSet doubleForColumn:@"sumexpense"];
            item.total = [resultSet doubleForColumn:@"total"];
            item.date = [resultSet stringForColumn:@"date"];
            item.dateString = [resultSet stringForColumn:@"datestring"];
            item.cycleType = [resultSet intForColumn:@"cycletype"];
            item.category = [resultSet intForColumn:@"category"];
            item.exceed = [resultSet intForColumn:@"exceed"];
            
            [budgetArray addObject:item];
            
        }
        
    }
    
    [self.dataBase close];
    
    for (int i = 1; i < budgetArray.count; i++) {
        budgetArray[0].exceed += budgetArray[i].exceed;
    }
    
    return budgetArray;
    
    
}

#pragma mark - 查询某组历史预算

- (NSArray *)queryHistoryBudgetWithDate:(NSString *)date cycleType:(int)cycleType {
    
    NSMutableArray *budgetArray = [NSMutableArray array];
    
    // 或者按类别升序排序，与面板顺序一致，id顺序为添加顺序
    
    NSString *selectSql = [NSString stringWithFormat:@"SELECT * FROM '%@' WHERE date = '%@' AND cycletype = %d ORDER BY id ASC", kBudgetTable, date, cycleType];
    
    if ([self.dataBase open]) {
        
        FMResultSet *resultSet = [self.dataBase executeQuery:selectSql];
        
        while ([resultSet next]) {
            // (cycleid, sumexpense, total, date, cycletype, category)
            SUBudgetItem *item = [[SUBudgetItem alloc] init];
            item.uniqueId = [resultSet intForColumn:@"id"];
            item.cycleId = [resultSet intForColumn:@"cycleid"];
            item.sumExpense = [resultSet doubleForColumn:@"sumexpense"];
            item.total = [resultSet doubleForColumn:@"total"];
            item.date = [resultSet stringForColumn:@"date"];
            item.dateString = [resultSet stringForColumn:@"datestring"];
            item.cycleType = [resultSet intForColumn:@"cycletype"];
            item.category = [resultSet intForColumn:@"category"];
            
            [budgetArray addObject:item];
            
        }
        
        [self.dataBase close];
    }
    
    return budgetArray;
    
}

#pragma mark - 查询某条预算的子预算组

- (NSArray *)querySubBudgetsWithCycleId:(int)cycleId {
    
    NSMutableArray *budgetArray = [NSMutableArray array];
    
    // 或者按类别升序排序，与面板顺序一致，id顺序为添加顺序
    
    NSString *selectSql = [NSString stringWithFormat:@"SELECT * FROM '%@' WHERE cycleid = %d AND category > 0 ORDER BY id ASC", kBudgetTable, cycleId];
    
    if ([self.dataBase open]) {
        
        FMResultSet *resultSet = [self.dataBase executeQuery:selectSql];
        
        while ([resultSet next]) {
            // (cycleid, sumexpense, total, date, cycletype, category)
            SUBudgetItem *item = [[SUBudgetItem alloc] init];
            item.uniqueId = [resultSet intForColumn:@"id"];
            item.cycleId = [resultSet intForColumn:@"cycleid"];
            item.sumExpense = [resultSet doubleForColumn:@"sumexpense"];
            item.total = [resultSet doubleForColumn:@"total"];
            item.date = [resultSet stringForColumn:@"date"];
            item.dateString = [resultSet stringForColumn:@"datestring"];
            item.cycleType = [resultSet intForColumn:@"cycletype"];
            item.category = [resultSet intForColumn:@"category"];
            
            [budgetArray addObject:item];
            
        }
        
        [self.dataBase close];
    }
    
    return budgetArray;
    
}


#pragma mark - 查询5条历史预算 仅总预算

- (NSArray *)queryHistoryBudgetsFromIndex:(int)index {
    
    NSMutableArray *array = [NSMutableArray array];
    int loadIndex = index;
    
    while (array.count < 5 && loadIndex > 0) {
        NSArray<SUBudgetItem *> *historyBudgets = [self queryHistoryBudgetsWithIndex:loadIndex];
        [array addObjectsFromArray:historyBudgets];
        loadIndex -= 5;
    }
    
    return array;
}

- (NSArray *)queryHistoryBudgetsWithIndex:(int)index {
    
    NSMutableArray *budgetsArray = [NSMutableArray array];

    NSString *querySql = [NSString stringWithFormat:@"SELECT * FROM '%@' WHERE category = 0 AND cycleid < %d AND cycleid >= %d - 5 ORDER BY id DESC", kBudgetTable, index, index];
    
    if ([self.dataBase open]) {
        
        FMResultSet *resultSet = [self.dataBase executeQuery:querySql];
        
        while ([resultSet next]) {
            // (cycleid, sumexpense, total, date, cycletype, category)
            SUBudgetItem *item = [[SUBudgetItem alloc] init];
            item.uniqueId = [resultSet intForColumn:@"id"];
            item.cycleId = [resultSet intForColumn:@"cycleid"];
            item.sumExpense = [resultSet doubleForColumn:@"sumexpense"];
            item.total = [resultSet doubleForColumn:@"total"];
            item.date = [resultSet stringForColumn:@"date"];
            item.dateString = [resultSet stringForColumn:@"datestring"];
            item.cycleType = [resultSet intForColumn:@"cycletype"];
            item.category = [resultSet intForColumn:@"category"];
            
            [budgetsArray addObject:item];
            
        }
    
        [self.dataBase close];
    }
    
    
    for (SUBudgetItem *item in budgetsArray) {
        
        item.exceed = [self queryExceedFlagWithId:item.cycleId];
        
    }
    
    
    return budgetsArray;
    
}


#pragma mark - 查询是否存在子预算超支

- (int)queryExceedFlagWithId:(int)cycleId {
    
    int flag = 0;
    
    if ([self.dataBase open]) {
        
        NSString *querySql = [NSString stringWithFormat:@"SELECT sum(exceed) FROM '%@' WHERE cycleid = %d", kBudgetTable, cycleId];
        
        flag = [self.dataBase intForQuery:querySql];
        
        [self.dataBase close];
    }
    
    return flag;
    
}


#pragma mark - 添加测试数据

- (void)addTestData {
    
    NSDateFormatter *formatter = [SUDateTool dateFormatterYMD];
    formatter.dateFormat = @"yyyy-MM-dd";
    
    NSDate *startDate = [formatter dateFromString:@"2017-08-07"];
    
    NSDateComponents *comps = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:startDate];
    
    
    
    NSMutableArray<SUBudgetItem *> *arr = [NSMutableArray arrayWithCapacity:20];
    
    for (int i = 0; i < 20; i++) {
        
        NSInteger day = [comps day];
        [comps setDay:day + 7];
        NSDate *date = [[NSCalendar currentCalendar] dateFromComponents:comps];
        NSString *dateString = [formatter stringFromDate:date];

        SUBudgetItem *budgetItem = [[SUBudgetItem alloc] init];
        budgetItem.cycleId = i + 1;
        budgetItem.total = (i + 1) * 1000;
        budgetItem.sumExpense = budgetItem.total - arc4random_uniform(500);
        budgetItem.date = [[SUDateTool dateTool] weekOfYearForDate:date];
        budgetItem.dateString = dateString;
        budgetItem.cycleType = 0;
        budgetItem.category = 0;

        [arr addObject:budgetItem];
        [self insertBudget:budgetItem];

    }
    
    for (int i = 0; i < 20; i++) {
        
        for (int j = 0; j < 4; j++) {
            
            SUBudgetItem *budgetItem = [[SUBudgetItem alloc] init];
            budgetItem.cycleId = i + 1;
            budgetItem.sumExpense = 300;
            budgetItem.total = 500 + j * 100;
            budgetItem.date = arr[i].date;
            budgetItem.cycleType = 0;
            budgetItem.category = i + 1 + j + 1;
            
            [self insertBudget:budgetItem];
            
        }
        
    }
    
}








@end
