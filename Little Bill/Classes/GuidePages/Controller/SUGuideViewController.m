//
//  SUGuideViewController.m
//  Little Bill
//
//  Created by SU on 2017/12/14.
//  Copyright © 2017年 SU. All rights reserved.
//

#import "SUGuideViewController.h"

#import "SUSumBudgetCell.h"
#import "SUSumBudgetItem.h"

#import "SUBudgetCategoryBoard.h"

#import "SUDataBase.h"

#import "SUBudgetItem.h"

#import "AppDelegate.h"

@interface SUGuideViewController () <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, SUBudgetCategoryBoardProtocol, UITextFieldDelegate, UIGestureRecognizerDelegate>

@property (strong, nonatomic) UITableView *budgetsTableView;
@property (strong, nonatomic) SUBudgetCategoryBoard *categoryBoard;

@property (strong, nonatomic) SUTextField *budgetField;
@property (strong, nonatomic) UIButton *selectedTypeButton;
@property (strong, nonatomic) UIButton *addButton;
@property (strong, nonatomic) UIButton *continueButton;
@property (strong, nonatomic) UILabel *subBudgetLabel;

@property (strong, nonatomic) UIScrollView *scrollView;

@property (strong, nonatomic) UIImageView *doneButton;
@property (strong, nonatomic) UITapGestureRecognizer *hideKeyboardGesture;

@property (strong, nonatomic) NSMutableArray *sumItems;

@property (assign, nonatomic) NSInteger totalBudget;


@end

/**TODO
 
 !! 内存泄漏 切换根控制器后没有释放，leaks没有检测到内存泄漏，
 修改备注弹出键盘时这里也会相应通知，导致自定义按钮添加到键盘上
 
 UI优化
 代码优化
 
 文本框处理
 
 */


@implementation SUGuideViewController

static NSString * const kBudgetCellId = @"kBudgetCellId";


#pragma mark - life cycle

- (instancetype)init {
    if (self = [super init]) {
        [self loadCategoryBoard];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
    [self observeKeyboard];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setupAddButtonWithLeftMoney:0];
    self.continueButton.enabled = NO;

}

#pragma mark -

- (void)loadCategoryBoard {
    
    if (self.categoryBoard == nil) {
        
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        if ([window viewWithTag:kBudgetCateoryBoardTag]) {
            self.categoryBoard = [window viewWithTag:kBudgetCateoryBoardTag];
        }else {
            self.categoryBoard = [SUBudgetCategoryBoard loadBoard];
        }
        self.categoryBoard.delegate = self;
    }
    
}

- (void)initUI {
    
    // 自定义收键盘按钮
    self.doneButton = [[UIImageView alloc] init];
    self.doneButton.frame = CGRectMake(6, (216 - (kScreenWidth > 375 ? 46 : 50)), 118*kScreenScale, 48*kScreenScale);
    self.doneButton.userInteractionEnabled = YES;
    self.doneButton.image = [UIImage imageNamed:@"hide"];
    self.doneButton.contentMode = UIViewContentModeCenter;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    
    // --------------------------------- 标题栏 ---------------------------------
    
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 44 + kStatusBarHeight)];
    titleView.backgroundColor = [UIColor whiteColor]; // [UIColor colorWithHexString:@"f9f9f9"];
    
//    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleRegular];
//    UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
//    effectView.frame = titleView.bounds;
//    effectView.alpha = 1.0;
//    [titleView addSubview:effectView];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightLight];
    titleLabel.textColor = kDarkTextColor;
    titleLabel.text = @"设置您的预算";
    [titleLabel sizeToFit];
    titleLabel.centerY = titleView.height - 32 + (kStatusBarHeight > 20) * 5;
    titleLabel.centerX = 0.5 * titleView.width;
    
    [titleView addSubview:titleLabel];
    
    
    // --------------------------------- Scroll View ---------------------------
    
    CGFloat scrollViewBottom = 50 + (kStatusBarHeight > 20) * 34;
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - scrollViewBottom)];
    scrollView.contentInset = UIEdgeInsetsMake(titleView.maxY, 0, 0, 0);
    if (@available(iOS 11.0, *)) {
        scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    scrollView.alwaysBounceVertical = YES;
    scrollView.delegate = self;
    scrollView.delaysContentTouches = NO;
    self.scrollView = scrollView;
    
    // --------------------------------- Header ---------------------------------
    
    // 周期lebel
    
    UILabel *cycleLabel = [UILabel labelWithFont:15 textColor:[UIColor colorWithHexString:@"666666"] textAlignment:NSTextAlignmentLeft frame:CGRectMake(16, 5, kScreenWidth, 36)];
    cycleLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
    cycleLabel.text = @"预算周期:";
    
    // 周期按钮
    
    UIView *segmentView = [[UIView alloc] initWithFrame:CGRectMake(16, cycleLabel.maxY, kScreenWidth - 32, 50)];
    segmentView.layer.cornerRadius = 4;
    segmentView.layer.masksToBounds = YES;
//    segmentView.layer.borderColor = (kLineColor).CGColor;
//    segmentView.layer.borderWidth = 0.5f;
    
    TypeButton *weeklyButton = [[TypeButton alloc] initWithFrame:CGRectMake(0, 0, 0.5 * segmentView.width, segmentView.height)];
    [weeklyButton setTitle:@"每周" forState: UIControlStateNormal];
    [weeklyButton addTarget:self action:@selector(chooseBudgetTypeAction:) forControlEvents:UIControlEventTouchDown];
    weeklyButton.selected = YES;
    weeklyButton.tag = 200;
    self.selectedTypeButton = weeklyButton;
    
    TypeButton *monthlyButton = [[TypeButton alloc] initWithFrame:CGRectMake(weeklyButton.maxX, 0, weeklyButton.width, weeklyButton.height)];
    [monthlyButton setTitle:@"每月" forState: UIControlStateNormal];
    [monthlyButton addTarget:self action:@selector(chooseBudgetTypeAction:) forControlEvents:UIControlEventTouchDown];
    monthlyButton.tag = 201;
    
    [segmentView addSubview:weeklyButton];
    [segmentView addSubview:monthlyButton];
    
    
    // 预算label
    
    UILabel *budgetLabel = [UILabel labelWithFont:15 textColor:[UIColor colorWithHexString:@"666666"] textAlignment:NSTextAlignmentLeft frame:CGRectMake(16, segmentView.maxY + 15, kScreenWidth, 36)];
    budgetLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
    budgetLabel.text = @"预算金额:";
    
    // 预算文本框
    
    SUTextField *budgetField = [[SUTextField alloc] initWithFrame:CGRectZero];
    budgetField.backgroundColor = kTitleViewColor; // [UIColor colorWithHexString:@"f1f1f1"];
//    budgetField.tintColor = kDarkTextColor;
    budgetField.textColor = kDarkTextColor;
    budgetField.font = [UIFont systemFontOfSize:20 weight:UIFontWeightLight];
    budgetField.textAlignment = NSTextAlignmentCenter;
    budgetField.keyboardType = UIKeyboardTypeNumberPad;
    budgetField.placeholder = @"¥0";
    //bug
//    [budgetField setValue:[UIColor grayColor] forKeyPath:@"_placeholderLabel.textColor"];
//    budgetField.keyboardAppearance = UIKeyboardAppearanceLight;
    budgetField.delegate = self;
    
//    budgetField.layer.borderColor = (kLineColor).CGColor;
//    budgetField.layer.borderWidth = 0.5f;
    budgetField.layer.cornerRadius = 4;
    budgetField.layer.masksToBounds = YES;
    
    // placeholder文字颜色
    self.budgetField = budgetField;
    
    budgetField.size = CGSizeMake(kScreenWidth - 32, 50);
    budgetField.x = 16;
    budgetField.y = budgetLabel.maxY;
    
    
    // 子预算label
    
    UILabel *subBudgetLabel = [UILabel labelWithFont:15 textColor:[UIColor colorWithHexString:@"666666"] textAlignment:NSTextAlignmentLeft frame:CGRectMake(16, budgetField.maxY + 15, kScreenWidth, 36)];
    subBudgetLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
    subBudgetLabel.text = @"子预算:";
    self.subBudgetLabel = budgetLabel;
    
    
    // ---------------------------------  tableView ---------------------------------
    
    UITableView *budgetsTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, subBudgetLabel.maxY, kScreenWidth, scrollView.height - subBudgetLabel.maxY) style:UITableViewStylePlain];
    [budgetsTableView registerClass:[SUSumBudgetCell class] forCellReuseIdentifier:kBudgetCellId];
    budgetsTableView.dataSource = self;
    budgetsTableView.delegate = self;
    budgetsTableView.backgroundColor = [UIColor clearColor];
    budgetsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    budgetsTableView.rowHeight = 50;
    budgetsTableView.showsVerticalScrollIndicator = NO;
    budgetsTableView.showsHorizontalScrollIndicator = NO;
    budgetsTableView.scrollEnabled = NO;
    budgetsTableView.clipsToBounds = NO;
    self.budgetsTableView = budgetsTableView;
    
    // 添加子预算按钮
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, budgetsTableView.width, 80)];
    
    UIButton *addButton = [[UIButton alloc] initWithFrame:CGRectMake(16, 10, budgetsTableView.width - 32, 50)];
    [addButton setTitle:@"添加子预算" forState:UIControlStateNormal];
    [addButton.titleLabel setFont:[UIFont systemFontOfSize:17 weight:UIFontWeightLight]];
    [addButton setTitleColor:kDarkTextColor forState:UIControlStateNormal];
    [addButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [addButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    [addButton setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
    [addButton setBackgroundImage:[UIImage imageWithHexString:@"fafafa"] forState:UIControlStateHighlighted];
    [addButton setBackgroundImage:[UIImage imageWithColor:kTitleViewColor] forState:UIControlStateDisabled];
    [addButton addTarget:self action:@selector(addButtonAction) forControlEvents:UIControlEventTouchUpInside];
    
    addButton.backgroundColor = self.view.backgroundColor;
    addButton.layer.borderColor = (kLineColor).CGColor;
    addButton.layer.borderWidth = 0.5f;
    addButton.layer.cornerRadius = 4.0f;
    addButton.layer.masksToBounds = YES;
    
    self.addButton = addButton;
    
    
    [footerView addSubview:addButton];
    
    budgetsTableView.tableFooterView = footerView;
    
    // ---------------------------------  下一步按钮 ---------------------------------
    
    UIButton *continueButton = [[UIButton alloc] initWithFrame:CGRectMake(0, kScreenHeight - scrollViewBottom, kScreenWidth, 50)];
    if (kStatusBarHeight > 20) {
        continueButton.width = kScreenWidth - 32;
        continueButton.x = 16;
    }
    [continueButton setBackgroundImage:[UIImage imageWithColor:kPurpleColor] forState:UIControlStateNormal];
    [continueButton setBackgroundImage:[UIImage imageWithHexString:@"7369e3"] forState:UIControlStateHighlighted];
    [continueButton setBackgroundImage:[UIImage imageWithHexString:@"948bfd"] forState:UIControlStateDisabled];
    [continueButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [continueButton setTitleColor:[UIColor colorWithWhite:1 alpha:0.8] forState:UIControlStateHighlighted];
    [continueButton setTitleColor:[UIColor colorWithWhite:1 alpha:0.8] forState:UIControlStateDisabled];
    [continueButton.titleLabel setFont:[UIFont systemFontOfSize:17 weight:UIFontWeightLight]];
    [continueButton setTitle:@"开始使用" forState:UIControlStateNormal];
    [continueButton addTarget:self action:@selector(continueButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    self.continueButton = continueButton;
    
    if (kStatusBarHeight > 20) {
        continueButton.layer.cornerRadius = 4.0f;
        continueButton.layer.masksToBounds = YES;
    }
    
    
    // 覆盖文本框的按钮
    UIButton *fieldButton = [[UIButton alloc] initWithFrame:self.budgetField.frame];
    [fieldButton addTarget:self action:@selector(fieldButtonAction) forControlEvents:UIControlEventTouchUpInside];
    
    
    [scrollView addSubview:budgetLabel];
    [scrollView addSubview:budgetField];
    [scrollView addSubview:fieldButton];
    [scrollView addSubview:cycleLabel];
    [scrollView addSubview:segmentView];
    [scrollView addSubview:subBudgetLabel];
    [scrollView addSubview:budgetsTableView];
    
    [self.view addSubview:scrollView];
    [self.view addSubview:titleView];
    [self.view addSubview:continueButton];
    
    
    // 测试
    
//    UIActivityIndicatorView *juhua = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
//    juhua.frame = CGRectMake(100, 560, 44, 44);
//    juhua.backgroundColor = [UIColor lightGrayColor];
//    [juhua startAnimating];
//    [self.view addSubview:juhua];
    
    
}

// 让addButton及时显示高亮效果


#pragma mark - 键盘监听

- (void)observeKeyboard {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardShowOnDelay) name:UIKeyboardWillShowNotification object:nil];
}

- (void)keyboardShowOnDelay {
    [self performSelector:@selector(keyboardWillShow) withObject:nil afterDelay:0];
}


/*
 类别面板也监听了键盘弹出，在调用完自身的监听方法后，会调用此方法及其他相关方法
 */
- (void)keyboardWillShow {
    
    UIView *foundKeyboard = nil;
    UIWindow *keyboardWindow = nil;
    for (UIWindow *testWindow in [[UIApplication sharedApplication] windows]) {
        
        /*
         iOS9以后，键盘window的最高层级由 UITextEffectsWindow 变为 UIRemoteKeyboardWindow
         */
        
        //        if (![[testWindow class] isEqual:[UIWindow class]]) {
        //            keyboardWindow = testWindow;
        //            break;
        //        }
        if ([[testWindow class] isEqual:NSClassFromString(@"UIRemoteKeyboardWindow")]) {
            keyboardWindow = testWindow;
            break;
        }
        
        
    }
    
    if (!keyboardWindow) return;
    for (__strong UIView *possibleKeyboard in [keyboardWindow subviews]) {
        if ([[possibleKeyboard description] hasPrefix:@"<UIInputSetContainerView"]) {
            for (__strong UIView *possibleKeyboard_2 in possibleKeyboard.subviews) {
                if ([possibleKeyboard_2.description hasPrefix:@"<UIInputSetHostView"]) {
                    foundKeyboard = possibleKeyboard_2;
                }
            }
        }
    }
    
    if (foundKeyboard) {
        if ([[foundKeyboard subviews] indexOfObject:self.doneButton] == NSNotFound) {
            [foundKeyboard addSubview:self.doneButton];
        } else {
            [foundKeyboard bringSubviewToFront:self.doneButton];
        }
        
        self.hideKeyboardGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboardClickDoneButton:)];
        self.hideKeyboardGesture.delegate = self;
        [foundKeyboard addGestureRecognizer:self.hideKeyboardGesture];
        
    }
    
}


- (void)hideKeyboard {
    [self.view endEditing:YES];
    [self.categoryBoard endEditing:YES];
}

- (void)hideKeyboardClickDoneButton:(UITapGestureRecognizer *)tap {
    
    CGPoint point = [tap locationInView:self.doneButton.superview];
    
    if (CGRectContainsPoint(CGRectMake(6, (216 - (kScreenWidth > 375 ? 46 : 50)), 118*kScreenScale, 48*kScreenScale), point)) {
        [self hideKeyboard];
    }
}

#pragma mark - 更新添加按钮标题

- (void)setupAddButtonWithLeftMoney:(NSInteger)left {
    
//    NSString *title = [NSString stringWithFormat:@"添加子预算 | 剩余¥%ld", left];
//    if (left == 0) {
//        title = @"添加子预算";
//    }
//    [self.addButton setTitle:title forState:UIControlStateNormal];
    
    self.addButton.enabled = left > 0;
    
}


#pragma mark - 按钮事件

- (void)dismissKeyboard {
    if ([self.budgetField isFirstResponder]) {
        [self.budgetField resignFirstResponder];
    }
}

// 添加子预算
- (void)addButtonAction {
    
    NSInteger sumOfSubBudgets = 0;
    for (SUSumBudgetItem *item in self.sumItems) {
        sumOfSubBudgets += item.sum;
    }
    
    if (sumOfSubBudgets >= self.totalBudget) {
        
        self.addButton.enabled = NO;
        
    }else {
        
        self.addButton.userInteractionEnabled = NO;
        __weak typeof(self) weakSelf = self;
        [self.categoryBoard showWithCompletion:^{
            weakSelf.addButton.userInteractionEnabled = YES;
        }];
        
    }
    
}

// 选中类别
- (void)chooseBudgetTypeAction:(UIButton *)sender {
    
    self.selectedTypeButton.selected = NO;
    sender.selected = YES;
    self.selectedTypeButton.userInteractionEnabled = YES;
    sender.userInteractionEnabled = NO;
    
    self.selectedTypeButton = sender;
    
    NSLog(@" -- %@", sender.currentTitle);
    
}

// 开始使用
- (void)continueButtonAction:(UIButton *)sender {
    

    NSString *dateString;
    int cycleType = 0;
    NSDateFormatter *formatter = [SUDateTool dateFormatterYMD];

    if (self.selectedTypeButton.tag == 200) { // 周
        dateString = [[SUDateTool dateTool] weekOfYearForDate:[NSDate date]];
        cycleType = 0;
    }else {
        formatter.dateFormat = @"yyyy-MM";
        dateString = [formatter stringFromDate:[NSDate date]];
        cycleType = 1;
    }

    SUSumBudgetItem *totalItem = [[SUSumBudgetItem alloc] init];
    totalItem.category = 0;
    totalItem.sum = self.totalBudget;

    [self.sumItems insertObject:totalItem atIndex:0];

    formatter.dateFormat = @"yyyy-MM-dd";

    for (SUSumBudgetItem *item in self.sumItems) {

        SUBudgetItem *budgetItem = [[SUBudgetItem alloc] init];
        budgetItem.cycleId = 21;
        budgetItem.sumExpense = 0;
        budgetItem.total = item.sum;
        budgetItem.date = dateString;
        budgetItem.dateString = [formatter stringFromDate:[NSDate date]];
        budgetItem.cycleType = cycleType;
        budgetItem.category = (int)item.category;

        [[SUDataBase sharedInstance] insertBudget:budgetItem];

    }

    [LifeCycleManager manager].cycleType = cycleType;

    [self.categoryBoard removeFromSuperview];
    self.categoryBoard = nil;

    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate switchRootController];
    
}

- (void)fieldButtonAction {
    if (![self.budgetField isFirstResponder]) {
        [self.budgetField becomeFirstResponder];
    }
}


#pragma mark - 类别面板代理

- (void)categoryBoardInputCompletion:(SUSumBudgetItem *)item {
    
    NSInteger sumOfSubBudgets = 0;
    BOOL alreadySetup = NO;
    
    for (SUSumBudgetItem *myItem in self.sumItems) {
        sumOfSubBudgets += myItem.sum;
        if (!alreadySetup && myItem.category == item.category) {
            alreadySetup = YES;
        }
        
    }
    
    if (sumOfSubBudgets + item.sum > self.totalBudget) {
        item.sum = self.totalBudget - sumOfSubBudgets;
    }
    
    if (item.sum != 0 && alreadySetup == NO) {
        
        [self.sumItems addObject:item];
        [self.budgetsTableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.sumItems.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationBottom];
        [self.budgetsTableView reloadData];
        
        sumOfSubBudgets += item.sum;
        [self setupAddButtonWithLeftMoney:self.totalBudget - sumOfSubBudgets];
        
        [UIView animateWithDuration:0.25 animations:^{
            if (self.scrollView.contentSize.height + self.scrollView.contentInset.top < self.scrollView.height) {
                self.scrollView.contentOffset = CGPointMake(0, -self.scrollView.contentInset.top);
            }else {
                self.scrollView.contentOffset = CGPointMake(0, self.scrollView.contentSize.height - self.scrollView.height);
            }
        }];
        
    }

}

#pragma mark - 文本框代理

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField.text == nil || [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length == 0) {
        textField.text = @"¥";
    }
    self.addButton.userInteractionEnabled = NO;
    self.budgetsTableView.userInteractionEnabled = NO;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    
    if (textField.text == nil || [textField.text isEqualToString:@"¥"] || [[textField.text substringFromIndex:1] integerValue] == 0) {
        self.totalBudget = 0;
        self.budgetField.text = nil;
    }else {
        NSString *numStr = [textField.text substringFromIndex:1];
        self.totalBudget = [numStr integerValue];
    }
    
    NSInteger sumOfItems = 0;
    for (SUSumBudgetItem *item in self.sumItems) {
        sumOfItems += item.sum;
    }
    
    if (self.totalBudget < sumOfItems) {
        self.totalBudget = sumOfItems;
        self.budgetField.text = [NSString stringWithFormat:@"¥%ld", (long)sumOfItems];
    }
    
    [self setupAddButtonWithLeftMoney: self.totalBudget - sumOfItems];
    
    self.continueButton.enabled = self.totalBudget != 0;
    
    
    self.addButton.userInteractionEnabled = YES;
    self.budgetsTableView.userInteractionEnabled = YES;
    
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if (textField.text.length == 8 && [@"0123456789" containsString:string]) {
        return NO;
    }
    
    if ([textField.text isEqualToString:@"¥"] && ![@"123456789" containsString:string]) {
        return NO;
    }
    
    if (range.location != textField.text.length) {
        
        NSLog(@"%@", textField.selectedTextRange);
        
        UITextPosition *position = [textField positionFromPosition:textField.selectedTextRange.start offset:textField.text.length - (range.location + range.length)];
        
        textField.selectedTextRange = [textField textRangeFromPosition:position toPosition:position];
        
        
    }
    
    NSString *text = [textField.text stringByReplacingCharactersInRange:range withString:string];
    self.addButton.enabled = text.length > 1;
    
    return YES;
    
}


#pragma mark -


//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//
//
//    NSLog(@"%@", tableView.gestureRecognizers);
//
//}

#pragma mark - tableView 左滑删除

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"删除";
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.sumItems removeObjectAtIndex:indexPath.row];
    [tableView beginUpdates];
    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [tableView endUpdates];
    if (indexPath.row > 0 && indexPath.row == self.sumItems.count) { // 不用-1，因为数据源已更新
        
        NSIndexPath *aboveIndexPath = [NSIndexPath indexPathForRow:indexPath.row - 1 inSection:indexPath.section];
        SUSumBudgetCell *aboveCell = [tableView cellForRowAtIndexPath:aboveIndexPath];
        aboveCell.line.hidden = YES;
        
    }
    
    NSInteger sumOfSubBudgets = 0;
    for (SUSumBudgetItem *myItem in self.sumItems) {
        sumOfSubBudgets += myItem.sum;
    }
    
    [self setupAddButtonWithLeftMoney:self.totalBudget - sumOfSubBudgets];
}



#pragma mark - tableView 数据源

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    tableView.height = 50 * self.sumItems.count + 80;
    [UIView animateWithDuration:0.25 animations:^{
        self.scrollView.contentSize = CGSizeMake(0, tableView.y + tableView.height);
    }];
    
    return self.sumItems.count;
}

- (SUSumBudgetCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    SUSumBudgetCell *cell = [tableView dequeueReusableCellWithIdentifier:kBudgetCellId];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor whiteColor];
//    cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageWithHexString:@"#eeeeee"]];
    cell.item = self.sumItems[indexPath.row];
    cell.line.hidden = indexPath.row == self.sumItems.count - 1;

    //  bug记录: 在这个方法里 应该使用 indexPathForRow 获取indexPath，因为 cellForRow 是刷新时调用，会获取到不相关的indexPath

    return cell;
}

#pragma mark - scroll view 代理

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([self.budgetField isFirstResponder]) {
        [self.budgetField resignFirstResponder];
    }
}

#pragma mark - tap手势代理

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    CGPoint point = [touch locationInView:self.doneButton.superview];
    if (!CGRectContainsPoint(CGRectMake(6, (216 - (kScreenWidth > 375 ? 46 : 50)), 118*kScreenScale, 48*kScreenScale), point)) {
        return NO;
    }
    return YES;
}


#pragma mark - lazy load

- (NSMutableArray *)sumItems {
    if (!_sumItems) {
        _sumItems = [NSMutableArray array];
    }
    return _sumItems;
}


#pragma mark -

- (BOOL)prefersStatusBarHidden {
    return kStatusBarHeight == 20;
}


@end


#pragma mark -


@implementation TypeButton

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    [self setTitleColor:kDarkTextColor forState:UIControlStateNormal];
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    self.backgroundColor = kTitleViewColor;
//    [self setBackgroundImage:[UIImage imageWithColor:kTitleViewColor] forState:UIControlStateNormal];
//    [self setBackgroundImage:[UIImage imageWithColor:kPurpleColor] forState:UIControlStateSelected];
//    [self setBackgroundImage:[UIImage imageWithColor:kPurpleColor] forState:UIControlStateHighlighted];
    [self.titleLabel setFont:[UIFont systemFontOfSize:17 weight:UIFontWeightLight]];
    return self;
}

- (void)setHighlighted:(BOOL)highlighted {}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    
    [UIView animateWithDuration:0.15 animations:^{
        self.backgroundColor = selected ? kPurpleColor : kTitleViewColor;
    }];
    
}

@end







