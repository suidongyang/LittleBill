//
//  SUButtonPanel.m
//  Little Bill
//
//  Created by SU on 2017/12/4.
//  Copyright © 2017年 SU. All rights reserved.
//

#import "SUButtonPanel.h"
#import "SUCategoryManager.h"

@interface SUButtonPanel() <UIScrollViewDelegate>

@property (strong, nonatomic) NSArray<SUCategoryItem *> *pureItems;

@end


@implementation SUButtonPanel

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initUI];
    }
    return self;
}

- (void)initUI {
    
    self.tag = -1;
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = NO;
    self.pagingEnabled = YES;
//    self.alwaysBounceHorizontal = YES;
    self.bounces = NO;
    self.delegate = self;
    self.contentSize = CGSizeMake(self.width * 2, self.height);
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showDetail)];
    [self addGestureRecognizer:tap];
    
//    CGFloat oneX = 10;
//    CGFloat oneY = 14;
    CGFloat XMargin = 10;
    CGFloat YMargin = 6;
    CGFloat itemWidth = 112 * kScreenScale;// (self.width - oneX * 2 - XMargin * 2) / 3.0;
    CGFloat itemHeight = 20;
    CGFloat oneX = (self.width - itemWidth * 3 - XMargin * 2);
    CGFloat oneY = 0; // (self.width - itemWidth * 3 - XMargin * 2) * 0.5 + 8;  // (self.height - itemHeight * 5 - YMargin * 4) * 0.5 - 30;
    
    for (int i = 0; i < 30; i++) { // 从上到下，从左到右
        
        if (i > 14) oneX = (self.width - itemWidth * 3 - XMargin * 2) * 2 - XMargin;
        
        CGFloat itemX = oneX + (i / 5) * (itemWidth + XMargin);
        CGFloat itemY = oneY + (i % 5) * (itemHeight + YMargin);
        
        StatisticButton *button = [[StatisticButton alloc] initWithFrame:CGRectMake(itemX, itemY, itemWidth, itemHeight)];
        button.tag = i + 1;
        
        [self addSubview:button];
        
    }
    
}

- (void)showDetail {
    
    for (StatisticButton *button in self.subviews) {
        if ([button isKindOfClass:[StatisticButton class]]) {
            button.selected = !button.selected;
        }
    }
    
}

#pragma mark - 刷新数据

- (void)reloadData {
    
    /**  [{key:sum}, ...]
     
     有数据 选中
     未选中
     
     无数据 选中
     未选中
     
     排序  有数据的降序排序
     无数据的按照面板中的默认顺序
     
     初始item数组，数额都是0，面板顺序
     根据DataSource对初始数组里的item赋值，根据DataSource的下标插入初始数组，排序完成
     给button赋值，先赋值数额，不为0则显示颜色，否则小圆圈 -1隐藏
     
     收入 空数组时怎么判断
     
     */
    
    for (UIView *view in self.subviews) {
        view.hidden = NO;
    }
    
    self.contentOffset = CGPointZero;
    
    NSArray *array = [[NSArray alloc] initWithArray:self.pureItems copyItems:YES];
    NSMutableArray<SUCategoryItem *> *items = [NSMutableArray arrayWithArray:array];
    
    if (self.dataSource.count == 0) {
        
        if (self.dataType == 1) {
            items = [self configHiddenFlag:items];
        }
        
        for (int i = 0; i < 30; i++) {
            StatisticButton *button = [self viewWithTag:i + 1];
            button.sumItem = items[i];
        }
        
        return;
    }
    
    for (NSDictionary *keySumDict in _dataSource) {
        for (SUCategoryItem *item in items) {
            if ([keySumDict.allKeys.firstObject integerValue] == item.key) {
                item.sum = [keySumDict.allValues.firstObject floatValue];
                break;
            }
        }
    }
    
    [items sortUsingComparator:^NSComparisonResult(SUCategoryItem * _Nonnull obj1, SUCategoryItem * _Nonnull obj2) {
        return [@(obj2.sum) compare:@(obj1.sum)];
    }];
    
    
    // >= 30 引起的bug：当总额最大的类别是花草(key==30)时，切换到开销却显示收入类别
    if (items.firstObject.key > 30) {
        items = [self configHiddenFlag:items];
    }
    
    for (int i = 0; i < 30; i++) {
        StatisticButton *button = [self viewWithTag:i + 1];
        button.sumItem = items[i];
    }
    
    
}


#pragma mark - 给需要隐藏的button的item 设置‘-1’标志位

- (NSMutableArray *)configHiddenFlag:(NSMutableArray *)myItems {
    
    NSMutableArray *items = myItems;
    
    for (SUCategoryItem *item in items) {
        if (item.key < 31) {
            item.sum = -1; // 用于隐藏button
        }
    }
    // 将收入类别前置
    [items sortUsingComparator:^NSComparisonResult(SUCategoryItem * _Nonnull obj1, SUCategoryItem * _Nonnull obj2) {
        return [@(obj2.sum) compare:@(obj1.sum)];
    }];
    
    return items;
}


#pragma mark - setter

- (void)setDataType:(NSInteger)dataType {
    _dataType = dataType;
    self.contentSize = CGSizeMake(kScreenWidth * (2 - dataType), 0);
}

- (void)setDataSource:(NSArray *)dataSource {
    _dataSource = dataSource;
}


#pragma mark - getter

- (NSArray<SUCategoryItem *> *)pureItems {
    if (!_pureItems) {
        _pureItems = [[SUCategoryManager manager] categoriesInUse];
    }
    return _pureItems;
}


@end



#pragma mark -
#pragma mark -
#pragma mark -


@implementation StatisticButton

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.titleLabel.font = [UIFont systemFontOfSize:13];
        [self setTitleColor:[UIColor colorWithWhite:0 alpha:0.8] forState:UIControlStateNormal];
        self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        self.userInteractionEnabled = NO;
        
        self.imageView.layer.cornerRadius = 5.0f;
        self.imageView.layer.masksToBounds = YES;
        [self setImage:[UIImage imageWithColor:[UIColor groupTableViewBackgroundColor]] forState:UIControlStateNormal];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.imageView.frame = CGRectMake(4, 0, 10, 10);
    self.imageView.centerY = 0.5 * self.height;
    self.titleLabel.frame = CGRectMake(self.imageView.maxX + 6, 0, self.width - self.imageView.width, self.height);
}

- (void)setSumItem:(SUCategoryItem *)sumItem {
    _sumItem = sumItem;
    
    if (sumItem.sum < 0) {
        self.hidden = YES;
        return;
    }
    
    [self setTitle:sumItem.title forState:UIControlStateNormal];
    [self setTitle:[NSString stringWithFormat:@"%.1f", sumItem.sum] forState:UIControlStateSelected];
    
    if (sumItem.sum > 0) {
        [self setImage:[UIImage imageWithColor:sumItem.color] forState:UIControlStateNormal];
        [self setTitleColor:[UIColor colorWithWhite:0 alpha:0.8] forState:UIControlStateNormal];
    }else {
        [self setImage:[UIImage imageWithHexString:@"e1e0e3"] forState:UIControlStateNormal];
        [self setTitleColor:[UIColor colorWithWhite:0 alpha:0.5] forState:UIControlStateNormal];
    }
    
}


@end


















