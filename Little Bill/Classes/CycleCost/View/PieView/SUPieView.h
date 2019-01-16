//
//  SUPieView.h
//  Little Bill
//
//  Created by SU on 2017/12/2.
//  Copyright © 2017年 SU. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SUPieView : UIView

- (instancetype)initWithFrame:(CGRect)frame;

/// type: 0-支出 1-收入
- (void)strokeWithDataItems:(NSArray *)dataItems colorItems:(NSArray *)colorItems recordType:(NSInteger)type;

@property (assign, nonatomic) CGFloat animateXOffset;
@property (assign, nonatomic) CGFloat frameXOffset;

@end
