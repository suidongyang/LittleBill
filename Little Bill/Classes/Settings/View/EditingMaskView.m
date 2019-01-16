//
//  EditingMaskView.m
//  Little Bill
//
//  Created by SU on 2017/12/30.
//  Copyright © 2017年 SU. All rights reserved.
//

#import "EditingMaskView.h"

@interface EditingMaskView ()

@property (assign, nonatomic) CGRect clearRect;

@end

@implementation EditingMaskView

+ (EditingMaskView *)showWithFrame:(CGRect)frame clearRect:(CGRect)clearRect {
    EditingMaskView *maskView = [[EditingMaskView alloc] initWithFrame:frame];
    maskView.clearRect = clearRect;
    maskView.backgroundColor = [UIColor clearColor];
    maskView.opaque = NO; // 设置为透明的
    [maskView setNeedsDisplay];
    maskView.hidden = YES;
    [maskView show];
    return maskView;
}

- (void)drawRect:(CGRect)rect {
    
    [[UIColor colorWithWhite:0 alpha:0.6] setFill];
    UIRectFill(self.bounds);
    
    CGRect clearRect = CGRectOffset(self.clearRect, 0, -self.y);
    CGRect clearIntersection = CGRectIntersection(clearRect, self.bounds);
    
    [[UIColor clearColor] setFill];
    UIRectFill(clearIntersection);
    
}

- (void)show {
    
    self.alpha = 0;
    self.hidden = NO;
    [UIView animateWithDuration:0.25 animations:^{
        self.alpha = 0.1;
    }];
    
}

- (void)dismiss {
    
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 0;
    }completion:^(BOOL finished) {
        self.hidden = YES;
        [self removeFromSuperview];
    }];
    
}


@end
