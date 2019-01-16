//
//  SUBudgetCategoryBoard.h
//  Little Bill
//
//  Created by SU on 2017/12/15.
//  Copyright © 2017年 SU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SUTextField.h"

UIKIT_EXTERN const NSInteger kBudgetCateoryBoardTag;


@class SUSumBudgetItem;

@protocol SUBudgetCategoryBoardProtocol <NSObject>

@optional
- (void)categoryBoardInputCompletion:(SUSumBudgetItem *)item; 

@end



@interface SUBudgetCategoryBoard : UIView

@property (weak, nonatomic) id<SUBudgetCategoryBoardProtocol> delegate;

+ (SUBudgetCategoryBoard *)loadBoard;

- (void)show;
- (void)hide;

- (void)showWithCompletion:(void(^)(void))completion;

@end
