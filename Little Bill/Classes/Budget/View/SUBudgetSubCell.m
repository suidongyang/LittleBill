//
//  SUBudgetSubCell.m
//  Little Bill
//
//  Created by SU on 2017/12/10.
//  Copyright © 2017年 SU. All rights reserved.
//

#import "SUBudgetSubCell.h"
#import "SUBudgetItem.h"
#import "BudgetConsts.h"

#import "SUCategoryManager.h"


@interface SUBudgetSubCell ()

@property (strong, nonatomic) UILabel *categoryLabel;
@property (strong, nonatomic) UILabel *detailLabel;
@property (strong, nonatomic) UIView *totalView;
@property (strong, nonatomic) UIView *expenseView;


@end


@implementation SUBudgetSubCell

+ (SUBudgetSubCell *)loadSubCell {
    SUBudgetSubCell *subcell = [[SUBudgetSubCell alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth - 20, kSubBudgetCellHeight)];
    [subcell initUI];
    return subcell;
}

- (void)initUI {
        
    UILabel *categoryLabel = [[UILabel alloc] init];
    categoryLabel.font = [UIFont systemFontOfSize:14];
    categoryLabel.textColor = [UIColor darkGrayColor];
    categoryLabel.textAlignment = NSTextAlignmentLeft;
    categoryLabel.text = @"类别";
    self.categoryLabel = categoryLabel;
    
    
    UILabel *detailLabel = [[UILabel alloc] init];
    detailLabel.font = [UIFont systemFontOfSize:14];
    detailLabel.textColor = [UIColor darkGrayColor];
    detailLabel.textAlignment = NSTextAlignmentRight;
    detailLabel.text = @"¥1800.0 / ¥2000.0";
    self.detailLabel = detailLabel;
    
    
    UIView *totalView = [[UIView alloc] init];
    totalView.backgroundColor =  [UIColor colorWithHexString:@"f0f0f0"]; // kLineColor; //
    totalView.layer.cornerRadius = 2.0f;
    totalView.layer.masksToBounds = YES;
    self.totalView = totalView;
    
    
    UIView *expenseView = [[UIView alloc] init];
    expenseView.backgroundColor = [UIColor randomColor];
    expenseView.layer.cornerRadius = 2.0f;
    expenseView.layer.masksToBounds = YES;
    self.expenseView = expenseView;
    
    
    [totalView addSubview:expenseView];
    [self addSubview:categoryLabel];
    [self addSubview:detailLabel];
    [self addSubview:totalView];
    
}

- (void)setupConstraints:(SUBudgetItem *)item {  // 子预算： 4 + 8 + 18 + 14 = 44   总预算：44 + 6
    
    // 从下到上 依赖布局
    
    BOOL isTotal = item.category == 0;
    
    self.totalView.frame = CGRectMake(0, 0, self.width, 8);
    self.totalView.maxY = self.height;
    
    self.expenseView.frame = self.totalView.bounds;
    self.expenseView.width = (self.budgetItem.sumExpense / self.budgetItem.total) * self.totalView.width;
    
    [self.categoryLabel sizeToFit];
    self.categoryLabel.height = isTotal ? 20 : 18;
    self.categoryLabel.maxY = self.totalView.y - 8;
    self.categoryLabel.x = 0;

    [self.detailLabel sizeToFit];
    self.detailLabel.height = isTotal ? 20 : 18;
    self.detailLabel.centerY = self.categoryLabel.centerY;
    self.detailLabel.maxX = self.width;
    
}


- (void)setBudgetItem:(SUBudgetItem *)budgetItem {
    _budgetItem = budgetItem;
    
    if (budgetItem.category == 0) {
        self.categoryLabel.text = @"总计";
        self.categoryLabel.font = [UIFont systemFontOfSize:16];
        self.detailLabel.font = [UIFont systemFontOfSize:16];
        self.expenseView.backgroundColor = [UIColor colorWithHexString:@"86869E"];
    }else {
        self.categoryLabel.text = [[SUCategoryManager manager] titleForKey:budgetItem.category];
        self.expenseView.backgroundColor = [[SUCategoryManager manager] colorForKey:budgetItem.category];
    }
    
    NSString *sumExpenseStr = [NSString stringWithFormat:@"%.1f", budgetItem.sumExpense];
    if ([sumExpenseStr hasSuffix:@".0"]) {
        sumExpenseStr = [sumExpenseStr substringToIndex:sumExpenseStr.length - 2];
    }
    
    self.detailLabel.text = [NSString stringWithFormat:@"¥%@ / ¥%.0f",sumExpenseStr, budgetItem.total];
    
    if (_budgetItem.sumExpense > _budgetItem.total) {
        self.categoryLabel.textColor = self.detailLabel.textColor = [UIColor redColor];
    }
    
    [self setupConstraints:_budgetItem];
    
}





@end
