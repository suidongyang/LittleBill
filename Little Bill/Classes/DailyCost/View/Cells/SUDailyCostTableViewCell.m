//
//  SUDailyCostTableViewCell.m
//  Little Bill
//
//  Created by SU on 2017/9/24.
//  Copyright © 2017年 SU. All rights reserved.
//

#import "SUDailyCostTableViewCell.h"
#import "SUDailyCostModel.h"
#import "SUCategoryManager.h"

@interface SUDailyCostTableViewCell ()

@property (strong, nonatomic) UIImageView *iconView;
@property (strong, nonatomic) UILabel *detailLabel;
@property (strong, nonatomic) UILabel *remarkLabel;
@property (strong, nonatomic) UIImageView *flagView; // 不计入预算的提示条

@end

@implementation SUDailyCostTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (!self) return nil;
    [self initUI];
    [self addLongPressGesture];
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) return nil;
    [self initUI];
    return self;
}

#pragma mark -

- (void)initUI {
    
    self.backgroundColor = [UIColor whiteColor];
    
    self.iconView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, kCellHeight - 20, kCellHeight - 20)];
//    self.iconView.layer.cornerRadius = 0.5 * self.iconView.height;
//    self.iconView.layer.masksToBounds = YES;
    self.iconView.image = [UIImage imageWithHexString:@"#4a86e8"];
    
    self.remarkLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.iconView.maxX + 8, 0, 100, kCellHeight)];
    self.remarkLabel.centerY = self.iconView.centerY;
    self.remarkLabel.font = [UIFont systemFontOfSize:15];
    self.remarkLabel.textColor = [UIColor colorWithWhite:0 alpha:0.6];
    self.remarkLabel.textAlignment = NSTextAlignmentLeft;
    
    self.detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.iconView.maxX, 0, kScreenWidth - 20 - self.iconView.maxX - 10, kCellHeight)];
    self.detailLabel.font = [UIFont systemFontOfSize:24];
    self.detailLabel.textColor = [UIColor blackColor];
    self.detailLabel.textAlignment = NSTextAlignmentRight;
    
    self.flagView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 4, kCellHeight)];
    self.flagView.contentMode = UIViewContentModeScaleToFill;
    self.flagView.image = [UIImage imageWithHexString:@"cccccc"];
    
    [self.contentView addSubview:self.iconView];
    [self.contentView addSubview:self.remarkLabel];
    [self.contentView addSubview:self.detailLabel];
    [self.contentView addSubview:self.flagView];
//    [self addBottomLine];
    
}

- (void)addBottomLine {
    
    CAShapeLayer *lineLayer = [CAShapeLayer layer];
    lineLayer.frame = CGRectMake(10, kCellHeight - 2, kScreenWidth - 40, 2);
    lineLayer.fillColor = [UIColor clearColor].CGColor;
    lineLayer.strokeColor = [UIColor colorWithHexString:@"d0d0d0"].CGColor;
    lineLayer.lineJoin = kCALineJoinRound;
    lineLayer.lineWidth = 2;
    lineLayer.lineDashPattern = @[@(8), @(5)];
    
    UIBezierPath *linePath = [UIBezierPath bezierPath];
    [linePath moveToPoint:CGPointMake(0, 0)];
    [linePath addLineToPoint:CGPointMake(lineLayer.frame.size.width, 0)];
    
    lineLayer.path = linePath.CGPath;
    
    [self.contentView.layer addSublayer:lineLayer];
    
}

#pragma mark -

- (void)addLongPressGesture {
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAction:)];
    longPress.minimumPressDuration = 0.5;
    [self addGestureRecognizer:longPress];
    
}

- (void)longPressAction:(UILongPressGestureRecognizer *)gesture {
        
    if ([self.delegate respondsToSelector:@selector(dailyCostCell:draggingWithGesture:)]) {
        [self.delegate dailyCostCell:self draggingWithGesture:gesture];
    }
    
}

#pragma mark -

- (void)layoutLabels {
    
    [self.detailLabel widthToFit];
    self.detailLabel.maxX = kScreenWidth - 30;
    
    CGFloat maxWidth = self.detailLabel.x - self.remarkLabel.x - 10;
    
    [self.remarkLabel widthToFitWithMaxWidth:maxWidth];
    
}

#pragma mark -

- (void)setPayoutModel:(SUDailyCostModel *)payoutModel {
    _payoutModel = payoutModel;
    
    self.iconView.image = [[SUCategoryManager manager] imageForKey:payoutModel.category];
    
    if (payoutModel.remarks) {
        self.remarkLabel.text = payoutModel.remarks;
    }else {
        NSString *remarks = [[SUCategoryManager manager] titleForKey:payoutModel.category];
        self.remarkLabel.text = remarks;
    }
    
    NSString *costStr = [NSString stringWithFormat:@"%.1f", payoutModel.cost];
    if ([costStr hasSuffix:@".0"] && ![costStr isEqualToString:@"0.0"]) {
        costStr = [costStr substringToIndex:costStr.length - 2];
    }
    self.detailLabel.text = costStr;
    
    if (payoutModel.category > 30) {
        self.detailLabel.textColor = kIncomeTextColor;
    }else {
        self.detailLabel.textColor = [UIColor blackColor];
    }
    
    [self configFlagViewHidden:payoutModel.inBudget];
    
    [self layoutLabels];
    
}

- (void)configFlagViewHidden:(BOOL)setHidden {
    
    if (setHidden) {
        
        if (self.flagView.hidden == NO) {
            
            [UIView animateWithDuration:0.2 animations:^{
                self.flagView.x -= self.flagView.width;
            }completion:^(BOOL finished) {
                self.flagView.hidden = YES;
            }];
            
        }
        
    }else {
        
        if (self.flagView.hidden) {
            
            self.flagView.x = - self.flagView.width;
            self.flagView.hidden = NO;
            
            [UIView animateWithDuration:0.2 animations:^{
                self.flagView.x += self.flagView.width;
            }];
            
        }
        
    }
    
}



- (void)setCostString:(NSString *)costString {
    _costString = costString;
    
    self.detailLabel.text = costString;
    
}


@end
