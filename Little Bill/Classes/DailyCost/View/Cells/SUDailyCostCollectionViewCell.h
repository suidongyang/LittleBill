//
//  SUDailyCostCollectionViewCell.h
//  Little Bill
//
//  Created by SU on 2017/9/24.
//  Copyright © 2017年 SU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HandleScrollActionProtocol.h"

@class SUDailyCostModel;
@protocol SUDailyCostCollectionViewCellDelegate

@optional
- (void)dailyCostTableView:(UITableView *)tableView didSelectCellAtIndexPath:(NSIndexPath *)indexPath;
- (void)dailyCostTableView:(UITableView *)tableView deleteItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)dailyCostTableView:(UITableView *)tableView swipeRightWithItem:(SUDailyCostModel *)item;

@end

@interface SUDailyCostCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) id<HandleScrollActionProtocol, SUDailyCostCollectionViewCellDelegate> delegate;

@property (copy, nonatomic) void(^insertItemAction)(CGFloat newCellOY);

@property (strong, nonatomic) NSMutableArray *dailyExpenseArray;

@property (assign, nonatomic) CGFloat tableViewInsetTop;

- (void)inputBoardCanceledNeedDeleteRow:(BOOL)shouldDelete;

- (void)reloadRowOfTableViewAtIndexPath:(NSIndexPath *)indexPath;

- (void)deleteRowAtIndexPath:(NSIndexPath *)indexPath;

- (void)insertRowAtIndexPath:(NSIndexPath *)indexPath;

- (void)reloadRowOfTableView;

- (void)scrollListToTop;


@end
