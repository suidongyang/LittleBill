//
//  SUCycleContrastController.m
//  Little Bill
//
//  Created by SU on 2017/9/21.
//  Copyright © 2017年 SU. All rights reserved.
//

#import "SUCycleContrastController.h"
#import "UIViewController+Switch.h"

@interface SUCycleContrastController () <UIScrollViewDelegate>

@end

@implementation SUCycleContrastController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    scrollView.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:scrollView];
    
    scrollView.alwaysBounceVertical = YES;
    scrollView.delegate = self;
    
    [self addSwitchIndicatorsWithTitles:@[@"", @"统计"]];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self backupSubviewFrames];
}

#pragma mark -

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self scrollWithScrollView:scrollView];
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    [self switchWithScrollView:scrollView];
}


@end
