//
//  EditingMaskView.h
//  Little Bill
//
//  Created by SU on 2017/12/30.
//  Copyright © 2017年 SU. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditingMaskView : UIView

+ (EditingMaskView *)showWithFrame:(CGRect)frame clearRect:(CGRect)clearRect;
- (void)dismiss;

@end
