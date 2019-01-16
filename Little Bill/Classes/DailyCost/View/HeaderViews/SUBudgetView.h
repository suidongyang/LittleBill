//
//  SUBudgetView.h
//  Little Bill
//
//  Created by SU on 2017/9/24.
//  Copyright © 2017年 SU. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SUBudgetViewDelegate <NSObject>

@optional
- (void)budgetViewDidTappedAtLeft:(BOOL)tappedLeft;

@end


@class SUBudgetItem;

@interface SUBudgetView : UIView

@property (weak, nonatomic) id<SUBudgetViewDelegate> delegate;

@property (strong, nonatomic) SUBudgetItem *totalBudgetItem;

+ (SUBudgetView *)loadBudgetView;



@end
