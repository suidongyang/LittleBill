//
//  SUDailyCostCollectionViewCell.m
//  Little Bill
//
//  Created by SU on 2017/9/24.
//  Copyright © 2017年 SU. All rights reserved.
//

#import "SUDailyCostCollectionViewCell.h"
#import "SUDailyCostTableViewCell.h"
#import "SUFooterView.h"
#import "SnapShotCell.h"
#import "SUDailyCostModel.h"


@interface SUDailyCostCollectionViewCell () <UITableViewDataSource, UITableViewDelegate, SUDailyCostCellDraggingDelegate>

@property (strong, nonatomic) UITableView *dailyCostTableView;
@property (strong, nonatomic) SUDailyCostTableViewCell *placeholderCell;

@property (assign, nonatomic) BOOL isTyping;
@property (assign, nonatomic) BOOL animateFooterHeight;

@property (assign, nonatomic) CGSize contentSize_beforeRolling;
@property (assign, nonatomic) CGPoint contentOffset_beforeRolling;

@property (strong, nonatomic) NSIndexPath *editingIndexPath;
@property (strong, nonatomic) NSIndexPath *pressingIndexPath;

@property (strong, nonatomic) SnapShotCell *snapShotCell;
@property (assign, nonatomic) CGPoint startLocation;
@property (assign, nonatomic) CGFloat startSnapShotCellX;

@end

static NSString * const kDailyCostTableViewCellID = @"kDailyCostTableViewCellID";

@implementation SUDailyCostCollectionViewCell

#pragma mark - Life cycle

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) return nil;
    
    [self initUI];
    [self initAddIndicator];
    
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    self.dailyCostTableView.contentOffset = CGPointMake(0, -self.tableViewInsetTop);
    
}


#pragma mark -

- (void)scrollListToTop {
    [self.dailyCostTableView setContentOffset:CGPointMake(0, -self.tableViewInsetTop) animated:NO];
}

#pragma mark - Private

// 此方法弃用！
- (void)observeNotifications {
    
//    // 监听通知
//
//    // 注意：通知是一对多的，所有存活的cell都会收到，所以需要指定 只允许当前显示的cell接收
//
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(inputBoardCancelNeedDeleteRow:) name:kInputBoardCancelNotification object:nil];
//
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(inputBoardCompleteAddOnePayout:) name:kInputBoardCompleteNotification object:nil];
    
}

- (void)initUI {
    
    self.contentView.backgroundColor = [UIColor clearColor]; // kThemeColor;
    
    self.dailyCostTableView = [[UITableView alloc] initWithFrame:CGRectMake(10, self.y, self.width - 20, self.height) style:UITableViewStylePlain];
    self.dailyCostTableView.backgroundColor = [UIColor clearColor]; // kThemeColor;
    self.dailyCostTableView.dataSource = self;
    self.dailyCostTableView.delegate = self;
    self.dailyCostTableView.separatorInset = UIEdgeInsetsZero;
    self.dailyCostTableView.showsVerticalScrollIndicator = NO;
    self.dailyCostTableView.separatorColor = [UIColor colorWithWhite:0 alpha:0.1];

    if (@available(iOS 11.0, *)) {
        self.dailyCostTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    
    SUFooterView *footerView = [[SUFooterView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth - 20, 40)];
    self.dailyCostTableView.tableFooterView = footerView;
    
    self.dailyCostTableView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.dailyCostTableView.layer.shadowOffset = CGSizeMake(0, 3);
    self.dailyCostTableView.layer.shadowRadius = 3;
    self.dailyCostTableView.layer.shadowOpacity = 0.2;
    self.dailyCostTableView.clipsToBounds = YES;
    
    self.dailyCostTableView.decelerationRate = UIScrollViewDecelerationRateFast;
    
    [self.dailyCostTableView registerClass:[SUDailyCostTableViewCell class] forCellReuseIdentifier:kDailyCostTableViewCellID];
    
    [self.contentView addSubview:self.dailyCostTableView];
    
}

- (void)setTableViewInsetTop:(CGFloat)tableViewInsetTop {
    _tableViewInsetTop = tableViewInsetTop;
    self.dailyCostTableView.contentInset = UIEdgeInsetsMake(tableViewInsetTop, 0, 0, 0);
    
}


- (void)insertItem {
    [self.dailyExpenseArray insertObject:[SUDailyCostModel defaultPayoutModel] atIndex:0];
    [self.dailyCostTableView reloadData];
}


// 取消添加 删除最新一条
- (void)inputBoardCanceledNeedDeleteRow:(BOOL)shouldDelete {
    
    if (shouldDelete) {
        [self.dailyExpenseArray removeObjectAtIndex:0];
        self.animateFooterHeight = YES;
        [self.dailyCostTableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
        
    }else {
        
        // tableView 复位
        
        [UIView animateWithDuration:0.25 animations:^{
            self.dailyCostTableView.contentOffset = self.contentOffset_beforeRolling;
        } completion:^(BOOL finished) {
            self.dailyCostTableView.contentSize = self.contentSize_beforeRolling;
        }];
        
    }
    
    
}


// 刷新刚才修改的一行
- (void)reloadRowOfTableView {
    [self.dailyCostTableView reloadRowsAtIndexPaths:@[self.editingIndexPath] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)reloadRowOfTableViewAtIndexPath:(NSIndexPath *)indexPath {
//    [self.dailyCostTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [self.dailyCostTableView reloadData];
}

- (void)deleteRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.dailyCostTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationBottom];
}

- (void)insertRowAtIndexPath:(NSIndexPath *)indexPath {
//    [self.dailyCostTableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationBottom];
    self.animateFooterHeight = NO;
    [self.dailyCostTableView reloadData];
}


#pragma mark - 长按cell删除

- (void)dailyCostCell:(SUDailyCostTableViewCell *)cell draggingWithGesture:(UILongPressGestureRecognizer *)gesture {
    
    /// 防止多个cell同时长按时，cell截图残留拖拽跳动等问题
    /// 这里只响应最先长按的cell，记录其indexpath，如果不相符则不响应
    NSIndexPath *indexpath = [self.dailyCostTableView indexPathForCell:cell];
    if (!self.pressingIndexPath) {
        self.pressingIndexPath = indexpath;
    }
    if (![indexpath isEqual:self.pressingIndexPath]) return;
    ///
    
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
        {
            
//            NSIndexPath *pressedIndexPath = [self.dailyCostTableView indexPathForCell:cell];
//            BOOL isLastOne = pressedIndexPath.row == self.dailyExpenseArray.count - 1;
//            if (isLastOne) {
//                SUFooterView *footerView = (SUFooterView *)self.dailyCostTableView.tableFooterView;
//                [footerView setFooterHeight:6 animate:YES];
//            }
            
            self.dailyCostTableView.userInteractionEnabled = NO;
            self.startLocation = [gesture locationInView:self];
            [UIView animateWithDuration:0 animations:^{
                cell.selected = NO;
            }completion:^(BOOL finished) {
                
                NSIndexPath *indexPath = [self.dailyCostTableView indexPathForCell:cell];
                SUDailyCostModel *item = self.dailyExpenseArray[indexPath.row];
                
                UIView *snapShot = [cell snapshotViewAfterScreenUpdates:YES];
                snapShot.frame = [self.dailyCostTableView convertRect:cell.frame toView:self];
                self.snapShotCell = [[SnapShotCell alloc] initWithSnapShot:snapShot inBudget:item.inBudget isExpense:item.category < 31];
//                self.snapShotCell.bottomLine.hidden = !isLastOne;
                self.startSnapShotCellX = self.snapShotCell.x;
                [self addSubview:self.snapShotCell];
                cell.hidden = YES;
            }];
            
            break;
        }
            
        case UIGestureRecognizerStateChanged:
        {
            CGPoint location = [gesture locationInView:self];
            // 计算偏移量，将截图的坐标与location关联
            self.snapShotCell.x = self.startSnapShotCellX + (location.x - self.startLocation.x) * 0.5;
            
            break;
        }
            
        default:
        {
            
            
            CGFloat diff = self.startSnapShotCellX - self.snapShotCell.x;
            
            NSIndexPath *indexPath = [self.dailyCostTableView indexPathForCell:cell];
            SUDailyCostModel *item = self.dailyExpenseArray[indexPath.row];
            
//            if (indexPath.row == self.dailyExpenseArray.count - 1) {
//                SUFooterView *footerView = (SUFooterView *)self.dailyCostTableView.tableFooterView;
//                [footerView setFooterHeight:0 animate:YES];
//            }
            
            // 左滑删除
            if (diff > 60) {
                
                [UIView animateWithDuration:0.2 animations:^{
                    self.snapShotCell.maxX = -61;
                }completion:^(BOOL finished) {
                    [self.snapShotCell removeFromSuperview];
                    self.snapShotCell = nil;
                    self.animateFooterHeight = YES;
//                    [self.dailyExpenseArray removeObjectAtIndex:indexPath.row];
//                    [self.dailyCostTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
                    
                    self.dailyCostTableView.userInteractionEnabled = YES;
                    
                    if ([self.delegate respondsToSelector:@selector(dailyCostTableView:deleteItemAtIndexPath:)]) {
                        [self.delegate dailyCostTableView:self.dailyCostTableView deleteItemAtIndexPath:indexPath];
                    }
                    
                }];
                
            }else {
                
                // 问题： 右划松手后，frame的变化监听不到，左滑没问题
                [UIView animateWithDuration:0.4 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:1.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                    
                    self.snapShotCell.x = self.startSnapShotCellX;
                    
                } completion:^(BOOL finished) {
                    
                    cell.hidden = NO;
                    [self.snapShotCell removeFromSuperview];
                    self.snapShotCell = nil;
                    self.dailyCostTableView.userInteractionEnabled = YES;
                    
                    if (diff < -60) {
                        
                        if ([self.delegate respondsToSelector:@selector(dailyCostTableView:swipeRightWithItem:)]) {
                            [self.delegate dailyCostTableView:self.dailyCostTableView swipeRightWithItem:item];
                        }
                        
                    }
                    
                }];
             
            }
            
            self.pressingIndexPath = nil;
            
            break;
        }
    }
    
    
   
    
}


#pragma mark - UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == self.dailyExpenseArray.count - 1) {
        return kCellHeight - 2;
    }else {
        return kCellHeight;
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    SUFooterView *footerView = (SUFooterView *)self.dailyCostTableView.tableFooterView;
    if (self.dailyExpenseArray.count == 0) {
        [footerView setFooterHeight:34 animate:self.animateFooterHeight];
        self.animateFooterHeight = NO;

    }else {
        [footerView setFooterHeight:0 animate:NO];
    }
    return self.dailyExpenseArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    SUDailyCostTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kDailyCostTableViewCellID];
    
    cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageWithHexString:@"#eeeeee"]];
    
    cell.payoutModel = self.dailyExpenseArray[indexPath.row];
    cell.delegate = self;
    cell.hidden = NO;

    return cell;
}

#pragma mark - UITableViewDelegate


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
    if ([self.delegate respondsToSelector:@selector(dailyCostTableView:didSelectCellAtIndexPath:)]) {
        [self.delegate dailyCostTableView:tableView didSelectCellAtIndexPath:indexPath];
    }
    
    // 点击cell时 tableView同步向上滚动
    
    self.editingIndexPath = indexPath;
    self.contentSize_beforeRolling = tableView.contentSize;
    self.contentOffset_beforeRolling = tableView.contentOffset;

    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];

    tableView.contentSize = CGSizeMake(tableView.contentSize.width, tableView.height + cell.y);

    [UIView animateWithDuration:0.25 animations:^{

        tableView.contentOffset = CGPointMake(0, cell.y - self.tableViewInsetTop);
    }];
    
}

#pragma mark - UIScrollViewDelegate



- (void)initAddIndicator {
    
    self.placeholderCell = [[SUDailyCostTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"placehodlerCell"];
    self.placeholderCell.frame = CGRectMake(0, 0, kScreenWidth - 20, kCellHeight);
    self.placeholderCell.layer.anchorPoint = CGPointMake(0.5, 1);
    self.placeholderCell.layer.position = CGPointMake(0.5 * (kScreenWidth - 20), 0);

    
    self.placeholderCell.payoutModel = [SUDailyCostModel defaultPayoutModel];
    self.placeholderCell.costString = @"0.0";
    
    UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, kCellHeight - 1, kScreenWidth - 20, 1)];
    bottomLine.backgroundColor = [UIColor colorWithHexString:@"ebebeb"];
    [self.placeholderCell.contentView addSubview:bottomLine];
    
    self.placeholderCell.backgroundColor = [UIColor whiteColor];
    self.placeholderCell.contentView.backgroundColor = [UIColor whiteColor];
    
    [self.dailyCostTableView insertSubview:self.placeholderCell atIndex:self.dailyCostTableView.subviews.count];
    
}

// 滑动中

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    
    CGFloat offsetY = scrollView.contentOffset.y + self.tableViewInsetTop;

    
    if (offsetY <= - kCellHeight) {
        self.placeholderCell.layer.transform = CATransform3DIdentity;
        self.placeholderCell.contentView.alpha = 1;
        self.placeholderCell.contentView.backgroundColor = [UIColor whiteColor];
    }
    
    else if (offsetY <= 0 && offsetY > - kCellHeight) {
        
        CATransform3D transform3d = CATransform3DIdentity;
        transform3d.m34 = -1.0 / 400;
        self.placeholderCell.layer.transform = transform3d;
//        self.placeholderCell.layer.sublayerTransform = transform3d;
        
        transform3d = CATransform3DRotate(transform3d, (1 + offsetY / kCellHeight) * M_PI_2, 1, 0, 0);

//        CGFloat calcOffset = 0.23 * (sinf(-offsetY / 28 * M_PI_2)) * (-offsetY / kCellHeight);
//        transform3d = CATransform3DRotate(transform3d, (1 + offsetY / kCellHeight + calcOffset) * M_PI_2, 1, 0, 0);
//        transform3d = CATransform3DRotate(transform3d, (1 + offsetY / kCellHeight + 0.2 * (sinf((-offsetY / 76 + 1) * M_PI_2)) * (-offsetY / kCellHeight)) * M_PI_2, 1, 0, 0);
        
        self.placeholderCell.layer.transform = transform3d;
//        self.placeholderCell.layer.sublayerTransform = transform3d;
        self.placeholderCell.contentView.backgroundColor = [[UIColor whiteColor] colorWithBrightness:0.5 + 0.5 * (-offsetY / kCellHeight)];
        self.placeholderCell.contentView.alpha = 0.8 + 0.2 * ( -offsetY / kCellHeight);
        
        
    }

    if ([self.delegate respondsToSelector:@selector(handleScrollViewDidScroll:)]) {
        [self.delegate handleScrollViewDidScroll:scrollView];
    }
}

// 开始减速前 立即停止滚动

-(void)scrollViewWillBeginDecelerating: (UIScrollView *)scrollView {
    
    CGFloat offsetY = scrollView.contentOffset.y + self.tableViewInsetTop;
    
    if (offsetY <= - kViewMargin_dailyCost) {
        
        if ([self.delegate respondsToSelector:@selector(handleScrollViewWillBeginDecelerating:)]) {
            [self.delegate handleScrollViewWillBeginDecelerating:scrollView];
        }
    }
    
    else if (offsetY < -kCellHeight) {
        
        
        self.dailyCostTableView.userInteractionEnabled = NO;
        [scrollView setContentOffset:scrollView.contentOffset animated:NO];
        
        // 弹出输入面板
        if (self.insertItemAction) {
            self.insertItemAction(-offsetY - kCellHeight);
        }
        
        [UIView animateWithDuration:0.25 animations:^{
            self.dailyCostTableView.contentInset = UIEdgeInsetsMake(kCellHeight + self.tableViewInsetTop, 0, 0, 0);
        }completion:^(BOOL finished) {
            self.dailyCostTableView.userInteractionEnabled = YES;
            
            
            [self insertItem];
            self.dailyCostTableView.contentInset = UIEdgeInsetsMake(self.tableViewInsetTop, 0, 0, 0);
            
        }];
    }
    
    else if (offsetY > 0) {
        
        if ([self.delegate respondsToSelector:@selector(handleScrollViewWillBeginDecelerating:)]) {
            [self.delegate handleScrollViewWillBeginDecelerating:scrollView];
        }
    }
}


#pragma mark - setter

- (void)setDailyExpenseArray:(NSMutableArray *)dailyExpenseArray {
    _dailyExpenseArray = dailyExpenseArray;
    // 会阻塞主线程，导致横向滑动时卡顿
    [self.dailyCostTableView reloadData];

}


@end
