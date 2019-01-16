//
//  LittleBillViewController.m
//  Little Bill
//
//  Created by SU on 2017/9/21.
//  Copyright © 2017年 SU. All rights reserved.
//

#import "LittleBillViewController.h"

#import "SUDailyCostController.h"
#import "SUCycleCostController.h"
#import "SUCycleContrastController.h"
#import "SUSettingController.h"

#import "UIViewController+Switch.h"

@interface LittleBillViewController ()

@property (strong, nonatomic) SUCycleCostController *cycleCost;
@property (strong, nonatomic) SUDailyCostController *dailyCost;
@property (strong, nonatomic) SUSettingController *settingVC;

@end

@implementation LittleBillViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    self.navigationController.interactivePopGestureRecognizer.delegate = (id)self;
    
    self.dailyCost = [[SUDailyCostController alloc] init];
    self.cycleCost = [[SUCycleCostController alloc] init];
    self.settingVC = [[SUSettingController alloc] init];
    
    [self addSubController: self.cycleCost frameY: -kScreenHeight];
    [self addSubController: self.dailyCost frameY: 0];
    [self addSubController: self.settingVC frameY: kScreenHeight];
    
    self.cycleCost.bottomController = self.dailyCost;
    self.dailyCost.topController = self.cycleCost;
    self.dailyCost.bottomController = self.settingVC;
    self.settingVC.topController = self.dailyCost;
    
}

- (void)addSubController:(UIViewController *)viewController frameY:(CGFloat)frameY {
    [self addChildViewController:viewController];
    [viewController didMoveToParentViewController:self];
    [self.view addSubview:viewController.view];
    viewController.view.frame = CGRectMake(0, frameY, kScreenWidth, kScreenHeight);
}

- (BOOL)prefersStatusBarHidden {
    return kStatusBarHeight == 20;
}


@end
