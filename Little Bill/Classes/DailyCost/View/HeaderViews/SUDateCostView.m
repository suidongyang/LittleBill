//
//  SUDateCostView.m
//  Little Bill
//
//  Created by SU on 2017/9/24.
//  Copyright © 2017年 SU. All rights reserved.
//

#import "SUDateCostView.h"

@interface SUDateCostView ()

@property (strong, nonatomic) UIButton *dateButton;
@property (strong, nonatomic) UILabel *costLabel;
@property (strong, nonatomic) UIButton *todayButton;

@property (strong, nonatomic) UILabel *weekdayLabel;

@end

@implementation SUDateCostView

+ (SUDateCostView *)loadDateCostView {
    
    SUDateCostView *dateCostView = [[SUDateCostView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 36)];
    [dateCostView initUI];
    return dateCostView;
}

- (void)initUI {
    
    self.backgroundColor = kThemeColor;
    
//    self.layer.shadowColor = [UIColor blackColor].CGColor;
//    self.layer.shadowOffset = CGSizeMake(0, 0);
//    self.layer.shadowRadius = 3;
//    self.layer.shadowOpacity = 0.2;
    
    self.dateButton = [[UIButton alloc] initWithFrame:CGRectMake(20, 8, 132, 20)];
    self.dateButton.titleLabel.font = [UIFont systemFontOfSize:24];
    [self.dateButton setTitleColor:[UIColor colorWithWhite:0 alpha:0.9] forState:UIControlStateNormal];
    [self.dateButton setTitle:@"9-24" forState:UIControlStateNormal];
    self.dateButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [self.dateButton addTarget:self action:@selector(backToTodayAction:) forControlEvents:UIControlEventTouchUpInside];
    
    self.weekdayLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, self.height)];
    self.weekdayLabel.font = [UIFont systemFontOfSize:24];
    self.weekdayLabel.textColor = [UIColor colorWithWhite:0 alpha:0.9];
    
    self.costLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.dateButton.maxX, 0, self.width - self.dateButton.maxX - 20, 20)];
    self.costLabel.maxY = self.dateButton.maxY;
    self.costLabel.font = [UIFont systemFontOfSize:24];
    self.costLabel.textColor = [UIColor colorWithWhite:0 alpha:0.9];
    self.costLabel.textAlignment = NSTextAlignmentRight;
    self.costLabel.text = @"1024";
        
    // 回到今天按钮
    UIButton *todayButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
    [todayButton setImage:[[UIImage imageNamed:@"back"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    todayButton.tintColor = self.dateButton.currentTitleColor;
    todayButton.x = self.dateButton.maxX + 4;
    todayButton.centerY = self.dateButton.centerY;
    [todayButton addTarget:self action:@selector(backToTodayAction:) forControlEvents:UIControlEventTouchUpInside];
    todayButton.hidden = YES;
    self.todayButton = todayButton;
    
    [self addSubview:self.dateButton];
    [self addSubview:self.costLabel];
    [self addSubview:self.todayButton];
    
}

- (void)backToTodayAction:(UIButton *)sender {
    if (self.todayButton.hidden) return;
   
    if (self.backTodayAction) {
        self.backTodayAction();
    }
    
    [UIView animateWithDuration:0.2 animations:^{
        self.todayButton.alpha = 0;
    }completion:^(BOOL finished) {
        self.todayButton.hidden = YES;
    }];
    
}

- (void)setDateString:(NSString *)dateString {
    _dateString = dateString;
    
    NSString *string = [dateString substringFromIndex:5];
    [self.dateButton setTitle:string forState:UIControlStateNormal];
    [self.dateButton sizeToFit];
    self.dateButton.centerY = self.costLabel.centerY;
    self.todayButton.x = self.dateButton.maxX + 4;
    self.todayButton.centerY = self.dateButton.centerY;
    
    NSString *todayDate = [SUDateTool stringForDate:[NSDate date]];
    
    if (![dateString isEqualToString:todayDate]) {
        
        self.todayButton.hidden = NO;
        [UIView animateWithDuration:0.2 animations:^{
            self.todayButton.alpha = 1;
        }];
    }
    else {
        [UIView animateWithDuration:0.2 animations:^{
            self.todayButton.alpha = 0;
        }completion:^(BOOL finished) {
            self.todayButton.hidden = YES;
        }];
    }
    
}

- (void)setSumExpense:(CGFloat)sumExpense {
    _sumExpense = sumExpense;
    
    NSString *costString = [NSString stringWithFormat:@"%.1f", sumExpense];
    if ([costString containsString:@".0"]) {
        costString = [costString substringToIndex:costString.length - 2];
    }
    
    self.costLabel.text = [NSString stringWithFormat:@"¥%@", costString];
    [self.costLabel sizeToFit];
    self.costLabel.maxX = self.width - 20;
    self.costLabel.centerY = self.dateButton.centerY;
    
}


@end
