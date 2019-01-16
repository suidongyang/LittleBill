//
//  SUBudgetSettingController.h
//  Little Bill
//
//  Created by SU on 2017/12/29.
//  Copyright © 2017年 SU. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SUBudgetItem;

@interface SUBudgetSettingController : UIViewController

@property (strong, nonatomic) NSMutableArray<SUBudgetItem *> *currentBudgets;

@end

@interface BTypeButton : UIButton

@end
