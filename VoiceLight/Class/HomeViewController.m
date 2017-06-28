//
//  ViewController.m
//  VoiceLight
//
//  Created by cocoawork on 2017/6/27.
//  Copyright © 2017年 cocoawork. All rights reserved.
//

#import "HomeViewController.h"
#import "SettingViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface HomeViewController ()

@property (nonatomic, strong) AVAudioRecorder *recoder;
@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *dateLabel;


@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self layoutSubviews];
    
    //单击点亮屏幕手势
    UITapGestureRecognizer *turnOnTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(turnOnScreen)];
    [turnOnTap setNumberOfTapsRequired:1];
    [self.view addGestureRecognizer:turnOnTap];
    
    //双击关闭屏幕
    UITapGestureRecognizer *turnOffTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(turnOffScreen)];
    [turnOffTap setNumberOfTapsRequired:2];
    [self.view addGestureRecognizer:turnOffTap];
    
    //滑动调整亮度
    UIPanGestureRecognizer *swipeUp = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(swipeSetBrightness:)];
    [self.view addGestureRecognizer:swipeUp];

    
    
    /* 必须添加这句话，否则在模拟器可以，在真机上获取始终是0  */
    [[AVAudioSession sharedInstance]
     setCategory: AVAudioSessionCategoryPlayAndRecord error: nil];
    
    /* 不需要保存录音文件 */
    NSURL *url = [NSURL fileURLWithPath:@"/dev/null"];
    
    NSDictionary *settings = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithFloat: 44100.0], AVSampleRateKey,
                              [NSNumber numberWithInt: kAudioFormatAppleLossless], AVFormatIDKey,
                              [NSNumber numberWithInt: 2], AVNumberOfChannelsKey,
                              [NSNumber numberWithInt: AVAudioQualityMax], AVEncoderAudioQualityKey,
                              nil];
    
    NSError *error;
    self.recoder = [[AVAudioRecorder alloc] initWithURL:url settings:settings error:&error];
    if (_recoder)
    {
        [_recoder prepareToRecord];
        _recoder.meteringEnabled = YES;
        [_recoder record];
    } else {
        NSLog(@"%@", [error description]);
    }
    
    
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.view.backgroundColor = [UIColor colorWithHexString:[[NSUserDefaults standardUserDefaults] valueForKey:@"LightColor"]];
    
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"LightMode"] != 1) {
        [self turnTorchOn:NO];
    }
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"VoiceLight"]) {
        [_recoder stop];
    }
}


#pragma mark - layout

- (void)layoutSubviews {
    //设置按钮
    UIButton *settingBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [settingBtn setFrame:CGRectMake(SCREEN_WIDTH - 60, 20, 40, 40)];
    [settingBtn setImage:[[UIImage imageNamed:@"set.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
    [settingBtn setImageEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    [settingBtn addTarget:self action:@selector(clickedSettingButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:settingBtn];
    
    
    //熄灯按钮
    UIButton *turnOffBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [turnOffBtn setFrame:CGRectMake(SCREEN_WIDTH / 2 - 40, SCREEN_HEIGHT - 100, 80, 80)];
    [turnOffBtn setImage:[[UIImage imageNamed:@"turnOff.png"] imageWithRenderingMode:(UIImageRenderingModeAlwaysOriginal)] forState:UIControlStateNormal];
    [turnOffBtn setImageEdgeInsets:UIEdgeInsetsMake(15, 15, 15, 15)];
    [turnOffBtn setBackgroundColor:[UIColor colorWithWhite:0.1 alpha:0.7]];
    [[turnOffBtn layer] setCornerRadius:40];
    [turnOffBtn setClipsToBounds:YES];
    [[turnOffBtn layer] setBorderColor:[[UIColor groupTableViewBackgroundColor] CGColor]];
    [[turnOffBtn layer] setBorderWidth:1.f];
    [turnOffBtn addTarget:self action:@selector(turnOffScreen) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:turnOffBtn];
    
    
    self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 100)];
    [_timeLabel setFont:[UIFont boldSystemFontOfSize:50]];
    [_timeLabel setTextAlignment:NSTextAlignmentCenter];
    [self.view insertSubview:_timeLabel belowSubview:settingBtn];
    [_timeLabel setCenter:CGPointMake(self.view.center.x, self.view.center.y - 30)];
    
    
    self.dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_timeLabel.frame), SCREEN_WIDTH, 30)];
    [_dateLabel setTextAlignment:NSTextAlignmentCenter];
    [_dateLabel setFont:[UIFont systemFontOfSize:20]];
    [self.view insertSubview:_dateLabel belowSubview:settingBtn];
    
    
    [NSTimer scheduledTimerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
        NSDate *date = [NSDate date];
        NSDateFormatter *formatter1 = [[NSDateFormatter alloc] init];
        [formatter1 setDateFormat:@"HH:mm"];
        NSString *hours = [formatter1 stringFromDate:date];
        
        NSDateFormatter *formatter2 = [[NSDateFormatter alloc] init];
        [formatter2 setDateFormat:@"yyyy-MM-dd"];
        NSString *dateString = [formatter2 stringFromDate:date];
        
        [_timeLabel setText:hours];
        [_dateLabel setText:dateString];
    }];
}



#pragma mark - jump
- (void)clickedSettingButton:(UIButton *)sender {
    SettingViewController *settingVC = [SettingViewController new];
//    settingVC.transitioningDelegate = self;
    [self presentViewController:[[BaseNavigationController alloc] initWithRootViewController:settingVC]
                       animated:YES
                     completion:nil];
}



#pragma mark - function
- (void)turnOffScreen { //关灯
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"LightVoice"] == YES) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [_recoder prepareToRecord];
            if (!_timer) {
                [NSTimer scheduledTimerWithTimeInterval: 0.1 target: self selector: @selector(levelTimerCallback:) userInfo: nil repeats: YES];
            }
        });
    }
    NSLog(@"%d", [[NSUserDefaults standardUserDefaults] boolForKey:@"LightVoice"]);
    NSInteger mode = [[NSUserDefaults standardUserDefaults] integerForKey:@"LightMode"];
    if (mode == 0) {
        [UIView transitionWithView:self.view
                          duration:0.7f
                           options:(UIViewAnimationOptionCurveEaseIn)
                        animations:^{
                            //降低亮度
                            [[UIApplication sharedApplication] keyWindow].alpha = 0.1;
                        } completion:^(BOOL finished) {
                            [[UIScreen mainScreen] setBrightness:0];
                        }];
        return;
    }
    
    if (mode == 1) {
        //关闭闪光灯
        [self turnTorchOn:NO];
    }
    
    
}
    
- (void)turnOnScreen {
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
        [_recoder stop];
    }
    
    NSInteger mode = [[NSUserDefaults standardUserDefaults] integerForKey:@"LightMode"];
    if (mode == 0) {
        [UIView transitionWithView:self.view
                          duration:0.7f
                           options:(UIViewAnimationOptionCurveEaseIn)
                        animations:^{
                            [[UIApplication sharedApplication] keyWindow].alpha = 1;
                            [[UIScreen mainScreen] setBrightness:[[NSUserDefaults standardUserDefaults] floatForKey:@"LightLevel"]];
                        } completion:nil];
        return;
    }
    
    if (mode == 1) {
        //打开闪光灯
        [self turnTorchOn:YES];
    }
}
    
    
- (void) turnTorchOn: (bool) on {
    
    Class captureDeviceClass = NSClassFromString(@"AVCaptureDevice");
    if (captureDeviceClass != nil) {
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        if ([device hasTorch] && [device hasFlash]){
            [device lockForConfiguration:nil];
            if (on) {
                [device setTorchMode:AVCaptureTorchModeOn];
                [device setFlashMode:AVCaptureFlashModeOn];
            } else {
                [device setTorchMode:AVCaptureTorchModeOff];
                [device setFlashMode:AVCaptureFlashModeOff];
            }
            [device unlockForConfiguration];
        }
    }
}
    
    
//滑动调整亮度
- (void)swipeSetBrightness:(UIPanGestureRecognizer *)pan {
    CGFloat y = [pan translationInView:self.view].y;
    CGFloat brightness = [[UIScreen mainScreen] brightness];
    if (y < 0) {
        brightness += 0.02;
    }
    if (y > 0) {
        brightness -= 0.02;
    }
    [[NSUserDefaults standardUserDefaults] setFloat:brightness forKey:@"LightLevel"];
    [[UIScreen mainScreen] setBrightness:brightness];
}
    

/* 该方法确实会随环境音量变化而变化，但具体分贝值是否准确暂时没有研究 */
- (void)levelTimerCallback:(NSTimer *)timer {
    [_recoder updateMeters];
    
    float   level;                // The linear 0.0 .. 1.0 value we need.
    float   minDecibels = -80.0f; // Or use -60dB, which I measured in a silent room.
    float   decibels    = [_recoder averagePowerForChannel:0];
    
    if (decibels < minDecibels)
    {
        level = 0.0f;
    }
    else if (decibels >= 0.0f)
    {
        level = 1.0f;
    }
    else
    {
        float   root            = 2.0f;
        float   minAmp          = powf(10.0f, 0.05f * minDecibels);
        float   inverseAmpRange = 1.0f / (1.0f - minAmp);
        float   amp             = powf(10.0f, 0.05f * decibels);
        float   adjAmp          = (amp - minAmp) * inverseAmpRange;
        
        level = powf(adjAmp, 1.0f / root);
    }
    if (level * 120 >= 50.0) {
        [self turnOnScreen];
    }

}
@end
