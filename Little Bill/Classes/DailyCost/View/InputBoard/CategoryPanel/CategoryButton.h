//
//  CategoryButton.h
//  Little Bill
//
//  Created by SU on 2017/12/15.
//  Copyright © 2017年 SU. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CategoryButton : UIButton

@property (assign, nonatomic) NSInteger categoryKey;

- (void)setChoosed:(BOOL)choosed color:(UIColor *)color;

@end
