//
//  SUInputBoard.h
//  Little Bill
//
//  Created by SU on 2017/9/25.
//  Copyright © 2017年 SU. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SUDailyCostModel;

@protocol SUInputBoardDelegate <NSObject>

@optional

- (void)inputBoardAddCompletion:(SUDailyCostModel *)payoutModel;
- (void)inputBoardEditCompletion:(SUDailyCostModel *)payoutModel;
- (void)inputBoardCanceledAndShouldRoll:(BOOL)shouldRoll;

@end


@interface SUInputBoard : UIView

@property (assign, nonatomic) id<SUInputBoardDelegate> delegate;

/// 用于动画，区分编辑状态和添加状态，编辑状态时不为nil
@property (strong, nonatomic) SUDailyCostModel *fakeCellModel;

+ (SUInputBoard *)loadInputBoard;

- (void)showWithFakeCellOriginY:(CGFloat)originY
                animateDistance:(CGFloat)animateDistance;

- (void)hide;


@end
