//
//  SUDailyCostController.m
//  Little Bill
//
//  Created by SU on 2017/9/21.
//  Copyright © 2017年 SU. All rights reserved.
//

#import "SUDailyCostController.h"
#import "SUBudgetController.h"
#import "UIViewController+Switch.h"
#import "SUDataBase.h"

#import "SUDailyCostCollectionViewCell.h"
#import "SUBudgetView.h"
#import "SUDateCostView.h"
#import "SUInputBoard.h"

#import "SUDailyCostModel.h"
#import "SUBudgetItem.h"
#import "SUSumBudgetItem.h"

#import "UIImageEffects.h"

#import "SUSettingController.h"


@interface SUDailyCostController () <UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate, HandleScrollActionProtocol, SUDailyCostCollectionViewCellDelegate, SUInputBoardDelegate, SUBudgetViewDelegate>

@property (strong, nonatomic) SUBudgetView *budgetView;
@property (strong, nonatomic) SUDateCostView *dateCostView;
@property (strong, nonatomic) UICollectionView *dailyCostCollectionView;
@property (strong, nonatomic) SUInputBoard *mineInputBoard; // 避免与系统控件重名

@property (assign, nonatomic) CGSize originContentSize;
@property (assign, nonatomic) CGPoint originContentOffset;

@property (strong, nonatomic) NSIndexPath *editingIndexPath;

@property (assign, nonatomic) int currentIndex; // collectionview当前滚动到的index

@property (strong, nonatomic) NSMutableDictionary<NSString *, NSMutableArray *> *dataDict; // @{ 日期:列表, ... }
@property (strong, nonatomic) NSMutableDictionary<NSString *, NSNumber *> *sumExpenseDict; // 日期：支出总额

@property (strong, nonatomic) NSMutableArray<SUBudgetItem *> *currentBudgets;

@property (assign, nonatomic) BOOL needReloadData;
@property (assign, nonatomic) BOOL hadResetSubviewFrame;

@property (strong, nonatomic) UIImageView *glassView;


@end

/**已解决
 
 !! 不计入预算的记录，除非重新计入预算，其他任何修改，预算不变
 不计入以后：
 1.删除，预算不变
 2.支出-->收入，预算不变，设置 inBudget = YES
 3.支出-->支出，预算只减少新记录的值，设置 inBudget = YES
 
 BUG记录 新增的一条立即修改，修改失败
 原因是sqlite的自增长主键不一定是连续的，因为删除一条记录以后，主键的最大值是基于历史最大值递增的，
 新增记录的时候，模型的id是手动获取id最大值再+1，入库的时候并没有将此id入库，数据库里这条记录的id是数据库按规则生成的主键值，
 所以模型的id与数据库里的id可能不一致，查询不到导致修改失败
 解决方法：id不再作为自增主键，作为常规字段进行保存。
 
 */

/**TODO
 
 后续添加子预算，在统计已支出金额时，只统计 inBudget == 1 的记录
 数据库相关方法增加返回值，失败时回滚数据源和UI
 
 */


@implementation SUDailyCostController

static NSString * const kDailyCostCellID = @"kDailyCostCellID";
int const itemCount = 1000;


#pragma mark - Life cycle

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadData];
    [self initUI];
    [self backupSubviewFrames];
    [self setSwitchIndicatorHidden:NO];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateBudgetDisplay) name:@"budgetM" object:nil];
    
    [self insertNewBudgetIfNeeded];
    
}

/*
 iOS7以后，程序进入后台仍可运行3分钟，之后挂起，当其他应用占用内存导致内存不足时 才会被杀死，
 挂起有可能持续到第二天，这时唤醒程序，会导致挂起前的页面直接显示，应该只调用了 viewWillAppear 方法，
 方法里只更新了 date-cost 视图，而 collectionview 没有刷新，导致点击时崩溃
 
 解决办法 ：进入后台后3分钟到期，立即退出
 */

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([LifeCycleManager manager].settingIsBusy) return;
    
    [self.view.superview bringSubviewToFront:self.topController.view];
    [self.view.superview bringSubviewToFront:self.bottomController.view];

    // 在viewdidload中执行，会被添加到window最下层
    if (self.mineInputBoard == nil) {
        self.mineInputBoard = [SUInputBoard loadInputBoard];
        self.mineInputBoard.delegate = self;
    }
    
    NSIndexPath *lastIndexPath = [NSIndexPath indexPathForItem:itemCount - 2 inSection:0];
    [self.dailyCostCollectionView scrollToItemAtIndexPath:lastIndexPath atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    
    self.dateCostView.dateString = [SUDateTool stringForDate:[NSDate date]];
    self.dateCostView.sumExpense = [self.sumExpenseDict objectForKey:self.dateCostView.dateString].floatValue;
    
    if (self.glassView) {
        [UIView animateWithDuration:0.2 animations:^{
            self.glassView.alpha = 0;
        }completion:^(BOOL finished) {
            self.glassView.hidden = YES;
        }];
    }
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if ([LifeCycleManager manager].settingIsBusy) return;
        
    SUSettingController *settingVC = (SUSettingController *)self.bottomController;
    settingVC.currentBudgets = self.currentBudgets;
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if ([LifeCycleManager manager].settingIsBusy) return;
    
    if (self.glassView == nil) {
        self.glassView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        self.glassView.alpha = 0;
        [self.view addSubview:self.glassView];
    }
    
    self.glassView.hidden = NO;
    
    UIGraphicsBeginImageContext([self.view.layer frame].size);
    
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage *inImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    UIImage *outImage = [UIImageEffects imageByApplyingBlurToImage:inImage withRadius:20.0 tintColor:[UIColor colorWithWhite:1 alpha:0.1] saturationDeltaFactor:1.0 maskImage:nil];
    
    UIGraphicsBeginImageContext(outImage.size);
    
    CGContextTranslateCTM(UIGraphicsGetCurrentContext(), 0, outImage.size.height);
    CGContextScaleCTM(UIGraphicsGetCurrentContext(), 1.0, -1.0);
    
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, outImage.size.width, outImage.size.height), outImage.CGImage);
    
    CGContextTranslateCTM(UIGraphicsGetCurrentContext(), 0, outImage.size.height);
    CGContextScaleCTM(UIGraphicsGetCurrentContext(), 1.0, -1.0);
    
    CGRect circlePoint = (CGRectZero);
    CGContextSetFillColorWithColor( UIGraphicsGetCurrentContext(), [UIColor clearColor].CGColor );
    CGContextSetBlendMode(UIGraphicsGetCurrentContext(), kCGBlendModeClear);
    CGContextFillRect(UIGraphicsGetCurrentContext(), circlePoint);
    
    UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    self.glassView.image = finalImage;
    
    [UIView animateWithDuration:0.2 animations:^{
        self.glassView.alpha = 1;
    }];
    
    
}


#pragma mark - Private

// 启动后判断是否需要自动插入新预算
//#warning 输入时判断是否插入预算

- (void)insertNewBudgetIfNeeded {
    
    if (self.currentBudgets == nil || self.currentBudgets.count == 0) {
        return;
    }
    
    NSDate *nowDate = [NSDate date];
    
    SUBudgetItem *currentItem = self.currentBudgets.firstObject;
    
    NSDateFormatter *formatter = [SUDateTool dateFormatterYMD];
    formatter.dateFormat = @"yyyy-MM-dd";
    NSString *detailDate = [formatter stringFromDate:nowDate];
    
    BOOL need = NO;
    NSString *date;
    
    if (currentItem.cycleType == 0) {
        date = [[SUDateTool dateTool] weekOfYearForDate:nowDate];
        need = ![date isEqualToString:currentItem.date];
    }else {
        
        formatter.dateFormat = @"yyyy-MM";
        date = [formatter stringFromDate:nowDate];
        need = ![date isEqualToString:currentItem.date];
    }
    
    if (need) {
        
        // 继承上一次的预算设置，创建新预算，同时更新当前预算数据源，更新预算视图
        
        for (SUBudgetItem *item in self.currentBudgets) {
            
            item.cycleId += 1;
            item.sumExpense = [[SUDataBase sharedInstance] querySumExpenseForCategory:item.category date:date cycleType:currentItem.cycleType];
            item.date = date;
            item.dateString = detailDate;
            item.exceed = item.sumExpense > item.total;
            
            [[SUDataBase sharedInstance] insertBudget:item];
            
        }
        
        self.budgetView.totalBudgetItem = currentItem;
        
    }
    
    
    
}

- (void)updateBudgetDisplay {
    SUBudgetItem *item = self.currentBudgets.firstObject;
    self.budgetView.totalBudgetItem = item;
}

- (void)loadData {
    
    self.dataDict = [NSMutableDictionary<NSString *, NSMutableArray *> dictionary];
    self.sumExpenseDict = [NSMutableDictionary<NSString *, NSNumber *> dictionary];
    
    NSArray *budgetArray = [[SUDataBase sharedInstance] queryCurrentBudget];
    self.currentBudgets = [NSMutableArray arrayWithArray:budgetArray];
    
    // 程序启动时 加载最近14天的数据
    for (int i = 0; i < 15; i++) {
        
        NSTimeInterval interval = - (i - 1) * 24 * 60 * 60;
        NSDate *date = [NSDate dateWithTimeIntervalSinceNow:interval];
        NSString *dateStr = [SUDateTool stringForDate:date];
        
        NSArray *dailyArray = [[SUDataBase sharedInstance] queryDailyExpensesList:dateStr];
        NSMutableArray *dailyArray_m = [NSMutableArray arrayWithArray:dailyArray];
        [self.dataDict setObject:dailyArray_m forKey:dateStr];
        
        NSNumber *sumExpense = @([[SUDataBase sharedInstance] queryDailySumExpense:dateStr]);
        [self.sumExpenseDict setObject:sumExpense forKey:dateStr];
    }
    
}


- (void)initUI {
    
    self.view.backgroundColor = kThemeColor;
    
    // 预算
    self.budgetView = [SUBudgetView loadBudgetView];
    self.budgetView.y = 0; //kStatusBarHeight + 10;
    self.budgetView.delegate = self;
    
    SUBudgetItem *item = self.currentBudgets.firstObject;
    self.budgetView.totalBudgetItem = item;
    
    // 日期-支出
    self.dateCostView = [SUDateCostView loadDateCostView];
    self.dateCostView.y = self.budgetView.maxY;
    self.dateCostView.dateString = [SUDateTool stringForDate:[NSDate date]];
    __weak typeof(self) weakSelf = self;
    self.dateCostView.backTodayAction = ^{
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:itemCount - 2 inSection:0];
        [weakSelf.dailyCostCollectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
    };
    
    [self setTableViewInsetTop:self.dateCostView.maxY];
    
    // 支出列表
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(kScreenWidth, kScreenHeight/* - self.dateCostView.maxY*/);
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    self.dailyCostCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0 /*self.dateCostView.maxY*/, layout.itemSize.width, layout.itemSize.height) collectionViewLayout:layout];
    
    // 重用会导致在横向滑动时，tableview RaloadData 卡顿
    [self.dailyCostCollectionView registerClass:[SUDailyCostCollectionViewCell class] forCellWithReuseIdentifier:kDailyCostCellID];
    
    self.dailyCostCollectionView.prefetchingEnabled = YES;
    
    self.dailyCostCollectionView.dataSource = self;
    self.dailyCostCollectionView.delegate = self;
    self.dailyCostCollectionView.pagingEnabled = YES;
    self.dailyCostCollectionView.showsHorizontalScrollIndicator = NO;
    self.dailyCostCollectionView.allowsSelection = NO;
    self.dailyCostCollectionView.backgroundColor = [UIColor clearColor]; //  kThemeColor;
    
    if (@available(iOS 11.0, *)) {
        self.dailyCostCollectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    
    [self.view addSubview:self.dailyCostCollectionView];
    [self.view addSubview:self.budgetView];
    [self.view addSubview:self.dateCostView];
    [self addSwitchIndicatorsWithTitles:@[@"统计", @"设置"]];
    
}


#pragma mark - UICollectionView 代理

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(SUDailyCostCollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {

    NSTimeInterval interval = (indexPath.item - itemCount + 2) * 24.0 * 60 * 60;
    NSDate *date = [NSDate dateWithTimeIntervalSinceNow: interval];
    NSString *dateString = [SUDateTool stringForDate:date];
    NSMutableArray *array = [self.dataDict objectForKey:dateString];
    
#warning why reused cell has an empty datasource array rather than nil ?
    if (cell.dailyExpenseArray == nil || cell.dailyExpenseArray.count == 0 || ![array isEqualToArray:cell.dailyExpenseArray]) {
        cell.dailyExpenseArray = array;
    }
    
    if (indexPath.item == itemCount - self.dataDict.allKeys.count + 2 && self.needReloadData == NO) {
        
        NSInteger recordCount = self.dataDict.allKeys.count;
        
        for (int i = 0; i < 14; i++) {
            
            NSTimeInterval interval = - (i + recordCount-1) * 24 * 60 * 60;
            NSDate *date = [NSDate dateWithTimeIntervalSinceNow:interval];
            NSString *dateStr = [SUDateTool stringForDate:date];
            
            NSArray *dailyArray = [[SUDataBase sharedInstance] queryDailyExpensesList:dateStr];
            NSMutableArray *dailyArray_m = [NSMutableArray arrayWithArray:dailyArray];
            [self.dataDict setObject:dailyArray_m forKey:dateStr];
            
            NSNumber *sumExpense = @([[SUDataBase sharedInstance] queryDailySumExpense:dateStr]);
            [self.sumExpenseDict setObject:sumExpense forKey:dateStr];
        }
        
        self.needReloadData = YES;
    }
    

}

#pragma mark - UICollectionView 数据源

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return itemCount;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    // 如何设置 使连续的7条不重用， 并预先加载7条
    
    /*
     在设置了不重用以后，滑动时，虽然能看到前一个将要显示的cell已经有数据了，但还是会卡，
     是因为collectionview在刷新邻近的其他未进入视野的cell
     */
    
//    NSString *dontReuseId = [NSString stringWithFormat:@"%@-%d", kDailyCostCellID, (int)indexPath.item];
//    [self.dailyCostCollectionView registerClass:[SUDailyCostCollectionViewCell class] forCellWithReuseIdentifier:dontReuseId];
    
    SUDailyCostCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier: kDailyCostCellID forIndexPath:indexPath];
    
    cell.delegate = self;
    
    __weak typeof(self) weakSelf = self;
    cell.insertItemAction = ^(CGFloat newCellY){
        __strong typeof(self) strongSelf = weakSelf;
        
        strongSelf.mineInputBoard.fakeCellModel = nil;
        // 弹出输入面板
        [strongSelf.mineInputBoard.superview bringSubviewToFront:strongSelf.mineInputBoard];
        [strongSelf.mineInputBoard showWithFakeCellOriginY:self.dailyCostCollectionView.y + self.tableViewInsetTop + newCellY animateDistance:newCellY];
    };
    
//    NSTimeInterval interval = (indexPath.item - itemCount + 2) * 24.0 * 60 * 60;
//    NSDate *date = [NSDate dateWithTimeIntervalSinceNow: interval];
//    NSMutableArray *array = [self.dataDict objectForKey:[SUDateTool stringForDate:date]];
//    if (![array isEqualToArray:cell.dailyExpenseArray]) {
//        cell.dailyExpenseArray = array;
//    }
    
    [cell setTableViewInsetTop:self.tableViewInsetTop];
    
    return cell;
    
}


#pragma mark -

#pragma mark - 点击预算视图

- (void)budgetViewDidTappedAtLeft:(BOOL)tappedLeft {
        
    for (int i = 1; i < self.currentBudgets.count; i++) {
        self.currentBudgets[0].exceed += self.currentBudgets[i].exceed;
    }
    
    SUBudgetController *budget = [[SUBudgetController alloc] init];
    budget.currentBudgets = self.currentBudgets;
    // 判断点击了哪侧
    budget.leftSideClose = tappedLeft;
    
    UINavigationController *budget_nav = [[UINavigationController alloc] initWithRootViewController:budget];
    budget_nav.navigationBarHidden = YES;
    
    [self presentViewController:budget_nav animated:YES completion:nil];
    
}

#pragma mark - 增删改后更新预算

// 修改某条记录后更新预算
- (void)updateBudgetWithItemBeforeModified:(SUDailyCostModel *)oldItem itemAfterModified:(SUDailyCostModel *)newItem {
    
    /** 已解决
     修改类别 该类别子预算增加，修改后的类别的子预算减少
     修改金额  20 --> 10 ;   10 --> 20
     收入-->支出 ； 支出-->收入 ？？
     注意不能让修改影响数据源
     
     */
    // 调试 查看数据库里修改后的记录是否 inBudget == 1
    SUDailyCostModel *newItemClone = [newItem copy]; // NSCopying
    
    
    // 都是支出
    if (oldItem.category < 31 && newItemClone.category < 31) {
        
        if (oldItem.category == newItemClone.category) {
            
            if (oldItem.inBudget) {
                newItemClone.cost -= oldItem.cost;
            }
            [self updateBudget:newItemClone addExpense:YES];
            
        }else {
            
#warning 优化，每次修改会导致 没有改动的子预算也重新保存一遍
            if (oldItem.inBudget) {
                [self updateBudget:oldItem addExpense:NO refreshDisplay:NO];
            }
            [self updateBudget:newItem addExpense:YES refreshDisplay:YES];
            
        }
        
    // 支出-->收入 原类别预算增加
    }else if (oldItem.category < 31 && newItemClone.category >= 31) {
        
        if (oldItem.inBudget) {
            
            newItemClone.cost = -1 * oldItem.cost;
            newItemClone.category = oldItem.category;
            [self updateBudget:newItemClone addExpense:YES refreshDisplay:YES];
        }
        
        
    // 收入-->支出 新类别预算减少
    }else if (oldItem.category >= 31 && newItemClone.category < 31) {
        
        [self updateBudget:newItemClone addExpense:YES refreshDisplay:YES];
        
        
    }else {
        // do nothing
    }
    
    
    
    
}


// 更新预算剩余（增、减(又包括不计入)），更新当期预算、历史预算

- (void)updateBudget:(SUDailyCostModel *)model addExpense:(BOOL)addExpense {
    [self updateBudget:model addExpense:addExpense refreshDisplay:YES];
}

- (void)updateBudget:(SUDailyCostModel *)model addExpense:(BOOL)addExpense refreshDisplay:(BOOL)refresh {
    
    if (model.category >= 31) return;
    
    SUBudgetItem *totalBudgetItem = self.currentBudgets.firstObject;
    
    /*
     判断是否是当前周期,
     如果不是，取对应的历史预算，更新其总预算和子预算
     如果是，更新预算数组，更新预算剩余
     入库
     
     !! 待修改：修改过去某一天的收支记录时，拿到那一天的日期，判断其所属的周期及预算周期类型（周/月），再更新对应周期的相关预算fuck
     
     */
    
    if (totalBudgetItem.cycleType == 0) { // 周预算
        
        // 是当前周
        if ([model.weekOfYear isEqualToString:totalBudgetItem.date]) {
            // 更新数组
            [self updateBudgets:self.currentBudgets withCostItem:model add:addExpense];
            // 更新预算剩余
            #warning 超支时怎么展示
            if (refresh) {
                self.budgetView.totalBudgetItem = totalBudgetItem;
            }
        // 不是当前周
        }else {
            NSArray *historyBudgets = [[SUDataBase sharedInstance] queryHistoryBudgetWithDate:model.weekOfYear cycleType:0];
            [self updateBudgets:historyBudgets withCostItem:model add:addExpense];
        }
        
        
    }else { // 月预算
        
        // 当前月
        if ([model.dateString containsString:totalBudgetItem.date]) {
            
            [self updateBudgets:self.currentBudgets withCostItem:model add:addExpense];
            if (refresh) {
                self.budgetView.totalBudgetItem = totalBudgetItem;
            }
            
        }else {
            
            NSDateFormatter *formatter = [SUDateTool dateFormatterYMD];
            formatter.dateFormat = @"yyyy-MM-dd";
            NSDate *date = [formatter dateFromString:model.dateString];
            formatter.dateFormat = @"yyyy-MM";
            NSString *dateStr = [formatter stringFromDate:date];
            
            NSArray *historyBudgets = [[SUDataBase sharedInstance] queryHistoryBudgetWithDate:dateStr cycleType:1];
            [self updateBudgets:historyBudgets withCostItem:model add:addExpense];
            
        }
        
        
        
    }
    
    
    
    
}

- (void)updateBudgets:(NSArray *)budgets withCostItem:(SUDailyCostModel *)model add:(BOOL)addOrDelete {
    
    // 用于标记 添加一条开销 和 删除开销或不计入预算
    int flag = addOrDelete ? 1 : -1;
    
    SUBudgetItem *totalBudgetItem = (SUBudgetItem *)budgets.firstObject;
    
    totalBudgetItem.sumExpense += flag * model.cost;
    for (SUBudgetItem *item in budgets) {
        if (item.category == model.category && item.category != 0) {
            item.sumExpense += flag * model.cost;
        }
    }
    
    // 入库
    
    for (SUBudgetItem *item in budgets) {
        [[SUDataBase sharedInstance] updateBudget:item type:BudgetValueTypeExpense];
    }
    
    
}


#pragma mark - 滑动时刷新列表


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if ([scrollView isEqual:self.dailyCostCollectionView]) {
        
        CGFloat offsetX = scrollView.contentOffset.x;
        
        int itemIndex = (int)(offsetX / kScreenWidth + 0.5);
        
        if (itemIndex != self.currentIndex) {
            
            NSTimeInterval interval = (itemIndex - itemCount + 2) * 24 * 60 * 60;
            
            NSDate *date = [NSDate dateWithTimeIntervalSinceNow:interval];
            
            self.dateCostView.dateString = [SUDateTool stringForDate:date];
            
            self.dateCostView.sumExpense = [self.sumExpenseDict objectForKey:self.dateCostView.dateString].floatValue;
            
            self.currentIndex = itemIndex;
        }
        
        if (itemIndex == itemCount - self.dataDict.allKeys.count + 16 && self.needReloadData) {
            self.needReloadData = NO;
            [self.dailyCostCollectionView reloadData];
        }
        
    }
    
}


#pragma mark - 输入主面板 代理

// 取消
- (void)inputBoardCanceledAndShouldRoll:(BOOL)shouldRoll {
    
    SUDailyCostCollectionViewCell *cell = (SUDailyCostCollectionViewCell *)[self.dailyCostCollectionView visibleCells].firstObject;
    [cell inputBoardCanceledNeedDeleteRow:!shouldRoll];
    
}

// 添加一条 根据 日期-支出 上的日期
/*
 待优化
 payoutModel：添加时这个模型由fakeCell创建，编辑时模型里的属性由fakeCell传递
 */
- (void)inputBoardAddCompletion:(SUDailyCostModel *)payoutModel {
    
    NSString *dateString = self.dateCostView.dateString;
    
    NSIndexPath *indexPath = [self.dailyCostCollectionView indexPathsForVisibleItems].firstObject;
    
    NSMutableArray *someDayCostList = [self.dataDict objectForKey:dateString];
    
    if (someDayCostList == nil) {
        someDayCostList = [NSMutableArray array];
        [self.dataDict setObject:someDayCostList forKey:dateString];
    }
    
    payoutModel.recordId = [[SUDataBase sharedInstance] maxId] + 1;
    payoutModel.dateString = dateString;
    payoutModel.inBudget = YES;
    
    // 以周一为每周第一天，计算某年第几周，"2017-25"
    NSDateFormatter *formatter = [SUDateTool dateFormatterYMD];
    formatter.dateFormat = @"yyyy-MM-dd";
    NSDate *listDate = [formatter dateFromString:dateString];
    payoutModel.weekOfYear = [[SUDateTool dateTool] weekOfYearForDate:listDate];
    
    /**
     #warning 跳到一个很早的日期，空列表添加一条收入，点击完成后，新添加的cell显示为 “ 一般 0.0 ” ，左右滑动刷新后显示正常，不刷新继续添加则继续异常都是0.0，确认数据已入库
     
     出错原因：重用的cell的数组在设置数据前被不明原因地初始化过了，在willDisplayCell里判断时，当cell的数据源数组存在时不会重新赋值，导致重用cell的数组与从dataDict里取出的数组不是同一个指针指向的，所以。
     解决方法：在willdisplaycell里加了 .count == 0 时 也要重新赋值数组
     
     */
    
    if (someDayCostList.count > 0) {
        [someDayCostList replaceObjectAtIndex:0 withObject:payoutModel];
    }else {
        [someDayCostList addObject:payoutModel];
    }
    
    // 注释原因：某个列表滚动上去以后，切换其他列表添加一条，列表头部视图上移
    // [self.dailyCostCollectionView reloadItemsAtIndexPaths:@[indexPath]];
    //// 临时解决：
    SUDailyCostCollectionViewCell *cell = (SUDailyCostCollectionViewCell *)[self.dailyCostCollectionView cellForItemAtIndexPath:indexPath];
    [cell reloadRowOfTableViewAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    ////
    
    [[SUDataBase sharedInstance] insert:payoutModel];
    
    [self updateSumExpense];
    [self updateBudget:payoutModel addExpense:YES];
    [self updateStatisticDataSource];

//     if ([someDayCostList containsObject:payoutModel]) {
//        [someDayCostList removeObject:payoutModel];
//        [cell deleteRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
//     }
    
}

// 修改一条 根据 日期-支出 上的日期
- (void)inputBoardEditCompletion:(SUDailyCostModel *)payoutModel {
    
    payoutModel.inBudget = YES;
    payoutModel.dateString = self.dateCostView.dateString;
    
    NSIndexPath *indexPath = [self.dailyCostCollectionView indexPathsForVisibleItems].firstObject;
    
    SUDailyCostCollectionViewCell *cell = (SUDailyCostCollectionViewCell *)[self.dailyCostCollectionView cellForItemAtIndexPath:indexPath];
    
    NSMutableArray *someDayCostList = [self.dataDict objectForKey:self.dateCostView.dateString];
    
    // someDayCostList  字典里的和cell里的是同一个对象，所以不需要给cell重新设置数组
    
    // 用于调整预算
    SUDailyCostModel *notModifiedItem = someDayCostList[self.editingIndexPath.row];
    
    [someDayCostList replaceObjectAtIndex:self.editingIndexPath.row withObject:payoutModel];
    
    [cell reloadRowOfTableView];
    
    
    [[SUDataBase sharedInstance] update:payoutModel];
    
    [self updateSumExpense];
    [self updateStatisticDataSource];
    [self updateBudgetWithItemBeforeModified:notModifiedItem itemAfterModified:payoutModel];

    
    // [someDayCostList replaceObjectAtIndex:self.editingIndexPath.row withObject:notModifiedItem];
    // [cell reloadRowOfTableView];
    

    self.editingIndexPath = nil;
    
}

#pragma mark -

// 更新支出总额
- (void)updateSumExpense {
    
    NSString *dateString = self.dateCostView.dateString;
    self.dateCostView.sumExpense = [[SUDataBase sharedInstance] queryDailySumExpense:dateString];
    
    [self.sumExpenseDict removeObjectForKey:dateString];
    [self.sumExpenseDict setObject:@(self.dateCostView.sumExpense) forKey:dateString];
    
}

/**
 添加或修改后，拿到此次修改的周次、月、年，通知CycleCost，如果cycleCost数据源里有查询结果，则重新查询更新数据源，没有则不查
 */
- (void)updateStatisticDataSource {
    
    NSDateFormatter *formatter = [SUDateTool dateFormatterYMD];
    formatter.dateFormat = @"yyyy-MM-dd";
    NSDate *date = [formatter dateFromString:self.dateCostView.dateString];
    [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateStstisticDataSourceNotification object:date];
    
}


#pragma mark - 上下切换页面 代理


- (void)handleScrollViewDidScroll:(UIScrollView *)scrollView {
    
    // 临时解决：某个超出屏幕的日期支出列表在滚动以后，横滑切换collectionviewCell后headerView位置向上偏移的问题。
    if (self.dailyCostCollectionView.isDragging || self.dailyCostCollectionView.isDecelerating) {
        return;
    }
    
    [self scrollWithScrollView:scrollView];

    CGFloat offsetY = scrollView.contentOffset.y + self.tableViewInsetTop;
    
    if (!self.hadResetSubviewFrame && offsetY < 0 && offsetY > -kCellHeight) {
        [self resetSubviewFrames];
        self.hadResetSubviewFrame = YES;
    }else if (offsetY >= 0 || offsetY <= -kCellHeight) {
        self.hadResetSubviewFrame = NO;
    }
    
}

- (void)handleScrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    [self switchWithScrollView:scrollView];
}


#pragma mark - CollectionViewCell 代理

// 点击cell 编辑
- (void)dailyCostTableView:(UITableView *)tableView didSelectCellAtIndexPath:(NSIndexPath *)indexPath {
    
    self.editingIndexPath = indexPath;
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    CGRect cellRect = [tableView convertRect:cell.frame toView:self.dailyCostCollectionView];
    
    self.mineInputBoard.fakeCellModel = [self.dataDict objectForKey:self.dateCostView.dateString][indexPath.row];
    
    // 显示输入面板
    [self.mineInputBoard.superview bringSubviewToFront:self.mineInputBoard];
    [self.mineInputBoard showWithFakeCellOriginY:self.dailyCostCollectionView.y + cellRect.origin.y animateDistance:cellRect.origin.y - self.tableViewInsetTop];
    
}

// 删除一条记录
- (void)dailyCostTableView:(UITableView *)tableView deleteItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *dateString = self.dateCostView.dateString;
    NSMutableArray *expenseArray = [self.dataDict objectForKey:dateString];
    SUDailyCostModel *item = [expenseArray objectAtIndex:indexPath.item];
    
    [expenseArray removeObject:item];
    
    NSIndexPath *pageIndexPath = [self.dailyCostCollectionView indexPathsForVisibleItems].firstObject;
    SUDailyCostCollectionViewCell *cell = (SUDailyCostCollectionViewCell *)[self.dailyCostCollectionView cellForItemAtIndexPath:pageIndexPath];
    
    [cell deleteRowAtIndexPath:indexPath];
    
    [[SUDataBase sharedInstance] deleteItem:item];
    
    [self updateSumExpense];
    [self updateStatisticDataSource];
    if (item.inBudget) {
        [self updateBudget:item addExpense:NO];
    }
    
    // [expenseArray insertObject:item atIndex:indexPath.row];
    // [cell insertRowAtIndexPath:indexPath];

    
}



#pragma mark - cell右划 不计入预算
- (void)dailyCostTableView:(UITableView *)tableView swipeRightWithItem:(SUDailyCostModel *)item {
    
    if (item.category > 30) return;
    
    item.inBudget = !item.inBudget;
    [[SUDataBase sharedInstance] update:item forColumn:7];
    
    [self updateBudget:item addExpense:item.inBudget];
    
    [tableView reloadData];
    
}




@end
