//
//  SUSumBudgetCell.h
//  Little Bill
//
//  Created by SU on 2017/12/15.
//  Copyright © 2017年 SU. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SUSumBudgetItem;

@interface SUSumBudgetCell : UITableViewCell

@property (strong, nonatomic) SUSumBudgetItem *item;

@property (strong, nonatomic) UIImageView *line;

@property (strong, nonatomic) UITextField *numberField;
@property (strong, nonatomic) UIButton *maskButton;
@property (strong, nonatomic) UILabel *sumLabel;

@end
