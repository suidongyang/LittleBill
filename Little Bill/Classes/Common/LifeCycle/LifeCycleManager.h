//
//  LifeCycleManager.h
//  Little Bill
//
//  Created by SU on 2017/12/29.
//  Copyright © 2017年 SU. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LifeCycleManager : NSObject

@property (assign, nonatomic) BOOL settingIsBusy;

@property (assign, nonatomic) int cycleType; // 0-周  1-月

+ (LifeCycleManager *)manager;

@end
