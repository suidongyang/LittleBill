//
//  TrafficLight.m
//  Little Bill
//
//  Created by SU on 2017/12/25.
//  Copyright © 2017年 SU. All rights reserved.
//

#import "TrafficLight.h"

#define kBaseLightTag 2030


@implementation TrafficLight


- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) return nil;
    
    [self initUI];
    
    return self;
}

- (void)initUI {
    
    NSArray<NSString *> *normalColors = @[@"f75652", @"fdbc41", @"33b23e"];
//    NSArray<NSString *> *disabledColors = @[];
    
    CGFloat itemWH = 10;
    
    for (int i = 0; i < 3; i++) {
        
        CGFloat XMargin = 0.25 * (self.width - itemWH * 3);
        CGFloat YMargin = 0.5 * (self.height - itemWH);
        
        CGFloat X = XMargin + i * (XMargin + itemWH);
        
        UIButton *butt = [[UIButton alloc] initWithFrame:CGRectMake(X, YMargin, itemWH, itemWH)];
        [butt setBackgroundImage:[UIImage imageWithHexString:normalColors[i]] forState:UIControlStateNormal];
        [butt setBackgroundImage: [UIImage imageWithColor:[UIColor colorWithHexString:normalColors[i] alpha:0.2]] forState:UIControlStateDisabled];
        butt.layer.cornerRadius = 5.0f;
        butt.layer.masksToBounds = YES;
        butt.tag = kBaseLightTag + i;
        butt.enabled = NO;
        
        [self addSubview:butt];
        
    }
    
    
}


- (void)setState:(LightState)state {
    _state = state;
    
    UIButton *butt = [self viewWithTag:kBaseLightTag + state];
    butt.enabled = YES;
    
}


@end
