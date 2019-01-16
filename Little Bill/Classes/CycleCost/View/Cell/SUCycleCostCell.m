//
//  SUCycleCostCell.m
//  Little Bill
//
//  Created by SU on 2017/12/1.
//  Copyright © 2017年 SU. All rights reserved.
//

#import "SUCycleCostCell.h"
#import "SUPieView.h"

#import "SUCategoryManager.h"

@interface SUCycleCostCell ()

@property (strong, nonatomic) SUPieView *bigPie;

@end

@implementation SUCycleCostCell

NSInteger const kPieTag = 110;

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        [self initUI];
        
    }
    return self;
}

- (void)initUI {
    
    SUPieView *bigPie = [[SUPieView alloc] initWithFrame:CGRectMake(0, 0, 280 * kScreenScale, 280 * kScreenScale)];
    bigPie.center = CGPointMake(0.5 * kScreenWidth, 0.5 * kScreenWidth);
    bigPie.tag = kPieTag;
    self.bigPie = bigPie;
    [self.contentView addSubview:bigPie];
    
}

- (void)setDataSource:(NSArray *)dataSource {
    _dataSource = dataSource;
    
    NSMutableArray *sumArray = [NSMutableArray array];
    NSMutableArray *keyArray = [NSMutableArray array];
    
    if (_dataSource.count > 0) { // 有数据
        
        for (NSDictionary<NSNumber *, NSNumber *> *item in _dataSource) {
            [sumArray addObject:item.allValues.firstObject];
            [keyArray addObject:item.allKeys.firstObject];
        }
        
        NSArray *colorArray = [self colorsFromKeys:keyArray];
        
        [self.bigPie strokeWithDataItems:sumArray colorItems:colorArray recordType:self.dataType];
        
    }else {
        [self.bigPie strokeWithDataItems:@[] colorItems:@[] recordType:self.dataType];
    }
    
}

// 事先已经按总额降序排序
- (NSArray *)colorsFromKeys:(NSArray *)keys {
    
    NSMutableArray *colorArray = [NSMutableArray array];
    for (NSNumber *key in keys) {
        UIColor *color = [[SUCategoryManager manager] colorForKey:key.integerValue];
        [colorArray addObject:color];
    }
    
    return colorArray;
}




@end
