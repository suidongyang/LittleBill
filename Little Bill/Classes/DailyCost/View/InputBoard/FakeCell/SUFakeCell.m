//
//  SUFakeCell.m
//  Little Bill
//
//  Created by SU on 2017/10/21.
//  Copyright © 2017年 SU. All rights reserved.
//

#import "SUFakeCell.h"
#import "SUDailyCostModel.h"

#import "SUCategoryPanel.h"

#import "SUCategoryManager.h"

#define kDotJudgeNumber 2 // 国际化时动态配置  2  3

@interface SUFakeCell () <SUCategoryPanelDelegate, SUNumberBoardDelegate, UITextFieldDelegate>

#warning 优化

@property (assign, nonatomic) NSInteger category; // 类别标识
@property (copy, nonatomic) NSString *remark; // 文本框输入的内容
@property (assign, nonatomic) int recordId;
@property (copy, nonatomic) NSString *weekOfYear; // 周次
@property (assign, nonatomic) NSInteger inBudget;

@property (strong, nonatomic) SUDailyCostModel *fakeCellModel;

@property (strong, nonatomic) UIImageView *iconView;
@property (strong, nonatomic) UITextField *remarkLabel;
@property (strong, nonatomic) UILabel *detailLabel;

@property (strong, nonatomic) UIView *leftMask;
@property (strong, nonatomic) UIView *rightMask;

@property (strong, nonatomic) UIButton *editButton;

// getter，不进行赋值
@property (strong, nonatomic) SUDailyCostModel *generatedModel;


@end

@implementation SUFakeCell

#pragma mark - 初始化

+ (SUFakeCell *)loadFakeCell {
    SUFakeCell *fakeCell = [[SUFakeCell alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kCellHeight)];
    [fakeCell initUI];
    fakeCell.category = 1;
    
    return fakeCell;
}

- (void)initUI {
    
    self.backgroundColor = [UIColor whiteColor];
    
    self.iconView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 10, kCellHeight - 20, kCellHeight - 20)];
    self.iconView.image = [[SUCategoryManager manager] imageForKey:1];
    
    self.remarkLabel = [[UITextField alloc] initWithFrame:CGRectMake(self.iconView.maxX + 8, 0, 80, kCellHeight)];
    self.remarkLabel.centerY = self.iconView.centerY;
    self.remarkLabel.font = [UIFont systemFontOfSize:15];
    self.remarkLabel.textColor = [UIColor colorWithWhite:0 alpha:0.6];
    self.remarkLabel.textAlignment = NSTextAlignmentLeft;
    self.remarkLabel.text = [[SUCategoryManager manager] titleForKey:1];
    self.remarkLabel.tintColor = self.remarkLabel.textColor;
    self.remarkLabel.delegate = self;
    self.remarkLabel.returnKeyType = UIReturnKeyDone;
//    self.remarkLabel.userInteractionEnabled = NO; // 否则调用becomeFirstResponder会弹不出键盘
    
    self.detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.remarkLabel.maxX, 0, kScreenWidth - 20 - self.remarkLabel.maxX, kCellHeight)];
    self.detailLabel.font = [UIFont systemFontOfSize:24];
    self.detailLabel.textColor = [UIColor blackColor];
    self.detailLabel.textAlignment = NSTextAlignmentRight;
    
    
    self.leftMask = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, kCellHeight)];
    self.leftMask.backgroundColor = kThemeColor;
    self.rightMask = [[UIView alloc] initWithFrame:CGRectMake(self.width - 10, 0, 10, kCellHeight)];
    self.rightMask.backgroundColor = kThemeColor;
    
    
    self.editIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"edit"]];
    self.editIconView.x = self.remarkLabel.maxX + 4;
    self.editIconView.centerY = self.remarkLabel.centerY;
    
    self.editButton = [[UIButton alloc] initWithFrame:CGRectMake(self.iconView.maxX, 0, self.width - self.iconView.maxX - 100, self.height)];
    [self.editButton addTarget:self action:@selector(inputRemarkAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:self.iconView];
    [self addSubview:self.remarkLabel];
    [self addSubview:self.detailLabel];
    [self addSubview:self.leftMask];
    [self addSubview:self.rightMask];
    [self addSubview:self.editIconView];
    [self addSubview:self.editButton];
    
}

#pragma mark - 输入备注
- (void)inputRemarkAction:(UIButton *)sender {
    if ([self.remarkLabel isFirstResponder]) return;
    if ([self.detailLabel.text containsString:@"+"] || [self.detailLabel.text containsString:@"-"]) {
        return;
    }
    
    self.editIconView.alpha = 0;
    self.editIconView.hidden = YES;
    
    [self.remarkLabel becomeFirstResponder];
    self.remarkLabel.placeholder = [[SUCategoryManager manager] titleForKey:self.category ?: 1];
    if ([self.remarkLabel.text isEqualToString:[[SUCategoryManager manager] titleForKey:self.category ?: 1]]) {
        self.remarkLabel.text = nil;
    }
    
    
    
    NSLog(@"input remark");
    
}

#pragma mark - 备注框代理

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if (textField.text == nil || [textField.text stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]].length == 0) {
        textField.text = [[SUCategoryManager manager] titleForKey:self.category ?: 1];
    }
    
    self.remark = textField.text;
    
    [self.remarkLabel resignFirstResponder];
    
    [self layoutLabels];
    
    if ([self.detailLabel.text floatValue] != 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kSwitchToConfirmNotification object:nil];
    }
    
    return YES;
}


- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    self.remarkLabel.width = self.detailLabel.x - self.remarkLabel.x - 10;
    
}


#pragma mark - 调整备注和数额的宽度

- (void)layoutLabels {
    
    [self.detailLabel widthToFit];
    self.detailLabel.maxX = self.width - 20;
    
    CGFloat maxWidth = self.detailLabel.x - self.remarkLabel.x - self.editIconView.width - 4 - 10;
    
    if (![self.remarkLabel isFirstResponder]) {
        [self.remarkLabel widthToFitWithMaxWidth:maxWidth];
    }
    
    self.editIconView.x = self.remarkLabel.maxX + 4;
    self.editButton.width = self.detailLabel.x - self.iconView.maxX;
    
}



#warning 优化

#pragma mark - 动画相关 显示隐藏

- (void)showWithModel:(SUDailyCostModel *)model {
    
    self.category = model.category;
    self.remark = model.remarks;
    self.recordId = model.recordId;
    self.weekOfYear = model.weekOfYear;
    self.inBudget = model.inBudget;
    
    self.fakeCellModel = model;
    
    if (model.category > 30) {
        self.detailLabel.textColor = kIncomeTextColor;
    }else {
        self.detailLabel.textColor = [UIColor blackColor];
    }
    
    if (model != nil) { // 编辑
        
        self.backgroundColor = [UIColor colorWithHexString:@"eeeeee"];
        self.detailLabel.hidden = NO;
        
        self.iconView.image = [[SUCategoryManager manager] imageForKey:model.category];
        self.remarkLabel.text = model.remarks ?: [[SUCategoryManager manager] titleForKey:model.category];
        
        NSString *costStr = [NSString stringWithFormat:@"%.1f", model.cost];
        if ([costStr hasSuffix:@".0"]) {
            costStr = [costStr substringToIndex:costStr.length - 2];
        }
        self.detailLabel.text = costStr;
        
        [self layoutLabels];
        
        [UIView animateWithDuration:0.25 animations:^{
            
            self.leftMask.x -= 10;
            self.rightMask.x += 10;
            
            self.backgroundColor = [UIColor whiteColor];
            
        }];
        
    }else { // 添加
        
        self.detailLabel.text = @"0.0";
        
        [self layoutLabels];
        
        [UIView animateWithDuration:0.25 animations:^{
            
            self.leftMask.x -= 10;
            self.rightMask.x += 10;
            
        }];
        
    }
    
    
}

- (void)prepareForDismiss {
    
    [UIView animateWithDuration:0.25 animations:^{
        self.leftMask.x += 10;
        self.rightMask.x -= 10;
        self.editIconView.alpha = 0;
    }completion:^(BOOL finished) {
        self.editIconView.hidden = YES;
    }];
    
}

- (void)resetWithModel:(SUDailyCostModel *)model {
    
    self.category = model.category;
    self.iconView.image = [[SUCategoryManager manager] imageForKey:model.category];
    self.remarkLabel.text = model.remarks ?: [[SUCategoryManager manager] titleForKey:model.category];
    
    if (model.cost > 0) {
        NSString *costStr = [NSString stringWithFormat:@"%.1f", model.cost];
        if ([costStr hasSuffix:@".0"]) {
            costStr = [costStr substringToIndex:costStr.length - 2];
        }
        self.detailLabel.text = costStr;
    }else {
        self.detailLabel.text = @"0.0";
    }
    
    if (model.category > 30) {
        self.detailLabel.textColor = kIncomeTextColor;
    }else {
        self.detailLabel.textColor = [UIColor blackColor];
    }
        
    self.remark = model.remarks;
    
    [self layoutLabels];
    
}


#pragma mark - 输入面板获取生成的model

- (SUDailyCostModel *)generatedModel {
    
//#warning 注意边界条件的处理   日期的处理
    
    SUDailyCostModel *model = [[SUDailyCostModel alloc] init];
    model.category = self.category ?: 1;
    model.remarks = self.remark ?: [[SUCategoryManager manager] titleForKey:model.category]; // remark只有点击确定后才有
    model.cost = self.detailLabel.text.floatValue;
    model.recordId = self.recordId;
    model.weekOfYear = self.weekOfYear;
    model.inBudget = self.inBudget;

    /*
     在哪一页处理的就是哪一页的date，由控制器赋值
     添加记录时，recordId、weekOfYear、date、inBudget都在控制器添加完成的回调里赋值
     编辑记录时，这些属性由fakeCell传递，不修改
     */
    
    
    self.remark = nil;
    
    return model;
    
}


#pragma mark - 类别面板代理

// 选中类别
- (void)categoryPanelChooseCategory:(NSInteger)category {
    
    NSLog(@"---- 选中类别 - %d", (int)category);
    
    self.category = category;
    self.remark = [[SUCategoryManager manager] titleForKey:category];
    self.iconView.image = [[SUCategoryManager manager] imageForKey:category];
    self.remarkLabel.text = self.remark;
    
    if (category > 30) {
        self.detailLabel.textColor = kIncomeTextColor;
    }else {
        self.detailLabel.textColor = [UIColor blackColor];
    }
    
    [self layoutLabels];
    
    if ([self.detailLabel.text floatValue] != 0 && ![self.detailLabel.text containsString:@"+"] && ![self.detailLabel.text containsString:@"-"]) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kSwitchToConfirmNotification object:nil];
    }
    
}


#pragma mark - 限制数字整数位数

- (NSString *)originText:(NSString *)string willAppendChar:(NSString *)typeWord {
    
    
    /*
     int 已查找位数
     从后往前查找 + 号，遇到小数点，计数归零，
     >=7 且 0123456789 则不拼接，
     */
    
    NSString *originStr = [string copy];
    
    int length = 0;
    
    for (int i = (int)string.length - 1; i >= 0; i--) {
        
        NSString *subString = [string substringWithRange:NSMakeRange(i, 1)];
        
        if ([@"+-." containsString:subString]) {
            break;
        }
        
        length++;

    }
    
    if (length >= 7 && [@"0123456789" containsString:typeWord]) {
        
    }else {
        originStr = [originStr stringByAppendingString:typeWord];
    }
    
    return originStr;
    
}


#pragma mark - 数字键盘代理

// 点击键盘 test
- (void)numberBoardDidTypedCharacter:(NSString *)word {
    
    NSString *string = self.detailLabel.text;
    
    /*
     字符串过长时缩小字号
     显示算式时隐藏图标和说明，计算完成后显示
     动态调整数字框的宽度
     
     */
    
    if (([string isEqualToString:@"0.0"] || [string isEqualToString:@"0"]) && ![word isEqualToString:@"cancel"] && ![word isEqualToString:@"OK"]) {
        
        if ([@"+-<=" containsString:word]) {
            self.detailLabel.text = @"0";
        }else if ([word isEqualToString:@"."]) {
            if ([string isEqualToString:@"0.0"]) {
                return;
            }
            self.detailLabel.text = [self originText:string willAppendChar:word]; // [string stringByAppendingString:word];
        }else {
            self.detailLabel.text = word;
        }
    }
    
    // 数字
    else if ([@"1234567890" containsString:word]) {
        
        if ([word isEqualToString:@"0"]) {
            
            if ([string isEqualToString:@"0"] || [string hasSuffix:@"+0"] || [string hasSuffix:@"-0"]) {
                return;
            }
            
        }
        
        if (string.length >= kDotJudgeNumber) {
            
            NSString *last3Word = [string substringWithRange:NSMakeRange(string.length - kDotJudgeNumber, kDotJudgeNumber)];
            if ([last3Word hasPrefix:@"."] && ![last3Word containsString:@"-"] && ![last3Word containsString:@"+"]) {
                return;
            }else {
                self.detailLabel.text = [self originText:string willAppendChar:word]; // [string stringByAppendingString:word];
            }
            
        }else {
            self.detailLabel.text = [self originText:string willAppendChar:word]; // [string stringByAppendingString:word];
            
        }
        
    }
    
    // 加减
    else if ([@"+-" containsString:word]) {
        
        
        NSArray *arr = @[@"+.", @"+.0", @"+.00", @"-.", @"-.0", @"-.00", @".", @".0", @".00"];
        
        for (NSString *pointZero in arr) {
            
            if ([string hasSuffix:pointZero]) {
                
                string = [string substringToIndex:string.length - pointZero.length];
                break;
            }
            
        }
        
        if (string.length == 0) {
            return;
        }
        
        if ([string hasSuffix:@"+"] || [string hasSuffix:@"-"]) {
            
            if ([[string substringWithRange:NSMakeRange(string.length - 1, 1)] isEqualToString:word]) {
                return;
            }else {
                self.detailLabel.text = [string stringByReplacingCharactersInRange:NSMakeRange(string.length - 1, 1) withString:word];
            }
            
        }else {
            self.detailLabel.text = [self originText:string willAppendChar:word]; // [string stringByAppendingString:word];
        }
        
    }
    
    // 小数点
    else if ([word isEqualToString:@"."]) {
        
        if ([string hasSuffix:@"+"] || [string hasSuffix:@"-"] || string.length == 0) {
            self.detailLabel.text = [string stringByAppendingString:word];
            
        }else {
            
            NSString *judgeString;
            
            if (string.length < kDotJudgeNumber) {
                judgeString = string;
                
            }else {
                
                NSString *last3Word = [string substringWithRange:NSMakeRange(string.length - kDotJudgeNumber, kDotJudgeNumber)];
                
                NSArray<NSString *> *strArr = [last3Word componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"+-"]];
                
                judgeString = strArr.lastObject;
            }
            
            
            if ([judgeString containsString:@"."]) {
                return;
                
            }else {
                self.detailLabel.text = [self originText:string willAppendChar:word]; // [string stringByAppendingString:word];
            }
            
            
        }
        
        
    }
    
    // 删除
    else if ([word isEqualToString:@"<"]) {
        
        if (string.length >= 2) {
            self.detailLabel.text = [string substringToIndex:string.length - 1];
        }else {
            self.detailLabel.text = @"0";
        }
        
    }
    
    // 等于
    else if ([word isEqualToString:@"="]) {
        
        if ([self.detailLabel.text isEqualToString:@"0"]) {
            return;
        }else {
            self.detailLabel.text = [self calcWithString:string];
        }
        [self layoutLabels];
    }
    
    // OK
    else if ([word isEqualToString:@"OK"]) {
        
        if ([string hasSuffix:@".0"] || [string hasSuffix:@"+"] || [string hasSuffix:@"-"] || [string hasSuffix:@"."]) {
            
            if ([string hasSuffix:@".0"]) {
                [self numberBoardDidTypedCharacter:@"<"];
            }
            [self numberBoardDidTypedCharacter:@"<"];
        }
        
        if ([self.detailLabel.text isEqualToString:@"0"]) {
            
            NSLog(@"请输入金额");
            return;
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kNumberBoardConfirmNotification object:nil];
        
        [self layoutLabels];
        
    }
    
    // 取消
    else if ([word isEqualToString:@"cancel"]) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kNumberBoardCancelNotification object:nil];
        
    }
    
    if ([self.detailLabel.text isEqualToString:@"0"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"showCancel" object:nil];
    }
    
//    if ([word isEqualToString:@"cancel"]) return;
    
    // 调整数字label的宽度
    [self.detailLabel widthToFit];
    self.detailLabel.maxX = self.width - 20;
    
    if (self.detailLabel.x < self.editIconView.maxX) {
        
        [UIView animateWithDuration:0.2 animations:^{
            self.iconView.alpha = 0.1;
            self.remarkLabel.alpha = 0.1;
            self.editIconView.alpha = 0.1;
        }];
        
    }else {
        
        if (self.remarkLabel.alpha != 1) {
            
            [UIView animateWithDuration:0.2 animations:^{
                self.iconView.alpha = 1;
                self.remarkLabel.alpha = 1;
                self.editIconView.alpha = 1;
            }];
        }
    }
    
}

// 计算

- (NSString *)calcWithString:(NSString *)string {
    
    NSArray<NSString *> *stringArr = [string componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"+-"]];
    
    NSMutableArray<NSNumber *> *numberArr = [NSMutableArray array];
    
    for (NSString *numStr in stringArr) {
        if ([numStr hasPrefix:@"."]) {
            [numberArr addObject:@([[@"0" stringByAppendingString:numStr] floatValue])];
        }else {
            [numberArr addObject:@([numStr floatValue])];
        }
    }
    
    CGFloat sum = numberArr.firstObject.floatValue;
    int j = 1;
    
    for (int i = 0; i < string.length; i++) {
        
        NSRange range = NSMakeRange(i, 1);
        NSString *subStr = [string substringWithRange:range];
        
        if ([subStr isEqualToString:@"+"]) {
            sum += numberArr[j].floatValue;
            j++;
        }else if ([subStr isEqualToString:@"-"]) {
            sum -= numberArr[j].floatValue;
            j++;
        }
        
    }
    
    NSString *sumStr = [NSString stringWithFormat:@"%.1f", sum];
    if (sum < 0) {
        sumStr = @"0";
    }
    if (sumStr.length > 2 && [sumStr hasSuffix:@".0"]) {
        sumStr = [sumStr stringByReplacingOccurrencesOfString:@".0" withString:@""];
    }
    
    
    return sumStr;
}




@end
