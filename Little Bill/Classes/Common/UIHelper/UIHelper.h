//
//  UIHelper.h
//  JSONKitDemo
//
//  Created by apple on 14-4-17.
//  Copyright (c) 2014年 ___A-EYE___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>


@interface UIHelper : NSObject

+ (void)animationWithDuration:(CGFloat)duration actions:(void(^)(void))actions;
+ (void)animationWithDuration:(CGFloat)duration delegate:(id)delegate actions:(void (^)(void))actions completion:(SEL)completionSelector;


@end


@interface UIColor (Additions)

+ (UIColor *)colorWithHexString:(NSString *)hexString;
+ (UIColor *)colorWithHexString:(NSString *)hexString alpha:(CGFloat)alpha;
- (UIColor *)colorWithBrightness:(CGFloat)brightnessComponent;
+ (UIColor *)randomColor;

@end


@interface UIImage (Additions)

+ (UIImage *)imageWithHexString:(NSString *)hexString;
+ (UIImage *)imageWithColor:(UIColor *)color;

@end


@interface UILabel (Additions)

+ (UILabel *)labelWithFont:(CGFloat)fontSize textColor:(id)color textAlignment:(NSTextAlignment)alignment frame:(CGRect)frame;

- (void)widthToFit;
- (void)widthToFitWithMaxWidth:(CGFloat)maxWidth;

@end

@interface UITextField (Additions)

- (void)widthToFitWithMaxWidth:(CGFloat)maxWidth;

@end


@interface UIView (Layout)

@property (assign, nonatomic) CGFloat x;
@property (assign, nonatomic) CGFloat y;
@property (assign, nonatomic) CGFloat width;
@property (assign, nonatomic) CGFloat height;
@property (assign, nonatomic) CGPoint origin;
@property (assign, nonatomic) CGSize  size;
@property (assign, nonatomic) CGFloat centerX;
@property (assign, nonatomic) CGFloat centerY;
@property (assign, nonatomic) CGFloat maxX;
@property (assign, nonatomic) CGFloat maxY;

@end

