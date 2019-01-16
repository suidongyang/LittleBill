//
//  SUFooterView.m
//  Little Bill
//
//  Created by SU on 2017/10/31.
//  Copyright © 2017年 SU. All rights reserved.
//

#import "SUFooterView.h"

@interface SUFooterView()

@property (strong, nonatomic) UIView *topView;
@property (strong, nonatomic) UIView *bottomView;

@end

@implementation SUFooterView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) return nil;
    [self initUI];
    return self;
}

- (void)initUI {
    
    int triangleCount = 46;
    CGFloat triangleWidth = ((CGFloat)self.width) / triangleCount;
    
    self.backgroundColor = [UIColor clearColor];
    
    self.topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, 0)];
    self.bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, -1, self.width, 0.5 * triangleWidth + 2)];
    self.bottomView.backgroundColor = self.topView.backgroundColor = [UIColor whiteColor];
    
    
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = self.bottomView.bounds;
    maskLayer.lineWidth = 1;
    maskLayer.fillColor = [UIColor whiteColor].CGColor;
    maskLayer.strokeColor = [UIColor clearColor].CGColor;
    
    
    UIBezierPath *borderPath = [UIBezierPath bezierPath];
    
    [borderPath moveToPoint:CGPointMake(0, 0)];
    [borderPath addLineToPoint:CGPointMake(0, self.bottomView.height - 1)];
    
    for (int i = 1; i <= triangleCount; i++) {
        
        CGPoint bottomPoint = CGPointMake(i * triangleWidth, self.bottomView.height - 1);
        CGPoint topPoint = CGPointMake((2 * i - 1) * 0.5 * triangleWidth, self.bottomView.height - 1 - 0.5 * triangleWidth);
        
        [borderPath addLineToPoint:topPoint];
        [borderPath addLineToPoint:bottomPoint];
        
    }
    
    [borderPath addLineToPoint:CGPointMake(self.bottomView.width, 0)];
    [borderPath addLineToPoint:CGPointMake(0, 0)];
    [borderPath closePath];
    
    maskLayer.path = borderPath.CGPath;
    
    self.bottomView.layer.mask = maskLayer;
    
    
    [self addSubview:self.topView];
    [self addSubview:self.bottomView];
    
}

- (void)setFooterHeight:(CGFloat)footerHeight animate:(BOOL)animate {
    
    if (animate) {
        [UIView animateWithDuration:0.25 animations:^{
            self.topView.height = footerHeight;
            self.bottomView.y = self.topView.maxY - 1;
        }];
        
    }else {
        self.topView.height = footerHeight;
        self.bottomView.y = self.topView.maxY - 1;
    }
    
    
}



@end
