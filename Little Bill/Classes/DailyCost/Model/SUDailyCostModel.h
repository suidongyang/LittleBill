//
//  SUDailyCostModel.h
//  Little Bill
//
//  Created by SU on 2017/9/28.
//  Copyright © 2017年 SU. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SUDailyCostModel : NSObject <NSCopying>

/// ID
@property (assign, nonatomic) int recordId;

/// 类别，大于 30 的是收入
@property (assign, nonatomic) NSInteger category;

/// 金额
@property (assign, nonatomic) CGFloat cost;

/// 备注
@property (copy, nonatomic) NSString *remarks;

/// 日期
@property (copy, nonatomic) NSString *dateString;

#warning 跨年周 如果周序号是1则需要查询上一年最后一周是否有记录，或者最后一周时检索下一年第一周
/// 某年第几周 "2017-35"
@property (copy, nonatomic) NSString *weekOfYear;

// 是否计入预算  （如房租可以不计入）
@property (assign, nonatomic) BOOL inBudget;


/// 默认选中的类别模型 “一般”
+ (SUDailyCostModel *)defaultPayoutModel;


@end
