//
//  SUCycleCostController.m
//  Little Bill
//
//  Created by SU on 2017/9/21.
//  Copyright © 2017年 SU. All rights reserved.
//

#import "SUCycleCostController.h"
#import "UIViewController+Switch.h"

#import "SUDateChooseView.h"
#import "SUCycleCostCell.h"
#import "SUPieView.h"
#import "SUButtonPanel.h"

#import "SUCategoryManager.h"
#import "SUDataBase.h"


@interface SUCycleCostController () <UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate, SUDateChooseViewDelegate>

@property (strong, nonatomic) UIScrollView *containerView;

@property (strong, nonatomic) SUDateChooseView *dateChooseView;
@property (strong, nonatomic) UICollectionView *pieCollectionView;
@property (strong, nonatomic) SUButtonPanel *buttonPanel;

@property (assign, nonatomic) NSInteger currentIndex;

@property (assign, nonatomic) CGFloat pieGridOffsetX;

// 数据源
@property (strong, nonatomic) NSMutableDictionary *dataSource;
@property (strong, nonatomic) NSMutableDictionary *incomeDataSource;

// 0-支出  1-收入
@property (assign, nonatomic) NSInteger statisticType;

@property (assign, nonatomic) BOOL reloadImmediately;
@property (assign, nonatomic) BOOL reloadAfterDecelerating;

@property (strong, nonatomic) UIPageControl *pageControl;

@end

/** TODO
 
    是否有必要在更改周期类型时预查询数据 看是否有卡顿
    优化：pie的数据源改为收入和支出数组[datas, colors], 并增加是否赋值的判断，避免重复绘制
 
 */


@implementation SUCycleCostController

static NSString * const kCycleCostCellID = @"kCycleCostCellID";


#pragma mark - life cycle

// ios9以后不再需要手动移除观察者
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateDataSource:) name:kUpdateStstisticDataSourceNotification object:nil];
    self.reloadImmediately = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([LifeCycleManager manager].settingIsBusy) return;
    
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if ([LifeCycleManager manager].settingIsBusy) return;
    [self backupSubviewFrames];
}


#pragma mark - private


- (void)initUI {
    
    self.currentIndex = -1;
    self.view.backgroundColor = kCycleCostColor; // [UIColor whiteColor];
    
    // 容器视图
    self.containerView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    self.containerView.alwaysBounceVertical = YES;
    self.containerView.backgroundColor = [UIColor clearColor]; // [UIColor groupTableViewBackgroundColor];
    
    if (@available(iOS 11.0, *)) {
        self.containerView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    
    self.containerView.delegate = self;
    
    // 周期切换按钮
    self.dateChooseView = [SUDateChooseView loadDateChooseView];
    self.dateChooseView.centerX = 0.5 * kScreenWidth;
    self.dateChooseView.y = 0; // (kStatusBarHeight > 20 ? kStatusBarHeight + 10 : kStatusBarHeight);
    self.dateChooseView.backgroundColor = [UIColor groupTableViewBackgroundColor]; // [UIColor colorWithHexString:@"d5ccf6"];
    self.dateChooseView.circleType = [LifeCycleManager manager].cycleType;
    self.dateChooseView.delegate = self;
    self.dateChooseView.backgroundColor = [UIColor clearColor];
    
    // 饼图 CollectionView
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(kScreenWidth, kScreenWidth);
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    self.pieCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, self.dateChooseView.maxY - 24, layout.itemSize.width, layout.itemSize.height) collectionViewLayout:layout];
    [self.pieCollectionView registerClass:[SUCycleCostCell class] forCellWithReuseIdentifier:kCycleCostCellID];
    self.pieCollectionView.dataSource = self;
    self.pieCollectionView.delegate = self;
    self.pieCollectionView.pagingEnabled = YES;
    self.pieCollectionView.backgroundColor = kCycleCostColor; // [UIColor groupTableViewBackgroundColor];
    self.pieCollectionView.showsVerticalScrollIndicator = NO;
    self.pieCollectionView.showsHorizontalScrollIndicator = NO;
    
    [self.pieCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:500 inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    
    // 类别统计
    self.buttonPanel = [[SUButtonPanel alloc] initWithFrame:CGRectMake(0, self.pieCollectionView.maxY, kScreenWidth, kScreenHeight - self.pieCollectionView.maxY)];
    self.buttonPanel.backgroundColor = kCycleCostColor; // [UIColor groupTableViewBackgroundColor];
    self.buttonPanel.delegate = self;
    
    [self.containerView addSubview:self.buttonPanel];
    [self.containerView addSubview:self.pieCollectionView];
    [self.containerView addSubview:self.dateChooseView];
    [self.view addSubview:self.containerView];
    
    self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, 0, 30, 10)];
    self.pageControl.numberOfPages = 2;
    self.pageControl.centerX = 0.5 * self.containerView.width;
    self.pageControl.y = self.buttonPanel.y + 6;
        self.pageControl.currentPageIndicatorTintColor = [UIColor colorWithHexString:@"cccccc"];
        self.pageControl.pageIndicatorTintColor = [UIColor colorWithHexString:@"f1f1f1"];
    self.pageControl.hidden = YES;
    
    [self.containerView addSubview:self.pageControl];
    
    [self addSwitchIndicatorsWithTitles:@[@"", @"账单"]];
    
}

#pragma mark - 添加或修改记录后 更新数据源

- (void)updateDataSource:(NSNotification *)notification {
    
    NSDate *modifiedDate = (NSDate *)notification.object;
    NSDateFormatter *formatter = [SUDateTool dateFormatterYMD];
    
    NSString *weekOfYear = [[SUDateTool dateTool] weekOfYearForDate:modifiedDate];
    
    formatter.dateFormat = @"yyyy-MM";
    NSString *month = [formatter stringFromDate:modifiedDate];
    
    formatter.dateFormat = @"yyyy";
    NSString *year = [formatter stringFromDate:modifiedDate];
    
    int needReload = 0;
    
    if ([self.dataSource objectForKey:weekOfYear]) {
        NSArray *queryArray = [[SUDataBase sharedInstance] queryWeeklyExpenseList:weekOfYear];
        [self.dataSource setObject:queryArray.firstObject forKey:weekOfYear];
        [self.incomeDataSource setObject:queryArray.lastObject forKey:weekOfYear];
        needReload++;
    }
    
    if ([self.dataSource objectForKey:month]) {
        NSArray *queryArray = [[SUDataBase sharedInstance] queryMonthlyExpenseList:month];
        [self.dataSource setObject:queryArray.firstObject forKey:month];
        [self.incomeDataSource setObject:queryArray.lastObject forKey:month];
        needReload++;
    }
    
    if ([self.dataSource objectForKey:year]) {
        NSArray *queryArray = [[SUDataBase sharedInstance] queryYearlyExpenseList:year];
        [self.dataSource setObject:queryArray.firstObject forKey:year];
        [self.incomeDataSource setObject:queryArray.lastObject forKey:year];
        needReload++;
    }
    
    if (needReload) {
        self.reloadImmediately = YES;
        [self.pieCollectionView reloadData];
    }
    
}

#pragma mark - SUDateChooseView 的回调

// 返回当前周期
- (void)dateChooseViewBackAction:(DateCircleType)circleType {
    
    self.reloadImmediately = YES;
    self.currentIndex = 500;
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:500 inSection:0];
    // scrollTo... 会导致 scrollViewDidScroll 被调用，必须在此之前设置 currentIndex
    [self.pieCollectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    
    [self.pieCollectionView reloadData];
    
}

// 切换周月年
- (void)dateChooseViewChangeDateCircle:(DateCircleType)circleType {
    self.reloadImmediately = YES;
    [self.pieCollectionView reloadData];
}

#pragma mark - UICollectionViewDelegate

// 切换 收入/支出
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
//    self.pageControl.hidden = !self.pageControl.hidden;
    self.statisticType = !self.statisticType;
    self.reloadImmediately = YES;
    [self.pieCollectionView reloadData];
}

// 刷新cell
- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(SUCycleCostCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {

    SUPieView *pie = [cell.contentView viewWithTag:kPieTag];
    
    SUDataBase *dataBase = [SUDataBase sharedInstance];
    SUDateTool *dateTool = [SUDateTool dateTool];
    NSDateFormatter *formatter = [SUDateTool dateFormatterYMD];
    
    NSInteger next = indexPath.item - self.currentIndex;
    NSString *dateString;
    
    switch (self.dateChooseView.circleType) {
        case DateCircleTypeWeek:
        {
            NSDate *willDisplayWeekFirstDay = [dateTool firstDayOfNextWeek:next];
            dateString = [dateTool weekOfYearForDate:willDisplayWeekFirstDay];
            break;
        }
            
        case DateCircleTypeMonth:
        {
            NSDate *willDisplayMonth = [dateTool nextMonth:next];
            formatter.dateFormat = @"yyyy-MM";
            dateString = [formatter stringFromDate:willDisplayMonth];
            break;
        }
            
        case DateCircleTypeYear:
        {
            NSDate *willDisplayYear = [dateTool nextYear:next];
            formatter.dateFormat = @"yyyy";
            dateString = [formatter stringFromDate:willDisplayYear];
            break;
        }
            
        default:
            break;
    }
    
    // {   "dateCircle" : [ {categoryKey : sum} , ... ]   , ... }
    
    NSArray *dataArray;
    if (self.statisticType == 0) {
        dataArray = [self.dataSource objectForKey:dateString];
    }else {
        dataArray = [self.incomeDataSource objectForKey:dateString];
    }
    
    if (nil == dataArray) { // 没有查询过

        NSArray *queryArray;
        switch (self.dateChooseView.circleType) {
            case DateCircleTypeWeek:
                queryArray = [dataBase queryWeeklyExpenseList:dateString];
                break;
            case DateCircleTypeMonth:
                queryArray = [dataBase queryMonthlyExpenseList:dateString];
                break;
            case DateCircleTypeYear:
                queryArray = [dataBase queryYearlyExpenseList:dateString];
                break;
        }
        
        [self.dataSource setObject:queryArray.firstObject forKey:dateString];
        [self.incomeDataSource setObject:queryArray.lastObject forKey:dateString];
        
        dataArray = self.statisticType ? queryArray.lastObject : queryArray.firstObject;
    }
    
    cell.dataType = self.statisticType;
    cell.dataSource = dataArray;
    
    if (self.reloadImmediately) {
        self.buttonPanel.dataType = self.statisticType;
        self.buttonPanel.dataSource = dataArray;
        [self.buttonPanel reloadData];
        self.reloadImmediately = NO;
    }
    
    if (indexPath.item > self.currentIndex && self.currentIndex != -1) {
        pie.frameXOffset = -100;
    }else if (indexPath.item < self.currentIndex) {
        pie.frameXOffset = 100;
    }else {
        pie.frameXOffset = 0;
        pie.animateXOffset = 0;
    }
    
    
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 1000;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SUCycleCostCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCycleCostCellID forIndexPath:indexPath];
    return cell;
}


#pragma mark - UIScrollViewDelegate


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if ([scrollView isEqual:self.containerView]) {
        [self scrollWithScrollView:scrollView];
    }
    
    else if ([scrollView isEqual:self.pieCollectionView]) {
        
        CGFloat offsetX = scrollView.contentOffset.x;
        
        if (self.currentIndex == -1) {
            self.currentIndex = (int)(offsetX / kScreenWidth);
        }
        
        int index = (int)(offsetX / kScreenWidth + 0.5);
        
        if (index != self.currentIndex) {
            
            [self.dateChooseView changeCircle: index > self.currentIndex];
            
            /*
             待优化
             滑动流畅，刷新延迟
             在这里如果设置 reloadImmediately ，willDisplayCell会先于didEndDecelerating判断并刷新buttonPanel，导致卡顿。
             */
            self.reloadAfterDecelerating = YES;
            
            self.currentIndex = index;
        }
        
        for (SUCycleCostCell *cell in self.pieCollectionView.visibleCells) {
            SUPieView *pie = [cell.contentView viewWithTag:kPieTag];
            pie.animateXOffset = (offsetX - self.pieGridOffsetX) * 100 / kScreenWidth;
            
            /* 将累加改为直接设置centerX，建立cellX与labelX的关系，避免监听不准确造成的精度损失
             NSIndexPath *indexPath = [self.pieCollectionView indexPathForCell:cell];
             pie.animateXOffset = - (cellRect.origin.x - (indexPath.item - indexThis) * kScreenWidth) * 100 / kScreenWidth;
             */
        }
        
        self.pieGridOffsetX = offsetX;
        
    }else if ([scrollView isEqual:self.buttonPanel]) {
        
        int page = (int)(scrollView.contentOffset.x / kScreenWidth + 0.5);
        self.pageControl.currentPage = page;
        
    }
    
    
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    if ([scrollView isEqual:self.pieCollectionView]) return;
    
    if ([scrollView isEqual:self.containerView]) {
        [self switchWithScrollView:scrollView];
    }
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if ([scrollView isEqual:self.containerView]) return;
    
    if (self.reloadAfterDecelerating) {
        
        if (scrollView.isDragging || scrollView.isDecelerating || scrollView.contentOffset.x - (int)(scrollView.contentOffset.x) != 0) {
            return;
        }
        
        SUCycleCostCell *visibleCell = (SUCycleCostCell *)[self.pieCollectionView visibleCells].firstObject;
        
        if (![visibleCell.dataSource isEqualToArray:self.buttonPanel.dataSource]) {
            self.buttonPanel.dataType = visibleCell.dataType;
            self.buttonPanel.dataSource = visibleCell.dataSource;
            [self.buttonPanel reloadData];
        }
        
        self.reloadAfterDecelerating = NO;
    }
}



#pragma mark - lazy loads

- (NSMutableDictionary *)dataSource {
    if (!_dataSource) {
        _dataSource = [NSMutableDictionary dictionary];
    }
    return _dataSource;
}

- (NSMutableDictionary *)incomeDataSource {
    if (!_incomeDataSource) {
        _incomeDataSource = [NSMutableDictionary dictionary];
    }
    return _incomeDataSource;
}



@end
