//
//  SUNumberboard.h
//  Little Bill
//
//  Created by SU on 2017/12/26.
//  Copyright © 2017年 SU. All rights reserved.
//

#import <UIKit/UIKit.h>

// 选中类别或添加了备注，通知键盘显示对号按钮
#define kSwitchToConfirmNotification @"kSwitchToConfirmNotification"

@protocol SUNumberBoardDelegate <NSObject>

@optional
- (void)numberBoardDidTypedCharacter:(NSString *)word;

@end

@interface SUNumberboard : UIView

@property (weak, nonatomic) id<SUNumberBoardDelegate> delegate;

+ (SUNumberboard *)loadNumberBoard;

@end
