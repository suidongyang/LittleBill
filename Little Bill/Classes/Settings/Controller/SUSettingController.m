//
//  SUSettingController.m
//  Little Bill
//
//  Created by SU on 2017/9/21.
//  Copyright © 2017年 SU. All rights reserved.
//

#import "SUSettingController.h"
#import "UIViewController+Switch.h"

#import "SUBudgetSettingController.h"

#import "CHCSVParser.h"
#import "SUDataBase.h"

#import <MessageUI/MessageUI.h>
#import <StoreKit/StoreKit.h>
#import <Social/Social.h>


@interface SUSettingController () <UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate>

@property (strong, nonatomic) UIView *titleView;
@property (strong, nonatomic) UITableView *settingTableView;

@end


@implementation SUSettingController

static NSString * const kSettingCellId = @"kSettingCellId";
static NSString * const kICloudCellId = @"kICloudCellId";

const CGFloat kSettingCellHeight = 50.0f;


#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    // 标题栏
    
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 44 + kStatusBarHeight)];
    titleView.backgroundColor = [UIColor whiteColor];
    
//    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleRegular];
//    UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
//    effectView.frame = titleView.bounds;
//    effectView.alpha = 1.0;
//    [titleView addSubview:effectView];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.font = [UIFont systemFontOfSize:18];
    titleLabel.textColor = kDarkTextColor;
    titleLabel.text = @"设置";
    [titleLabel sizeToFit];
    titleLabel.centerX = 0.5 * titleView.width;
    titleLabel.centerY = titleView.height - 32 + (kStatusBarHeight > 20) * 5;
    
    [titleView addSubview:titleLabel];
    self.titleView = titleView;
    
    // 列表
    
    self.settingTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.settingTableView.backgroundColor = [UIColor clearColor];
    self.settingTableView.dataSource = self;
    self.settingTableView.delegate = self;
    self.settingTableView.rowHeight = kSettingCellHeight;
//    self.settingTableView.separatorColor = [UIColor colorWithWhite:0 alpha:0.1];
//    self.settingTableView.separatorInset = UIEdgeInsetsMake(0, 16, 0, 0);
    self.settingTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.settingTableView.contentInset = UIEdgeInsetsMake(self.titleView.maxY, 0, 0, 0);
    if (@available(iOS 11.0, *)) {
        self.settingTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    
    // Header 总资产
//    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 100)];
//    headerView.backgroundColor = kPurpleColor;
    
//    self.settingTableView.tableHeaderView = headerView;
    self.settingTableView.tableFooterView = [[UIView alloc] init];
    
    
    
    
    [self.view addSubview:self.settingTableView];
    [self.view addSubview:self.titleView];

    [self addSwitchIndicatorsWithTitles:@[@"账单", @""]];
    [self setTableViewInsetTop:self.titleView.maxY];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if ([LifeCycleManager manager].settingIsBusy) {
        [LifeCycleManager manager].settingIsBusy = NO;
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self backupSubviewFrames];
}


#pragma mark - 点击cell

// iCloud同步
- (void)iCloudSwitchAction:(UISwitch *)sender {
    
}

// 导出
- (void)exportCSVData {
    
    [LifeCycleManager manager].settingIsBusy = YES;
    
    // 生成CSV文件
    
    NSString *docPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *CSVFilePath = [docPath stringByAppendingPathComponent:@"小账单数据备份.csv"];
    
    NSLog(@"%@", CSVFilePath);
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:CSVFilePath]) {
        [fileManager removeItemAtPath:CSVFilePath error:nil];
    }
    
    CHCSVWriter *writer = [[CHCSVWriter alloc] initForWritingToCSVFile:CSVFilePath];
    
    [writer writeField:@"日期"];
    [writer writeField:@"类别"];
    [writer writeField:@"类型"];
    [writer writeField:@"金额"];
    [writer writeField:@"备注"];
    [writer finishLine];
    
    NSArray *allExpenses = [[SUDataBase sharedInstance] queryAllExpenses];
    
    for (NSDictionary *dict in allExpenses) {
        [writer writeLineWithDictionary:dict];
    }
    
    // 调起邮件程序
    
    if (![MFMailComposeViewController canSendMail]) {
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"无法发送邮件" message:@"请先设置您的系统邮箱账户" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
        
        [self presentViewController:alert animated:YES completion:nil];
        
        return;
    }
    
    MFMailComposeViewController *mailPicker = [[MFMailComposeViewController alloc] init];
    mailPicker.mailComposeDelegate = self;
    
    // 主题
    
    [mailPicker setSubject: @"小账单数据备份"];
    
    // 附件  关于mimeType：http://www.iana.org/assignments/media-types/index.html
    
    NSData *csvData = [NSData dataWithContentsOfFile:CSVFilePath];
    [mailPicker addAttachmentData: csvData mimeType: @"text/csv" fileName: @"小账单数据备份.csv"];
    
    // 正文
    
    NSString *emailBody = @"Keep it simple and elegant.<br><br>如果您打开附件中所包含的 CSV 文件时显示乱码，这可能是 Excel 的编码问题，请尝试以下方法修复：<br>1. 使用记事本打开 CSV 文件<br>2. 选择菜单“文件 – 另存为...”<br>3. 选择“编码为 ASCII”并保存<br>即可在 Excel 中正常使用。";
    [mailPicker setMessageBody:emailBody isHTML:YES];
    
    [self presentViewController:mailPicker animated:YES completion:nil];
    
}

// 预算设置
- (void)budgetConfigs {
    
    [LifeCycleManager manager].settingIsBusy = YES;
    SUBudgetSettingController *budgetSettings = [[SUBudgetSettingController alloc] init];
    budgetSettings.currentBudgets = self.currentBudgets;
    [self.navigationController pushViewController:budgetSettings animated:YES];
    
}

// 去评分
- (void)commentAction {
    
    // 仅支持iOS10.3+（需要做校验） 且每个APP内每年最多弹出3次评分alart
    if (@available(iOS 10.3, *)) {
        
        if ([SKStoreReviewController respondsToSelector:@selector(requestReview)]) {
            
            // 防止键盘遮挡
            [[UIApplication sharedApplication].keyWindow endEditing:YES];
            [SKStoreReviewController requestReview];
            
        }else {
            
            NSString *commentUrl = @"itms-apps://itunes.apple.com/app/id1333938354?action=write-review";
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:commentUrl]options:@{} completionHandler:nil];
        }
        
    }else {
        
        NSString *commentUrl = @"itms-apps://itunes.apple.com/app/id1333938354?action=write-review";
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:commentUrl]options:@{} completionHandler:nil];
    }
    
}

// 分享推荐
- (void)shareToFriends {
    
    [LifeCycleManager manager].settingIsBusy = YES;
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[[NSURL URLWithString:@"https://itunes.apple.com/cn/app/id1333938354"]] applicationActivities: nil];
    
    [self presentViewController:activityVC animated:YES completion:nil];
    
}

// 联系我
- (void)contactMe {
    
    [LifeCycleManager manager].settingIsBusy = YES;
    
    if (![MFMailComposeViewController canSendMail]) {
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"无法发送邮件" message:@"请先设置您的系统邮箱账户" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
        
        [self presentViewController:alert animated:YES completion:nil];
        
        return;
    }
    
    MFMailComposeViewController *mailPicker = [[MFMailComposeViewController alloc] init];
    mailPicker.mailComposeDelegate = self;
    [mailPicker setSubject: @"小账单问题反馈"];
    [mailPicker setToRecipients:@[@"18561365907@163.com"]];
    [mailPicker setMessageBody:@"请在这里写下您的问题：" isHTML:YES];
    
    [self presentViewController:mailPicker animated:YES completion:nil];
    
}

#pragma mark - 邮件代理

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Table View 代理

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0 && indexPath.row == 1) {
        
        // 导出
        [self exportCSVData];
        
    }else if (indexPath.section == 1 && indexPath.row == 0) {
        
        // 预算设置
        [self budgetConfigs];
        
    }else if (indexPath.section == 2 && indexPath.row == 0) {
        
        // 去评分
        [self commentAction];
        
    }else if (indexPath.section == 2 && indexPath.row == 1) {
        
        // 分享
        [self shareToFriends];
        
    }else if (indexPath.section == 2 && indexPath.row == 2) {
        
        // 联系我
        [self contactMe];
        
    }
    
}

#pragma mark - Table View 数据源

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 2;
    }else if (section == 1) {
        return 2;
    }else {
        return 3;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell;
    
    if (indexPath.section == 0 && indexPath.row == 0) {

        cell = [tableView dequeueReusableCellWithIdentifier:kICloudCellId];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kICloudCellId];
            
            UILabel *label = [UILabel labelWithFont:17 textColor:kDarkTextColor textAlignment:NSTextAlignmentLeft frame:CGRectMake(16, 0, 200, kSettingCellHeight)];
            label.tag = 200;
            
            UISwitch *syncSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 88, kSettingCellHeight)];
            syncSwitch.onTintColor = kPurpleColor;
            syncSwitch.centerY = 0.5 * kSettingCellHeight;
            syncSwitch.maxX = kScreenWidth - 10;
            [syncSwitch addTarget:self action:@selector(iCloudSwitchAction:) forControlEvents:UIControlEventValueChanged];
            syncSwitch.enabled = NO;
            
            [cell.contentView addSubview:label];
            [cell.contentView addSubview:syncSwitch];
            
            cell.backgroundColor = [UIColor whiteColor];
            cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageWithHexString:@"#f1f1f1"]];
            
        }

    }else {
        
        cell = [tableView dequeueReusableCellWithIdentifier:kSettingCellId];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kSettingCellId];
            
            UILabel *label = [UILabel labelWithFont:17 textColor:kDarkTextColor textAlignment:NSTextAlignmentLeft frame:CGRectMake(16, 0, 200, kSettingCellHeight)];
            label.tag = 200;
            
            UIImageView *arrowView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"arrow"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
            arrowView.tintColor = kLineColor;
            arrowView.centerY = 0.5 * kSettingCellHeight;
            arrowView.maxX = kScreenWidth - 15;
            
            [cell.contentView addSubview:label];
            [cell.contentView addSubview:arrowView];
            
            cell.backgroundColor = [UIColor whiteColor];
            cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageWithHexString:@"#f1f1f1"]];
            
        }
        
    }
    
    NSArray *titles = @[@[@"iCloud同步", @"导出"], @[@"预算", @"类别"], @[@"去评分", @"推荐给朋友", @"联系我"]];
    
    UILabel *titleLabel = [cell.contentView viewWithTag:200];
    titleLabel.text = titles[indexPath.section][indexPath.row];
    [titleLabel widthToFit];
    
    if ((indexPath.section == 0 && indexPath.row == 0) || (indexPath.section == 1 && indexPath.row == 1)) {
        
        UILabel *developingLabel = [cell.contentView viewWithTag:100];
        if (!developingLabel) {
            developingLabel = [UILabel labelWithFont:14 textColor:[UIColor colorWithHexString:@"807f96"] textAlignment:NSTextAlignmentLeft frame:CGRectMake(0, 0, 100, kSettingCellHeight)];
            developingLabel.text = @"敬请期待";
            developingLabel.x = titleLabel.maxX + 10;
            developingLabel.tag = 100;
            [cell.contentView addSubview:developingLabel];
        }

    }
    
    return cell;
    
}

#pragma mark - Header

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 38;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    NSArray *titles = @[@"数据", @"常规", @"其他"];
    UIView *headerView = [self subTitleViewWithTitle:titles[section]];
    return headerView;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[UIView alloc] init];
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


#pragma mark -


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self scrollWithScrollView:scrollView];
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    [self switchWithScrollView:scrollView];
}


@end















