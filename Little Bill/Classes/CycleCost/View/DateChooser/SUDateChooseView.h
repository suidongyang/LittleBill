//
//  SUDateChooseView.h
//  Little Bill
//
//  Created by SU on 2017/9/24.
//  Copyright © 2017年 SU. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, DateCircleType) {
    DateCircleTypeWeek = 0,
    DateCircleTypeMonth = 1,
    DateCircleTypeYear = 2,
};


@protocol SUDateChooseViewDelegate <NSObject>

@optional

// 点击按钮 切换周月年的回调
- (void)dateChooseViewChangeDateCircle:(DateCircleType)circleType;
// 点击返回按钮
- (void)dateChooseViewBackAction:(DateCircleType)circleType;

@end



@interface SUDateChooseView : UIView

@property (weak, nonatomic) id<SUDateChooseViewDelegate> delegate;

@property (assign, nonatomic) DateCircleType circleType;

+ (SUDateChooseView *)loadDateChooseView;

// 切换前后周期: 0-前 1-后
- (void)changeCircle:(NSInteger)next;


@end




@interface DateShiftButton : UIButton

@end





