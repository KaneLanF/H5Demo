//
//  ViewController.m
//  H5Demo
//
//  Created by kane on 2018/8/6.
//  Copyright © 2018年 JQX. All rights reserved.
//

#import "ViewController.h"
#import "H5ViewController.h"
#import "UIView+Toast.h"
#import "SGQRCode.h"
#import "WBQRCodeVC.h"

@interface ViewController ()<UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) NSMutableArray *switchArr;
@property (nonatomic, assign) BOOL isHttps;
@property (nonatomic, assign) NSInteger ipNum;
@property (nonatomic, copy) NSString *lastStr;
@property (nonatomic, strong) NSMutableArray *hisArr;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.switchArr = [NSMutableArray array];
    [self.switchArr addObject:self.insideSwitch];
    [self.switchArr addObject:self.externalSwitch];
    [self.switchArr addObject:self.customSwitch];
    
    NSUserDefaults * usr = [NSUserDefaults standardUserDefaults];
    self.httpBtn.selected = [usr boolForKey:@"isHttps"]?NO:YES;
    self.httpsBtn.selected = [usr boolForKey:@"isHttps"]?YES:NO;
    self.isHttps = [usr boolForKey:@"isHttps"];
    if ([usr objectForKey:@"lastStr"]) {
        self.lastStr = [usr objectForKey:@"lastStr"];
        self.urlTF.text = [usr objectForKey:@"lastStr"];
    } else {
        self.urlTF.text = [usr boolForKey:@"isHttps"]?@"https://":@"http://";
    }
    
    if ([usr integerForKey:@"ipNum"] == 0) {
        [self.insideSwitch setOn:YES];
        [self.externalSwitch setOn:NO];
        [self.customSwitch setOn:NO];
    } else if ([usr integerForKey:@"ipNum"] == 1) {
        [self.insideSwitch setOn:NO];
        [self.externalSwitch setOn:YES];
        [self.customSwitch setOn:NO];
    } else if ([usr integerForKey:@"ipNum"] == 2) {
        [self.insideSwitch setOn:NO];
        [self.externalSwitch setOn:NO];
        [self.customSwitch setOn:YES];
    }
    
    if ([usr objectForKey:@"inside"]) {
        self.insideTF.text = [usr objectForKey:@"inside"];
    }
    if ([usr objectForKey:@"external"]) {
        self.externalTF.text = [usr objectForKey:@"external"];
    }
    if ([usr objectForKey:@"custom"]) {
        self.customTF.text = [usr objectForKey:@"custom"];
    }
    
    [self.logSwitch setOn:[usr boolForKey:@"ShowLog"]];
    
    if ([usr objectForKey:@"historyUrl"]) {
        self.hisArr = [usr objectForKey:@"historyUrl"];
    }
}


- (void)viewWillAppear:(BOOL)animated {
    NSUserDefaults * usr = [NSUserDefaults standardUserDefaults];
    if ([usr objectForKey:@"lastStr"]) {
        self.urlTF.text = [usr objectForKey:@"lastStr"];
    }
    if ([usr objectForKey:@"historyUrl"]) {
        self.hisArr = [usr objectForKey:@"historyUrl"];
        [self.historyTable reloadData];
    }
    
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    if (textField == self.urlTF) {
        
    } else {
        if (self.ipNum == 0) {
            self.urlTF.text = [NSString stringWithFormat:@"%@%@",self.isHttps?@"https://":@"http://",self.insideTF.text];
        } else if (self.ipNum == 1) {
            self.urlTF.text = [NSString stringWithFormat:@"%@%@",self.isHttps?@"https://":@"http://",self.externalTF.text];
        } else if (self.ipNum == 2) {
            self.urlTF.text = [NSString stringWithFormat:@"%@%@",self.isHttps?@"https://":@"http://",self.customTF.text];
        }
    }
    
    return YES;
}



- (IBAction)switch1Action:(id)sender {
    //内网域名
    UISwitch *btn = (UISwitch*)sender;
    for (UISwitch *sw in self.switchArr) {
        if (sw != btn) {
            [sw setOn:false];
        }
    }
    
    self.urlTF.text = [NSString stringWithFormat:@"%@%@",self.isHttps?@"https://":@"http://",self.insideTF.text];
}

- (IBAction)switch2Action:(id)sender {
    //外网域名
    UISwitch *btn = (UISwitch*)sender;
    for (UISwitch *sw in self.switchArr) {
        if (sw != btn) {
            [sw setOn:false];
        }
    }
    
    self.urlTF.text = [NSString stringWithFormat:@"%@%@",self.isHttps?@"https://":@"http://",self.externalTF.text];
}

- (IBAction)switch3Action:(id)sender {
    //设置自定义域名
    UISwitch *btn = (UISwitch*)sender;
    for (UISwitch *sw in self.switchArr) {
        if (sw != btn) {
            [sw setOn:false];
        }
    }
    
    self.urlTF.text = [NSString stringWithFormat:@"%@%@",self.isHttps?@"https://":@"http://",self.customTF.text];
}

- (IBAction)switch4Action:(id)sender {
    //是否显示调试日志
    UISwitch *btn = (UISwitch*)sender;
    NSUserDefaults * usr = [NSUserDefaults standardUserDefaults];
    [usr setBool:btn.isOn forKey:@"ShowLog"];
    [self.view makeToast:btn.isOn?@"显示调试日志":@"关闭调试日志"];
}

- (IBAction)httpAction:(id)sender {
    //http访问
    UIButton *btn = (UIButton*)sender;
    btn.selected = !btn.selected;
    if ([self.urlTF.text hasPrefix:@"https://"]) {
        self.urlTF.text = [self.urlTF.text stringByReplacingOccurrencesOfString:@"https://" withString:@"http://"];
    }
    if (btn.selected) {
        self.httpsBtn.selected = NO;
    }
    
    NSUserDefaults * usr = [NSUserDefaults standardUserDefaults];
    [usr setBool:self.httpsBtn.selected forKey:@"isHttps"];
}

- (IBAction)httpsAction:(id)sender {
    //https访问
    UIButton *btn = (UIButton*)sender;
    btn.selected = !btn.selected;
    if ([self.urlTF.text hasPrefix:@"http://"]) {
        self.urlTF.text = [self.urlTF.text stringByReplacingOccurrencesOfString:@"http://" withString:@"https://"];
    }
    
    if (btn.selected) {
        self.httpBtn.selected = NO;
    }
    
    NSUserDefaults * usr = [NSUserDefaults standardUserDefaults];
    [usr setBool:self.httpsBtn.selected forKey:@"isHttps"];
}

- (IBAction)openAction:(id)sender {
    if (!self.urlTF.text) {
        [self.view makeToast:@"访问网址为空"];
    }
    
    NSUserDefaults * usr = [NSUserDefaults standardUserDefaults];
    if (self.insideTF.text) {
        [usr setObject:self.insideTF.text forKey:@"inside"];
    }
    if (self.externalTF.text) {
        [usr setObject:self.externalTF.text forKey:@"external"];
    }
    if (self.customTF.text) {
        [usr setObject:self.customTF.text forKey:@"custom"];
    }
    
    [usr setObject:self.urlTF.text forKey:@"lastStr"];
    if (![self.hisArr containsObject:self.urlTF.text]) {
        NSMutableArray *arr = [NSMutableArray arrayWithArray:self.hisArr];
        [arr addObject:self.urlTF.text];
        [usr setObject:arr forKey:@"historyUrl"];
    }
    
    H5ViewController *h5Vc = [[H5ViewController alloc] init];
    h5Vc.urlStr = self.urlTF.text;
    h5Vc.isShowLog = [usr boolForKey:@"ShowLog"];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:h5Vc];
    [self presentViewController:nav animated:YES completion:^{
        
    }];
}

//Scan二维码
- (IBAction)openScan:(id)sender {
    
    WBQRCodeVC *WBVC = [[WBQRCodeVC alloc] init];
    [self QRCodeScanVC:WBVC];
    /*
    __weak typeof(self) weakSelf = self;
    /// 扫描二维码
    SGQRCodeObtain *obtain = [SGQRCodeObtain QRCodeObtain];
    SGQRCodeObtainConfigure *configure = [SGQRCodeObtainConfigure QRCodeObtainConfigure];
    [obtain establishQRCodeObtainScanWithController:self configure:configure];
    // 二维码扫描回调方法
    [obtain setBlockWithQRCodeObtainScanResult:^(SGQRCodeObtain *obtain, NSString *result) {
        if (result) {
            [weakSelf openScanResultWith:result];
        } else {
            [weakSelf.view makeToast:@"扫描结果为空"];
        }
    }];
    // 二维码开启方法: 需手动开启扫描
//    [obtain startRunningWithBefore:^{
//        // 在此可添加 HUD
//    } completion:^{
//        // 在此可移除 HUD
//    }];
    // 根据外界光线值判断是否自动打开手电筒
    [obtain setBlockWithQRCodeObtainScanBrightness:^(SGQRCodeObtain *obtain, CGFloat brightness) {
        
    }];
    
    [obtain startRunning];
    
    
    /// 从相册中读取二维码
    [obtain establishAuthorizationQRCodeObtainAlbumWithController:self];
    // 从相册中读取图片上的二维码回调方法
    [obtain setBlockWithQRCodeObtainAlbumResult:^(SGQRCodeObtain *obtain, NSString *result) {
        if (result) {
            [weakSelf openScanResultWith:result];
        } else {
            [weakSelf.view makeToast:@"扫描结果为空"];
        }
        
    }];
     */
}

- (void)QRCodeScanVC:(UIViewController *)scanVC {
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (device) {
        AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        switch (status) {
            case AVAuthorizationStatusNotDetermined: {
                [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                    if (granted) {
                        dispatch_sync(dispatch_get_main_queue(), ^{
                            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:scanVC];
                            [self presentViewController:nav animated:YES completion:^{
                                
                            }];
//                            [self.navigationController pushViewController:scanVC animated:YES];
                        });
                        NSLog(@"用户第一次同意了访问相机权限 - - %@", [NSThread currentThread]);
                    } else {
                        NSLog(@"用户第一次拒绝了访问相机权限 - - %@", [NSThread currentThread]);
                    }
                }];
                break;
            }
            case AVAuthorizationStatusAuthorized: {
                
//                [self.navigationController pushViewController:scanVC animated:YES];
                UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:scanVC];
                [self presentViewController:nav animated:YES completion:^{
                    
                }];
                break;
            }
            case AVAuthorizationStatusDenied: {
                UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"请去-> [设置 - 隐私 - 相机 - SGQRCodeExample] 打开访问开关" preferredStyle:(UIAlertControllerStyleAlert)];
                UIAlertAction *alertA = [UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
                    
                }];
                
                [alertC addAction:alertA];
                [self presentViewController:alertC animated:YES completion:nil];
                break;
            }
            case AVAuthorizationStatusRestricted: {
                NSLog(@"因为系统原因, 无法访问相册");
                break;
            }
                
            default:
                break;
        }
        return;
    }
    
    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"未检测到您的摄像头" preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *alertA = [UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [alertC addAction:alertA];
    [self presentViewController:alertC animated:YES completion:nil];
}

//- (void)openScanResultWith:(NSString *)str {
//    H5ViewController *h5Vc = [[H5ViewController alloc] init];
//    h5Vc.urlStr = str;
//    NSUserDefaults * usr = [NSUserDefaults standardUserDefaults];
//    h5Vc.isShowLog = [usr boolForKey:@"ShowLog"];
//    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:h5Vc];
//    [self presentViewController:nav animated:YES completion:^{
//
//    }];
//}


#pragma mark -
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.hisArr.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"mycell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"mycell"];
    }
    cell.textLabel.text = [self.hisArr objectAtIndex:self.hisArr.count-1 -indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *urlStr = [self.hisArr objectAtIndex:self.hisArr.count-1 -indexPath.row];
    self.urlTF.text = urlStr;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSMutableArray*)hisArr {
    if (!_hisArr) {
        _hisArr = [NSMutableArray array];
    }
    return _hisArr;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
