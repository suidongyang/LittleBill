//
//  UIViewController+Switch.h
//  Little Bill
//
//  Created by SU on 2017/9/26.
//  Copyright © 2017年 SU. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (Switch)

@property (strong, nonatomic) UIViewController *topController;
@property (strong, nonatomic) UIViewController *bottomController;

@property (strong, nonatomic) NSMutableDictionary *subviewFrameDict;
@property (assign, nonatomic) CGFloat tableViewInsetTop;


- (void)scrollWithScrollView:(UIScrollView *)scrollView;
- (void)switchWithScrollView:(UIScrollView *)scrollView;

- (void)backupSubviewFrames;
- (void)resetSubviewFrames;

- (void)addSwitchIndicatorsWithTitles:(NSArray<NSString *> *)titles;
- (void)setSwitchIndicatorHidden:(BOOL)hidden;


// 设置控制器push或pop时，禁止其他控制器走生命周期方法
@property (assign, nonatomic) BOOL settingVCIsBusy;

@end
