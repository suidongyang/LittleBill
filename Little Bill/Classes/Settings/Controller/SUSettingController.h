//
//  SUSettingController.h
//  Little Bill
//
//  Created by SU on 2017/9/21.
//  Copyright © 2017年 SU. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SUBudgetItem;

@interface SUSettingController : UIViewController

@property (strong, nonatomic) NSMutableArray<SUBudgetItem *> *currentBudgets;

@end
