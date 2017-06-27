//
//  BaseViewController.m
//  VoiceLight
//
//  Created by cocoawork on 2017/6/27.
//  Copyright © 2017年 cocoawork. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupStyle];
}


- (void)setupStyle {
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithWhite:0.2 alpha:0.8]];
    
}



@end
