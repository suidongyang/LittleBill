//
//  SUInputBoard.m
//  Little Bill
//
//  Created by SU on 2017/9/25.
//  Copyright © 2017年 SU. All rights reserved.
//

#import "SUInputBoard.h"
#import "SUDailyCostModel.h"
#import "SUCategoryPanel.h"
#import "SUFakeCell.h"

@interface SUInputBoard ()

@property (strong, nonatomic) UIView *bgview;
@property (strong, nonatomic) SUFakeCell *fakeCell;
@property (strong, nonatomic) SUCategoryPanel *categoryPanel;

@property (assign, nonatomic) CGFloat animateDistance;

@end

@implementation SUInputBoard

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - 初始化

+ (SUInputBoard *)loadInputBoard {
    
    SUInputBoard *board = [[SUInputBoard alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [board initUI];
    board.hidden = YES;
    
    UIWindow *keyWindow = [UIApplication sharedApplication].delegate.window;
    [keyWindow addSubview:board];
    
    [[NSNotificationCenter defaultCenter] addObserver:board selector:@selector(numberBoardCanceled:) name:kNumberBoardCancelNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:board selector:@selector(numberBoardConfirmed:) name:kNumberBoardConfirmNotification object:nil];
    
    return board;
}


- (void)initUI {
    
    self.backgroundColor = [UIColor clearColor];
    
    // 透明背景
    
    self.bgview = [[UIView alloc] initWithFrame:self.bounds];
    self.bgview.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
    self.bgview.alpha = 0;

    UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleRegular];
    UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
    effectView.frame = self.bgview.bounds;
    [self.bgview addSubview:effectView];
    
    // 假cell
    
    self.fakeCell = [SUFakeCell loadFakeCell];
    
    // 类别面板
    
    CGFloat pannelHeight = kScreenHeight - kStatusBarHeight - kBudgetViewHeight - kDateCostViewHeight - kCellHeight;
    self.categoryPanel = [[SUCategoryPanel alloc] initWithFrame:CGRectMake(0, 0, self.width, pannelHeight)];
    self.categoryPanel.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    // 设置代理
    
    self.categoryPanel.delegate = (id<SUCategoryPanelDelegate>)self.fakeCell;
    self.categoryPanel.aNumberBoard.delegate = (id<SUNumberBoardDelegate>)self.fakeCell;
    
    //
    
    [self addSubview:self.bgview];
    [self addSubview:self.fakeCell];
    [self addSubview:self.categoryPanel];
    
}

#pragma mark - 处理 数字键盘 取消、完成 的通知

- (void)numberBoardCanceled:(NSNotification *)notification {
    [self hide];
}

- (void)hide {
    
    if (self.fakeCellModel != nil) {
        [self.fakeCell resetWithModel:self.fakeCellModel];
    }else {
        [self.fakeCell resetWithModel:[SUDailyCostModel defaultPayoutModel]];
    }
    
    [UIView animateWithDuration:0.25 animations:^{
        
        self.bgview.alpha = 0;
        self.categoryPanel.y = self.height;
//        self.categoryPanel.alpha = 0;
        [self.fakeCell prepareForDismiss];
        
        if (self.fakeCellModel != nil) {
            self.fakeCell.y += self.animateDistance;
            if ([self.delegate respondsToSelector:@selector(inputBoardCanceledAndShouldRoll:)]) {
                [self.delegate inputBoardCanceledAndShouldRoll:YES];
            }
        }
        
    } completion:^(BOOL finished) {
        
        self.hidden = YES;
        [self.fakeCell resetWithModel:[SUDailyCostModel defaultPayoutModel]];
        [self.categoryPanel reset];
        
        if (self.fakeCellModel == nil) {
            // 不使用通知，因为通知会影响到所有存活的cell
            if ([self.delegate respondsToSelector:@selector(inputBoardCanceledAndShouldRoll:)]) {
                [self.delegate inputBoardCanceledAndShouldRoll:NO];
            }
        }
        
    }];
    
}


// 完成

- (void)numberBoardConfirmed:(NSNotification *)notification {
    
    SUDailyCostModel *model = self.fakeCell.generatedModel;
    
    if (self.fakeCellModel == nil) {
        
        // 完成添加
        
        if ([self.delegate respondsToSelector:@selector(inputBoardAddCompletion:)]) {
            [self.delegate inputBoardAddCompletion:model];
        }
        
        [UIView animateWithDuration:0.25 animations:^{
            
            self.bgview.alpha = 0;
            self.categoryPanel.y = self.height;
//            self.categoryPanel.alpha = 0;
            [self.fakeCell prepareForDismiss];
            
        } completion:^(BOOL finished) {
            
            self.hidden = YES;
            [self.fakeCell resetWithModel:[SUDailyCostModel defaultPayoutModel]];
            [self.categoryPanel reset];
            
        }];
        
    }else {
        
        // 完成编辑
        
        [UIView animateWithDuration:0.25 animations:^{
            
            self.bgview.alpha = 0;
            self.categoryPanel.y = self.height;
//            self.categoryPanel.alpha = 0;
            [self.fakeCell prepareForDismiss];
            
            self.fakeCell.y += self.animateDistance;
            if ([self.delegate respondsToSelector:@selector(inputBoardCanceledAndShouldRoll:)]) {
                [self.delegate inputBoardCanceledAndShouldRoll:YES];
            }
            
        } completion:^(BOOL finished) {
            
            if ([self.delegate respondsToSelector:@selector(inputBoardEditCompletion:)]) {
                [self.delegate inputBoardEditCompletion:model];
            }
            self.hidden = YES;
            [self.fakeCell resetWithModel:[SUDailyCostModel defaultPayoutModel]];
            [self.categoryPanel reset];
            
        }];
        
    }
    
    
}

#pragma mark - 显示 隐藏

// 显示

- (void)showWithFakeCellOriginY:(CGFloat)originY animateDistance:(CGFloat)animateDistance {
    
    self.animateDistance = animateDistance;
    self.hidden = NO;
    self.categoryPanel.y = self.height;
    self.fakeCell.y = originY;
    
    [self.fakeCell showWithModel:self.fakeCellModel];
    [self.categoryPanel showWithCategory:self.fakeCellModel.category ?: 1];
    
    self.fakeCell.editIconView.hidden = NO;
    self.fakeCell.editIconView.alpha = 0;
    
    [UIView animateWithDuration:0.25 animations:^{
        
        self.bgview.alpha = 1;
        self.categoryPanel.y = originY - animateDistance + kCellHeight;
//        self.categoryPanel.alpha = 1;
        self.fakeCell.y -= animateDistance;
        self.fakeCell.editIconView.alpha = 1;
        
    }];
    
}


#pragma mark - Setter

- (void)setFakeCellModel:(SUDailyCostModel *)fakeCellModel {
    _fakeCellModel = fakeCellModel;
    
    
}


















@end
