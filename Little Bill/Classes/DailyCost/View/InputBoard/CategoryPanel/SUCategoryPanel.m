//
//  SUCategoryPanel.m
//  Little Bill
//
//  Created by SU on 2017/10/16.
//  Copyright © 2017年 SU. All rights reserved.
//

#import "SUCategoryPanel.h"
#import "CategoryButton.h"
#import "SUCategoryManager.h"

@interface SUCategoryPanel () <UIScrollViewDelegate>

@property (strong, nonatomic) UIScrollView *categoryView;

@property (assign, nonatomic) CGFloat panelOriginY; // 面板的原始Y值
@property (assign, nonatomic) CGFloat offsetY; // 类别视图每次滚动前的OffestY

@property (strong, nonatomic) CategoryButton *selectedButton;
@property (strong, nonatomic) UIView *separator;

@property (assign, nonatomic) CGPoint prevCenter; // 拖动中按钮拖动前的center

@property (assign, nonatomic, getter=isSorting) BOOL sorting;

@property (strong, nonatomic) UIButton *saveButton;
@property (strong, nonatomic) UIButton *cancelButton;

@end


@implementation SUCategoryPanel

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) return nil;
    
    self.panelOriginY = frame.origin.y;
    [self initUI];
    
    return self;
}

- (void)initUI {
    
    UIScrollView *categoryview = [[UIScrollView alloc] initWithFrame:self.bounds];
    categoryview.backgroundColor = [UIColor groupTableViewBackgroundColor];
    categoryview.alwaysBounceVertical = YES;
    categoryview.showsVerticalScrollIndicator = NO;
    categoryview.showsHorizontalScrollIndicator = NO;
    categoryview.delegate = self;
    self.categoryView = categoryview;
    
    CGFloat yMargin = 8;
    CGFloat margin = 8;
    CGFloat itemWidth = (kScreenWidth - margin * 6) / 5.0;
    CGFloat itemHeight = itemWidth * 1.1;
    
    // 类别按钮
    
    NSArray<SUCategoryItem *> *categories = [[SUCategoryManager manager] categoriesInUse];
    
    for (int i = 0; i < categories.count; i++) {
        
        CGFloat X = margin + i % 5 * (margin + itemWidth);
        CGFloat Y = yMargin + i / 5 * (margin + itemHeight);
        
        CategoryButton *button = [[CategoryButton alloc] initWithFrame:CGRectMake(X, Y, itemWidth, itemHeight)];
        
        [button setTitle:categories[i].title forState: UIControlStateNormal];
        UIImage *selectedImage = [[SUCategoryManager manager] imageForKey:categories[i].key];
        UIImage *normalImage = [[SUCategoryManager manager] normalImageForKey:categories[i].key];
        [button setImage:normalImage forState:UIControlStateNormal];
        [button setImage:selectedImage forState:UIControlStateSelected];
        
        button.categoryKey = categories[i].key;
        
        button.tag = i + 10000;
        
        [button addTarget:self action:@selector(chooseCategoryAction:) forControlEvents:UIControlEventTouchUpInside];
        
        
        UILongPressGestureRecognizer *pressGes = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPreessAction:)];
        pressGes.minimumPressDuration = 0.3;
        [button addGestureRecognizer:pressGes];
        
        [self.categoryView addSubview:button];
        
        if (i < categories.count - 1 && categories[i + 1].group == 1 && self.separator == nil) {
            
            self.separator = [self createSeparator];
            self.separator.tag = 11;
            self.separator.origin = CGPointMake(20, button.maxY + 20);
            [self.categoryView addSubview:self.separator];
            yMargin = 50;
            
        }
        
        self.categoryView.contentSize = CGSizeMake(0, button.maxY + 20);
        
    }
    
    // 自定义键盘
    
    self.aNumberBoard = [SUNumberboard loadNumberBoard];
    self.aNumberBoard.origin = CGPointMake(0, self.height - self.aNumberBoard.height);
    
    // 编辑完成按钮
    
    UIButton *saveButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.width, kCellHeight)];
    [saveButton setBackgroundImage:[UIImage imageWithColor:kPurpleColor] forState:UIControlStateNormal];
    [saveButton setBackgroundImage:[UIImage imageWithHexString:@"7369e3"] forState:UIControlStateHighlighted];
    [saveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [saveButton setTitleColor:[UIColor colorWithWhite:1 alpha:0.8] forState:UIControlStateHighlighted];
    [saveButton.titleLabel setFont:[UIFont systemFontOfSize:17 weight:UIFontWeightLight]];
    [saveButton setTitle:@"保存" forState:UIControlStateNormal];
    [saveButton addTarget:self action:@selector(sortCompletion:) forControlEvents:UIControlEventTouchUpInside];
    saveButton.hidden = YES;
    self.saveButton = saveButton;

    UIButton *cancelButton = [[UIButton alloc] initWithFrame:saveButton.frame];
    cancelButton.x = saveButton.maxX;
    [cancelButton setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
    [cancelButton setBackgroundImage:[UIImage imageWithColor:kLightGrayColor] forState:UIControlStateHighlighted];
    [cancelButton setTitleColor:kDarkTextColor forState:UIControlStateNormal];
    [cancelButton setTitleColor:[UIColor colorWithHexString:@"333333" alpha:0.8] forState:UIControlStateHighlighted];
    [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [cancelButton.titleLabel setFont:[UIFont systemFontOfSize:17 weight:UIFontWeightLight]];
    [cancelButton addTarget:self action:@selector(sortCancelAction:) forControlEvents:UIControlEventTouchUpInside];
    cancelButton.hidden = YES;
    self.cancelButton = cancelButton;
    
    
    
//    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, saveButton.height - 1, kScreenWidth, 1)];
//    line.backgroundColor = [UIColor colorWithWhite:0 alpha:0.1];
//    [saveButton addSubview:line];
    
    
    
    //
    
    [self addSubview:self.cancelButton];
    [self addSubview:self.saveButton];
    [self addSubview:self.categoryView];
    [self addSubview:self.aNumberBoard];
    
    
}

- (UIView *)createSeparator {
    
    UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth - 40, 20)];
    
    UIView *lline = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 1)];
    UIView *rline = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 1)];
    lline.backgroundColor = rline.backgroundColor = [UIColor lightGrayColor];
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont systemFontOfSize:13];
    label.textColor = [UIColor grayColor];
    label.text = @"收入";
    
    [label sizeToFit];
    label.center = CGPointMake(0.5 * separator.width, 0.5 * separator.height);
    
    lline.width = rline.width = 0.5 * (separator.width - label.width - 20);
    lline.centerY = rline.centerY = label.centerY;
    lline.x = 0;
    rline.maxX = separator.width;
    
    [separator addSubview:lline];
    [separator addSubview:label];
    [separator addSubview:rline];
    
    return separator;
}

- (void)showWithCategory:(NSInteger)categoryKey {
    
    for (CategoryButton *btn in self.categoryView.subviews) {
        if ([btn isEqual:self.separator]) continue;
        
        if (categoryKey == btn.categoryKey) {
            [self.selectedButton setChoosed:NO color:nil];
            [btn setChoosed:YES color:[UIColor colorWithHexString:@"d5ccf6"]];
            self.selectedButton = btn;
            break;
        }
    }
    
}

- (void)reset {
    
    [self.selectedButton setChoosed:NO color:nil];
    self.selectedButton = nil;
    
    [self.categoryView setContentOffset:CGPointZero];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"showCancel" object:nil];
    
}

#pragma mark - 按钮事件

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *view = [super hitTest:point withEvent:event];
    
    if (view == nil) {
        for (UIView *subView in self.subviews) {
            CGPoint tp = [subView convertPoint:point fromView:self];
            if (CGRectContainsPoint(subView.bounds, tp)) {
                view = subView;
            }
        }
    }
    return view;
    
}

- (void)sortCompletion:(UIButton *)sender {
    
    // 保存排序结果
    
    NSMutableArray *subviewArray = [NSMutableArray arrayWithArray:self.categoryView.subviews];
    NSArray *cArray = [[SUCategoryManager manager] categoriesInUse];
    
    NSMutableArray *keyArray = [NSMutableArray array];
    NSMutableArray *resultArray = [NSMutableArray array];
    
    [subviewArray sortUsingComparator:^NSComparisonResult(UIView * _Nonnull obj1, UIView * _Nonnull obj2) {
        return [@(obj1.tag) compare:@(obj2.tag)];
    }];
    
    for (CategoryButton *btn in subviewArray) {
        if (![btn isKindOfClass:[CategoryButton class]]) continue;
        [keyArray addObject:@(btn.categoryKey)];
    }
    
    for (NSNumber *keyNumber in keyArray) {
        
        for (SUCategoryItem *item in cArray) {
            if (item.key == [keyNumber integerValue]) {
                
                NSDictionary *itemDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                          [NSString stringWithFormat:@"%ld", item.key], @"key",
                                          item.title, @"title",
                                          item.imageName, @"img",
                                          item.colorString, @"color",
                                          [NSString stringWithFormat:@"%ld", item.group], @"group",
                                          nil
                                          ];
                
                [resultArray addObject:itemDict];
                break;
            }
        }
    }

    // 写入plist  在真机上运行时，只有代码创建的plist才能写入
    
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSString *plistPath = [path stringByAppendingPathComponent:@"editedCategories.plist" ];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
        NSError *error;
        [[NSFileManager defaultManager] removeItemAtPath:plistPath error:&error];
        
        NSLog(@"haha");
    }
    [resultArray writeToFile:plistPath atomically:YES];
    
    
    [self.selectedButton setChoosed:YES color:[UIColor colorWithHexString:@"d5ccf6"]];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [UIView animateWithDuration:0.2 animations:^{
            self.saveButton.y += kCellHeight;
            self.cancelButton.y += kCellHeight;
            self.aNumberBoard.y = self.height - self.aNumberBoard.height;
            self.categoryView.contentOffset = CGPointZero;
        }completion:^(BOOL finished) {
            self.saveButton.hidden = YES;
            self.cancelButton.hidden = YES;
            self.sorting = NO;
        }];
        
    });
    
    
}

- (void)sortCancelAction:(UIButton *)sender {
    
    // 仅不入库
    
    [self.selectedButton setChoosed:YES color:[UIColor colorWithHexString:@"d5ccf6"]];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [UIView animateWithDuration:0.2 animations:^{
            self.saveButton.y += kCellHeight;
            self.cancelButton.y += kCellHeight;
            self.aNumberBoard.y = self.height - self.aNumberBoard.height;
            self.categoryView.contentOffset = CGPointZero;
        }completion:^(BOOL finished) {
            self.saveButton.hidden = YES;
            self.cancelButton.hidden = YES;
            self.sorting = NO;
        }];
        
    });
    
}


- (void)chooseCategoryAction:(CategoryButton *)sender {
    
    if (self.isSorting) return;
    
    [self.selectedButton setChoosed:NO color:nil];
    [sender setChoosed:YES color:[UIColor colorWithHexString:@"d5ccf6"]];
    self.selectedButton = sender;
    
    [UIView animateWithDuration:0.15 animations:^{
        self.aNumberBoard.y = self.height - self.aNumberBoard.height;
    }];
    
    //
    if ([self.delegate respondsToSelector:@selector(categoryPanelChooseCategory:)]) {
        [self.delegate categoryPanelChooseCategory:sender.categoryKey];
    }
    
}

#pragma mark - 长按排序

- (void)longPreessAction:(UILongPressGestureRecognizer *)ges {
    
    CategoryButton *button = (CategoryButton *)ges.view;
    
    switch (ges.state) {
            
        case UIGestureRecognizerStateBegan:
        {
            if (self.isSorting == NO) {
                
                self.sorting = YES;
                
                self.saveButton.y = self.categoryView.y;
                self.cancelButton.y = self.categoryView.y;
                self.saveButton.hidden = NO;
                self.cancelButton.hidden = NO;
                
                [self.selectedButton setChoosed:NO color:nil];
                
                [UIView animateWithDuration:0.2 animations:^{
                    self.aNumberBoard.y = self.height;
                    self.saveButton.y -= kCellHeight;
                    self.cancelButton.y -= kCellHeight;
                }];
            }
            
            [self.categoryView bringSubviewToFront:button];
            
            self.prevCenter = button.center;
            [UIView animateWithDuration:0.2 animations:^{
                button.transform = CGAffineTransformMakeScale(1.1, 1.1);
                CGPoint location = [ges locationInView:self.categoryView];
                button.center = CGPointMake(location.x, location.y - 44);
            }];
            break;
        }
            
        case UIGestureRecognizerStateChanged:
        {
            CGPoint location = [ges locationInView:self.categoryView];
            button.center = CGPointMake(location.x, location.y - 44);
            
            for (CategoryButton *otherButton in self.categoryView.subviews) {
                if (![otherButton isKindOfClass:[CategoryButton class]]) continue;
                if ((otherButton.categoryKey <= 30 && button.categoryKey > 30) || (otherButton.categoryKey > 30 && button.categoryKey <= 30)) continue;
 
                if (CGRectContainsPoint(otherButton.frame, location)) {
                    
                    if (otherButton.tag < button.tag) {
                        
                        int tag = (int)button.tag;
                        while (tag > otherButton.tag) {
                            tag--;
                            UIView *prevView = [self.categoryView viewWithTag:tag];
                            CGPoint center = prevView.center;
                            
                            [UIView animateWithDuration:0.3 animations:^{
                                prevView.center = self.prevCenter;
                            }];
                            self.prevCenter = center;
                            prevView.tag++;
                        }
                        button.tag = otherButton.tag - 1;
                    }
                    
                    else if (otherButton.tag > button.tag) {
                        
                        int tag = (int)button.tag;
                        while (tag < otherButton.tag) {
                            tag++;
                            UIView *nextView = [self.categoryView viewWithTag:tag];
                            CGPoint center = nextView.center;
                            
                            [UIView animateWithDuration:0.3 animations:^{
                                nextView.center = self.prevCenter;
                            }];
                            self.prevCenter = center;
                            nextView.tag--;
                        }
                        button.tag = otherButton.tag + 1;
                    }
                }
            }
            
            break;
        }
            
        default:
        {
            [UIView animateWithDuration:0.2 animations:^{
                button.transform = CGAffineTransformIdentity;
                button.center = self.prevCenter;
                [button layoutSubviews];
            }];
            break;
        }
    }
    
}

#pragma mark - scrollView 代理


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.isSorting) return;
    
    if ((scrollView.contentOffset.y > scrollView.contentSize.height - scrollView.height) && (self.aNumberBoard.y == self.height - self.aNumberBoard.height)) {
        
        [UIView animateWithDuration:0.15 animations:^{
            self.aNumberBoard.y = self.height;
        }];
        
    }
    
    // 问题：按钮数量不超出屏幕时，下拉没有弹出键盘，上拉时键盘会闪现一下
    
    if (!scrollView.dragging ||
        (scrollView.contentOffset.y < 0) ||
        (scrollView.contentSize.height > scrollView.height && scrollView.contentOffset.y > scrollView.contentSize.height - scrollView.height)) {
        
        return;
    }
    
    if (scrollView.contentOffset.y > self.offsetY) {

        [UIView animateWithDuration:0.15 animations:^{
            self.aNumberBoard.y = self.height;
        }];

    }
    else if (scrollView.contentOffset.y < self.offsetY) {

        [UIView animateWithDuration:0.15 animations:^{
            self.aNumberBoard.y = self.height - self.aNumberBoard.height;
        }];

    }

    self.offsetY = scrollView.contentOffset.y;

}



@end






