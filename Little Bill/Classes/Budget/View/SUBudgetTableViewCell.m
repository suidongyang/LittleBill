//
//  SUBudgetTableViewCell.m
//  Little Bill
//
//  Created by SU on 2017/12/10.
//  Copyright © 2017年 SU. All rights reserved.
//

#import "SUBudgetTableViewCell.h"

#import "SUBudgetSubCell.h"
#import "SUBudgetItem.h"
#import "TrafficLight.h"

#import "BudgetConsts.h"


@interface SUBudgetTableViewCell ()

@property (strong, nonatomic) UILabel *dateLabel;
@property (strong, nonatomic) TrafficLight *lightView;

@property (strong, nonatomic) UIView *containerView;

@property (strong, nonatomic) NSMutableArray<SUBudgetSubCell *> *subCells;


@end

#define kTotalCellTag 2847


@implementation SUBudgetTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self initUI];
    }
    return self;
}

- (void)initUI {
    
    // 容器视图
    self.containerView = [[UIView alloc] init];
    self.containerView.backgroundColor = [UIColor whiteColor]; // [UIColor colorWithHexString:@"fdfdff"];
    
    self.containerView.layer.borderWidth = 0.5f;
    self.containerView.layer.borderColor = [UIColor colorWithHexString:@"c4c4d6"].CGColor;
//    self.containerView.layer.cornerRadius = 4.0f;
    self.containerView.layer.masksToBounds = YES;
    
    // 时间
    UILabel *dateLabel = [[UILabel alloc] init];
    dateLabel.font = [UIFont systemFontOfSize:17];
    dateLabel.textColor = kDarkTextColor;
    dateLabel.textAlignment = NSTextAlignmentLeft;
    dateLabel.text = @"2017年12月";
    self.dateLabel = dateLabel;
    
    // 红绿灯
    self.lightView = [[TrafficLight alloc] initWithFrame:CGRectMake(0, 0, 50, 20)];
    
    [self.contentView addSubview:dateLabel];
    [self.contentView addSubview:self.lightView];
    [self.contentView addSubview:self.containerView];
    
}


- (void)constraintSubviews {  // 10 + 18 + 4 + 54
    
    [self.dateLabel sizeToFit];
    self.dateLabel.height = 18;
    self.dateLabel.x = 20;
    self.dateLabel.y = 10;
    
    self.lightView.centerY = self.dateLabel.centerY;
    self.lightView.maxX = kScreenWidth - 15;
    
    
    self.containerView.frame = CGRectMake(10, self.dateLabel.maxY + 6, kScreenWidth - 20, kContainerNormalHeight);
    
}


#pragma mark - setters


- (void)setBudgetItem:(SUBudgetItem *)budgetItem {
    _budgetItem = budgetItem;
    
    NSDateFormatter *formatter = [SUDateTool dateFormatterYMD];
    formatter.dateFormat = @"yyyy-MM-dd";
    NSDate *date = [formatter dateFromString:_budgetItem.dateString];
    
    if (_budgetItem.cycleType == 0) { // 周
        
        NSArray<NSDate *> *dateArray = [[SUDateTool dateTool] getFirstAndLastDayOfSomeWeek:date];
        
        NSString *dateStr = [[SUDateTool dateTool] stringFromWeekDates:dateArray];
        
        self.dateLabel.text = dateStr;
        
    }else {
        formatter.dateFormat = @"yyyy年MM月";
        NSString *dateStr = [formatter stringFromDate:date];
        self.dateLabel.text = dateStr;
    }
    
    
    SUBudgetSubCell *subCell = [self.containerView viewWithTag:kTotalCellTag];
    if (subCell == nil) {
        subCell = [SUBudgetSubCell loadSubCell];
        subCell.x = 10;
        subCell.maxY = kContainerNormalHeight - 15;
        subCell.width = kScreenWidth - 40;
        subCell.tag = kTotalCellTag;
        [self.containerView addSubview:subCell];
        
        // 放在这里，防止调用cellforrow以后，重新设置budgetItem导致行高不变container收起的问题
        [self constraintSubviews];
        
    }
    subCell.budgetItem = budgetItem;
    
    
    if (_budgetItem.sumExpense > _budgetItem.total) {
        self.lightView.state = LightStateRed;
    }else {
        if (_budgetItem.exceed > 0) {
            self.lightView.state = LightStateYellow;
        }else {
            self.lightView.state = LightStateGreen;
        }
    }

    
    
    // [self constraintSubviews];
    
}


- (void)setSubItems:(NSArray<SUBudgetItem *> *)subItems {
    _subItems = subItems;
    
    if (!_subItems || _subItems.count == 0) return;
    
    if (!self.subCells) {
        self.subCells = [NSMutableArray array];
    }
    
    [self.subCells makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.subCells removeAllObjects];
    
    // 在设置里增减子预算怎么处理
    
    for (int i = 0; i < _subItems.count; i++) {
        
        SUBudgetSubCell *subCell = [SUBudgetSubCell loadSubCell];
        subCell.origin = CGPointMake(10, 48 + kSubBudgetCellHeight * i);
        subCell.width = kScreenWidth - 40;
        subCell.alpha = 0;
        subCell.budgetItem = _subItems[i];
        
        [self.containerView addSubview:subCell];
        [self.subCells addObject:subCell];
        
    }
    
}

- (void)setSpread:(BOOL)spread {
    _spread = spread;
    
    CGFloat duration = self.animatable ? 0.3 : 0;
    
    if (spread) {
        
        for (UIView *subCell in self.subCells) {
            subCell.hidden = NO;
        }
        [UIView animateWithDuration:duration animations:^{
            self.containerView.height = kContainerNormalHeight + self.subItems.count * kSubBudgetCellHeight;
            for (UIView *subCell in self.subCells) {
                subCell.alpha = 1;
            }
        }];
        
    }else {
        
        [UIView animateWithDuration:0.3 animations:^{
            self.containerView.height = kContainerNormalHeight;
            for (UIView *subCell in self.subCells) {
                subCell.alpha = 0;
            }
        }completion:^(BOOL finished) {
            for (UIView *subCell in self.subCells) {
                subCell.hidden = YES;
            }
        }];
        
    }
    
    
    
    
    
}











@end
