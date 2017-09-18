//
//  AppDelegate.m
//  VoiceLight
//
//  Created by cocoawork on 2017/6/27.
//  Copyright © 2017年 cocoawork. All rights reserved.
//

#import "AppDelegate.h"
#import <Appirater/Appirater.h>
#import <Harpy/Harpy.h>

@interface AppDelegate ()

@property (nonatomic, assign) CGFloat brightness;


@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"isFirstLaunch"]) {
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"LightMode"];
        [[NSUserDefaults standardUserDefaults] setValue:@"#FFE4C4" forKey:@"LightColor"];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"LightVoice"];
        [[NSUserDefaults standardUserDefaults] setFloat:[[UIScreen mainScreen] brightness] forKey:@"LightLevel"];
    }
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isFirstLaunch"];
    [application setIdleTimerDisabled:YES];
    
    //记录当前亮度值,在app退出后台后还原亮度值
    _brightness = [[UIScreen mainScreen] brightness];
    
    
    //引导用户评论
    [Appirater setAppId:@"1284275579"];
    [Appirater setDaysUntilPrompt:2];
    [Appirater setUsesUntilPrompt:3];
    [Appirater setSignificantEventsUntilPrompt:-1];
    [Appirater setTimeBeforeReminding:2];
    [Appirater setDebug:NO];
    [Appirater appLaunched:YES];
    
    
    
    //检查更新
    [[Harpy sharedInstance] setPresentingViewController:_window.rootViewController];
    [[Harpy sharedInstance] checkVersion];
    return YES;
}





- (void)applicationWillResignActive:(UIApplication *)application {
    [[Harpy sharedInstance] checkVersionDaily];
//    [[NSUserDefaults standardUserDefaults] setFloat:[[UIScreen mainScreen] brightness] forKey:@"LightLevel"];
    [[UIScreen mainScreen] setBrightness:_brightness];
}




- (void)applicationDidEnterBackground:(UIApplication *)application {
//    [[NSUserDefaults standardUserDefaults] setFloat:[[UIScreen mainScreen] brightness] forKey:@"LightLevel"];
//    [[UIScreen mainScreen] setBrightness:_brightness];
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    [[Harpy sharedInstance] checkVersion];
//    [[UIScreen mainScreen] setBrightness:[[NSUserDefaults standardUserDefaults] floatForKey:@"LightLevel"]];
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    [[UIScreen mainScreen] setBrightness:[[NSUserDefaults standardUserDefaults] floatForKey:@"LightLevel"]];
}


- (void)applicationWillTerminate:(UIApplication *)application {
//    [[NSUserDefaults standardUserDefaults] setFloat:[[UIScreen mainScreen] brightness] forKey:@"LightLevel"];
//    [[UIScreen mainScreen] setBrightness:_brightness];
    
}


@end
