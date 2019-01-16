//
//  SUCategoryPanel.h
//  Little Bill
//
//  Created by SU on 2017/10/16.
//  Copyright © 2017年 SU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SUNumberboard.h"

@protocol SUCategoryPanelDelegate <NSObject>

@optional
- (void)categoryPanelChooseCategory:(NSInteger)category;

@end


@interface SUCategoryPanel : UIView

@property (weak, nonatomic) id<SUCategoryPanelDelegate> delegate; // fakeCell

@property (strong, nonatomic) SUNumberboard *aNumberBoard;

- (void)showWithCategory:(NSInteger)categoryKey;
- (void)reset;

@end

