//
//  TrafficLight.h
//  Little Bill
//
//  Created by SU on 2017/12/25.
//  Copyright © 2017年 SU. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, LightState) {
    LightStateRed = 0,
    LightStateYellow = 1,
    LightStateGreen = 2,
};

@interface TrafficLight : UIView

@property (assign, nonatomic) LightState state;

@end
