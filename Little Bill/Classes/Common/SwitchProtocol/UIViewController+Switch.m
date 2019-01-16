//
//  UIViewController+Switch.m
//  Little Bill
//
//  Created by SU on 2017/9/26.
//  Copyright © 2017年 SU. All rights reserved.
//

#import "UIViewController+Switch.h"
#import <objc/runtime.h>

@implementation UIViewController (Switch)

const void * kTopIndicatorKey = "kTopIndicatorKey";
const void * kBottomIndicatorKey = "kBottomIndicatorKey";


#pragma mark - 监听Offset

// ScrollViewDidScroll
- (void)scrollWithScrollView:(UIScrollView *)scrollView {
    
    if (self.view.y != 0) {
        // 会在当前控制器滑出屏幕停止滚动后调用一次 注意系统更新后会不会出问题
        [self setSwitchIndicatorHidden:YES];
        [self rotateIndicatorArrow:0 whichOne:1];
        [self rotateIndicatorArrow:0 whichOne:0];
    }
    
    BOOL isDailyCost = [self isKindOfClass:NSClassFromString(@"SUDailyCostController")];
    CGFloat viewMargin = isDailyCost ? kViewMargin_dailyCost : kViewMargin;
    CGFloat offsetY = scrollView.contentOffset.y + self.tableViewInsetTop;
    CGFloat contentHeight = scrollView.contentSize.height;
    
    CGFloat offset_ = offsetY - kViewMargin; // 只影响上拉
    if (contentHeight >= scrollView.height - self.tableViewInsetTop) {
        offset_ = offsetY + scrollView.height - self.tableViewInsetTop - contentHeight - kViewMargin;
    }
    
    [self scrollSubviewsWithScrollView:scrollView margin:viewMargin];
    
    // 下拉
    if (offsetY < 0) {
        if (self.topController == nil) return;
        
        if (offsetY <= - viewMargin) {
            self.topController.view.y = - kScreenHeight + (-offsetY - viewMargin);
            [self rotateIndicatorArrow:M_PI whichOne:1];
        }else {
            self.topController.view.y = self.view.y - kScreenHeight;
            [self rotateIndicatorArrow:M_PI * 2 whichOne:1];
        }
    }
    
    // 上拉
    else if (offsetY > 0) {
        if (self.bottomController == nil) return;
        
        if (offset_ >= 0) {
            self.bottomController.view.y = kScreenHeight - offset_;
            [self rotateIndicatorArrow:M_PI whichOne:0];
        }else {
            self.bottomController.view.y = self.view.y + kScreenHeight;
            [self rotateIndicatorArrow:M_PI * 2 whichOne:0];
        }
    }
    
}

- (void)scrollSubviewsWithScrollView:(UIScrollView *)scrollView margin:(CGFloat)viewMargin {
    
    CGFloat triggerOffset = viewMargin == kViewMargin_dailyCost ? 56 : 0;
    CGFloat offsetY = scrollView.contentOffset.y + self.tableViewInsetTop;
    CGFloat contentHeight = scrollView.contentSize.height;
    CGFloat offset_ = offsetY - viewMargin;
    if (contentHeight >= scrollView.height - self.tableViewInsetTop) {
        offset_ = offsetY + scrollView.height - self.tableViewInsetTop - contentHeight - viewMargin;
    }
    
    // 下拉
    if (offsetY <= - triggerOffset) {
        
        if (self.topController == nil) return;
        
        for (NSNumber *tagNumber in self.subviewFrameDict.allKeys) {
            
            NSInteger tag = tagNumber.integerValue;
            CGFloat originalY = [self.subviewFrameDict[tagNumber] floatValue];
            UIView *subview = [self.view viewWithTag:tag];
            
            if ([subview isEqual:objc_getAssociatedObject(self, kBottomIndicatorKey)]) {
                continue;
            }
            
            subview.y = originalY + (-offsetY - triggerOffset);
            
        }
    }
    
    // 上拉
    else if (offset_ + viewMargin > 0) {
        
        if (self.bottomController == nil) return;
        
        for (NSNumber *tagNumber in self.subviewFrameDict.allKeys) {
            
            NSInteger tag = tagNumber.integerValue;
            CGFloat originalY = [self.subviewFrameDict[tagNumber] floatValue];
            UIView *subview = [self.view viewWithTag:tag];
            
            if ([subview isEqual:objc_getAssociatedObject(self, kTopIndicatorKey)]) {
                continue;
            }
            
            subview.y = originalY - offset_ - viewMargin;
            
        }
        
    }
    
}


// ScrollViewWillBeginDecelerating
- (void)switchWithScrollView:(UIScrollView *)scrollView {
    
    BOOL isDailyCost = [self isKindOfClass:NSClassFromString(@"SUDailyCostController")];
    CGFloat viewMargin = isDailyCost ? kViewMargin_dailyCost : kViewMargin;
    CGFloat offsetY = scrollView.contentOffset.y + self.tableViewInsetTop;
    CGFloat contentHeight = scrollView.contentSize.height;
    CGFloat insetTop = offsetY - kViewMargin;
    if (contentHeight >= scrollView.height - self.tableViewInsetTop) {
        insetTop = offsetY + scrollView.height - self.tableViewInsetTop - contentHeight - kViewMargin;
    }
    
    // 下拉结束
    
    if (offsetY <= - viewMargin) {
        if (self.topController == nil) return;
        
        [scrollView setContentOffset:scrollView.contentOffset animated:NO];
        scrollView.scrollEnabled = NO;
        
        [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            
            self.topController.view.y = 0;
            self.view.y += kScreenHeight - (-offsetY - viewMargin);
            
        } completion:^(BOOL finished) {
            
            self.view.y = kScreenHeight;
            scrollView.contentOffset = CGPointMake(0, -self.tableViewInsetTop); // CGPointZero;
            scrollView.scrollEnabled = YES;
            
            [self resetSubviewFrames];
            [self.topController setSwitchIndicatorHidden:NO];
            
            [self.view.superview bringSubviewToFront:self.topController.topController.view];
            [self.view.superview bringSubviewToFront:self.view];
            
        }];
        
    }

    // 上拉结束
    
    if (offsetY > 0 && insetTop >= 0) {
        if (self.bottomController == nil) return;
        
        [scrollView setContentOffset:scrollView.contentOffset animated:NO];
        scrollView.scrollEnabled = NO;

        [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{

            self.bottomController.view.y = 0;
            self.view.y -= kScreenHeight - insetTop;

        } completion:^(BOOL finished) {

            self.view.y = - kScreenHeight;
            
            if (scrollView.contentSize.height < scrollView.height - self.tableViewInsetTop) {
                scrollView.contentOffset = CGPointMake(0, -self.tableViewInsetTop); // CGPointZero;
            }else {
                scrollView.contentOffset = CGPointMake(0, (scrollView.contentSize.height - scrollView.height));
            }
            
            scrollView.scrollEnabled = YES;
            
            [self resetSubviewFrames];
            [self.bottomController setSwitchIndicatorHidden:NO];
            
            [self.view.superview bringSubviewToFront:self.bottomController.bottomController.view];
            [self.view.superview bringSubviewToFront:self.view];
            
        }];
        
    }
    
}



#pragma mark - 子视图frame相关



- (void)resetSubviewFrames {
    
    for (NSNumber *tagNumber in self.subviewFrameDict.allKeys) {
        
        NSInteger tag = tagNumber.integerValue;
        CGFloat originalY = [self.subviewFrameDict[tagNumber] floatValue];
        UIView *subview = [self.view viewWithTag:tag];
        if (subview.y > 0.5 * kScreenHeight) {
            continue;
        }
        subview.y = originalY;
    }
}

- (void)backupSubviewFrames {
    
    self.subviewFrameDict = [NSMutableDictionary dictionary];
    
    int tag = kBaseTag;
    
    for (UIView *subView in self.view.subviews) {
        if (![subView isKindOfClass:[UIScrollView class]]) {
            
            subView.tag = tag;
            [self.subviewFrameDict setObject:@(subView.y) forKey:@(subView.tag)];
            tag++;
        }
    }
}



#pragma mark - 指示器相关



// 添加指示器
- (void)addSwitchIndicatorsWithTitles:(NSArray<NSString *> *)titles {
    
    if (titles[0].length > 0) {
        
        UIView *topIndicator = [self createIndicatorWithTitle:titles[0] direction:1];
        topIndicator.backgroundColor = self.view.backgroundColor;
        objc_setAssociatedObject(self, kTopIndicatorKey, topIndicator, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [self.view addSubview:topIndicator];
    }
    
    if (titles[1].length > 0) {
        
        UIView *bottomIndicator = [self createIndicatorWithTitle:titles[1] direction:0];
        bottomIndicator.backgroundColor = self.view.backgroundColor;
        objc_setAssociatedObject(self, kBottomIndicatorKey, bottomIndicator, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [self.view addSubview: bottomIndicator];
        
    }
   
}

// 创建指示器   direction: 0-up-bottom  1-down-top
- (UIView *)createIndicatorWithTitle:(NSString *)title direction:(int)direction {
    
    UIView *indicator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kCellHeight)];
    indicator.y = direction ? -kCellHeight : kScreenHeight;
    
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont systemFontOfSize:18];
    label.textColor = [UIColor colorWithWhite:0 alpha:0.7];
    label.text = title;
    [label sizeToFit];
    
    UIImageView *arrow = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 22, 22)];
    arrow.image = [[UIImage imageNamed:direction ? @"down" : @"up"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    arrow.tintColor = [UIColor colorWithWhite:0 alpha:0.6];
    
    
    arrow.x = (indicator.width - arrow.width - 6 - label.width) / 2;
    label.x = arrow.maxX + 6;
    label.height = indicator.height;
    arrow.centerY = label.centerY;
    
    [indicator addSubview:label];
    [indicator addSubview:arrow];
    
    indicator.hidden = YES;
    
    return indicator;
    
}

// 旋转指示器   0-bottom  1-top
- (void)rotateIndicatorArrow:(CGFloat)angle whichOne:(BOOL)which {
    
    UIView *indicator = objc_getAssociatedObject(self, which ? kTopIndicatorKey : kBottomIndicatorKey);
    for (UIView *view in indicator.subviews) {
        if ([view isKindOfClass:[UIImageView class]]) {
            
            [UIView animateWithDuration:0.2 animations:^{
                view.transform = CGAffineTransformMakeRotation(angle);
            }];
        }
    }
    
    
}

// 隐藏指示器
- (void)setSwitchIndicatorHidden:(BOOL)hidden {
    
    UIView *topIndicator = objc_getAssociatedObject(self, kTopIndicatorKey);
    UIView *bottomIndicator = objc_getAssociatedObject(self, kBottomIndicatorKey);
    topIndicator.hidden = hidden;
    bottomIndicator.hidden = hidden;
    
    topIndicator.y = -kCellHeight;
    bottomIndicator.y = kScreenHeight;
    
}



#pragma mark - 关联对象




- (UIView *)topController {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setTopController:(UIView *)topController {
    objc_setAssociatedObject(self, @selector(topController), topController, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIView *)bottomController {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setBottomController:(UIView *)bottomController {
    objc_setAssociatedObject(self, @selector(bottomController), bottomController, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableDictionary *)subviewFrameDict {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setSubviewFrameDict:(NSMutableDictionary *)subviewFrameDict {
    objc_setAssociatedObject(self, @selector(subviewFrameDict), subviewFrameDict, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)tableViewInsetTop {
    return [objc_getAssociatedObject(self, _cmd) floatValue];
}

- (void)setTableViewInsetTop:(CGFloat)tableViewInsetTop {
    objc_setAssociatedObject(self, @selector(tableViewInsetTop), @(tableViewInsetTop), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


#pragma mark -

- (BOOL)settingVCIsBusy {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setSettingVCIsBusy:(BOOL)settingVCIsBusy {
    objc_setAssociatedObject(self, @selector(settingVCIsBusy), @(settingVCIsBusy), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


@end
