//
//  UIHelper.m
//  JSONKitDemo
//
//  Created by apple on 14-4-17.
//  Copyright (c) 2014年 ___A-EYE___. All rights reserved.
//

#import "UIHelper.h"

@implementation UIHelper

+ (void)animationWithDuration:(CGFloat)duration delegate:(id)delegate actions:(void (^)(void))actions completion:(SEL)completionSelector {
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:7];
    [UIView setAnimationDuration:duration];
    if (delegate != nil && completionSelector != NULL) {
        [UIView setAnimationDelegate:delegate];
        [UIView setAnimationDidStopSelector:completionSelector];
    }
    
    if (actions) {
        actions();
    }
    
    [UIView commitAnimations];
    
}

+ (void)animationWithDuration:(CGFloat)duration actions:(void (^)(void))actions {
    [UIHelper animationWithDuration:duration delegate:nil actions:actions completion:NULL];
}

@end


@implementation UIColor (Additions)

- (UIColor *)colorWithBrightness:(CGFloat)brightnessComponent {
    
    UIColor *newColor = nil;
    if ( ! newColor) {
        CGFloat hue, saturation, brightness, alpha;
        if ([self getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha]) {
            newColor = [UIColor colorWithHue:hue
                                  saturation:saturation
                                  brightness:brightness * brightnessComponent
                                       alpha:alpha];
        }
    }
    
    if ( ! newColor) {
        CGFloat red, green, blue, alpha;
        if ([self getRed:&red green:&green blue:&blue alpha:&alpha]) {
            newColor = [UIColor colorWithRed:red*brightnessComponent
                                       green:green*brightnessComponent
                                        blue:blue*brightnessComponent
                                       alpha:alpha];
        }
    }
    
    if ( ! newColor) {
        CGFloat white, alpha;
        if ([self getWhite:&white alpha:&alpha]) {
            newColor = [UIColor colorWithWhite:white * brightnessComponent alpha:alpha];
        }
    }
    
    return newColor;
}

+ (UIColor *)randomColor {
    
    CGFloat r = arc4random_uniform(255) / 255.0;
    CGFloat g = arc4random_uniform(255) / 255.0;
    CGFloat b = arc4random_uniform(255) / 255.0;
    
    return [UIColor colorWithRed:r green:g blue:b alpha:1.0];
}

+ (UIColor *)colorWithHexString:(NSString *)hexString {
    return [UIColor colorWithHexString:hexString alpha:1.0f];
}

+ (UIColor *)colorWithHexString:(NSString *)hexString alpha:(CGFloat)alpha {
    
    NSString *cString = [[hexString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    if ([cString hasPrefix:@"#"]) cString = [cString substringFromIndex:1];
    if ([cString length] != 6) return [UIColor blackColor];
    
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    unsigned int r, g, b;
    
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:alpha];
}


@end


@implementation UIImage (Additions)

+ (UIImage *)imageWithHexString:(NSString *)hexString {
    UIColor *color = [UIColor colorWithHexString:hexString];
    return [UIImage imageWithColor:color];
}

+ (UIImage *)imageWithColor:(UIColor *)color {
    
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
        
    return image;
}

@end


@implementation UILabel(Additions)

+ (UILabel *)labelWithFont:(CGFloat)fontSize textColor:(id)color textAlignment:(NSTextAlignment)alignment frame:(CGRect)frame {
    
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont systemFontOfSize:fontSize];
    if ([color isKindOfClass:[NSString class]]) {
        label.textColor = [UIColor colorWithHexString:color];
    }else {
        label.textColor = (UIColor *)color;
    }
    label.textAlignment = alignment;
    label.frame = frame;
    
    return label;
}

- (void)widthToFit {
    [self widthToFitWithMaxWidth:kScreenWidth];
}

- (void)widthToFitWithMaxWidth:(CGFloat)maxWidth {
    CGRect stringRect = [self.text boundingRectWithSize:CGSizeMake(maxWidth, kCellHeight) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : self.font} context:nil];
    
    self.width = stringRect.size.width;
}

@end

@implementation UITextField (Additions)

- (void)widthToFitWithMaxWidth:(CGFloat)maxWidth {
    
    CGRect stringRect = [self.text boundingRectWithSize:CGSizeMake(maxWidth, kCellHeight) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : self.font} context:nil];
    
    self.width = stringRect.size.width;
}

@end


@implementation UIView(Layout)

- (CGFloat)x
{
    return self.frame.origin.x;
}

- (void)setX:(CGFloat)value
{
    CGRect frame = self.frame;
    frame.origin.x = value;
    self.frame = frame;
}

- (CGFloat)y
{
    return self.frame.origin.y;
}

- (void)setY:(CGFloat)value
{
    CGRect frame = self.frame;
    frame.origin.y = value;
    self.frame = frame;
}

- (CGPoint)origin
{
    return self.frame.origin;
}

- (void)setOrigin:(CGPoint)origin
{
    CGRect frame = self.frame;
    frame.origin = origin;
    self.frame = frame;
}

- (CGFloat)centerX
{
    return self.center.x;
}

- (void)setCenterX:(CGFloat)centerX
{
    CGPoint center = self.center;
    center.x = centerX;
    self.center = center;
}

- (CGFloat)centerY
{
    return self.center.y;
}

- (void)setCenterY:(CGFloat)centerY
{
    CGPoint center = self.center;
    center.y = centerY;
    self.center = center;
}

- (CGFloat)width
{
    return self.frame.size.width;
}

- (void)setWidth:(CGFloat)width
{
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

- (CGFloat)height
{
    return self.frame.size.height;
}

- (void)setHeight:(CGFloat)height
{
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

- (CGSize)size
{
    return self.frame.size;
}

- (void)setSize:(CGSize)size
{
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}

- (void)setMaxX:(CGFloat)maxX
{
    CGRect tempFrame = self.frame;
    tempFrame.origin.x = maxX - self.width;
    self.frame = tempFrame;
}

- (CGFloat)maxX
{
    return self.x+self.width;
}

- (void)setMaxY:(CGFloat)maxY
{
    CGRect tempFrame = self.frame;
    tempFrame.origin.y = maxY - self.height;
    self.frame = tempFrame;
}

- (CGFloat)maxY
{
    return self.y+self.height;
}

@end

