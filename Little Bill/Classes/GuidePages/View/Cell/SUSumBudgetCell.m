//
//  SUSumBudgetCell.m
//  Little Bill
//
//  Created by SU on 2017/12/15.
//  Copyright © 2017年 SU. All rights reserved.
//

#import "SUSumBudgetCell.h"
#import "SUSumBudgetItem.h"
#import "SUCategoryManager.h"

@interface SUSumBudgetCell ()

@property (strong, nonatomic) UIImageView *colorView;
@property (strong, nonatomic) UILabel *categoryLabel;

@end


@implementation SUSumBudgetCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self initUI];
    }
    return self;
}

- (void)initUI {
    
    self.contentView.backgroundColor = [UIColor clearColor];
    self.backgroundColor = [UIColor clearColor];
    
    self.colorView = [[UIImageView alloc] initWithFrame:CGRectMake(16, 0, 12, 12)];
    self.colorView.contentMode = UIViewContentModeScaleToFill;
    self.colorView.layer.cornerRadius = 0.5 * self.colorView.height;
    self.colorView.layer.masksToBounds = YES;
    self.colorView.centerY = 25;
    
    self.categoryLabel = [UILabel labelWithFont:16 textColor:kDarkTextColor textAlignment:NSTextAlignmentLeft frame:CGRectMake(self.colorView.maxX + 6, 0, 150, 50)];
    self.categoryLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightLight];
    
    self.sumLabel = [UILabel labelWithFont:17 textColor:kDarkTextColor textAlignment:NSTextAlignmentRight frame:CGRectMake(0, 0, 150, 50)];
    self.sumLabel.maxX = kScreenWidth - 18;
    self.sumLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightLight];
    
    self.numberField = [[UITextField alloc] initWithFrame:self.sumLabel.frame];
    self.numberField.backgroundColor = [UIColor whiteColor];
    self.numberField.font = self.sumLabel.font;
    self.numberField.textColor = kDarkTextColor;
//    self.numberField.tintColor = kDarkTextColor;
    self.numberField.textAlignment = NSTextAlignmentRight;
    self.numberField.keyboardType = UIKeyboardTypeNumberPad;
    self.numberField.hidden = YES;
    
    self.maskButton = [[UIButton alloc] initWithFrame:self.numberField.frame];
    self.maskButton.hidden = YES;
    
    UIImageView *line = [[UIImageView alloc] initWithFrame:CGRectMake(16, 50 - 0.5, kScreenWidth - 32, 0.5)];
    line.contentMode = UIViewContentModeScaleToFill;
    line.image = [UIImage imageWithColor:kLightGrayColor];
    self.line = line;
    
    
    [self.contentView addSubview:self.colorView];
    [self.contentView addSubview:self.categoryLabel];
    [self.contentView addSubview:self.sumLabel];
    [self.contentView addSubview:self.numberField];
    [self.contentView addSubview:self.maskButton];
    [self.contentView addSubview:self.line];
    
    
}


- (void)setItem:(SUSumBudgetItem *)item {
    _item = item;
    
    UIColor *color = [[SUCategoryManager manager] colorForKey:item.category ?: 1];
    self.colorView.image = [UIImage imageWithColor:color];
    self.categoryLabel.text = [NSString stringWithFormat:@"%@", [[SUCategoryManager manager] titleForKey:item.category] ?: @"总计"];
    self.sumLabel.text = [NSString stringWithFormat:@"¥%.0f", item.sum];
    self.numberField.text = self.sumLabel.text;
    
}


@end
