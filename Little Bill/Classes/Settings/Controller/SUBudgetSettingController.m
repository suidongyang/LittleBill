//
//  SUBudgetSettingController.m
//  Little Bill
//
//  Created by SU on 2017/12/29.
//  Copyright © 2017年 SU. All rights reserved.
//

#import "SUBudgetSettingController.h"

#import "SUSumBudgetCell.h"
#import "SUBudgetCategoryBoard.h"
#import "EditingMaskView.h"

#import "SUBudgetItem.h"
#import "SUSumBudgetItem.h"

#import "SUDataBase.h"

@interface SUBudgetSettingController () <UITableViewDataSource, UITableViewDelegate, SUBudgetCategoryBoardProtocol, UITextFieldDelegate, UIGestureRecognizerDelegate>

@property (strong, nonatomic) UIView *titleView;
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UITableView *tableView;

@property (strong, nonatomic) UIButton *addButton;

@property (strong, nonatomic) UIButton *selectedTypeButton;

@property (strong, nonatomic) NSMutableArray<SUSumBudgetItem *> *sumItems;

@property (strong, nonatomic) UIImageView *doneButton;
@property (strong, nonatomic) UITapGestureRecognizer *hideKeyboardGesture;

@property (strong, nonatomic) SUBudgetCategoryBoard *categoryBoard;

@property (strong, nonatomic) NSIndexPath *editingIndexPath;

@property (strong, nonatomic) NSMutableArray<SUSumBudgetItem *> *addedItems;
@property (strong, nonatomic) NSMutableArray<SUSumBudgetItem *> *deletedItems;
@property (strong, nonatomic) NSMutableArray<SUSumBudgetItem *> *modifiedItems;

@property (strong, nonatomic) EditingMaskView *editingMaskView;

@property (assign, nonatomic) CGPoint originOffset;


@end


@implementation SUBudgetSettingController

static NSString *kBudgetSettingCellId = @"kBudgetSettingCellId";


- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
    [self observeKeyboard];
    
    self.addedItems = [NSMutableArray<SUSumBudgetItem *> array];
    self.deletedItems = [NSMutableArray<SUSumBudgetItem *> array];
    self.modifiedItems = [NSMutableArray<SUSumBudgetItem *> array];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    int cycleType = self.currentBudgets.firstObject.cycleType;
    UIButton *button = [self.view viewWithTag: 200 + cycleType];
    button.selected = YES;
    self.selectedTypeButton = button;
    
}

- (void)initUI {
    
    // 自定义收键盘按钮
    self.doneButton = [[UIImageView alloc] init];
    self.doneButton.frame = CGRectMake(6, (216 - (kScreenWidth > 375 ? 46 : 50)), 118*kScreenScale, 48*kScreenScale);
    self.doneButton.userInteractionEnabled = YES;
    self.doneButton.image = [UIImage imageNamed:@"hide"];
    self.doneButton.contentMode = UIViewContentModeCenter;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    // 标题栏
    
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 44 + kStatusBarHeight)];
    
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleRegular];
    UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    effectView.frame = titleView.bounds;
    effectView.alpha = 1.0;
    [titleView addSubview:effectView];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.font = [UIFont systemFontOfSize:18];
    titleLabel.textColor = kDarkTextColor;
    titleLabel.text = @"预算设置";
    [titleLabel sizeToFit];
    titleLabel.centerX = 0.5 * titleView.width;
    titleLabel.centerY = titleView.height - 32 + (kStatusBarHeight > 20) * 5;
    
    [titleView addSubview:titleLabel];
    
    
    // 返回
    
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    [backButton addTarget:self action:@selector(popToSettings) forControlEvents:UIControlEventTouchUpInside];
//    backButton.backgroundColor = klightTextColor;
    [backButton setImage:[UIImage imageNamed:@"backto"] forState:UIControlStateNormal];
    backButton.centerY = titleLabel.centerY;
    backButton.x = 5;
    
    [titleView addSubview:backButton];
    
    self.titleView = titleView;
    
    // Scroll View
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    scrollView.height = kScreenHeight - 50;
    scrollView.alwaysBounceVertical = YES;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.delaysContentTouches = NO;
    self.scrollView = scrollView;
    
//    scrollView.contentInset = UIEdgeInsetsMake(self.titleView.maxY, 0, 0, 0);
    if (@available(iOS 11.0, *)) {
        scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    
    // 预算周期
    
    UIView *budgetCycle = [self subTitleViewWithTitle:@"周期"];
    budgetCycle.y = titleView.height;
    
    // 周期按钮
    
    UIView *segmentView = [[UIView alloc] initWithFrame:CGRectMake(0, budgetCycle.maxY, kScreenWidth, 100.5)];
    
    BTypeButton *weeklyButton = [[BTypeButton alloc] initWithFrame:CGRectMake(0, 0, segmentView.width, 0.5 * segmentView.height)];
    [weeklyButton setTitle:@"每周" forState: UIControlStateNormal];
    [weeklyButton addTarget:self action:@selector(chooseBudgetTypeAction:) forControlEvents:UIControlEventTouchUpInside];
    weeklyButton.tag = 200;
    
    UIView *sline = [[UIView alloc] initWithFrame:CGRectMake(16, weeklyButton.maxY, kScreenWidth - 32, 0.5)];
    sline.backgroundColor = kLightGrayColor;
    
    BTypeButton *monthlyButton = [[BTypeButton alloc] initWithFrame:CGRectMake(0, sline.maxY, weeklyButton.width, weeklyButton.height)];
    [monthlyButton setTitle:@"每月" forState: UIControlStateNormal];
    [monthlyButton addTarget:self action:@selector(chooseBudgetTypeAction:) forControlEvents:UIControlEventTouchUpInside];
    monthlyButton.tag = 201;
    
    [segmentView addSubview:weeklyButton];
    [segmentView addSubview:sline];
    [segmentView addSubview:monthlyButton];
    
    
    // 预算编辑
    
    UIView *budgetTitleView = [self subTitleViewWithTitle:@"明细"];
    budgetTitleView.y = segmentView.maxY;
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, budgetTitleView.maxY, scrollView.width, kScreenWidth) style:UITableViewStylePlain];
    [self.tableView registerClass:[SUSumBudgetCell class] forCellReuseIdentifier:kBudgetSettingCellId];
    self.tableView.rowHeight = 50;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.scrollEnabled = NO;
    self.tableView.clipsToBounds = NO;
    
    // 添加按钮
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.width, 90)];
    
    UIButton *addButton = [[UIButton alloc] initWithFrame:CGRectMake(16, 10, self.tableView.width - 32, 50)];
    [addButton setTitle:@"添加子预算" forState:UIControlStateNormal];
    [addButton.titleLabel setFont:[UIFont systemFontOfSize:17 weight:UIFontWeightLight]];
    [addButton setTitleColor:kDarkTextColor forState:UIControlStateNormal];
    [addButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [addButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    [addButton setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
    [addButton setBackgroundImage:[UIImage imageWithHexString:@"fafafa"] forState:UIControlStateHighlighted];
    [addButton setBackgroundImage:[UIImage imageWithColor:kTitleViewColor] forState:UIControlStateDisabled];
    [addButton addTarget:self action:@selector(addButtonAction) forControlEvents:UIControlEventTouchUpInside];
    
    addButton.layer.borderColor = (kLineColor).CGColor;
    addButton.layer.borderWidth = 0.5f;
    addButton.layer.cornerRadius = 4.0f;
    addButton.layer.masksToBounds = YES;
    
    self.addButton = addButton;
    
    [footerView addSubview:addButton];
    
    self.tableView.tableFooterView = footerView;
    self.tableView.tableHeaderView = [[UIView alloc] init];
    
    // 保存按钮
    UIButton *continueButton = [[UIButton alloc] initWithFrame:CGRectMake(0, kScreenHeight - 50, kScreenWidth, 50)];
    if (kStatusBarHeight > 20) {
        continueButton.x = 20;
        continueButton.y -= 34;
        continueButton.width = kScreenWidth - 40;
        continueButton.layer.cornerRadius = 4.0f;
        continueButton.layer.masksToBounds = YES;
        
    }
    [continueButton setBackgroundImage:[UIImage imageWithColor:kPurpleColor] forState:UIControlStateNormal];
    [continueButton setBackgroundImage:[UIImage imageWithHexString:@"7369e3"] forState:UIControlStateHighlighted];
    [continueButton setBackgroundImage:[UIImage imageWithHexString:@"beb9fb"] forState:UIControlStateDisabled];
    [continueButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [continueButton setTitleColor:[UIColor colorWithWhite:1 alpha:0.8] forState:UIControlStateHighlighted];
    [continueButton setTitleColor:[UIColor colorWithWhite:1 alpha:0.8] forState:UIControlStateDisabled];
    [continueButton.titleLabel setFont:[UIFont systemFontOfSize:17 weight:UIFontWeightLight]];
    [continueButton setTitle:@"保存" forState:UIControlStateNormal];
    [continueButton addTarget:self action:@selector(saveButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    
    [scrollView addSubview:budgetCycle];
    [scrollView addSubview:segmentView];
    [scrollView addSubview:budgetTitleView];
    [scrollView addSubview:self.tableView];
    
    [self.view addSubview:scrollView];
    [self.view addSubview:self.titleView];
    [self.view addSubview:continueButton];
    
}

- (UIView *)subTitleViewWithTitle:(NSString *)title {
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 38)];
    view.backgroundColor = kBudgetBGColor; // [UIColor colorWithHexString:@"fafafa"];
    
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
    label.textColor = klightTextColor;
    label.text = title;
    [label sizeToFit];
    label.centerY = 0.5 * view.height;
    label.x = 16;
    
    [view addSubview:label];
    
    return view;
    
}


#pragma mark - 键盘监听

- (void)observeKeyboard {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardShowOnDelay:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardShowOnDelay:(NSNotification *)notify {
    [self performSelector:@selector(keyboardWillShow:) withObject:notify afterDelay:0];
}


/*
 类别面板也监听了键盘弹出，在调用完自身的监听方法后，会调用此方法及其他相关方法
 */
- (void)keyboardWillShow:(NSNotification *)notify {
        
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
    
    
    if (self.editingIndexPath == nil) return;
    
//    NSDictionary *dict = notify.userInfo;
    
    CGRect keyboardRect = [[notify.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyboardY = keyboardRect.origin.y;
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:self.editingIndexPath];
    __block CGRect cellRect = [self.tableView convertRect:cell.frame toView:self.view];
    CGFloat cellMaxY = cellRect.origin.y + cell.size.height;
    
    if (cellMaxY > keyboardY) {
        self.originOffset = self.scrollView.contentOffset;
        [UIView animateWithDuration:0.2 animations:^{
            self.scrollView.contentOffset = CGPointMake(0, self.originOffset.y + cellMaxY - keyboardY + 10);
        }completion:^(BOOL finished) {
            
            cellRect.origin.y += 0.5 - cellMaxY + keyboardY - 10;
            cellRect.size.height -= 1;
            
            self.editingMaskView = [EditingMaskView showWithFrame:CGRectMake(0, self.titleView.maxY, kScreenWidth, kScreenHeight - self.titleView.maxY - 50) clearRect:cellRect];
            
            [self.view addSubview:self.editingMaskView];
            
        }];
        
    }else {
        
        cellRect.origin.y += 0.5;
        cellRect.size.height -= 1;
        
        self.editingMaskView = [EditingMaskView showWithFrame:CGRectMake(0, self.titleView.maxY, kScreenWidth, kScreenHeight - self.titleView.maxY - 50) clearRect:cellRect];
        
        [self.view addSubview:self.editingMaskView];
    }
    
    
}

- (void)keyboardWillHide:(NSNotification *)notify {
    
    [UIView animateWithDuration:0.25 animations:^{
        self.editingMaskView.alpha = 0;
        if (self.editingIndexPath != nil && !CGPointEqualToPoint(self.scrollView.contentOffset, CGPointZero)) {
            self.editingMaskView.y += self.scrollView.contentOffset.y - self.originOffset.y;
            self.scrollView.contentOffset = self.originOffset;
        }
    }completion:^(BOOL finished) {
        self.editingMaskView.hidden = YES;
        [self.editingMaskView removeFromSuperview];
        self.originOffset = CGPointZero;
    }];
    
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

#pragma mark - 按钮事件

// 回到上一页
- (void)popToSettings {
    [self.navigationController popViewControllerAnimated:YES];
}

// 添加子预算
- (void)addButtonAction {
    
    NSInteger sumOfSubBudgets = 0;
    for (int i = 1; i < self.sumItems.count; i++) {
        sumOfSubBudgets += self.sumItems[i].sum;
    }
    
    if (sumOfSubBudgets < self.sumItems.firstObject.sum) {
        
        if (self.categoryBoard == nil) {
            
            UIWindow *window = [UIApplication sharedApplication].keyWindow;
            if ([window viewWithTag:kBudgetCateoryBoardTag]) {
                self.categoryBoard = [window viewWithTag:kBudgetCateoryBoardTag];
            }else {
                self.categoryBoard = [SUBudgetCategoryBoard loadBoard];
            }
            self.categoryBoard.delegate = self;
        }
        
        [self.categoryBoard show];
        
    }else {
        self.addButton.enabled = NO;
    }
    
}

// 选中类别
- (void)chooseBudgetTypeAction:(UIButton *)sender {
    
    [UIView animateWithDuration:0.3 animations:^{
        sender.backgroundColor = [UIColor whiteColor];
    }];
    
    self.selectedTypeButton.selected = NO;
    sender.selected = YES;
    self.selectedTypeButton.userInteractionEnabled = YES;
    sender.userInteractionEnabled = NO;
    
    self.selectedTypeButton = sender;
    
    NSLog(@" -- %@", sender.currentTitle);
    
}

// 保存

- (void)saveButtonAction:(UIButton *)sender {
    
    sender.userInteractionEnabled = NO;
    
    // 清理数组
    
    for (SUSumBudgetItem *item in self.deletedItems) {
        if ([self.addedItems containsObject:item]) {
            [self.addedItems removeObject:item];
        }
        if ([self.modifiedItems containsObject:item]) {
            [self.modifiedItems removeObject:item];
        }
    }
    
    for (SUSumBudgetItem *item in self.addedItems) {
        if ([self.modifiedItems containsObject:item]) {
            [self.modifiedItems removeObject:item];
        }
    }
    
    
    int modifiedCycleType = self.selectedTypeButton.tag == 200 ? 0 : 1;
    
    // 周期不变
    
    if (modifiedCycleType == self.currentBudgets.firstObject.cycleType) {
        
        // 删除
    
        NSMutableArray *deleteArray = [NSMutableArray array];
        
        for (SUSumBudgetItem *sumitem in self.deletedItems) {
            for (SUBudgetItem *budgetItem in self.currentBudgets) {
                if (budgetItem.category == sumitem.category) {
                    [deleteArray addObject:budgetItem];
                }
            }
        }
        
        for (SUBudgetItem *item in deleteArray) {
            [[SUDataBase sharedInstance] deleteBudget:item];
        }
        
        [self.currentBudgets removeObjectsInArray:deleteArray];
        
        // 修改
        
        for (SUSumBudgetItem *sumItem in self.modifiedItems) {
            
            for (SUBudgetItem *budgetItem in self.currentBudgets) {
                
                if (budgetItem.category == sumItem.category) {
                    budgetItem.total = sumItem.sum;
                    [[SUDataBase sharedInstance] updateBudget:budgetItem type:BudgetValueTypeTotal];
                    
                }
            }
            
        }
        
        // 添加
        
        SUBudgetItem *totalItem = self.currentBudgets.firstObject;
        
        for (SUSumBudgetItem *sumItem in self.addedItems) {
            
            SUBudgetItem *budgetItem = [[SUBudgetItem alloc] init];
            // budgetItem.uniqueId 入库时自动设置
            budgetItem.cycleId = totalItem.cycleId;
            budgetItem.sumExpense = [[SUDataBase sharedInstance] querySumExpenseForCategory:(int)sumItem.category date:totalItem.date cycleType:totalItem.cycleType];
            budgetItem.total = sumItem.sum;
            budgetItem.date = totalItem.date;
            budgetItem.dateString = totalItem.dateString;
            budgetItem.cycleType = totalItem.cycleType;
            budgetItem.category = (int)sumItem.category;
            
            [[SUDataBase sharedInstance] insertBudget:budgetItem];
            
            [self.currentBudgets addObject:budgetItem];
            
        }
        
    
    // 周期改变
        
    }else {
        
        int cycleId = [[SUDataBase sharedInstance] maxCycleId] + 1;
        
        NSString *dateString;
        
        NSDateFormatter *formatter = [SUDateTool dateFormatterYMD];
        formatter.dateFormat = @"yyyy-MM-dd";
        NSString *detailDateString = [formatter stringFromDate:[NSDate date]];
        
        if (modifiedCycleType == 0) {
            dateString = [[SUDateTool dateTool] weekOfYearForDate:[NSDate date]];
        }else if (modifiedCycleType == 1) {
            formatter.dateFormat = @"yyyy-MM";
            dateString = [formatter stringFromDate:[NSDate date]];
        }
        
        [self.currentBudgets removeAllObjects];
        
        for (SUSumBudgetItem *sumItem in self.sumItems) {
            
            SUBudgetItem *budgetItem = [[SUBudgetItem alloc] init];
            // budgetItem.uniqueId 入库时自动设置
            budgetItem.cycleId = cycleId;
            if (sumItem.category == 0) {
                budgetItem.sumExpense = [[SUDataBase sharedInstance] querySumExpenseForDate:dateString cycleType:modifiedCycleType];
            }else {
                budgetItem.sumExpense = [[SUDataBase sharedInstance] querySumExpenseForCategory:(int)sumItem.category date:dateString cycleType:modifiedCycleType];
            }
            budgetItem.total = sumItem.sum;
            budgetItem.date = dateString;
            budgetItem.dateString = detailDateString;
            budgetItem.cycleType = modifiedCycleType;
            budgetItem.category = (int)sumItem.category;
            
            [[SUDataBase sharedInstance] insertBudget:budgetItem];
            
            [self.currentBudgets addObject:budgetItem];
            
        }
        
        
        
    }
    
    [sender setTitle:@"保存成功" forState: UIControlStateNormal];
    
    self.view.userInteractionEnabled = NO;
    
    [LifeCycleManager manager].cycleType = modifiedCycleType;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"budgetM" object:nil];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        self.view.userInteractionEnabled = YES;
        [self.navigationController popViewControllerAnimated:YES];
        
    });
    
}

#pragma mark - 输入面板代理

- (void)categoryBoardInputCompletion:(SUSumBudgetItem *)item {
    
    NSInteger sumOfSubBudgets = 0;
    BOOL alreadySetup = NO;
    
    for (int i = 1; i < self.sumItems.count; i++) {
        sumOfSubBudgets += self.sumItems[i].sum;
        if (!alreadySetup && self.sumItems[i].category == item.category) {
            alreadySetup = YES;
        }
        
    }
    
    if (sumOfSubBudgets + item.sum > self.sumItems.firstObject.sum) {
        item.sum = self.sumItems.firstObject.sum - sumOfSubBudgets;
    }
    
    if (item.sum != 0 && alreadySetup == NO) {
        [self.sumItems addObject:item];
        [self.addedItems addObject:item];
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.sumItems.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationBottom];
        
        [UIView animateWithDuration:0.25 animations:^{
            if (self.scrollView.contentSize.height + self.scrollView.contentInset.top < self.scrollView.height) {
                self.scrollView.contentOffset = CGPointMake(0, -self.scrollView.contentInset.top);
            }else {
                self.scrollView.contentOffset = CGPointMake(0, self.scrollView.contentSize.height - self.scrollView.height);
            }
        }];
        
        self.addButton.enabled = sumOfSubBudgets + item.sum < self.sumItems.firstObject.sum;
        
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

#pragma mark - 文本框代理

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField.text == nil || [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length == 0) {
        textField.text = @"¥";
    }
    
//    self.tableView.userInteractionEnabled = NO;
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    
    if (![textField isKindOfClass:[SUTextField class]]) {
        
        SUSumBudgetItem *item = self.sumItems[self.editingIndexPath.row];
        
        NSInteger originSum = item.sum;
        
        // 修改后的金额
        NSString *sumStr = [textField.text substringFromIndex:1];
        NSInteger sum = [sumStr integerValue];
        
        // 修改总预算
        if (self.editingIndexPath.row == 0) {
            
            // 子预算的和
            NSInteger sumOfSubs = 0;
            for (int i = 1; i < self.sumItems.count; i++) {
                sumOfSubs += self.sumItems[i].sum;
            }
            
            if (sum < sumOfSubs) {
                sum = sumOfSubs;
            }
            
            if (sum == 0) {
                sum = originSum;
            }
            
            self.addButton.enabled = sum > sumOfSubs;
            
        // 修改子预算
        }else {
            
            NSInteger sumOfSubs = 0;
            for (int i = 1; i < self.sumItems.count; i++) {
                if (i == self.editingIndexPath.row) continue;
                sumOfSubs += self.sumItems[i].sum;
            }
            
            if (sum + sumOfSubs > self.sumItems.firstObject.sum) {
                sum = self.sumItems.firstObject.sum - sumOfSubs;
            }
            
            if (sum == 0) {
                sum = originSum;
            }
            
            self.addButton.enabled = self.sumItems.firstObject.sum > sum + sumOfSubs;
        }
        
        item.sum = sum;
        
        if (originSum != sum && ![self.modifiedItems containsObject:item]) {
            [self.modifiedItems addObject:item];
        }
        
        SUSumBudgetCell *cell = [self.tableView cellForRowAtIndexPath:self.editingIndexPath];
        cell.sumLabel.text = cell.numberField.text;
        cell.sumLabel.hidden = NO;
        cell.numberField.hidden = YES;
        cell.maskButton.hidden = YES;
        
        [self.tableView reloadRowsAtIndexPaths:@[self.editingIndexPath] withRowAnimation:UITableViewRowAnimationNone];
        
        
        
    }
    
    self.editingIndexPath = nil;
    
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

#pragma mark - 预算 删除

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return indexPath.row != 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"删除";
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    SUSumBudgetItem *item = self.sumItems[indexPath.row];
    [self.sumItems removeObject:item];
    [self.deletedItems addObject:item];
    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    
    if (indexPath.row > 0 && indexPath.row == self.sumItems.count) { // 不用-1，因为数据源已更新
        
        NSIndexPath *aboveIndexPath = [NSIndexPath indexPathForRow:indexPath.row - 1 inSection:indexPath.section];
        SUSumBudgetCell *aboveCell = [tableView cellForRowAtIndexPath:aboveIndexPath];
        aboveCell.line.hidden = YES;
        
    }
    
    self.addButton.enabled = YES;
    
}

#pragma mark - 预算 代理

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    SUSumBudgetCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.numberField.hidden = NO;
    cell.maskButton.hidden = NO;
    cell.numberField.delegate = self;
    cell.sumLabel.hidden = YES;
    [cell.numberField becomeFirstResponder];
    
    self.editingIndexPath = indexPath;
    
}



#pragma mark - 预算 数据源

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    tableView.height = 50 * self.sumItems.count + 80;
    [UIView animateWithDuration:0.25 animations:^{
        self.scrollView.contentSize = CGSizeMake(0, tableView.y + tableView.height);
    }];

    return self.sumItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    SUSumBudgetCell *cell = [tableView dequeueReusableCellWithIdentifier:kBudgetSettingCellId];
    cell.backgroundColor = [UIColor whiteColor];
    cell.item = self.sumItems[indexPath.row];
    cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageWithHexString:@"#f1f1f1"]];
    
    if (indexPath.row == self.sumItems.count - 1) {
        for (SUSumBudgetCell *visibleCell in tableView.visibleCells) {
            visibleCell.line.hidden = NO;
        }
    }
    
    if (indexPath.row == self.sumItems.count - 1) {
        cell.line.hidden = YES;
    }
    
    return cell;
    
}


#pragma mark - Setter

- (void)setCurrentBudgets:(NSMutableArray<SUBudgetItem *> *)currentBudgets {
    _currentBudgets = currentBudgets;
    
    self.sumItems = [NSMutableArray<SUSumBudgetItem *> array];
    
    for (SUBudgetItem *item in _currentBudgets) {
        
        SUSumBudgetItem *sumItem = [[SUSumBudgetItem alloc] init];
        sumItem.sum = item.total;
        sumItem.category = item.category;
        
        [self.sumItems addObject:sumItem];
    }
    
}



- (BOOL)prefersStatusBarHidden {
    return kStatusBarHeight == 20;
}







@end


#pragma mark -

@implementation BTypeButton

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    [self setTitleColor:kDarkTextColor forState:UIControlStateNormal];
    [self.titleLabel setFont:[UIFont systemFontOfSize:17 weight:UIFontWeightLight]];
    [self addTarget:self action:@selector(touchDownAction) forControlEvents:UIControlEventTouchDown];
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.titleLabel.x = 16;
    self.titleLabel.centerY = 0.5 * self.height;
    
    self.imageView.maxX = self.width - 18;
    self.imageView.centerY = 0.5 * self.height;
    
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    
    if (selected) {
        [self setImage:[UIImage imageNamed:@"select"] forState:UIControlStateNormal];
    }else {
        [self setImage:nil forState:UIControlStateNormal];
    }
    
}

- (void)touchDownAction {
    self.backgroundColor = [UIColor colorWithHexString:@"f1f1f1"];
}


@end














