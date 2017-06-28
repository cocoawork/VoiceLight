//
//  SettingViewController.m
//  VoiceLight
//
//  Created by cocoawork on 2017/6/27.
//  Copyright © 2017年 cocoawork. All rights reserved.
//

#import "SettingViewController.h"
#import <SCLAlertView-Objective-C/SCLAlertView.h>
#import <Color-Picker-for-iOS/HRColorPickerView.h>

@interface SettingViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UISwitch *voiceSwitch;
@property (nonatomic, strong) UIView *colorBlock;

@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"SettingTitle", nil);
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:(UIBarButtonSystemItemCancel) target:self action:@selector(clickBackButton:)];
    [self layoutSubviews];
}




- (void)layoutSubviews {
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEIGHT - 64) style:(UITableViewStyleGrouped)];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];
    
    
}

#pragma mark - getter
- (UISwitch *)voiceSwitch {
    if (!_voiceSwitch) {
        self.voiceSwitch = [[UISwitch alloc] init];
        [_voiceSwitch setOn:[[NSUserDefaults standardUserDefaults] boolForKey:@"LightVoice"]];
        [_voiceSwitch addTarget:self action:@selector(voiceSwitchValueChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return _voiceSwitch;
}

- (UIView *)colorBlock {
    if (!_colorBlock) {
        self.colorBlock = [[UIView alloc] init];
    }
    return _colorBlock;
}

#pragma mark - jump 
- (void)clickBackButton:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}



#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == NULL) {
        cell = [[UITableViewCell alloc] initWithStyle:(UITableViewCellStyleValue1) reuseIdentifier:@"cell"];
    }
    [self configCell:cell forIndexPath:indexPath];
    return cell;
}

- (void)configCell:(UITableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        //模式
        cell.textLabel.text = NSLocalizedString(@"Mode", nil);
        NSInteger mode = [[NSUserDefaults standardUserDefaults] integerForKey:@"LightMode"];
        if (mode == 0) {cell.detailTextLabel.text = NSLocalizedString(@"ScreenLight", nil);}
        if (mode == 1) {cell.detailTextLabel.text = NSLocalizedString(@"FlashLight", nil);}
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        return;
    }
    if (indexPath.section == 1) {
        //颜色
        cell.textLabel.text = NSLocalizedString(@"Color", nil);
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        [self.colorBlock setFrame:CGRectMake(SCREEN_WIDTH - 60, 7, 30, 30)];
        [_colorBlock setBackgroundColor:[UIColor colorWithHexString:[[NSUserDefaults standardUserDefaults] valueForKey:@"LightColor"]]];
        [cell.contentView addSubview:_colorBlock];
        return;
    }
    if (indexPath.section == 2) {
        //声控
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.text = NSLocalizedString(@"Voice", nil);
        self.voiceSwitch.frame = CGRectMake(SCREEN_WIDTH - 70, 5, 60, 34);
        [cell.contentView addSubview:_voiceSwitch];
        return;
    }
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 15;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    //切换灯源
    if (indexPath.section == 0) {
        SCLAlertView *lightModeAlertView = [[SCLAlertView alloc] init];
        [lightModeAlertView addButton:NSLocalizedString(@"ScreenLight", nil) actionBlock:^{
            [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"LightMode"];
            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:(UITableViewRowAnimationNone)];
        }];
        [lightModeAlertView addButton:NSLocalizedString(@"FlashLight", nil) actionBlock:^{
            [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"LightMode"];
            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:(UITableViewRowAnimationNone)];
        }];
        
        [lightModeAlertView showCustom:self
                                 image:[UIImage imageNamed:@"exchange.png"]
                                 color:self.navigationController.navigationBar.barTintColor
                                 title:NSLocalizedString(@"FlashLight", nil)
                              subTitle:nil
                      closeButtonTitle:NSLocalizedString(@"Cancel", nil)
                              duration:0];
        return;
    }
    
    //切换屏幕灯颜色
    if (indexPath.section == 1) {
        if ([[NSUserDefaults standardUserDefaults] integerForKey:@"LightMode"] == 1){
            SCLAlertView *errorAlertView = [[SCLAlertView alloc] init];
            
            [errorAlertView showError:self
                                title:nil
                             subTitle:NSLocalizedString(@"SetLightSourceDescription", nil)
                     closeButtonTitle:NSLocalizedString(@"Cancel", nil)
                             duration:0];
     
        }else {
            //更换颜色
            HRColorPickerView *colorPickerView = [[HRColorPickerView alloc] initWithFrame:CGRectMake(0, 0, 215, 300)];
            [colorPickerView.colorInfoView setFrame:CGRectZero];
            colorPickerView.color = [UIColor orangeColor];
            [colorPickerView addTarget:self action:@selector(colorPickerViewValueChanged:) forControlEvents:(UIControlEventValueChanged)];
            SCLAlertView *colorSelectAlertView = [[SCLAlertView alloc] init];
            [colorSelectAlertView addCustomView:colorPickerView];
            [colorSelectAlertView showCustom:self
                                     image:[UIImage imageNamed:@"color.png"]
                                     color:self.navigationController.navigationBar.barTintColor
                                     title:nil
                                  subTitle:nil
                          closeButtonTitle:NSLocalizedString(@"Cancel", nil)
                                  duration:0];
        }
        return;
    }
    
}


- (void)colorPickerViewValueChanged:(HRColorPickerView *)pickerView {
    CGFloat r, g, b, a;
    UIColor *color = pickerView.color;
    [color getRed:&r green:&g blue:&b alpha:&a];
    int rgb = (int) (r * 255.0f)<<16 | (int) (g * 255.0f)<<8 | (int) (b * 255.0f)<<0;
    NSString *hexColorString = [NSString stringWithFormat:@"#%06x", rgb];
    [[NSUserDefaults standardUserDefaults] setValue:hexColorString forKey:@"LightColor"];
    [_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:1]] withRowAnimation:(UITableViewRowAnimationNone)];
}

- (void)voiceSwitchValueChanged:(UISwitch *)switcher {
    [[NSUserDefaults standardUserDefaults] setBool:switcher.isOn forKey:@"LightVoice"];
}
@end
