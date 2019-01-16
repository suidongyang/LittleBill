//
//  SUDateChooseView.m
//  Little Bill
//
//  Created by SU on 2017/9/24.
//  Copyright © 2017年 SU. All rights reserved.
//

#import "SUDateChooseView.h"
#import "SUDateTool.h"

@interface SUDateChooseView ()

@property (strong, nonatomic) DateShiftButton *dateChooseButton;
@property (strong, nonatomic) UIButton *backButton;

@end

@implementation SUDateChooseView

+ (SUDateChooseView *)loadDateChooseView {
    SUDateChooseView *dateChooseView = [[SUDateChooseView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 44 + kStatusBarHeight)];
    [dateChooseView initUI];
    
    [[NSNotificationCenter defaultCenter] addObserver:dateChooseView selector:@selector(onBudgetChangedAction) name:@"budgetM" object:nil];
    
    return dateChooseView;
}


- (void)initUI {
    
    DateShiftButton *button = [[DateShiftButton alloc] initWithFrame:self.bounds];
    button.height = 60;
    button.centerY = self.height - 32 + (kStatusBarHeight > 20) * 5;
    [button setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont boldSystemFontOfSize:20]];
    [button setImage:[UIImage imageNamed:@"timeShift"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(changeCicleType:) forControlEvents:UIControlEventTouchUpInside];
    self.dateChooseButton = button;
    
    
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
    backButton.centerY = button.centerY;
    [backButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backToCurrentCircleAction:) forControlEvents:UIControlEventTouchUpInside];
    backButton.hidden = YES;
    self.backButton = backButton;
    
    [self addSubview:button];
    [self addSubview:backButton];
    
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *view = [super hitTest:point withEvent:event];
    if (view == nil) {
        for (UIView *subView in self.subviews) {
            CGPoint tp = [subView convertPoint:point fromView:self];
            if (CGRectContainsPoint(subView.bounds, tp)) {
                view = subView;
            }
        }
    }
    return view;
}

#pragma mark -


// 显示星期
- (void)displayWeek {
    
    SUDateTool *dateTool = [SUDateTool dateTool];
    
    NSArray<NSDate *> *thisWeek = dateTool.currentWeek;
    
    NSString *buttonTitle = [[SUDateTool dateTool] stringFromWeekDates:thisWeek];
    
    [self.dateChooseButton setTitle:buttonTitle forState:UIControlStateNormal];
    
    BOOL shouldShow = ![[dateTool weekOfYearForDate: thisWeek.firstObject] isEqualToString:[dateTool weekOfYearForDate:[NSDate date]]];
    [self showBackButton:shouldShow];
    
}

// 显示月
- (void)displayMonth {
    
    NSDate *month = [SUDateTool dateTool].currentMonth;
    NSDateFormatter *formatter = [SUDateTool dateFormatterYMD];
    formatter.dateFormat = @"yyyy年MM月";
    NSString *monthStr = [formatter stringFromDate: month];
    
    [self.dateChooseButton setTitle:monthStr forState:UIControlStateNormal];
    
    NSString *currentMonthStr = [formatter stringFromDate:[NSDate date]];
    BOOL shouldShow = ![monthStr isEqualToString:currentMonthStr];
    [self showBackButton:shouldShow];
    
}

// 显示年
- (void)displayYear {
    
    NSDate *year = [SUDateTool dateTool].currentYear;
    NSDateFormatter *formatter = [SUDateTool dateFormatterYMD];
    formatter.dateFormat = @"yyyy年";
    NSString *yearStr = [formatter stringFromDate: year];
    
    [self.dateChooseButton setTitle:yearStr forState:UIControlStateNormal];
    
    NSString *currentYearStr = [formatter stringFromDate:[NSDate date]];
    BOOL shouldShow = ![yearStr isEqualToString:currentYearStr];
    [self showBackButton:shouldShow];
    
}


- (void)update {
    
    if (self.circleType == DateCircleTypeWeek) {
        [self displayWeek];
    }else if (self.circleType == DateCircleTypeMonth) {
        [self displayMonth];
    }else if (self.circleType == DateCircleTypeYear) {
        [self displayYear];
    }
    
}


/*
 在设置里修改了预算周期后，lifeCycleManager 保存修改后的周期类型，设置页发送修改通知，这里接收通知，更新统计页UI
 */

- (void)onBudgetChangedAction {
    
    SUDateTool *dateTool = [SUDateTool dateTool];
    dateTool.currentWeek = [dateTool getFirstAndLastDayOfThisWeek];
    dateTool.currentMonth = dateTool.currentYear = [NSDate date];
    
    self.circleType = [LifeCycleManager manager].cycleType;
    
    [self update];
    
    if ([self.delegate respondsToSelector:@selector(dateChooseViewChangeDateCircle:)]) {
        [self.delegate dateChooseViewChangeDateCircle:self.circleType];
    }
    
    [self showBackButton:NO];
    
}

// 左右滑动时 切换前后周期
- (void)changeCircle:(NSInteger)next {
    
    switch (self.circleType) {
            
        case DateCircleTypeWeek:
            [[SUDateTool dateTool] getFirstAndLastDayOfNextWeek:next];
            [self displayWeek];
            break;
            
        case DateCircleTypeMonth:
            [[SUDateTool dateTool] getNextMonth:next];
            [self displayMonth];
            break;
            
        case DateCircleTypeYear:
            [[SUDateTool dateTool] getNextYear:next];
            [self displayYear];
            break;
            
        default:
            break;
    }
}


// 点击按钮时 切换周月年
- (void)changeCicleType:(UIButton *)sender {
    
    self.circleType = (self.circleType + 1) % 3;
    
    [self update];
    
    if ([self.delegate respondsToSelector:@selector(dateChooseViewChangeDateCircle:)]) {
        [self.delegate dateChooseViewChangeDateCircle:self.circleType];
    }
    
}

// 返回当前周期
- (void)backToCurrentCircleAction:(UIButton *)sender {
    
    SUDateTool *dateTool = [SUDateTool dateTool];
    dateTool.currentWeek = [dateTool getFirstAndLastDayOfThisWeek];
    dateTool.currentMonth = dateTool.currentYear = [NSDate date];
    
    [self update];
    
    if ([self.delegate respondsToSelector:@selector(dateChooseViewBackAction:)]) {
        [self.delegate dateChooseViewBackAction:self.circleType];
    }
    [self showBackButton:NO];
    
}

// 显示返回按钮
- (void)showBackButton:(BOOL)show {
    
    if (show && self.backButton.hidden) {
        
        self.backButton.hidden = NO;
        [UIView animateWithDuration:0.2 animations:^{
            self.backButton.alpha = 1;
        }];

    }else if (!show && !self.backButton.hidden) {
        
        [UIView animateWithDuration:0.2 animations:^{
            self.backButton.alpha = 0;
        }completion:^(BOOL finished) {
            self.backButton.hidden = YES;
        }];
    }
    
}

- (void)setCircleType:(DateCircleType)circleType {
    _circleType = circleType;
    [self update];
}


@end




@implementation DateShiftButton

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self.titleLabel sizeToFit];
    [self.imageView sizeToFit];
    
    self.titleLabel.x = 0.5 * (self.width - self.titleLabel.width - self.imageView.width);
    self.imageView.x = self.titleLabel.maxX + 2;
    self.titleLabel.centerY = self.imageView.centerY = 0.5 * self.height;
    
}

@end



















