//
//  SUBudgetSubCell.h
//  Little Bill
//
//  Created by SU on 2017/12/10.
//  Copyright © 2017年 SU. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SUBudgetItem;

@interface SUBudgetSubCell : UIView

@property (strong, nonatomic) SUBudgetItem *budgetItem;

+ (SUBudgetSubCell *)loadSubCell;

@end
