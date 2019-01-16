//
//  SUBudgetController.m
//  Little Bill
//
//  Created by SU on 2017/9/21.
//  Copyright © 2017年 SU. All rights reserved.
//

#import "SUBudgetController.h"
#import "SUBudgetItem.h"
#import "SUBudgetTableViewCell.h"
#import "BudgetConsts.h"
#import "SUDataBase.h"
#import "SUBudgetSettingController.h"

@interface SUBudgetController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UITableView *budgetTableView;

@property (strong, nonatomic) NSMutableArray *cellHeightArray;
@property (strong, nonatomic) NSMutableArray *cellExpreadFlags; // 0-正常  1-展开
@property (copy, nonatomic) NSMutableString *cellIdCache;

@property (assign, nonatomic) CGFloat firstCellHeight;

@property (strong, nonatomic) NSMutableArray *historyBudgets;

@property (assign, nonatomic) int maxCycleId;

@property (strong, nonatomic) UIView *loadMoreView;
@property (assign, nonatomic) BOOL isloading;
@property (assign, nonatomic) BOOL backFromSettings;

@end

/** TODO
 
 点击哪边 关闭按钮显示在哪边
 
 */


@implementation SUBudgetController

static NSString * const kBudgetCellId = @"kBudgetCellId";

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.backFromSettings == NO) {
        
        self.firstCellHeight = kBudgetCellNormalHeight + (self.currentBudgets.count - 1) * kSubBudgetCellHeight;
        self.maxCycleId = [[SUDataBase sharedInstance] maxCycleId];
        self.historyBudgets = [NSMutableArray array];
        
        [self loadBudgets];
        
    }else {
        
        self.firstCellHeight = kBudgetCellNormalHeight + (self.currentBudgets.count - 1) * kSubBudgetCellHeight;
        [self.budgetTableView reloadData];
        
        self.backFromSettings = NO;
    }
    
}


#pragma mark - private

- (void)loadBudgets {
    
    NSArray<SUBudgetItem *> *array = [[SUDataBase sharedInstance] queryHistoryBudgetsFromIndex:self.maxCycleId];
    [self.historyBudgets addObjectsFromArray:array];
    self.maxCycleId = array.lastObject.cycleId;
    [self.budgetTableView reloadData];
    
}


- (void)initUI {
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 44 + kStatusBarHeight)];
    titleView.backgroundColor = [UIColor whiteColor];
    
//    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleRegular];
//    UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
//    effectView.frame = titleView.bounds;
//    effectView.alpha = 1.0;
//    [titleView addSubview:effectView];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.font = [UIFont systemFontOfSize:18];
    titleLabel.textColor = kDarkTextColor;
    titleLabel.text = @"预算";
    [titleLabel sizeToFit];
    titleLabel.centerX = 0.5 * titleView.width;
    titleLabel.centerY = titleView.height - 32 + (kStatusBarHeight > 20) * 5;
    
    UIButton *closeButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    [closeButton setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    closeButton.centerY = titleLabel.centerY;
    if (self.leftSideClose) {
        closeButton.x = 10;
    }else {
        closeButton.maxX = titleView.width - 10;
    }
    
    
    [titleView addSubview:titleLabel];
    [titleView addSubview:closeButton];
    
    
    UITableView *budgetTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight) style:UITableViewStyleGrouped];
    budgetTableView.contentInset = UIEdgeInsetsMake(titleView.maxY + 10, 0, 0, 0);
    budgetTableView.dataSource = self;
    budgetTableView.delegate = self;
    budgetTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    budgetTableView.backgroundColor = kBudgetBGColor; // [UIColor groupTableViewBackgroundColor];
    budgetTableView.showsVerticalScrollIndicator = NO;
    budgetTableView.showsHorizontalScrollIndicator = NO;
    
    // 解决bug：滑动到默认展开的cell时，点击其他cell，tableview跳动
    budgetTableView.estimatedRowHeight = 0;
    budgetTableView.estimatedSectionHeaderHeight = 0;
    budgetTableView.estimatedSectionFooterHeight = 0;
    
    if (@available(iOS 11.0, *)) {
        budgetTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    
    self.budgetTableView = budgetTableView;
    
    self.loadMoreView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenHeight, kScreenWidth, 56)];
    self.loadMoreView.backgroundColor = [UIColor lightGrayColor];
    self.loadMoreView.hidden = YES;
    
    [self.view addSubview:budgetTableView];
    [self.view addSubview:titleView];
    [self.view addSubview:self.loadMoreView];
    
    
}

#pragma mark - 按钮事件

// 设置
- (void)settingButtonAction {
    
    
    
}

// 返回
- (void)dismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 删除预算

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.section == 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.section == 1 ? @"删除" : @"设置";
}

//- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
//
//    if (indexPath.section == 0) {
//
//        UITableViewRowAction *action = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"设置" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
//
//            SUBudgetSettingController *budgetSettings = [[SUBudgetSettingController alloc] init];
//            budgetSettings.currentBudgets = self.currentBudgets;
//            [self.navigationController pushViewController:budgetSettings animated:YES];
//            self.backFromSettings = YES;
//
//        }];
//
//        return @[action];
//    }
//    else {
//        return nil;
//    }
//
//
//}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 1) {
        
        SUBudgetItem *item = self.historyBudgets[indexPath.row];
        [[SUDataBase sharedInstance] deleteBudget:item];
        
        [self.historyBudgets removeObject:item];
        [self.cellHeightArray removeObjectAtIndex:indexPath.row];
        [self.cellExpreadFlags removeObjectAtIndex:indexPath.row];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
    }

}


#pragma mark - UITableViewDelegate

//- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
//
//    if (indexPath.section == 0) return;
//
//    cell.alpha = 0;
//    [UIView animateWithDuration:0.2 animations:^{
//        cell.alpha = 1;
//    }];
//
//}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) return;
    
    SUBudgetTableViewCell *cell = (SUBudgetTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    
    BOOL spread = ![self.cellExpreadFlags[indexPath.item] boolValue];
    cell.spread = spread;
    self.cellExpreadFlags[indexPath.item] = @(spread);
    self.cellHeightArray[indexPath.item] = spread ? @(cell.spreadHeight) : @(kBudgetCellNormalHeight);
    
    
    [tableView beginUpdates];
    [tableView endUpdates];
    
    [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:YES];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return indexPath.section == 0 ? self.firstCellHeight : [self.cellHeightArray[indexPath.item] floatValue];
    
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return section == 0 ? 1 : self.historyBudgets.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *dontReuseId = [NSString stringWithFormat:@"su%ld-%ld", indexPath.section, indexPath.row];
    if (![self.cellIdCache containsString:dontReuseId]) {
        [tableView registerClass:[SUBudgetTableViewCell class] forCellReuseIdentifier:dontReuseId];
        [self.cellIdCache appendString:dontReuseId];
    }
    
    
    SUBudgetTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:dontReuseId];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    cell.animatable = YES;
    
    if (indexPath.section == 0) {
        
        SUBudgetItem *item = self.currentBudgets.firstObject;
        
        cell.budgetItem = item;
        
        NSMutableArray *subItems = [NSMutableArray array];
        for (int i = 1; i < self.currentBudgets.count; i++) {
            [subItems addObject:self.currentBudgets[i]];
        }
        cell.subItems = subItems;
        cell.animatable = NO;
        cell.spread = YES;
        
        
    }else {
        
        if (indexPath.item < self.historyBudgets.count) {
            
            SUBudgetItem *item = self.historyBudgets[indexPath.item];
            
            if (![cell.budgetItem isEqual: item]) {
                
                cell.budgetItem = item;
                
                // 查库 加载子预算并更新行高缓存
                
                NSMutableArray *arr = [NSMutableArray array];
                
                NSArray *budgets = [[SUDataBase sharedInstance] querySubBudgetsWithCycleId:cell.budgetItem.cycleId];
                arr = [NSMutableArray arrayWithArray:budgets];
                
                cell.subItems = arr;
                
                cell.spreadHeight = kBudgetCellNormalHeight + arr.count * kSubBudgetCellHeight;
                
                cell.spread = [self.cellExpreadFlags[indexPath.row] boolValue];
                
            }
        }
    }
    
    
    
    return cell;
}

#pragma mark - Header / Footer

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.01f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {

     return [[UIView alloc] init];
//    if (section == 0)
    
//    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 40)];
//
//    UILabel *historyLabel = [[UILabel alloc] init];
//    historyLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightLight];
//    historyLabel.textColor = klightTextColor;
//    historyLabel.text = @"— 历史预算 —";
//    [historyLabel sizeToFit];
//    historyLabel.centerX = 0.5 * headerView.width;
//    historyLabel.centerY = 0.5 * headerView.height + 14;
//    [headerView addSubview:historyLabel];
//
//    return headerView;
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == 0) {
        return 0.01f;
    }else {
        // 加上 if 空页面 else
        return 10.0f;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {

    if (section == 0) {
        return [[UIView alloc] init];
    }else {
         UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 10)];
        return footerView;
    }

}


#pragma mark - Scroll View 代理

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
    if (scrollView.contentSize.height + scrollView.contentInset.top < scrollView.height) {
        
        if (scrollView.contentOffset.y + scrollView.contentInset.top > 56) {
            if (!self.isloading) {
                self.isloading = YES;
                [self loadMoreBudgets];
            }
        }
        
    }else {
        
        if (scrollView.contentOffset.y + scrollView.height - scrollView.contentSize.height > 56) {
            if (!self.isloading) {
                self.isloading = YES;
                [self loadMoreBudgets];
            }
        }
    }
    
}

- (void)loadMoreBudgets {
    
    // bug记录：有时加载会超过5条，但不会超过10条， cellHeightArray越界，所以这里将5改成10
    for (int i = 0; i < 10; i++) {
        [self.cellHeightArray addObject:@(kBudgetCellNormalHeight)];
        [self.cellExpreadFlags addObject:@(0)];
    }
    
    [self loadBudgets];
    
    self.isloading = NO;
    
}



#pragma mark - lazy loads

- (NSMutableString *)cellIdCache {
    if (!_cellIdCache) {
        _cellIdCache = [NSMutableString string];
    }
    return _cellIdCache;
}

- (NSMutableArray *)cellHeightArray {
    if (!_cellHeightArray) {
        _cellHeightArray = [NSMutableArray array];
        for (int i = 0; i < self.historyBudgets.count; i++) {
            _cellHeightArray[i] = @(kBudgetCellNormalHeight);
        }
    }
    return _cellHeightArray;
}

// 加载更多后需要更新
- (NSMutableArray *)cellExpreadFlags {
    if (!_cellExpreadFlags) {
        _cellExpreadFlags = [NSMutableArray array];
        for (int i = 0; i < self.historyBudgets.count; i++) {
            _cellExpreadFlags[i] = @0;
        }
    }
    return _cellExpreadFlags;
}




#pragma mark -

- (BOOL)prefersStatusBarHidden {
    return kStatusBarHeight == 20;
}


@end
