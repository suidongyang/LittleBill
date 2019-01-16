//
//  ConstDefine.h
//  Little Bill
//
//  Created by SU on 2017/9/25.
//  Copyright © 2017年 SU. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifdef DEBUG
#define NSLog(...) NSLog(__VA_ARGS__)
#else
#define NSLog(...)
#endif

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#define kScreenScale ([UIScreen mainScreen].bounds.size.width / 375.0)

#define kStatusBarHeight (kScreenHeight == 812 ? 44 : 20)

#define kBudgetViewHeight 90.0f
#define kDateCostViewHeight 36.0f

#define kThemeColor [UIColor colorWithHexString: @"808ed6"] //@"8293ca"]
#define kIncomeTextColor [UIColor colorWithHexString:@"1F6D5F"]

// 灰色 递浅
#define kDarkTextColor  [UIColor colorWithHexString:@"333333"]
#define klightTextColor [UIColor colorWithHexString: @"909090"] //@"9f9f9f"]
#define kBorderColor    [UIColor colorWithHexString: @"9f9f9f"] //@"cccccc"]
#define kLineColor      [UIColor colorWithHexString:@"d9d9d9"]
#define kLightGrayColor [UIColor colorWithHexString:@"f1f1f1"]
#define kTitleViewColor [UIColor colorWithHexString:@"f7f7f7"]

#define kCycleCostColor [UIColor colorWithHexString:@"f7f8fd"] //@"f1f1f9"]

#define kBudgetBGColor  [UIColor colorWithHexString:@"f7f8fd"]

// 紫色
#define kPurpleColor [UIColor colorWithHexString:@"7e73ff"]





//#define kGuideButtonColor [UIColor colorWithHexString:@"88b04b"]

UIKIT_EXTERN NSString * const kGuidePageLoadedKey;

UIKIT_EXTERN CGFloat const kCellHeight;
UIKIT_EXTERN CGFloat const kViewMargin;
UIKIT_EXTERN CGFloat const kViewMargin_dailyCost;

UIKIT_EXTERN CGFloat const kBaseTag;

UIKIT_EXTERN NSString * const kNumberBoardCancelNotification;
UIKIT_EXTERN NSString * const kNumberBoardConfirmNotification;

UIKIT_EXTERN NSString * const kInputBoardCancelNotification;
UIKIT_EXTERN NSString * const kInputBoardCompleteNotification;

UIKIT_EXTERN NSString * const kUpdateStstisticDataSourceNotification;

UIKIT_EXTERN NSString * const kNeedInsertNewBudgetNotification;
