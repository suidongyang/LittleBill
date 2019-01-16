//
//  SUFakeCell.h
//  Little Bill
//
//  Created by SU on 2017/10/21.
//  Copyright © 2017年 SU. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SUDailyCostModel;

@interface SUFakeCell : UIView

+ (SUFakeCell *)loadFakeCell;

// 由输入面板获取
@property (strong, nonatomic, readonly) SUDailyCostModel *generatedModel;
@property (strong, nonatomic) UIImageView *editIconView;

- (void)showWithModel:(SUDailyCostModel *)model;

/// 将子控件变化到正常cell的位置和大小
- (void)prepareForDismiss;

/// 恢复到初始位置大小
- (void)resetWithModel:(SUDailyCostModel *)model;


@end
