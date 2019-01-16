//
//  SUCategoryManager.h
//  Little Bill
//
//  Created by SU on 2017/10/22.
//  Copyright © 2017年 SU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SUCategoryItem.h"

@interface SUCategoryManager : NSObject

@property (strong, nonatomic, readonly) NSArray<SUCategoryItem *> *categoriesInUse;

+ (SUCategoryManager *)manager;

- (SUCategoryItem *)itemForKey:(NSInteger)key;

- (UIImage *)imageForKey:(NSInteger)key;         // 选中
- (UIImage *)normalImageForKey:(NSInteger)key;   // 正常
- (NSString *)titleForKey:(NSInteger)key;
- (UIColor *)colorForKey:(NSInteger)key;


@end
