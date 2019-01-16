//
//  SnapShotCell.h
//  Little Bill
//
//  Created by SU on 2017/12/19.
//  Copyright © 2017年 SU. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SnapShotCell : UIView

@property (strong, nonatomic) UIView *bottomLine;
@property (strong, nonatomic) UIView *holeView;

- (SnapShotCell *)initWithSnapShot:(UIView *)snapShot inBudget:(BOOL)inBudget isExpense:(BOOL)isExpense;

@end
