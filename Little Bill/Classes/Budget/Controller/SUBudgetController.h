//
//  SUBudgetController.h
//  Little Bill
//
//  Created by SU on 2017/9/21.
//  Copyright © 2017年 SU. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SUBudgetItem;

@interface SUBudgetController : UIViewController

// 使用dailyCost已经查询更新过的预算数组，直接展示
@property (strong, nonatomic) NSMutableArray<SUBudgetItem *> *currentBudgets;

// 关闭按钮显示在哪一侧
@property (assign, nonatomic) BOOL leftSideClose;

@end
