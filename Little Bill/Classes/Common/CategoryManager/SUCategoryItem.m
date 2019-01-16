//
//  SUCategoryItem.m
//  Little Bill
//
//  Created by SU on 2017/10/22.
//  Copyright © 2017年 SU. All rights reserved.
//

#import "SUCategoryItem.h"

@implementation SUCategoryItem

- (id)copyWithZone:(NSZone *)zone {
    
    SUCategoryItem *item = [[SUCategoryItem alloc] init];
    item.key = self.key;
    item.title = self.title;
    item.color = self.color;
    
    return item;
    
}

@end
