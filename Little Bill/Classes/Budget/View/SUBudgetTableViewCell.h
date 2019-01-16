//
//  SUBudgetTableViewCell.h
//  Little Bill
//
//  Created by SU on 2017/12/10.
//  Copyright © 2017年 SU. All rights reserved.
//
// normalHeight == 60

#import <UIKit/UIKit.h>

@class SUBudgetItem;

@interface SUBudgetTableViewCell : UITableViewCell

// 总预算
@property (strong, nonatomic) SUBudgetItem *budgetItem;

// 所有子预算
@property (strong, nonatomic) NSArray<SUBudgetItem *> *subItems;
@property (assign, nonatomic) BOOL animatable;
@property (assign, nonatomic) BOOL spread;

@property (assign, nonatomic) CGFloat spreadHeight;


@end
