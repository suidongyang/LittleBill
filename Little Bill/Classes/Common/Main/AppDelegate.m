//
//  AppDelegate.m
//  Little Bill
//
//  Created by SU on 2017/9/21.
//  Copyright © 2017年 SU. All rights reserved.
//

#import "AppDelegate.h"
#import "LittleBillViewController.h"
#import "SUGuideViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kGuidePageLoadedKey]) {

        LittleBillViewController *littleBill = [[LittleBillViewController alloc] init];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:littleBill];
        nav.navigationBarHidden = YES;

        self.window.rootViewController = nav;

    }else {
        self.window.rootViewController = [[SUGuideViewController alloc] init];

        // 预算设置完成以后设置 guidePageLoaded = YES
    }

    
//    self.window.rootViewController = [[SUGuideViewController alloc] init];
    
    [self.window makeKeyAndVisible];
    
    
    return YES;
}

// 进入后台几分钟后，退出程序
- (void)applicationDidEnterBackground:(UIApplication *)application {
    
    [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        exit(0);
    }];
    
}





// 禁用第三方键盘

- (BOOL)application:(UIApplication *)application shouldAllowExtensionPointIdentifier:(UIApplicationExtensionPointIdentifier)extensionPointIdentifier {
    
    if ([self.window.rootViewController isKindOfClass:[SUGuideViewController class]]) {
        return NO;
    }
    else if ([[self currentViewController] isKindOfClass:NSClassFromString(@"SUBudgetSettingController")]) {
        return NO;
    }
    else {
        return YES;
    }
}

// 获取屏幕上正在显示的控制器
- (UIViewController*)currentViewController {

    UIViewController* vc = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    while (1) {
        
        if ([vc isKindOfClass:[UITabBarController class]]) {
            vc = ((UITabBarController*)vc).selectedViewController;
        }
        if ([vc isKindOfClass:[UINavigationController class]]) {
            vc = ((UINavigationController*)vc).visibleViewController;
        }
        if (vc.presentedViewController) {
            vc = vc.presentedViewController;
        }else{
            break;
        }
    }
    return vc;
}


#pragma mark -

- (void)switchRootController {
    
    [[NSUserDefaults standardUserDefaults] setObject:@YES forKey:kGuidePageLoadedKey];

    LittleBillViewController *littleBill = [[LittleBillViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:littleBill];
    nav.navigationBarHidden = YES;
    
    CATransition *animation = [CATransition animation];
    animation.duration = 1.0;
//    animation.timingFunction = [CAMediaTimingFunction functionWithName:@"easeOut"];
    animation.type = @"rippleEffect"; //  kCATransitionMoveIn; //
//    animation.subtype = kCATransitionFromRight;
    
    [self.window.layer addAnimation:animation forKey:@"push"];
    
    self.window.rootViewController = nav;

    
    
    
    
//    [UIView transitionWithView:self.window duration:0.5f options:UIViewAnimationOptionTransitionFlipFromRight animations:^{
//
//        self.window.rootViewController = nav;
//
//    } completion:nil];
    
}




















@end
