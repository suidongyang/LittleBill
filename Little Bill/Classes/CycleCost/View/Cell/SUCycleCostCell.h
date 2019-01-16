//
//  SUCycleCostCell.h
//  Little Bill
//
//  Created by SU on 2017/12/1.
//  Copyright © 2017年 SU. All rights reserved.
//

#import <UIKit/UIKit.h>

UIKIT_EXTERN NSInteger const kPieTag;

@interface SUCycleCostCell : UICollectionViewCell

@property (assign, nonatomic) NSInteger dataType;  // 0-支出  1-收入
@property (strong, nonatomic) NSArray *dataSource;

@end
