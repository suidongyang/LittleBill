//
//  SUDateCostView.h
//  Little Bill
//
//  Created by SU on 2017/9/24.
//  Copyright © 2017年 SU. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SUDateCostView : UIView

+ (SUDateCostView *)loadDateCostView;

/// yyyy-MM-dd 只显示 MM-dd
@property (copy, nonatomic, readwrite) NSString *dateString;
@property (assign, nonatomic) CGFloat sumExpense;

@property (copy, nonatomic) void(^backTodayAction)(void);

@end
