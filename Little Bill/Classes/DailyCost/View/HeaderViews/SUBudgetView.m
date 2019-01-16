//
//  SUBudgetView.m
//  Little Bill
//
//  Created by SU on 2017/9/24.
//  Copyright © 2017年 SU. All rights reserved.
//

#import "SUBudgetView.h"
#import "SUBudgetItem.h"

@interface SUBudgetView ()

@property (strong, nonatomic) UILabel *symbolLabel;
@property (strong, nonatomic) UILabel *numberLabel;
@property (strong, nonatomic) UILabel *bottomLabel;

@end

@implementation SUBudgetView

+ (SUBudgetView *)loadBudgetView {
    SUBudgetView *budgetView = [[SUBudgetView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 90 + kStatusBarHeight)];
    [budgetView initUI];
    [budgetView addGestures];
    return budgetView;
}


#pragma mark -


- (void)addGestures {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(presentBudgetController:)];
    [self addGestureRecognizer:tap];
}
- (void)presentBudgetController:(UITapGestureRecognizer *)gesture {
    
    CGPoint location = [gesture locationInView:self];
    
    BOOL left = location.x < 0.5 * self.width;
    
    if ([self.delegate respondsToSelector:@selector(budgetViewDidTappedAtLeft:)]) {
        [self.delegate budgetViewDidTappedAtLeft:left];
    }
}


#pragma mark -


- (void)initUI {
    
    self.backgroundColor = kThemeColor; // [UIColor colorWithWhite:1 alpha:0.2];
    
    UILabel *symbolLabel = [[UILabel alloc] init];
    symbolLabel.font = [UIFont systemFontOfSize:40 weight:UIFontWeightLight];
    symbolLabel.textColor = [UIColor colorWithHexString:@"ffc87a"]; // fec780
//    symbolLabel.alpha = 0.9;

    symbolLabel.text = @"¥";
    self.symbolLabel = symbolLabel;
    
    UILabel *numberLabel = [[UILabel alloc] init];
    numberLabel.font = [UIFont systemFontOfSize:60 weight:UIFontWeightLight];
    numberLabel.textColor = [UIColor colorWithHexString:@"ffc87a"]; // [UIColor colorWithWhite:0 alpha:0.7];
//    numberLabel.alpha = 0.9;
    numberLabel.text = @"2000";
    self.numberLabel = numberLabel;
    
    UILabel *bottomLabel = [[UILabel alloc] init];
    bottomLabel.font = [UIFont systemFontOfSize:13];
    bottomLabel.textColor = [UIColor colorWithHexString:@"ffc87a"]; // [UIColor colorWithWhite:0 alpha:0.4];
    bottomLabel.alpha = 0.8;
    bottomLabel.textAlignment = NSTextAlignmentCenter;
    bottomLabel.text = @"本周可用预算";
    self.bottomLabel = bottomLabel;
    
    [self addSubview:symbolLabel];
    [self addSubview:numberLabel];
    [self addSubview:bottomLabel];
    
    [self constraintSubviews];
    
    
}

- (void)constraintSubviews {
    
    [self.symbolLabel sizeToFit];
    [self.numberLabel sizeToFit];
    [self.bottomLabel sizeToFit];
    
    self.symbolLabel.height = self.symbolLabel.font.capHeight + 1;
    self.numberLabel.height = self.numberLabel.font.capHeight + 3;
    
    self.symbolLabel.x = 0.5 * (self.width - self.symbolLabel.width - self.numberLabel.width - 3);
    self.numberLabel.x = self.symbolLabel.maxX - 3;
    
    
    self.bottomLabel.maxY = self.height - (100+20 - self.numberLabel.height - self.bottomLabel.height - 10) * 0.5 + 16;
    self.numberLabel.maxY = self.bottomLabel.maxY - self.bottomLabel.height - 10;
    
    self.bottomLabel.centerX = 0.5 * self.width;
    
    self.symbolLabel.maxY = self.numberLabel.maxY - 1;
    
}


#pragma mark -


- (void)setTotalBudgetItem:(SUBudgetItem *)totalBudgetItem {
    _totalBudgetItem = totalBudgetItem;
    
    self.numberLabel.text = [NSString stringWithFormat:@"%.1f", totalBudgetItem.total - totalBudgetItem.sumExpense];
    
    if ([self.numberLabel.text hasSuffix:@".0"]) {
        self.numberLabel.text = [self.numberLabel.text substringToIndex:self.numberLabel.text.length - 2];
    }
    
    if (self.numberLabel.text.integerValue <= 0) {
        self.numberLabel.text = @"0";
    }
    
    self.bottomLabel.text = totalBudgetItem.cycleType == 0 ? @"本周可用预算" : @"本月可用预算";
    
    [self constraintSubviews];
    
}





@end
