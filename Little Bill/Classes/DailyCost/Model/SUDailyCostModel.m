//
//  SUDailyCostModel.m
//  Little Bill
//
//  Created by SU on 2017/9/28.
//  Copyright © 2017年 SU. All rights reserved.
//

#import "SUDailyCostModel.h"

@implementation SUDailyCostModel

- (id)copyWithZone:(NSZone *)zone {
    
    SUDailyCostModel *copy = [[SUDailyCostModel alloc] init];
    
    copy.recordId = self.recordId;
    copy.category = self.category;
    copy.cost = self.cost;
    copy.remarks = self.remarks;
    copy.dateString = self.dateString;
    copy.weekOfYear = self.weekOfYear;
    copy.inBudget = self.inBudget;
    
    return copy;
    
}

+ (SUDailyCostModel *)defaultPayoutModel {
    
    SUDailyCostModel *model = [[SUDailyCostModel alloc] init];
    model.cost = 0;
    model.category = 1;
    model.inBudget = YES;
    return model;
    
}

@end
