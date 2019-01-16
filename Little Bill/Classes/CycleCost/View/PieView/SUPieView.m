//
//  SUPieView.m
//  Little Bill
//
//  Created by SU on 2017/12/2.
//  Copyright © 2017年 SU. All rights reserved.
//

#import "SUPieView.h"

@interface SUPieView()

@property (strong, nonatomic) UIView *centerView;

@property (strong, nonatomic) NSArray *dataItems;
@property (strong, nonatomic) NSArray *colorItems;
@property (assign, nonatomic) CGFloat total;

@property (assign, nonatomic) BOOL shouldShowBlankPage;

@end


@implementation SUPieView

static const int kLabelTag = 2000;
static const int kTopLabelTag = 11;
static const int kBottomLabelTag = 12;


- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        [self initCenterView];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    
    CGFloat centerX = 0.5 * self.width;
    CGFloat centerY = 0.5 * self.height;
    CGPoint centerPoint = CGPointMake(centerX, centerY);
    CGFloat radiusBasic = centerX;
    CGFloat otherRadius = 0.5 * radiusBasic;
    
    UIBezierPath *otherPath = [UIBezierPath bezierPathWithArcCenter:centerPoint radius:otherRadius startAngle:-M_PI_2 endAngle:M_PI_2 * 3 clockwise:YES];
    
    CGFloat start = 0.0f;
    CGFloat end = 0.0f;
    
    for (int i = 0; i < self.dataItems.count; i++) {
        
        end = [self.dataItems[i] floatValue] / self.total + start;
        
        CAShapeLayer *pie = [CAShapeLayer layer];
        [self.layer addSublayer:pie];
        pie.fillColor = [UIColor clearColor].CGColor;
        pie.strokeColor = ((UIColor *)self.colorItems[i]).CGColor;
        pie.strokeStart = start;
        pie.strokeEnd   = end;
        pie.lineWidth   = otherRadius * 2.0f;
        pie.zPosition   = 2;
        pie.path        = otherPath.CGPath;
        
        
        CGFloat centerAngle = M_PI * (start + end);
        CGFloat labelCenterX = 2.3 * otherRadius * sinf(centerAngle) + centerX;
        CGFloat labelCenterY = -2.3 * otherRadius * cosf(centerAngle) + centerY;
        
        UILabel *label = [self viewWithTag:kLabelTag + i];
        if (![label isKindOfClass:[UILabel class]]) {
            label = nil;
        }
        if (label == nil) {
            label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 20)];
            label.textAlignment = NSTextAlignmentCenter;
            label.textColor = [UIColor colorWithWhite:0 alpha:0.6];
            label.font = [UIFont systemFontOfSize:15];
            label.layer.zPosition = 3;
            label.tag = kLabelTag + i;
            [self addSubview:label];
        }
        label.center = CGPointMake(labelCenterX, labelCenterY);
        
        long percentage = (long)((end - start + 0.005) * 100);
        label.text = [NSString stringWithFormat:@"%ld%%", percentage];
        label.hidden = percentage < 5 || self.shouldShowBlankPage;
        
        start = end;
        
    }
    
    [otherPath stroke];
    
}


- (void)strokeWithDataItems:(NSArray *)dataItems colorItems:(NSArray *)colorItems recordType:(NSInteger)type {
    
    if (!dataItems.count || !colorItems.count) {
        self.shouldShowBlankPage = YES;
        self.dataItems = @[@1];
        self.colorItems = @[[UIColor colorWithHexString:@"e1e0e3"]];
        
    }else {
        self.shouldShowBlankPage = NO;
        self.dataItems = dataItems;
        self.colorItems = colorItems;
    }
    
    for (UILabel *label in self.subviews) {
        if ([label isKindOfClass:[UILabel class]] && label.tag >= kLabelTag) {
            label.hidden = YES;
        }
    }
    
    NSMutableArray<CAShapeLayer *> *layerArr = [NSMutableArray array];
    for (CAShapeLayer *layer in self.layer.sublayers) {
        if ([layer isKindOfClass:[CAShapeLayer class]]) {
            [layerArr addObject:layer];
        }
    }
    [layerArr makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    
    self.total = 0.0f;
    for (int i = 0; i < self.dataItems.count; i++) {
        self.total += [self.dataItems[i] floatValue];
    }
    
    [self setNeedsDisplay];
    
    [self setupCenterViewWithTotal:self.total type:type];
    
}

#pragma mark -

- (void)setupCenterViewWithTotal:(CGFloat)total type:(NSInteger)type {
    
    UILabel *sumLabel = [self.centerView viewWithTag:kTopLabelTag];
    UILabel *typeLabel = [self.centerView viewWithTag:kBottomLabelTag];
    typeLabel.text = type ? @"— 收入 —" : @"— 开销 —";
    
    if (self.shouldShowBlankPage) {
        sumLabel.text = @"暂无数据";
        sumLabel.font = [UIFont systemFontOfSize:20 weight:UIFontWeightLight];
    }else {
        sumLabel.text = [NSString stringWithFormat:@"%.1f", total];
        if ([sumLabel.text hasSuffix:@".0"]) {
            sumLabel.text = [sumLabel.text substringToIndex:sumLabel.text.length - 2];
        }
        sumLabel.font = [UIFont systemFontOfSize:46 weight:UIFontWeightLight];
    }
    
    
    [sumLabel sizeToFit];
    sumLabel.width = self.centerView.width - 20;
    sumLabel.height = sumLabel.font.capHeight + 6;
    [typeLabel sizeToFit];
    
    sumLabel.centerX = typeLabel.centerX = 0.5 * self.centerView.width;
    sumLabel.y = 0.5 * (self.centerView.height - sumLabel.height - typeLabel.height - 7);
    typeLabel.y = sumLabel.maxY + 7;
    
}

- (void)initCenterView {
    
    UIView *centerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0.7 * self.height, 0.7 * self.height)];
    centerView.center = CGPointMake(0.5 * self.width, 0.5 * self.height);
    centerView.backgroundColor = kCycleCostColor; // [UIColor groupTableViewBackgroundColor];
    centerView.layer.cornerRadius = 0.5 * centerView.height;
    centerView.layer.masksToBounds = YES;
    centerView.layer.zPosition = 5;
    
    UILabel *topLabel = [[UILabel alloc] init];
    topLabel.font = [UIFont systemFontOfSize:46 weight:UIFontWeightLight];
    topLabel.textColor = [UIColor colorWithWhite:0 alpha:0.7];
    topLabel.textAlignment = NSTextAlignmentCenter;
    
    topLabel.adjustsFontSizeToFitWidth = YES;
    topLabel.minimumScaleFactor = 0.6;
    
    topLabel.tag = kTopLabelTag;
    
    UILabel *bottomLabel = [[UILabel alloc] init];
    bottomLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightLight];
    bottomLabel.textColor = [UIColor colorWithWhite:0 alpha:0.7];
    bottomLabel.textAlignment = NSTextAlignmentCenter;
    bottomLabel.tag = kBottomLabelTag;
    
    [centerView addSubview:topLabel];
    [centerView addSubview:bottomLabel];
    
    self.centerView = centerView;
    [self addSubview:centerView];
    
    
}


#pragma mark -

- (void)setFrameXOffset:(CGFloat)frameXOffset {
    _frameXOffset = frameXOffset;
    UILabel *topLabel = [self.centerView viewWithTag:kTopLabelTag];
    UILabel *bottomLabel = [self.centerView viewWithTag:kBottomLabelTag];
    topLabel.centerX = bottomLabel.centerX = 0.5 * self.centerView.width + frameXOffset;
}

- (void)setAnimateXOffset:(CGFloat)animateXOffset {
    _animateXOffset = animateXOffset;
    UILabel *topLabel = [self.centerView viewWithTag:kTopLabelTag];
    UILabel *bottomLabel = [self.centerView viewWithTag:kBottomLabelTag];
    topLabel.x += animateXOffset;
    bottomLabel.x += animateXOffset;
    
    bottomLabel.alpha = topLabel.alpha = 1 - fabs(topLabel.centerX - 0.5 * self.centerView.width) / 55;

    for (UILabel *label in self.subviews) {
        if (label.tag >= kLabelTag) {
            label.alpha = 1 - fabs(topLabel.centerX - 0.5 * self.centerView.width) / 40;
        }
    }
    
}


@end


