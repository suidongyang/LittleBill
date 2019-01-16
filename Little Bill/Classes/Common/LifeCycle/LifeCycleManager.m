//
//  LifeCycleManager.m
//  Little Bill
//
//  Created by SU on 2017/12/29.
//  Copyright © 2017年 SU. All rights reserved.
//

#import "LifeCycleManager.h"

@implementation LifeCycleManager

@synthesize cycleType = _cycleType;

static LifeCycleManager *_manager;

+ (LifeCycleManager *)manager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[self alloc] init];
    });
    return _manager;
}

- (void)setCycleType:(int)cycleType {
    _cycleType = cycleType;
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"cycleType"]) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"cycleType"];
    }
    [[NSUserDefaults standardUserDefaults] setObject:@(cycleType) forKey:@"cycleType"];
    
}

- (int)cycleType {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"cycleType"]) {
            _cycleType = [[[NSUserDefaults standardUserDefaults] objectForKey:@"cycleType"] intValue];
        }
    });
    return _cycleType;
}

@end
