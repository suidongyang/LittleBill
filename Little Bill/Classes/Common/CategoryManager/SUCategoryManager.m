//
//  SUCategoryManager.m
//  Little Bill
//
//  Created by SU on 2017/10/22.
//  Copyright © 2017年 SU. All rights reserved.
//

#import "SUCategoryManager.h"

@interface SUCategoryManager ()

@property (strong, nonatomic) NSArray<SUCategoryItem *> *categoriesInUse;

@end

static SUCategoryManager *_manager;

@implementation SUCategoryManager

+ (instancetype)manager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[SUCategoryManager alloc] init];
    });
    return _manager;
}

- (UIImage *)imageForKey:(NSInteger)key {
    SUCategoryItem *item = [self itemForKey:key];
    NSString *imageName = [NSString stringWithFormat:@"%@_sel", item.imageName];
    return [UIImage imageNamed:imageName];
}

- (UIImage *)normalImageForKey:(NSInteger)key {
    SUCategoryItem *item = [self itemForKey:key];
    return [UIImage imageNamed:item.imageName];
}

- (NSString *)titleForKey:(NSInteger)key {
    SUCategoryItem *item = [self itemForKey:key];
    return item.title;
}

- (UIColor *)colorForKey:(NSInteger)key {
    SUCategoryItem *item = [self itemForKey:key];
    return item.color;
}

- (SUCategoryItem *)itemForKey:(NSInteger)key {
    
    __block SUCategoryItem *item;
    
    [self.categoriesInUse enumerateObjectsUsingBlock:^(SUCategoryItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if (obj.key == key) {
            item = obj;
            *stop = YES;
        }
    }];
    
    return item;
}

#pragma mark - getter

/*
 使用xcode创建的plist，真机只能读取，必须代码创建的才能写入
 */

- (NSArray<SUCategoryItem *> *)categoriesInUse {
    
    if (!_categoriesInUse) {
        
        NSArray *cArray;
        
        NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
        NSString *editedPlistPath = [path stringByAppendingPathComponent:@"editedCategories.plist" ];
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"Categories.plist" ofType:nil];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:editedPlistPath]) {
            cArray = [[NSArray alloc] initWithContentsOfFile:editedPlistPath];
        }else {
            cArray = [[NSArray alloc] initWithContentsOfFile:plistPath];
        }
        
        
        NSMutableArray *temp = [NSMutableArray array];
        
        for (int i = 0; i < cArray.count; i++) {
            
            SUCategoryItem *item = [[SUCategoryItem alloc] init];
            item.key = [cArray[i][@"key"] integerValue];
            item.imageName = cArray[i][@"img"];
            item.title = cArray[i][@"title"];
            item.color = [UIColor colorWithHexString:cArray[i][@"color"]];
            item.colorString = cArray[i][@"color"];
            item.group = [cArray[i][@"group"] integerValue];
            
            [temp addObject:item];
        }
        
        _categoriesInUse = [NSArray arrayWithArray:temp];
    }
    
    return _categoriesInUse;
}
















@end
