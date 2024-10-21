//
//  CategoryButton.m
//  Little Bill
//
//  Created by SU on 2017/12/15.
//  Copyright © 2017年 SU. All rights reserved.
//

#import "CategoryButton.h"

@implementation CategoryButton {
    BOOL _isLayouting;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (_isLayouting) return;
    _isLayouting = YES;
    
    self.titleLabel.font = [UIFont systemFontOfSize:13];
    [self setTitleColor: [UIColor darkGrayColor] forState:UIControlStateNormal];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    self.titleLabel.text = @"类别";
    [self.titleLabel sizeToFit];
    self.titleLabel.width = self.width + 30;
    self.imageView.frame = CGRectMake(0, 0, 36, 36);
    
    self.imageView.x = 0.5 * (self.width - self.imageView.width);
    self.imageView.y = 0.5 * (self.height - self.imageView.height - self.titleLabel.height - 6);
    
    self.titleLabel.centerX = self.imageView.centerX;
    self.titleLabel.y = self.imageView.maxY + 6;
    
    self.layer.cornerRadius = 4;
    self.layer.masksToBounds = YES;
    
    _isLayouting = NO;
    
}

- (void)setChoosed:(BOOL)choosed color:(UIColor *)color {
    self.selected = choosed;
    
    UIColor *bgColor = color ?: [UIColor clearColor];
    
    self.backgroundColor = bgColor;
    
}

@end
