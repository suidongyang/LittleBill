//
//  SUButtonPanel.h
//  Little Bill
//
//  Created by SU on 2017/12/4.
//  Copyright © 2017年 SU. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SUButtonPanel : UIScrollView

@property (assign, nonatomic) NSInteger dataType; // 0-支出  1-收入
@property (strong, nonatomic) NSArray *dataSource; // [{key:sum}, ...]

- (instancetype)initWithFrame:(CGRect)frame;
- (void)reloadData;

@end



@class SUCategoryItem;
@interface StatisticButton : UIButton

@property (strong, nonatomic) SUCategoryItem *sumItem;

@end
