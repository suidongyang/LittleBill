//
//  SUTextField.m
//  Little Bill
//
//  Created by SU on 2017/12/18.
//  Copyright © 2017年 SU. All rights reserved.
//

#import "SUTextField.h"

@implementation SUTextField

// 是否允许编辑操作
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    
//    if (action == @selector(paste:) || action == @selector(select:) || action == @selector(selectAll:)) {
//        return NO;
//    }
//    return [super canPerformAction:action withSender:sender];
    
    return NO;
    
}

// 调整光标高度
- (CGRect)caretRectForPosition:(UITextPosition *)position {

    CGRect originalRect = [super caretRectForPosition:position];
    
    originalRect.size.height = self.font.capHeight + 6;
    originalRect.origin.y = 0.5 * (self.height - originalRect.size.height);
    
    return originalRect;
    
}

@end
