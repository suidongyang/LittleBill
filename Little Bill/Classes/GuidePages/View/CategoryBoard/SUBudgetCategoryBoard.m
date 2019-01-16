//
//  SUBudgetCategoryBoard.m
//  Little Bill
//
//  Created by SU on 2017/12/15.
//  Copyright © 2017年 SU. All rights reserved.
//

#import "SUBudgetCategoryBoard.h"
#import "CategoryButton.h"
#import "SUCategoryManager.h"
#import "SUSumBudgetItem.h"

const NSInteger kBudgetCateoryBoardTag = 2017;


@interface SUBudgetCategoryBoard () <UITextFieldDelegate>

@property (strong, nonatomic) CategoryButton *selectedButton;
@property (strong, nonatomic) SUTextField *budgetField;

@property (strong, nonatomic) UIView *bgView;

@property (strong, nonatomic) UIView *keyBoardBgView;

@property (strong, nonatomic) UIScrollView *categoryView;

@property (copy, nonatomic) void(^completion)(void);

@end


@implementation SUBudgetCategoryBoard

#pragma mark -

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


+ (SUBudgetCategoryBoard *)loadBoard {
    
    SUBudgetCategoryBoard *board = [[SUBudgetCategoryBoard alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 200)];
    [board initUI];
    
    [[NSNotificationCenter defaultCenter] addObserver:board selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:board selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    board.hidden = board.bgView.hidden = YES;
    
    return board;
    
}


- (void)initUI {
    
    self.backgroundColor = [UIColor whiteColor]; //[UIColor colorWithHexString:@"d5ccf6"];
    
    self.bgView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.bgView.backgroundColor = [UIColor blackColor];
    self.bgView.alpha = 0.6;
    
    UITapGestureRecognizer *dismissKeyboardGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(budgetFieldEndEditing)];
    [self.bgView addGestureRecognizer:dismissKeyboardGesture];
    
    
    // 输入框
    
    SUTextField *budgetField = [[SUTextField alloc] initWithFrame:CGRectMake(0, 0, self.width, 50)];
    budgetField.backgroundColor = [UIColor whiteColor];
    budgetField.font = [UIFont systemFontOfSize:20 weight:UIFontWeightLight];
    budgetField.textColor = kDarkTextColor;
//    budgetField.tintColor = kDarkTextColor;
    budgetField.placeholder = @"¥500";
    [budgetField setValue:[UIColor grayColor] forKeyPath:@"_placeholderLabel.textColor"];
    budgetField.textAlignment = NSTextAlignmentCenter;
    budgetField.keyboardType = UIKeyboardTypeNumberPad;
    budgetField.delegate = self;
    self.budgetField = budgetField;
    
    UIView *line1 = [[UIView alloc] initWithFrame:CGRectMake(0, budgetField.maxY - 0.5, self.width, 0.5)];
    line1.backgroundColor = kLightGrayColor;
    
    // 类别面板
    
    CGFloat yMargin = 8;
    CGFloat margin = 8;
    CGFloat itemWidth = (kScreenWidth - margin * 6) / 5.0;
    CGFloat itemHeight = itemWidth * 1.1;
    CGFloat boardHeight = itemHeight * 3 + 4 * margin;
    
    UIScrollView *categoryview = [[UIScrollView alloc] initWithFrame:CGRectMake(0, budgetField.maxY, self.width, boardHeight)];
    categoryview.backgroundColor = [UIColor groupTableViewBackgroundColor];
    categoryview.alwaysBounceVertical = YES;
    categoryview.pagingEnabled = YES;
    categoryview.contentSize = CGSizeMake(0, 2 * boardHeight);
    categoryview.showsVerticalScrollIndicator = NO;
    categoryview.showsHorizontalScrollIndicator = NO;
    self.categoryView = categoryview;

    // 类别按钮

    NSArray<SUCategoryItem *> *categories = [[SUCategoryManager manager] categoriesInUse];

    for (int i = 0; i < categories.count; i++) {
        
        if (categories[i].key > 30) continue;
        

        CGFloat X = margin + i % 5 * (margin + itemWidth);
        CGFloat Y = yMargin + i / 5 * (margin + itemHeight);

        CategoryButton *button = [[CategoryButton alloc] initWithFrame:CGRectMake(X, Y, itemWidth, itemHeight)];

        [button setTitle:categories[i].title forState: UIControlStateNormal];
        UIImage *selectedImage = [[SUCategoryManager manager] imageForKey:categories[i].key];
        UIImage *normalImage = [[SUCategoryManager manager] normalImageForKey:categories[i].key];
        [button setImage:normalImage forState:UIControlStateNormal];
        [button setImage:selectedImage forState:UIControlStateSelected];

        button.categoryKey = categories[i].key;
        button.tag = categories[i].key;
        
        [button addTarget:self action:@selector(chooseCategoryAction:) forControlEvents:UIControlEventTouchUpInside];

        [categoryview addSubview:button];
        
        if (i == 0) {
            [button setChoosed:YES color:[UIColor colorWithHexString:@"d5ccf6"]];
            self.selectedButton = button;
        }
        
        if (i > 13) {
            yMargin = 16;
        }

    }
    
    // 保存按钮
    
    UIButton *saveButton = [[UIButton alloc] initWithFrame:CGRectMake(0, categoryview.maxY, 0.5 * self.width, 50)];
    [saveButton setBackgroundImage:[UIImage imageWithColor:kPurpleColor] forState:UIControlStateNormal];
    [saveButton setBackgroundImage:[UIImage imageWithHexString:@"7369e3"] forState:UIControlStateHighlighted];
    [saveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [saveButton setTitleColor:[UIColor colorWithWhite:1 alpha:0.8] forState:UIControlStateHighlighted];
    [saveButton setTitle:@"保存" forState:UIControlStateNormal];
    [saveButton.titleLabel setFont:[UIFont systemFontOfSize:17 weight:UIFontWeightLight]];
    [saveButton addTarget:self action:@selector(saveButtonAction) forControlEvents:UIControlEventTouchUpInside];
    
    // 取消按钮
    UIButton *cancelButton = [[UIButton alloc] initWithFrame:saveButton.frame];
    cancelButton.x = saveButton.maxX;
    [cancelButton setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
    [cancelButton setBackgroundImage:[UIImage imageWithHexString:@"fafafa"] forState:UIControlStateHighlighted];
    [cancelButton setTitleColor:kDarkTextColor forState:UIControlStateNormal];
    [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [cancelButton.titleLabel setFont:[UIFont systemFontOfSize:17 weight:UIFontWeightLight]];
    [cancelButton addTarget:self action:@selector(cancelButtonAction) forControlEvents:UIControlEventTouchUpInside];
    
    self.height = saveButton.maxY;
    
    
    self.keyBoardBgView = [[UIView alloc] initWithFrame:CGRectMake(0, budgetField.maxY, kScreenWidth, self.height - budgetField.maxY)];
    self.keyBoardBgView.backgroundColor = [UIColor blackColor];
    self.keyBoardBgView.alpha = 0;
    self.keyBoardBgView.hidden = YES;
    
    UIView *line2 = [[UIView alloc] initWithFrame:CGRectMake(0, saveButton.y - 0.5, self.width, 0.5)];
    line2.backgroundColor = kLightGrayColor;
    
    UITapGestureRecognizer *dismiss = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(budgetFieldEndEditing)];
    [self.keyBoardBgView addGestureRecognizer:dismiss];
    
    // 覆盖文本框的button
    UIButton *fieldButton = [[UIButton alloc] initWithFrame:self.budgetField.frame];
    [fieldButton addTarget:self action:@selector(fieldButtonAction) forControlEvents:UIControlEventTouchUpInside];
    
    
    [self addSubview:budgetField];
    [self addSubview:fieldButton];
    [self addSubview:line1];
    [self addSubview:categoryview];
    [self addSubview:saveButton];
    [self addSubview:cancelButton];
    [self addSubview:line2];
    [self addSubview:self.keyBoardBgView];
    
    if (kStatusBarHeight > 20) {
        
        self.height = saveButton.maxY + 34;
        UIView *line3 = [[UIView alloc] initWithFrame:CGRectMake(0, saveButton.maxY, kScreenWidth, 0.5)];
        line3.backgroundColor = kLightGrayColor;
        [self addSubview:line3];
        
        
    }
    
    
}

#pragma mark - 监听键盘弹出

- (void)keyboardWillShow:(NSNotification *)notify {
    
    self.keyBoardBgView.hidden = NO;
    [UIView animateWithDuration:0.25 animations:^{
        self.keyBoardBgView.alpha = 0.2;
    }];
    
}

- (void)keyboardWillHide:(NSNotification *)notify {
    
    [UIView animateWithDuration:0.25 animations:^{
        self.keyBoardBgView.alpha = 0;
    }completion:^(BOOL finished) {
        self.keyBoardBgView.hidden = YES;
    }];
    
    
}

#pragma mark - 文本框代理

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField.text == nil || [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length == 0) {
        textField.text = @"¥";
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    
    if (textField.text == nil || [textField.text isEqualToString:@"¥"] || [[textField.text substringFromIndex:1] integerValue] == 0) {
        textField.text = textField.placeholder;
    }
    
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if (textField.text.length == 8 && [@"0123456789" containsString:string]) {
        return NO;
    }
    
    if ([textField.text isEqualToString:@"¥"] && ![@"123456789" containsString:string]) {
        return NO;
    }
    
    if (range.location != textField.text.length) {
        
        UITextPosition *position = [textField positionFromPosition:textField.selectedTextRange.start offset:textField.text.length - (range.location + range.length)];
        
        textField.selectedTextRange = [textField textRangeFromPosition:position toPosition:position];
        
    }
    
    return YES;
    
}


#pragma mark -


- (void)show {
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    
    if (![window viewWithTag:kBudgetCateoryBoardTag]) {
        [window addSubview:self.bgView];
        [window addSubview:self];
        self.tag = kBudgetCateoryBoardTag;
    }
    
    self.hidden = self.bgView.hidden = NO;
    self.y = kScreenHeight;
    self.bgView.alpha = 0;

    
    [UIHelper animationWithDuration:0.2 actions:^{
        self.y -= self.height;
        self.bgView.alpha = 0.4;
    }];
    
}

- (void)showWithCompletion:(void (^)(void))completion {
    self.completion = completion;
    [self show];
}

- (void)hide {
    
    [UIHelper animationWithDuration:0.2 delegate:self actions:^{
        
        self.y = kScreenHeight;
        self.bgView.alpha = 0;
        
    } completion:@selector(hideCompletion)];
    
}

- (void)hideCompletion {
    self.hidden = self.bgView.hidden = YES;
    [self reset];
    if (self.completion) {
        self.completion();
    }
}


#pragma mark -

- (void)reset {
    
    self.budgetField.text = @"";
    [self.selectedButton setChoosed:NO color:nil];
    CategoryButton *button = self.categoryView.subviews.firstObject;
    [button setChoosed:YES color:[UIColor colorWithHexString:@"d5ccf6"]];
    self.selectedButton = button;
    self.categoryView.contentOffset = CGPointZero;
    
    
}

#pragma mark - Button Actions

- (void)chooseCategoryAction:(CategoryButton *)sender {
    
    [self.selectedButton setChoosed:NO color:nil];
    [sender setChoosed:YES color:[UIColor colorWithHexString:@"d5ccf6"]];
    self.selectedButton = sender;
    
}

- (void)saveButtonAction {
    
    [self hide];
    
    NSString *text;
    if (self.budgetField.text == nil || [self.budgetField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length == 0) {
        text = self.budgetField.placeholder;
    }else {
        text = self.budgetField.text;
    }
    
    NSInteger sum = [[text substringFromIndex:1] integerValue];
    
    SUSumBudgetItem *item = [[SUSumBudgetItem alloc] init];
    item.category = self.selectedButton.categoryKey;
    item.sum = sum;
    
    
    if ([self.delegate respondsToSelector:@selector(categoryBoardInputCompletion:)]) {
        [self.delegate categoryBoardInputCompletion:item];
    }
    
    
}

- (void)cancelButtonAction {
    
    [self hide];
    
}

- (void)budgetFieldEndEditing {
    
    if ([self.budgetField isFirstResponder]) {
        [self.budgetField resignFirstResponder];
    }
    
}

- (void)fieldButtonAction {
    if (![self.budgetField isFirstResponder]) {
        [self.budgetField becomeFirstResponder];
    }
}







@end
