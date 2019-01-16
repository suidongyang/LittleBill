//
//  SnapShotCell.m
//  Little Bill
//
//  Created by SU on 2017/12/19.
//  Copyright © 2017年 SU. All rights reserved.
//

#import "SnapShotCell.h"

@interface SnapShotCell ()

@property (strong, nonatomic) UIImageView *deleteView;
@property (strong, nonatomic) UIButton *removeView;
@property (strong, nonatomic) UIView *snapShot;

@property (assign, nonatomic) CGFloat startX;
@property (assign, nonatomic) CGFloat deleteViewStartX;
@property (assign, nonatomic) CGFloat removeViewStartX;

@property (strong, nonatomic) UIImage *inImg;
@property (strong, nonatomic) UIImage *notInImg;

@end


@implementation SnapShotCell

- (SnapShotCell *)initWithSnapShot:(UIView *)snapShot inBudget:(BOOL)inBudget isExpense:(BOOL)isExpense {
    
    self = [[SnapShotCell alloc] initWithFrame:snapShot.frame];
    snapShot.frame = self.bounds;
    self.snapShot = snapShot;
    
    self.inImg = [UIImage imageNamed:@"in"];
    self.notInImg = [UIImage imageNamed:@"notin"];
    
    self.deleteView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"shanchu"]];
    self.deleteView.contentMode = UIViewContentModeCenter;
    self.deleteView.maxX = self.width - 18;
    self.deleteView.centerY = 0.5 * self.height;
    
    self.removeView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
    self.removeView.x = 18;
    self.removeView.centerY = 0.5 * self.height;
    self.removeView.userInteractionEnabled = NO;
    self.removeView.hidden = !isExpense;
    if (inBudget) {
        [self.removeView setImage:self.notInImg forState:UIControlStateNormal];
    }else {
        [self.removeView setImage:self.inImg forState:UIControlStateNormal];
    }
    
    self.bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, self.height - 0.5, self.width, 0.5)];
    self.bottomLine.backgroundColor = [UIColor colorWithWhite:0 alpha:0.1];
    self.bottomLine.hidden = YES;
    
    self.startX = self.x;
    self.deleteViewStartX = self.deleteView.x;
    self.removeViewStartX = self.removeView.x;
    
    
    [self addSubview:self.removeView];
    [self addSubview:self.deleteView];
    [self addSubview:self.snapShot];
    [self addSubview:self.bottomLine];
    
    [self addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
    
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    CGFloat x = [change[@"new"] CGRectValue].origin.x;
    
    if (x - self.startX <= 0 && x - self.startX > -60) {
        self.deleteView.x = self.deleteViewStartX + self.startX - x;
    }else if (x - self.startX <= -60) {
        self.deleteView.x = self.deleteViewStartX + 60;
        
        
    }else if (x - self.startX > 0 && x - self.startX <= 60) {
        self.removeView.x = self.removeViewStartX - (x - self.startX);
    }else if (x - self.startX > 60) {
        self.removeView.x = self.removeViewStartX - 60;
    }
    
    
    if (self.x == self.startX) {
        self.removeView.x = 10;
    }
    
}



@end
