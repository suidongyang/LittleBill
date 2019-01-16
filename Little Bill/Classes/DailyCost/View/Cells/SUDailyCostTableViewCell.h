//
//  SUDailyCostTableViewCell.h
//  Little Bill
//
//  Created by SU on 2017/9/24.
//  Copyright © 2017年 SU. All rights reserved.
//

@class SUDailyCostTableViewCell;
@protocol SUDailyCostCellDraggingDelegate <NSObject>

@optional
- (void)dailyCostCell:(SUDailyCostTableViewCell *)cell draggingWithGesture:(UILongPressGestureRecognizer *)gesture;

@end

#import <UIKit/UIKit.h>

@class SUDailyCostModel;

@interface SUDailyCostTableViewCell : UITableViewCell

@property (weak, nonatomic) id<SUDailyCostCellDraggingDelegate> delegate;

@property (strong, nonatomic) SUDailyCostModel *payoutModel;

@property (strong, nonatomic) NSString *costString;

@end
