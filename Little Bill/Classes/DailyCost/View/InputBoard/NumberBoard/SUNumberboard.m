//
//  SUNumberboard.m
//  Little Bill
//
//  Created by SU on 2017/12/26.
//  Copyright © 2017年 SU. All rights reserved.
//

#import "SUNumberboard.h"

@interface SUNumberboard ()

@property (strong, nonatomic) UIButton *doneButton;
@property (strong, nonatomic) UIButton *deleteButton;
@property (strong, nonatomic) UIButton *addButton;
@property (strong, nonatomic) UIButton *minusButton;

@property (strong, nonatomic) UIButton *cancelButton;

@property (copy, nonatomic) NSString *doneTitle;

@end


/**
 适配
 
 44 34
 
 输入面板contentSize.height 在iPhoneX上需要增加 34
 
 */


@implementation SUNumberboard


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


+ (SUNumberboard *)loadNumberBoard {
    
    SUNumberboard *numberBoard = [[SUNumberboard alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 220 * kScreenScale)];
    
    [numberBoard initUI];
    
    [[NSNotificationCenter defaultCenter] addObserver:numberBoard selector:@selector(switchToCancel) name:@"showCancel" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:numberBoard selector:@selector(switchToConfirm) name:kSwitchToConfirmNotification object:nil];
    
    return numberBoard;
}


- (void)initUI {
    
    self.backgroundColor = [UIColor colorWithHexString:@"cfcdd4"];
    
    self.layer.shadowColor = self.backgroundColor.CGColor;
    self.layer.shadowOffset = CGSizeMake(0, 0);
    self.layer.shadowRadius = 3;
    self.layer.shadowOpacity = 0.3;
    
    
    NSArray<NSString *> *titles = @[@"1", @"2", @"3", @"", @"4", @"5", @"6", @"+", @"7", @"8", @"9", @"-", @"", @"0", @".", @""];
    
    CGFloat itemWidth = 0.25 * (self.width - 1.5);
    CGFloat itemHeight = 0.25 * (self.height - 2);
    
    for (int i = 0; i < 16; i++) {
        
        CGFloat itemX = i % 4 * (itemWidth + 0.5);
        CGFloat itemY = 0.5 + i / 4 * (itemHeight + 0.5);
        
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(itemX, itemY, itemWidth, itemHeight)];
        button.titleLabel.font = [UIFont systemFontOfSize:24];
        [button setTitleColor:kDarkTextColor forState:UIControlStateNormal];
        [button setTitleColor:kDarkTextColor forState:UIControlStateHighlighted];
        [button setBackgroundImage:[UIImage imageWithHexString:@"f8f8fb"] forState:UIControlStateNormal]; //@"faf9fe"] f3f3f7
        [button setBackgroundImage:[UIImage imageWithHexString:@"d8d7db"] forState:UIControlStateHighlighted];
        
        [button setTitle:titles[i] forState:UIControlStateNormal];
        
        [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:button];
        
        if (i == 3) {
            self.deleteButton = button;
        }else if (i == 7) {
            self.addButton = button;
        }else if (i == 11) {
            self.minusButton = button;
        }else if (i == 12) {
            self.cancelButton = button;
        }else if (i == 15) {
            self.doneButton = button;
        }
        
    }
    
    if (kStatusBarHeight > 20) {
        
        UIView *safeAreaView = [[UIView alloc] initWithFrame:CGRectMake(0, self.subviews.lastObject.maxY + 0.5, self.width, 34)];
        safeAreaView.backgroundColor = [UIColor colorWithHexString:@"f2f2f2"];
        [self addSubview:safeAreaView];
        
    }
    
    self.height = self.subviews.lastObject.maxY;
    
    [self configButtons];
    
}

- (void)configButtons {
    
    [self.deleteButton setImage:[UIImage imageNamed:@"clear"] forState:UIControlStateNormal];
    [self.deleteButton setImage:[UIImage imageNamed:@"clear"] forState:UIControlStateHighlighted];
    
    self.addButton.titleLabel.font = [UIFont systemFontOfSize:32];
    self.minusButton.titleLabel.font = [UIFont systemFontOfSize:32];
    
    [self setupDoneButtonType:2];
    
    
}

// 1-确认  2-取消  3-等于
- (void)setupDoneButtonType:(int)type {
    
    if (type == 1) {
        [self.doneButton setImage:[UIImage imageNamed:@"confirm"] forState:UIControlStateNormal];
        [self.doneButton setImage:[UIImage imageNamed:@"confirm"] forState:UIControlStateHighlighted];
        self.doneTitle = @"OK";
    }else if (type == 2) {
        [self.doneButton setImage:[UIImage imageNamed:@"cancel"] forState:UIControlStateNormal];
        [self.doneButton setImage:[UIImage imageNamed:@"cancel"] forState:UIControlStateHighlighted];
        self.doneTitle = @"cancel";
    }else if (type == 3) {
        [self.doneButton setImage:[UIImage imageNamed:@"equal"] forState:UIControlStateNormal];
        [self.doneButton setImage:[UIImage imageNamed:@"equal"] forState:UIControlStateHighlighted];
        self.doneTitle = @"=";
    }
    
}


#pragma mark -

- (void)switchToCancel {
    [self setupDoneButtonType:2];
}

- (void)switchToConfirm {
    [self setupDoneButtonType:1];
}


- (void)buttonAction:(UIButton *)sender {
    
    // done tag =-110  ok-111 取消-112
    
    NSString *typeWord = sender.currentTitle;
    if ([sender isEqual:self.cancelButton]) {
        typeWord = @"cancel";
    }
    
    if ([sender isEqual:self.deleteButton]) {
        typeWord = @"<";
    }
    
    if ([sender isEqual:self.doneButton]) {
        
        typeWord = self.doneTitle;
        
        if ([self.doneTitle isEqualToString:@"="]) {
            [self setupDoneButtonType:1];
            
        }else if ([self.doneTitle isEqualToString:@"OK"]) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self setupDoneButtonType:2];
            });
        }
        
        if ([self.delegate respondsToSelector:@selector(numberBoardDidTypedCharacter:)]) {
            [self.delegate numberBoardDidTypedCharacter:typeWord];
        }
        
        return;
    }
    
    if ([self.doneTitle isEqualToString:@"cancel"]) {
        
        if ([@"+-" containsString:typeWord]) {
            [self setupDoneButtonType:3];
        }
        
        else if (![sender.currentTitle isEqualToString:@"cancel"] && (![@"+-." containsString:typeWord])) {
            [self setupDoneButtonType:1];
        }
        
    }else if ([self.doneTitle isEqualToString:@"OK"]) {
        
        if ([@"+-" containsString:typeWord]) {
            [self setupDoneButtonType:3];
        }
        
    }
    
    if ([self.delegate respondsToSelector:@selector(numberBoardDidTypedCharacter:)]) {
        [self.delegate numberBoardDidTypedCharacter:typeWord];
    }
    
    
}


@end




