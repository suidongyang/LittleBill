//
//  SUCategoryItem.h
//  Little Bill
//
//  Created by SU on 2017/10/22.
//  Copyright © 2017年 SU. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SUCategoryItem : NSObject <NSCopying>

@property (assign, nonatomic) long key;

@property (copy, nonatomic) NSString *title;

@property (copy, nonatomic) NSString *imageName;

@property (strong, nonatomic) UIColor *color;
@property (copy, nonatomic) NSString *colorString;
/// 0-支出，1-收入
@property (assign, nonatomic) long group;

/// 收支总额
@property (assign, nonatomic) CGFloat sum;

@end
